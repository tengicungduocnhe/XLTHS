%% MULTIBANDEQUALIZER Step 1: inspect and analyze the source audio.
% This script intentionally performs no equalization or filter design yet.

clear
close all
clc

projectRoot = fileparts(mfilename("fullpath"));
addpath(fullfile(projectRoot, "functions"));

config = getProjectConfig();
audioFile = fullfile(projectRoot, "audio", "Bass_Switch_30s.wav");

[audioSamples, sampleRate, fileInfo] = loadAudioFile(audioFile);
analysis = analyzeAudio(audioSamples, sampleRate);

printAudioSummary(fileInfo, analysis, config);
plotAudioAnalysis(audioSamples, sampleRate, analysis, fileInfo.Filename);

% Step 2: create the filter bank only. No audio is filtered or played yet.
filterBank = designEQFilters(sampleRate, config);
printFilterBankSummary(filterBank);
plotFilterBankResponse(filterBank, sampleRate);

% Step 4: compare floating-point coefficients with 16-bit fixed-point ones.
[fixedPointFilterBank, quantization] = quantizeCoefficients(filterBank, ...
    config.quantization.wordLength);
printQuantizationSummary(quantization);
plotQuantizationComparison(filterBank, fixedPointFilterBank, sampleRate, ...
    config.quantization.wordLength);

% Step 3: apply the parallel filter bank using the configured gain values.
[equalizedSamples, equalizerDetails] = applyEqualizer(audioSamples, filterBank, ...
    config.equalizer.defaultGainDB, config.output);
outputAnalysis = analyzeAudio(equalizedSamples, sampleRate);
stability = analyzeStability(filterBank);
printEqualizerSummary(equalizerDetails, outputAnalysis, stability);
plotEqualizerComparison(audioSamples, equalizedSamples, sampleRate, ...
    analysis, outputAnalysis, config.equalizer.defaultGainDB);
