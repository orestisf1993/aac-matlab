function frameFout = iTNS(frameFin, frameType, TNScoeffs)
%ITNS Inverts Temporal Noise Shaping.
%   FRAMEFOUT = ITNS(FRAMEFIN, FRAMETYPE, TNSCOEFFS) will invert TNSs output.
%
%   See also TNS.

assertIsFrameType(frameType);
assertMDCTSize(frameFin, frameType);

frameFout = zeros(size(frameFin));
for idx = 1:size(frameFin, 2) % Column wise iteration.
    a = [1, -TNScoeffs(:, idx).'];
    frameFout(:, idx) = filter(1, a, frameFin(:, idx));
end
end
