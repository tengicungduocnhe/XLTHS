function config = getProjectConfig()
%GETPROJECTCONFIG Return centrally defined project parameters.
%   Update the temporary band edges or gain limits here when the project
%   specification is finalized. Step 1 does not apply these values.

config.equalizer.bassUpperHz = 250;
config.equalizer.midRangeHz = [250, 4000];
config.equalizer.trebleLowerHz = 4000;
config.equalizer.gainRangeDB = [-12, 12];
config.equalizer.defaultGainDB = [6, 0, -6];

% Filter orders are deliberately centralized with the temporary band edges.
% The band-pass prototype order doubles after the LP-to-BP transformation.
config.filter.family = "Butterworth";
config.filter.lowHighPrototypeOrder = 4;
config.filter.bandpassPrototypeOrder = 2;

% Preserve EQ tonal balance while ensuring samples are safe for 16-bit WAV
% export and audio playback. Set peakManagement to "none" to disable it.
config.output.peakManagement = "normalize";
config.output.targetPeak = 0.98;

config.quantization.wordLength = 16;
end
