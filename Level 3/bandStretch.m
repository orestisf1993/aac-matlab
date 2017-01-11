function stretched = bandStretch(original, newSize, bands)
bb = 1:length(bands) - 1;
stretched = zeros(newSize);
for b = bb
    wLow = bands(b);
    wHigh = bands(b+1) - 1;
    k = wLow:wHigh;
    stretched(k) = original(b);
end
end
