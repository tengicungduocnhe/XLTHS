function [equalizedSamples, details] = applyEqualizer(audioSamples, filterBank, gainDB, outputConfig)
%APPLYEQUALIZER Filter audio through three IIR branches and sum their output.
%   gainDB is a three-element vector ordered as [Bass, Mid, Treble]. The
%   implementation is causal, matching the future real-time application.
%   outputConfig controls optional peak normalization after the branch sum.

if ~isnumeric(audioSamples) || isempty(audioSamples) || ndims(audioSamples) ~= 2
    error("MultiBandEqualizer:InvalidAudio", ...
        "Audio samples must be a nonempty samples-by-channels numeric matrix.");
end
if ~isnumeric(gainDB) || numel(gainDB) ~= 3 || any(~isfinite(gainDB))
    error("MultiBandEqualizer:InvalidGain", ...
        "gainDB must contain three finite values: [Bass, Mid, Treble].");
end

bandFields = ["bass", "mid", "treble"];
bandNames = ["Bass", "Mid", "Treble"];
gainDB = reshape(gainDB, 1, []);
gainLinear = 10 .^ (gainDB / 20);
equalizedSamples = zeros(size(audioSamples), "like", audioSamples);
branchPeak = zeros(1, numel(bandFields));

for bandIndex = 1:numel(bandFields)
    currentFilter = filterBank.(bandFields(bandIndex));
    branchSamples = filter(currentFilter.numerator, currentFilter.denominator, ...
        audioSamples);
    branchSamples = gainLinear(bandIndex) * branchSamples;
    equalizedSamples = equalizedSamples + branchSamples;
    branchPeak(bandIndex) = max(abs(branchSamples), [], "all");
end

[equalizedSamples, peakManagement] = manageOutputPeak(equalizedSamples, outputConfig);

details.bandNames = bandNames;
details.gainDB = gainDB;
details.gainLinear = gainLinear;
details.branchPeak = branchPeak;
details.outputPeakBeforeManagement = peakManagement.inputPeak;
details.outputPeak = peakManagement.outputPeak;
details.outputScale = peakManagement.scaleFactor;
details.peakManagementApplied = peakManagement.applied;
details.peakManagementMode = peakManagement.mode;
end
