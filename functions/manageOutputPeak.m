function [outputSamples, details] = manageOutputPeak(inputSamples, config)
%MANAGEOUTPUTPEAK Apply optional peak normalization to avoid clipping.
%   "normalize" scales the entire signal only when its peak exceeds the
%   configured target. It preserves the relative gain between EQ bands.

if ~isstruct(config) || ~isfield(config, "peakManagement") || ...
        ~isfield(config, "targetPeak")
    error("MultiBandEqualizer:InvalidOutputConfig", ...
        "Output configuration must define peakManagement and targetPeak.");
end
if ~isscalar(config.targetPeak) || config.targetPeak <= 0 || config.targetPeak > 1
    error("MultiBandEqualizer:InvalidTargetPeak", ...
        "targetPeak must be greater than 0 and no greater than 1.");
end

mode = string(config.peakManagement);
if ~ismember(mode, ["none", "normalize"])
    error("MultiBandEqualizer:InvalidPeakManagement", ...
        "peakManagement must be either none or normalize.");
end

inputPeak = max(abs(inputSamples), [], "all");
scaleFactor = 1;
if mode == "normalize" && inputPeak > config.targetPeak
    scaleFactor = config.targetPeak / inputPeak;
end

outputSamples = scaleFactor * inputSamples;
details.mode = mode;
details.inputPeak = inputPeak;
details.outputPeak = max(abs(outputSamples), [], "all");
details.scaleFactor = scaleFactor;
details.applied = scaleFactor < 1;
end
