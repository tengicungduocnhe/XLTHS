function filterBank = designEQFilters(sampleRate, config)
%DESIGNEQFILTERS Design a 3-band Butterworth IIR filter bank.
%   The design explicitly follows the required analog-prototype workflow:
%   Butterworth prototype -> analog frequency transformation -> bilinear
%   transform. The returned filters are not applied to audio in this step.

requireSignalProcessingToolbox()
validateFilterSpecification(sampleRate, config)

bassCutoff = config.equalizer.bassUpperHz;
midEdges = config.equalizer.midRangeHz;
trebleCutoff = config.equalizer.trebleLowerHz;

filterBank.bass = designLowpass(bassCutoff, ...
    config.filter.lowHighPrototypeOrder, sampleRate);
filterBank.mid = designBandpass(midEdges, ...
    config.filter.bandpassPrototypeOrder, sampleRate);
filterBank.treble = designHighpass(trebleCutoff, ...
    config.filter.lowHighPrototypeOrder, sampleRate);
end

function filter = designLowpass(cutoffHz, prototypeOrder, sampleRate)
[zerosAnalog, polesAnalog, gainAnalog] = buttap(prototypeOrder);
% State-space transformations avoid poorly conditioned analog polynomials.
[stateA, stateB, stateC, stateD] = zp2ss(zerosAnalog, polesAnalog, gainAnalog);
cutoffRadPerSecond = prewarpFrequency(cutoffHz, sampleRate);
[stateA, stateB, stateC, stateD] = lp2lp(stateA, stateB, stateC, stateD, ...
    cutoffRadPerSecond);
filter = convertToDigitalFilter(stateA, stateB, stateC, stateD, ...
    sampleRate, "Bass", "Low-pass", [0, cutoffHz]);
end

function filter = designBandpass(edgeHz, prototypeOrder, sampleRate)
[zerosAnalog, polesAnalog, gainAnalog] = buttap(prototypeOrder);
[stateA, stateB, stateC, stateD] = zp2ss(zerosAnalog, polesAnalog, gainAnalog);
lowerEdgeRadPerSecond = prewarpFrequency(edgeHz(1), sampleRate);
upperEdgeRadPerSecond = prewarpFrequency(edgeHz(2), sampleRate);
centerRadPerSecond = sqrt(lowerEdgeRadPerSecond * upperEdgeRadPerSecond);
bandwidthRadPerSecond = upperEdgeRadPerSecond - lowerEdgeRadPerSecond;
[stateA, stateB, stateC, stateD] = lp2bp(stateA, stateB, stateC, stateD, ...
    centerRadPerSecond, bandwidthRadPerSecond);
filter = convertToDigitalFilter(stateA, stateB, stateC, stateD, ...
    sampleRate, "Mid", "Band-pass", edgeHz);
end

function filter = designHighpass(cutoffHz, prototypeOrder, sampleRate)
[zerosAnalog, polesAnalog, gainAnalog] = buttap(prototypeOrder);
[stateA, stateB, stateC, stateD] = zp2ss(zerosAnalog, polesAnalog, gainAnalog);
cutoffRadPerSecond = prewarpFrequency(cutoffHz, sampleRate);
[stateA, stateB, stateC, stateD] = lp2hp(stateA, stateB, stateC, stateD, ...
    cutoffRadPerSecond);
filter = convertToDigitalFilter(stateA, stateB, stateC, stateD, ...
    sampleRate, "Treble", "High-pass", [cutoffHz, sampleRate / 2]);
end

function filter = convertToDigitalFilter(stateA, stateB, stateC, stateD, ...
        sampleRate, name, responseType, passbandHz)
% Bilinear transformation maps the stable analog poles into the unit disk.
[stateA, stateB, stateC, stateD] = bilinear(stateA, stateB, stateC, stateD, ...
    sampleRate);
[numerator, denominator] = ss2tf(stateA, stateB, stateC, stateD);
numerator = numerator(:).';
denominator = denominator(:).';

filter.name = name;
filter.responseType = responseType;
filter.passbandHz = passbandHz;
filter.numerator = real(numerator);
filter.denominator = real(denominator);
filter.zeros = roots(numerator);
filter.poles = roots(denominator);
filter.order = numel(filter.poles);
end

function omega = prewarpFrequency(frequencyHz, sampleRate)
% Prewarping ensures the requested digital cutoff is preserved by bilinear.
omega = 2 * sampleRate * tan(pi * frequencyHz / sampleRate);
end

function validateFilterSpecification(sampleRate, config)
if ~isscalar(sampleRate) || sampleRate <= 0
    error("MultiBandEqualizer:InvalidSampleRate", ...
        "Sample rate must be a positive scalar.");
end

nyquistFrequency = sampleRate / 2;
bassCutoff = config.equalizer.bassUpperHz;
midEdges = config.equalizer.midRangeHz;
trebleCutoff = config.equalizer.trebleLowerHz;
if bassCutoff <= 0 || midEdges(1) <= 0 || midEdges(2) >= nyquistFrequency || ...
        trebleCutoff >= nyquistFrequency || midEdges(1) >= midEdges(2)
    error("MultiBandEqualizer:InvalidBandEdges", ...
        "Band edges must be positive, ordered, and below the Nyquist frequency.");
end
if bassCutoff ~= midEdges(1) || trebleCutoff ~= midEdges(2)
    error("MultiBandEqualizer:NonContiguousBands", ...
        "Bass/Mid and Mid/Treble edges must meet at the same frequencies.");
end
end

function requireSignalProcessingToolbox()
requiredFunctions = ["buttap", "zp2ss", "lp2lp", "lp2bp", "lp2hp", ...
    "bilinear", "ss2tf"];
for functionName = requiredFunctions
    if exist(functionName, "file") == 0
        error("MultiBandEqualizer:MissingToolbox", ...
            "Signal Processing Toolbox is required (%s is unavailable).", functionName);
    end
end
end
