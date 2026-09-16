function plotFilterBankResponse(filterBank, sampleRate)
%PLOTFILTERBANKRESPONSE Plot individual and unity-gain summed responses.
%   The summed trace is diagnostic only; no gains or audio processing occur.

filters = [filterBank.bass, filterBank.mid, filterBank.treble];
frequencyPoints = 4096;
responses = zeros(frequencyPoints, numel(filters));

for filterIndex = 1:numel(filters)
    currentFilter = filters(filterIndex);
    [responses(:, filterIndex), frequencyHz] = freqz( ...
        currentFilter.numerator, currentFilter.denominator, frequencyPoints, sampleRate);
end

figure("Name", "Step 2 - IIR Filter Bank", "Color", "w");
tiledlayout(2, 1, "TileSpacing", "compact", "Padding", "compact");

nexttile
plot(frequencyHz, 20 * log10(max(abs(responses), realmin("double"))), "LineWidth", 1)
grid on
xlim([0, sampleRate / 2])
ylim([-80, 5])
xlabel("Frequency (Hz)")
ylabel("Magnitude (dB)")
title("Individual Butterworth IIR responses")
legend(string({filters.name}), "Location", "southwest")

nexttile
combinedResponse = sum(responses, 2);
plot(frequencyHz, 20 * log10(max(abs(combinedResponse), realmin("double"))), ...
    "k", "LineWidth", 1)
grid on
xlim([0, sampleRate / 2])
ylim([-20, 10])
xlabel("Frequency (Hz)")
ylabel("Magnitude (dB)")
title("Parallel sum with unity gains (diagnostic only)")
end
