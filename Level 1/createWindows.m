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
window = zeros(N, 1);
sumvalue = 0;
beta = pi * alpha;

for i = 0:N / 2 - 1
    sumvalue = sumvalue + besseli(0, beta*sqrt(1-(4 * i / N - 1)^2));
    window(i + 1) = sumvalue;
end
sumvalue = sumvalue + besseli(0, beta*sqrt(1-(4 * (N / 2) / N - 1)^2));

for i = 0:N / 2 - 1
    window(i + 1) = sqrt(window(i+1)/sumvalue);
    window(N-i) = window(i+1);
end
end


function window = SINWindow(N)
x = 0:N - 1;
window = sin(pi / N * (x + 0.5));
window = window.';
end
