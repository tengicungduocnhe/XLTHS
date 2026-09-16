function printQuantizationSummary(quantization)
%PRINTQUANTIZATIONSUMMARY Print 16-bit coefficient-quantization results.

fprintf("\nStep 4: %d-bit fixed-point coefficient quantization\n", ...
    quantization.wordLength);
fprintf("  Implementation: %s\n", quantization.implementation);
for bandIndex = 1:numel(quantization.bands)
    band = quantization.bands(bandIndex);
    fprintf("  %s: %d SOS section(s)\n", band.name, band.sectionCount);
    for sectionIndex = 1:band.sectionCount
        fprintf("    Section %d: numerator scale = %g, denominator scale = %g\n", ...
            sectionIndex, band.numeratorScales(sectionIndex), ...
            band.denominatorScales(sectionIndex));
    end
    fprintf("    max coefficient error = %.3e, max |quantized pole| = %.6f\n", ...
        band.maximumCoefficientError, band.maximumPoleMagnitude);
end
fprintf("  Quantized filter bank BIBO stable: %s\n", ...
    string(quantization.isBIBOStable));
end
