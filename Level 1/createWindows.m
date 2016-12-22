function [short, long] = createWindows(N, frameType, winType)
%CREATEWINDOWS wrapper around 'KBD' and 'SIN' window creators.
%   [SHORT, LONG] = CREATEWINDOWS(N, FRAMETYPE, WINTYPE) will create 2 windows:
%   SHORT and LONG with type WINTYPE for a frame of length N and type FRAMETYPE.
%   Possible WINTYPE values are 'KDB' and 'SIN'.
%
%   See also FILTERBANK, IFILTERBANK.

short = [];
long = [];

%% Check input validity.
assertIsWinType(winType);
assertIsFrameType(frameType);

%% Fill return values.
needShort = ~strcmp(frameType, {'OLS'});
needLong = ~strcmp(frameType, {'ESH'});
assert(needShort || needLong);
switch winType
    case 'KBD'
        if needShort
            short = KDBWindow(N/8, 4);
        end
        if needLong
            long = KDBWindow(N, 6);
        end
    case 'SIN'
        if needShort
            short = SINWindow(N/8);
        end
        if needLong
            long = SINWindow(N);
        end
end
short = [short, short];
long = [long, long];
end


function window = KDBWindow(N, alpha)
w = kaiser(N/2+1, pi*alpha);
window = zeros(N, 1);
denominator = sqrt(sum(w));
for n = 1:N / 2
    window(n) = sqrt(sum(w(1:n+1))) / denominator;
end
window(N/2+1:N) = window(N/2:-1:1);
end


function window = SINWindow(N)
x = 0:N-1;
window = sin(pi / N * (x + 0.5));
window = window.';
end
