function plotAudioAnalysis(audioSamples, sampleRate, analysis, fileName)
%PLOTAUDIOANALYSIS Plot the full waveform and one-sided FFT magnitude.

timeSeconds = (0:size(audioSamples, 1) - 1)' / sampleRate;

figure("Name", "Step 1 - Audio Analysis", "Color", "w");
tiledlayout(2, 1, "TileSpacing", "compact", "Padding", "compact");

nexttile
plot(timeSeconds, audioSamples, "LineWidth", 0.5)
grid on
xlabel("Time (s)")
ylabel("Amplitude")
title("Input waveform: " + string(fileName), "Interpreter", "none")
if size(audioSamples, 2) > 1
    legend(compose("Channel %d", 1:size(audioSamples, 2)), "Location", "best")
end

nexttile
validBins = analysis.spectrumFrequencyHz > 0;
semilogx(analysis.spectrumFrequencyHz(validBins), analysis.spectrumDBFS(validBins), ...
    "LineWidth", 0.75)
grid on
xlim([20, sampleRate / 2])
xlabel("Frequency (Hz)")
ylabel("Magnitude (dBFS re 1.0)")
title(sprintf("One-sided windowed FFT magnitude (bin spacing %.5f Hz)", ...
    analysis.frequencyResolutionHz))
end
