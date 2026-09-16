function printAudioSummary(fileInfo, analysis, config)
%PRINTAUDIOSUMMARY Print source-file and Step 1 analysis measurements.

fprintf("Source audio information\n");
fprintf("  File: %s\n", fileInfo.Filename);
fprintf("  Format: %s, %d-bit\n", fileInfo.CompressionMethod, fileInfo.BitsPerSample);
fprintf("  Sample rate: %g Hz\n", fileInfo.SampleRate);
fprintf("  Channels: %d\n", fileInfo.NumChannels);
fprintf("  Samples per channel: %d\n", analysis.sampleCount);
fprintf("  Duration: %.3f s\n", analysis.durationSeconds);

fprintf("\nTime-domain levels (dBFS is referenced to full scale = 1.0)\n");
for channelIndex = 1:analysis.channelCount
    fprintf("  Channel %d: peak = %.6f (%.2f dBFS), RMS = %.6f (%.2f dBFS)\n", ...
        channelIndex, analysis.peakPerChannel(channelIndex), ...
        analysis.peakDBFSPerChannel(channelIndex), ...
        analysis.rmsPerChannel(channelIndex), ...
        analysis.rmsDBFSPerChannel(channelIndex));
end

fprintf("\nFFT spectrum\n");
fprintf("  FFT length: %d samples\n", analysis.fftLength);
fprintf("  Bin spacing: %.5f Hz\n", analysis.frequencyResolutionHz);

fprintf("\nTemporary equalizer parameters (not applied in Step 1)\n");
fprintf("  Bass: below %g Hz\n", config.equalizer.bassUpperHz);
fprintf("  Mid: %g Hz to %g Hz\n", config.equalizer.midRangeHz(1), config.equalizer.midRangeHz(2));
fprintf("  Treble: above %g Hz\n", config.equalizer.trebleLowerHz);
fprintf("  Gain range: %g dB to %+g dB\n", config.equalizer.gainRangeDB(1), config.equalizer.gainRangeDB(2));
end
