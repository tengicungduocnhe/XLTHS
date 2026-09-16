function [fixedPointFilterBank, quantization] = quantizeCoefficients(filterBank, wordLength)
%QUANTIZECOEFFICIENTS Quantize IIR filters as scaled 16-bit SOS biquads.
%   Second-order sections prevent the low-frequency Bass poles from being
%   distorted by a single high-order direct-form denominator quantization.

if ~isscalar(wordLength) || wordLength < 2 || wordLength > 16 || ...
        wordLength ~= floor(wordLength)
    error("MultiBandEqualizer:InvalidWordLength", ...
        "wordLength must be an integer from 2 through 16.");
end

bandFields = ["bass", "mid", "treble"];
for bandIndex = 1:numel(bandFields)
    fieldName = bandFields(bandIndex);
    floatingFilter = filterBank.(fieldName);
    [sos, overallGain] = tf2sos(floatingFilter.numerator, ...
        floatingFilter.denominator);
    sos(1, 1:3) = overallGain * sos(1, 1:3);

    [quantizedSOS, integerNumerator, integerDenominator, numeratorScales, ...
        denominatorScales, maximumCoefficientError] = quantizeSOS(sos, wordLength);

    fixedPointFilter = floatingFilter;
    fixedPointFilter.sos = quantizedSOS;
    fixedPointFilter.integerNumerator = integerNumerator;
    fixedPointFilter.integerDenominator = integerDenominator;
    fixedPointFilter.numeratorScales = numeratorScales;
    fixedPointFilter.denominatorScales = denominatorScales;
    fixedPointFilter.poles = sosPoles(quantizedSOS);
    fixedPointFilterBank.(fieldName) = fixedPointFilter;

    bandResult.name = floatingFilter.name;
    bandResult.sectionCount = size(sos, 1);
    bandResult.numeratorScales = numeratorScales;
    bandResult.denominatorScales = denominatorScales;
    bandResult.maximumCoefficientError = maximumCoefficientError;
    bandResult.maximumPoleMagnitude = max(abs(fixedPointFilter.poles));
    quantization.bands(bandIndex) = bandResult;
end

quantization.wordLength = wordLength;
quantization.implementation = "Second-order sections with per-section binary scaling";
quantization.isBIBOStable = all([quantization.bands.maximumPoleMagnitude] < 1);
end

function [quantizedSOS, integerNumerator, integerDenominator, numeratorScales, ...
        denominatorScales, maximumCoefficientError] = quantizeSOS(sos, wordLength)
sectionCount = size(sos, 1);
quantizedSOS = zeros(size(sos));
integerNumerator = zeros(sectionCount, 3, "int16");
integerDenominator = zeros(sectionCount, 3, "int16");
numeratorScales = zeros(sectionCount, 1);
denominatorScales = zeros(sectionCount, 1);
maximumCoefficientError = 0;

for sectionIndex = 1:sectionCount
    [integerNumerator(sectionIndex, :), quantizedNumerator, numeratorScales(sectionIndex)] = ...
        quantizeVector(sos(sectionIndex, 1:3), wordLength);
    [integerDenominator(sectionIndex, :), quantizedDenominator, denominatorScales(sectionIndex)] = ...
        quantizeVector(sos(sectionIndex, 4:6), wordLength);
    quantizedSOS(sectionIndex, :) = [quantizedNumerator, quantizedDenominator];
    maximumCoefficientError = max(maximumCoefficientError, max(abs( ...
        quantizedSOS(sectionIndex, :) - sos(sectionIndex, :))));
end
end

function [integerCoefficients, dequantizedCoefficients, scaleFactor] = ...
        quantizeVector(coefficients, wordLength)
maximumInteger = 2 ^ (wordLength - 1) - 1;
largestMagnitude = max(abs(coefficients));
if largestMagnitude == 0
    scaleFactor = 1;
else
    scaleFactor = 2 ^ floor(log2(maximumInteger / largestMagnitude));
end

roundedCoefficients = round(coefficients * scaleFactor);
roundedCoefficients = min(max(roundedCoefficients, -maximumInteger), maximumInteger);
integerCoefficients = int16(roundedCoefficients);
dequantizedCoefficients = double(integerCoefficients) / scaleFactor;
end

function poles = sosPoles(sos)
poles = [];
for sectionIndex = 1:size(sos, 1)
    poles = [poles; roots(sos(sectionIndex, 4:6))]; %#ok<AGROW>
end
end
