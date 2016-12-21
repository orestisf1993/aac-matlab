function frameFout = iTNS(frameFin, frameType, TNScoeffs)
%ITNS Inverts Temporal Noise Shaping.
%   Detailed explanation goes here

assertIsFrameType(frameType);
assertMDCTSize(frameFin, frameType);

frameFout = zeros(size(frameFin));
for idx = 1:size(frameFin, 2) % Column wise iteration.
    a = [1, -TNScoeffs(:, idx).'];
    frameFout(:, idx) = filter(1, a, frameFin(:, idx));
end
end
