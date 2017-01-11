function assertIsFullFrame(frame, message, frameLength)
%ASSERTISFULLFRAME Assertion that given frame is the correct size for the exercise.
if ~exist('frameLength', 'var')
    frameLength = 2048;
end
if ~exist('message', 'var')
    message = 'Invalid frame size';
end
assert(all(size(frame) == [frameLength, 2]), message);
end
