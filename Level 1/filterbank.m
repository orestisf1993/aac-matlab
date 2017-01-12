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
            rangeF = (1:128) + idx * 128;
            rangeT = (1:256) + 448 + idx * 128;
            subFrame = frameT(rangeT,:);
            subFrame = subFrame .* shortWindow;
            frameF(rangeF, 1) = mdct(subFrame(:, 1));
            frameF(rangeF, 2) = mdct(subFrame(:, 2));
        end
    case 'LSS'
        % A long window on the left and a short on the right.
        window = [longWindow(1:1024,:); ones(448, 2); shortWindow(129:256,:); zeros(448, 2)];
    case 'LPS'
        window = [zeros(448, 2); shortWindow(1:128,:); ones(448, 2); longWindow(1025:2048,:)];
end
if ~exist('frameF', 'var')
    frameT = frameT .* window;
    frameF = mdct(frameT);
end

%% Check and return.
assertIsFullFrame(frameF, 'Wrong output size.', 1024);
end


function y = mdct(x)
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
% Make sure length is multiple of 4
if (rem(flen, 4) ~= 0)
    error('MDCT4 defined for lengths multiple of four.');
end

% We need these for furmulas below
N = flen; % Length of window
M = N / 2; % Number of coefficients
N4 = N / 4; % Simplify the way eqs look
sqrtN = sqrt(N);

% Preallocate rotation matrix
% It would be nice to be able to do it in-place but we cannot
% cause of the prerotation.
rot = zeros(flen, fnum);

% Shift
t = (0:(N4 - 1)).';
rot(t+1,:) = -x(t+3*N4+1,:);
t = (N4:(N - 1)).';
rot(t+1,:) = x(t-N4+1,:);

% We need this twice so keep it around
t = (0:(N4 - 1)).';
w = diag(sparse(exp(-1i*2*pi*(t + 1 / 8)/N)));

% Pre-twiddle
t = (0:(N4 - 1)).';
c = (rot(2*t+1,:) - rot(N-1-2*t+1,:)) - 1i * (rot(M+2*t+1,:) - rot(M-1-2*t+1,:));
% This is a really cool Matlab trick ;)
c = 0.5 * w * c;

% FFT for N/4 points only !!!
c = fft(c, N4);

% Post-twiddle
c = (2 / sqrtN) * w * c;

% Sort
t = (0:(N4 - 1)).';
y(2*t+1,:) = real(c(t+1,:));
y(M-1-2*t+1,:) = - imag(c(t+1,:));
end
