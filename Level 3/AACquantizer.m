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
Nb = length(bands)-1;
isESH = strcmp(frameType, 'ESH');
NSubFrames = 1 + isESH * 7;
G = zeros(1, NSubFrames);
sfc = zeros(Nb, NSubFrames);
S = zeros(size(frameF));

idx = 1;
for frame = frameF
    %% Energy of MDCT coefficients.
    P = bandEnergy(frame, bands);

    %% Loudness threshold.
    T = P ./ SMR(:, idx);

    %% Scalefactor gains.
    MQ = 8191;
    aNew = floor(16/3*log2(max(frame)^(3/4)/MQ));
    aNew = ones(Nb, 1) * aNew;
    while true
        a = aNew;
        P = quantizationError(frame, a, bands);
        aNew = a + (P < T);
        if all(aNew==a) || max(abs(diff(aNew))) > 60
            break
        end
    end

    %% Return values.
    G(idx) = a(1);
    sfc(:, idx) = [G; diff(a)];
    S(:, idx) = quantize(frame, bandStretch(a, size(frameF), bands));
    idx = idx + 1;
end
S = reshape(S, [1024 1]);
end

function P = bandEnergy(X, bands)
bb = 1:length(bands)-1;
P = zeros(length(bb), 1);
for b = bb
    wLow = bands(b);
    wHigh = bands(b+1)-1;%TODO: should it be -1 or not?
    k = wLow:wHigh;
    P(b) = sum(X(k).^2);
end
end

function P = quantizationError(X, a, bands)
a = bandStretch(a, size(X), bands);
S = quantize(X, a);
Xbar = deQuantize(S, a);
P = bandEnergy(X - Xbar, bands);
end

function S = quantize(X, a)
S = sign(X) .* fix((abs(X) .* 2.^(-1/4 * a)).^(3/4) + 0.4054);
end
