function plotEqualizerComparison(inputSamples, outputSamples, sampleRate, ...
        inputAnalysis, outputAnalysis, gainDB)
%PLOTEQUALIZERCOMPARISON Plot time- and frequency-domain input/output data.

timeSeconds = (0:size(inputSamples, 1) - 1)' / sampleRate;
inputMono = mean(inputSamples, 2);
outputMono = mean(outputSamples, 2);

figure("Name", "Step 3 - Equalizer Comparison", "Color", "w");
tiledlayout(2, 1, "TileSpacing", "compact", "Padding", "compact");

nexttile
plot(timeSeconds, inputMono, "Color", [0.35, 0.35, 0.35], "LineWidth", 0.5)
hold on
plot(timeSeconds, outputMono, "b", "LineWidth", 0.5)
hold off
grid on
xlabel("Time (s)")
ylabel("Amplitude")
title("Waveform before and after parallel equalization")
legend("Input (stereo average)", "Output (stereo average)", "Location", "best")

nexttile
validBins = inputAnalysis.spectrumFrequencyHz > 0;
semilogx(inputAnalysis.spectrumFrequencyHz(validBins), ...
    inputAnalysis.spectrumDBFS(validBins), "Color", [0.35, 0.35, 0.35])
hold on
semilogx(outputAnalysis.spectrumFrequencyHz(validBins), ...
    outputAnalysis.spectrumDBFS(validBins), "b")
hold off
grid on
xlim([20, sampleRate / 2])
xlabel("Frequency (Hz)")
ylabel("Magnitude (dBFS re 1.0)")
title(sprintf("FFT comparison, gains [Bass Mid Treble] = [%+g %+g %+g] dB", gainDB))
legend("Input", "Equalized output", "Location", "best")
end
