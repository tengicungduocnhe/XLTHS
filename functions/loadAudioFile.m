function [audioSamples, sampleRate, fileInfo] = loadAudioFile(audioFile)
%LOADAUDIOFILE Read an audio file and return its samples and metadata.

if ~(ischar(audioFile) || isstring(audioFile)) || ~isfile(audioFile)
    error("MultiBandEqualizer:AudioFileNotFound", ...
        "Audio file was not found: %s", string(audioFile));
end

fileInfo = audioinfo(audioFile);
[audioSamples, sampleRate] = audioread(audioFile);
end
