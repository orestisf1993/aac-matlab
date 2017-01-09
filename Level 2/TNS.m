function [frameFout, TNScoeffs] = TNS(frameFin, frameType)
%TNS Implements the Temporal Noise Shaping.
%   Detailed explanation goes here
%TODO

assertIsFrameType(frameType);
assertMDCTSize(frameFin, frameType);

bands = initBands(frameType);
frameFout = zeros(size(frameFin));
TNScoeffs = zeros([4, size(frameFin, 2)]);
idx = 1;
for frame = frameFin % Column wise iteration.
    Sw = normalizationCoeff(frame, bands); % 1. Sw coefficients.
    a = linearCoeffs(frame, Sw); % 2. Linear predictor coefficients.
    assert(numel(a) == 4);
    a = quantizeCoeffs(a); % 3. Quantize lp coefficients.
    % 4. Apply FIR filter.
    [frameFout(:, idx), TNScoeffs(:, idx)] = filterFrame(frame, a);

    idx = idx + 1;
end
end


function Sw = normalizationCoeff(X, b)
%% Calculate energy P and initial Sw.
Nb = length(b);
Sw = zeros(size(X));
for j = 1:Nb - 1
    k = b(j):b(j+1) - 1; % X's index.
    P = sum(X(k).^2);
    Sw(k) = sqrt(P);
end
%% Smoothen Sw.
for k = length(Sw) - 1:-1:1
    Sw(k) = (Sw(k) + Sw(k+1)) / 2;
end
for k = 2:length(Sw)
    Sw(k) = (Sw(k) + Sw(k-1)) / 2;
end
end


function a = linearCoeffs(X, Sw)
Xw = X ./ Sw;
a = lpc(Xw, 4);
a = -a(2:end);
end


function a = quantizeCoeffs(a)
a = round(a*10) / 10;
a(a < -0.7) = - 0.7;
a(a > 0.8) = 0.8;
end


function [frameFout, a] = filterFrame(frame, a)
a = [1, -a];
a = makeInvertible(a);
frameFout = filter(a, 1, frame);
a = -a(2:end);
end


function a = makeInvertible(a)
r = roots(a);
e = 0.001;
r(r == 0) = e; % Avoid division by zero.
% Force roots inside |z| < 1 circle.
r(r > 1) = 1 - e;
r(r < -1) = - 1 + e;
a = poly(r); % Recreate.
end
