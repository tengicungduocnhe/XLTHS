function analysis = analyzeAudio(audioSamples, sampleRate)
%ANALYZEAUDIO Calculate time-domain levels and a one-sided FFT spectrum.
%   Stereo input is retained for level measurements. Its channel average is
%   used for the overview spectrum so that one trace represents the track.

if ~isnumeric(audioSamples) || isempty(audioSamples) || ndims(audioSamples) ~= 2
    error("MultiBandEqualizer:InvalidAudio", ...
        "Audio samples must be a nonempty samples-by-channels numeric matrix.");
end
if ~isscalar(sampleRate) || sampleRate <= 0
    error("MultiBandEqualizer:InvalidSampleRate", ...
        "Sample rate must be a positive scalar.");
end

sampleCount = size(audioSamples, 1);
channelCount = size(audioSamples, 2);

analysis.sampleCount = sampleCount;
analysis.channelCount = channelCount;
analysis.durationSeconds = sampleCount / sampleRate;
analysis.peakPerChannel = max(abs(audioSamples), [], 1);
analysis.rmsPerChannel = sqrt(mean(audioSamples .^ 2, 1));
analysis.peakDBFSPerChannel = amplitudeToDBFS(analysis.peakPerChannel);
analysis.rmsDBFSPerChannel = amplitudeToDBFS(analysis.rmsPerChannel);

% A Hann window reduces spectral leakage. The coherent-gain normalization
% preserves the amplitude scale of the one-sided spectrum.
monoSamples = mean(audioSamples, 2);
window = 0.5 - 0.5 * cos(2 * pi * (0:sampleCount - 1)' / (sampleCount - 1));
fftLength = 2 ^ nextpow2(sampleCount);
fftValues = fft(monoSamples .* window, fftLength);
positiveBinCount = fftLength / 2 + 1;
amplitude = abs(fftValues(1:positiveBinCount)) / sum(window);
amplitude(2:end - 1) = 2 * amplitude(2:end - 1);

analysis.spectrumFrequencyHz = sampleRate * (0:positiveBinCount - 1)' / fftLength;
analysis.spectrumAmplitude = amplitude;
analysis.spectrumDBFS = amplitudeToDBFS(amplitude);
analysis.fftLength = fftLength;
analysis.frequencyResolutionHz = sampleRate / fftLength;
end

function levelDBFS = amplitudeToDBFS(amplitude)
% Convert a linear amplitude referenced to full scale (1.0) into dBFS.
levelDBFS = 20 * log10(max(amplitude, realmin("double")));
end
