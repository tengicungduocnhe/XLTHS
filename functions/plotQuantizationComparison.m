function plotQuantizationComparison(floatingFilterBank, fixedPointFilterBank, ...
        sampleRate, wordLength)
%PLOTQUANTIZATIONCOMPARISON Compare floating-point and quantized responses.

bandFields = ["bass", "mid", "treble"];
frequencyPoints = 4096;

figure("Name", "Step 4 - Fixed-Point Quantization", "Color", "w");
tiledlayout(3, 2, "TileSpacing", "compact", "Padding", "compact");

for bandIndex = 1:numel(bandFields)
    fieldName = bandFields(bandIndex);
    floatingFilter = floatingFilterBank.(fieldName);
    fixedPointFilter = fixedPointFilterBank.(fieldName);
    [floatingSOS, overallGain] = tf2sos(floatingFilter.numerator, ...
        floatingFilter.denominator);
    floatingSOS(1, 1:3) = overallGain * floatingSOS(1, 1:3);
    [floatingResponse, frequencyHz] = computeSOSResponse(floatingSOS, ...
        frequencyPoints, sampleRate);
    fixedPointResponse = computeSOSResponse(fixedPointFilter.sos, ...
        frequencyPoints, sampleRate);
    floatingMagnitudeDB = 20 * log10(max(abs(floatingResponse), realmin("double")));
    fixedPointMagnitudeDB = 20 * log10(max(abs(fixedPointResponse), realmin("double")));
    validBins = frequencyHz >= 20;

    nexttile
    semilogx(frequencyHz(validBins), floatingMagnitudeDB(validBins), "k", ...
        "LineWidth", 1)
    hold on
    semilogx(frequencyHz(validBins), fixedPointMagnitudeDB(validBins), "r--", ...
        "LineWidth", 1)
    hold off
    grid on
    xlim([20, sampleRate / 2])
    ylim([-100, 5])
    xlabel("Frequency (Hz)")
    ylabel("Magnitude (dB)")
    title(floatingFilter.name + " response")
    legend("Floating point", sprintf("%d-bit fixed point", wordLength), ...
        "Location", "southwest")

    nexttile
    semilogx(frequencyHz(validBins), ...
        fixedPointMagnitudeDB(validBins) - floatingMagnitudeDB(validBins), ...
        "b", "LineWidth", 1)
    grid on
    xlim([20, sampleRate / 2])
    xlabel("Frequency (Hz)")
    ylabel("Magnitude error (dB)")
    title(floatingFilter.name + " quantization error")
end

function [response, frequencyHz] = computeSOSResponse(sos, frequencyPoints, sampleRate)
response = ones(frequencyPoints, 1);
for sectionIndex = 1:size(sos, 1)
    [sectionResponse, frequencyHz] = freqz(sos(sectionIndex, 1:3), ...
        sos(sectionIndex, 4:6), frequencyPoints, sampleRate);
    response = response .* sectionResponse;
end
end
end
