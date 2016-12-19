function frameF = filterbank(frameT, frameType, winType)
%FILTERBANK MDCT transform of a frame.
%   FRAMEF = FILTERBANK(FRAMET, FRAMETYPE, WINTYPE) will call the mdct
%   transformation for FRAMET using a window of type WINTYPE. FRAMEF is the
%   transformed frame.
%
%   See also IFILTERBANK.

N = length(frameT);
%% Check input validity.
assertIsFrameType(frameType);
assertIsFullFrame(frameT, 'Different frame size expected');
assert(N == 2048);
assert(~exist('frameF', 'var'));

%% Create needed windows.
[shortWindow, longWindow] = createWindows(N, frameType, winType);

%% Calculate frameF.
switch frameType
    case 'OLS'
        window = longWindow;
    case 'ESH'
        frameF = zeros(1024, 2);
        % Split in 8 regions with 50% overlap.
        for idx = 0:7
            rangeF = idx * 128 + 1:(idx + 1) * 128;
            rangeT = 448 + idx * 128 + 1:448 + (idx + 2) * 128;
            subFrame = frameT(rangeT,:);
            subFrame = subFrame .* shortWindow;
            frameF(rangeF,:) = mdct(subFrame);
        end
    case 'LSS'
        % A long window on the left and a short on the right.
        window = [longWindow(1:1024,:); ones(448, 2); shortWindow(1:128,:); ones(448, 2)];
    case 'LPS'
        window = [ones(448, 2); shortWindow(1:128,:); ones(448, 2); longWindow(1:1024,:)];
end
if ~exist('frameF', 'var')
    frameT = frameT .* window;
    frameF = mdct(frameT);
end

%% Check and return.
assertIsFullFrame(frameF, 'Wrong output size.', 1024);
end


function result = mdct(frame)
% Taken from http://www.ee.columbia.edu/~marios/mdct/mdctv.m.
N = length(frame);
M = N / 2;
n0 = (M + 1) / 2;

[n, k] = meshgrid(0:(N - 1), 0:(M - 1));
T = cos(pi*(n + n0).*(k + 0.5)/M); % Transformation matrix.
result = T * frame;
end

