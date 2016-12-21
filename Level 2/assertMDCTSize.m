function assertMDCTSize(frameFin, frameType, N)
%ASSERTISMDCTSIZE Assertion that a frame is the correct size for the given
%frame type.

if ~exist('N', 'var')
    N = 2048;
end
assert(mod(N, 2) == 0);
assertIsFrameType(frameType);
isESH = strcmp(frameType, 'ESH');
expected = N / 2;
if isESH
    expected = expected / 8;
    dim2 = 8;
else
    dim2 = 1;
end

assert(all(size(frameFin) == [expected, dim2]));

end
