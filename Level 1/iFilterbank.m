function frameT = iFilterbank(frameF, frameType, winType)
%IFILTERBANK inverse MDCT transform of a frame.
%   FRAMET = FILTERBANK(FRAMEF, FRAMETYPE, WINTYPE) will call the inverse mdct
%   transformation for FRAMEF using a window of type WINTYPE. FRAMET is the
%   (original) transformed frame.
%
%   See also FILTERBANK.

N = 2 * length(frameF); % frameT's length.
%% Check input validity.
assertIsFrameType(frameType);
assertIsFullFrame(frameF, 'Different frame size expected', 1024);
assert(N == 2048);
assert(~exist('frameT', 'var'));

%% Create needed windows.
[shortWindow, longWindow] = createWindows(N, frameType, winType);

%% Calculate frameT.
switch frameType
    case 'OLS'
        window = longWindow;
    case 'ESH'
        frameT = zeros(N, 2);
        % Split in 8 regions with 50% overlap.
        for idx = 0:7
            rangeF = (1:128) + idx * 128;
            rangeT = (1:256) + 448 + idx * 128;
            subFrame = frameF(rangeF,:);
            subFrameT(:, 1) = imdct(subFrame(:, 1));
            subFrameT(:, 2) = imdct(subFrame(:, 2));
            subFrameT = subFrameT .* shortWindow;
            frameT(rangeT,:) = frameT(rangeT,:) + subFrameT;
        end
    case 'LSS'
        % A long window on the left and a short on the right.
        window = [longWindow(1:1024,:); ones(448, 2); shortWindow(1:128,:); ones(448, 2)];
    case 'LPS'
        window = [ones(448, 2); shortWindow(1:128,:); ones(448, 2); longWindow(1:1024,:)];
end
if ~exist('frameT', 'var')
    frameT = imdct(frameF);
    frameT = frameT .* window;
end

%% Check and return.
assertIsFullFrame(frameT, 'Wrong output size.');
end


function result = imdct(frame)
% Taken from http://www.ee.columbia.edu/~marios/mdct/imdctv.m.
M = length(frame);
N = M * 2;
n0 = (M + 1) / 2;

[k, n] = meshgrid(0:(M - 1), 0:(N - 1));
T = cos(pi*(n + n0).*(k + 0.5)/M);
result = T * frame / (N / 4);
end
