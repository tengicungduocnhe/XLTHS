function stability = analyzeStability(filterBank)
%ANALYZESTABILITY Verify BIBO stability from the filter-bank pole locations.
%   Changing a finite branch gain affects only the numerator of the
%   parallel sum. It cannot introduce new poles, so stable branches yield
%   a stable equalizer for every finite allowed gain.

bandFields = ["bass", "mid", "treble"];
bandNames = ["Bass", "Mid", "Treble"];
stability.branchMaxPoleMagnitude = zeros(1, numel(bandFields));

for bandIndex = 1:numel(bandFields)
    currentFilter = filterBank.(bandFields(bandIndex));
    stability.branchMaxPoleMagnitude(bandIndex) = max(abs(currentFilter.poles));
end

stability.bandNames = bandNames;
stability.isBIBOStable = all(stability.branchMaxPoleMagnitude < 1);
stability.reason = "Finite gains scale branch numerators only; they do not add poles.";
end
