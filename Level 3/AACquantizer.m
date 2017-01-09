function [S, sfc, G] = AACquantizer(frameF, frameType, SMR)
%AACQUANTIZER Quantize channel.
%   [S, SFC, G] = AACQUANTIZER(FRAMEF, FRAMETYPE, SMR) will quantize frame FRAMEF of type FRAMETYPE
%   according to the Signal to Mask Ratio SMR. Returns the MDCT symbols in S, scalefactor
%   coefficients in SFC and the global gain in G.
%
%   See also IAACQUANTIZER.

%% Validate input.
assertIsFrameType(frameType);

%% Initialize.
bands = initBands(frameType);

%% Energy of MDCT coefficients.
P = bandEnergy(frameF);

%% Loudness threshold.
T = P ./ SMR;

%% Scalefactor gains.
MQ = 8191;
a = 16 / 3 * log2(max(x)^(3/4)/MQ);
while true
    a = aNew;
    P = quantizationError(frameF, a, bands);
    aNew = a + (P < T);
    if ~any(aNew~=a) || max(abs(diff(aNew))) > 60
        break
    end
end

%% Return values.
G = a(1);
sfc = [G diff(a)];
end

function P = bandEnergy(X, bands)
bb = 1:length(bands)-1;
P = zeros(size(bb));
for b = bb
    wLow = bands(b);
    wHigh = bands(b+1);
    k = wLow:wHigh;
    P(b) = sum(X(k).^2);
end
end

function P = quantizationError(frameF, a, bands)
a = bandStretch(a, size(frameF), bands);
S = quantize(frameF, a);
X = deQuantize(S, a);
P = bandEnergy(S - X, bands);
end

function S = quantize(frameF, a)
magicNumber = 0.4054;
S = sgn(frameF) .* floor((abs(frameF) .* (2.^(-a./4))).^(3/4) + magicNumber);
end
