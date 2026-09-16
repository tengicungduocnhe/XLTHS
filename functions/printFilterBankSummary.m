function printFilterBankSummary(filterBank)
%PRINTFILTERBANKSUMMARY Print the designed IIR filter-bank characteristics.

filters = [filterBank.bass, filterBank.mid, filterBank.treble];

fprintf("\nStep 2: Butterworth IIR filter bank (bilinear transform)\n");
for filterIndex = 1:numel(filters)
    currentFilter = filters(filterIndex);
    largestPoleMagnitude = max(abs(currentFilter.poles));
    fprintf("  %s: %s, order %d, passband [%g, %g] Hz, max |pole| = %.6f\n", ...
        currentFilter.name, currentFilter.responseType, currentFilter.order, ...
        currentFilter.passbandHz(1), currentFilter.passbandHz(2), ...
        largestPoleMagnitude);
end
end
