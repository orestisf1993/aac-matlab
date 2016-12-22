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
        window = [longWindow(1:1024,:); ones(448, 2); shortWindow(129:256,:); zeros(448, 2)];
    case 'LPS'
        window = [zeros(448, 2); shortWindow(1:128,:); ones(448, 2); longWindow(1025:2048,:)];
end
if ~exist('frameT', 'var')
    frameT = imdct(frameF);
    frameT = frameT .* window;
end

%% Check and return.
assertIsFullFrame(frameT, 'Wrong output size.');
end


function y = imdct(x)
% Marios Athineos, marios@ee.columbia.edu
% http://www.ee.columbia.edu/~marios/
% Copyright (c) 2002 by Columbia University.
% All rights reserved.

[flen, fnum] = size(x);
% Make column if it's a single row
if (flen == 1)
    x = x(:);
    flen = fnum;
    fnum = 1;
end

% We need these for furmulas below
N = flen;
M = N / 2;
twoN = 2 * N;
sqrtN = sqrt(twoN);

% We need this twice so keep it around
t = (0:(M - 1)).';
w = diag(sparse(exp(-1i*2*pi*(t + 1 / 8)/twoN)));

% Pre-twiddle
t = (0:(M - 1)).';
c = x(2*t+1,:) + 1i * x(N-1-2*t+1,:);
c = (0.5 * w) * c;

% FFT for N/2 points only !!!
c = fft(c, M);

% Post-twiddle
c = ((8 / sqrtN) * w) * c;

% Preallocate rotation matrix
rot = zeros(twoN, fnum);

% Sort
t = (0:(M - 1)).';
rot(2*t+1,:) = real(c(t+1,:));
rot(N+2*t+1,:) = imag(c(t+1,:));
t = (1:2:(twoN - 1)).';
rot(t+1,:) = -rot(twoN-1-t+1,:);

% Shift
t = (0:(3 * M - 1)).';
y(t+1,:) = rot(t+M+1,:);
t = (3 * M:(twoN - 1)).';
y(t+1,:) = - rot(t-3*M+1,:);
end
