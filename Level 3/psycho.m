function SMR = psycho(frameT, frameType, frameTprev1, frameTprev2)
%PSYCHO Psychoacoustic model for one channel.
%   SMR = PSYCHO(FRAMET, FRAMETYPE, FRAMETPREV1, FRAMETPREV2) returns the signal
%   to mask ratio SMR according to a the current frame FRAMET, the previous
%   frames FRAMETPREV1 and FRAMETPREV2 and the frame type FRAMETYPE.

%% Validate input.
%TODO:3 frameTs
assertIsFrameType(frameType);

%% Initialize.
isESH = strcmp(frameType, 'ESH');
nColumns = 1 + isESH * 7;
frameT = reshape(frameT, [length(frameT) / nColumns, nColumns]);
N = size(frameT, 1);
w = 1:N/2;
hannWindow = 0.5 - 0.5 * cos(pi / N * ((0:N - 1) + 0.5));
hannWindow = hannWindow(:);
[bands, qthr, bval] = initBands(frameType);
bb = 1:length(bands) - 1;
spreading = zeros(size(bands)-1);
for b1 = bb
    for b2 = bb
        spreading(b1, b2) = spreadingFunction(b1, b2, bval);
    end
end

frameTprev1 = reshape(frameTprev1, size(frameT));
frameTprev2 = reshape(frameTprev2, size(frameT));
isESH = strcmp(frameType, 'ESH');
if isESH
    frameTprev2 = frameTprev1(:, end-1);
    frameTprev1 = frameTprev1(:, end);
end

%TODO: persistent r,f?
frame0 = frameTprev1;
frame1 = frameTprev2;
sw0 = frame0 .* hannWindow;
sw1 = frame1 .* hannWindow;
[r0, f0] = frameFFT(sw0);
[r1, f1] = frameFFT(sw1);
for columnIdx = 1:nColumns
    %     frame2 = frame1;
    %     frame1 = frame0;
    r2 = r1;
    r1 = r0;
    f2 = f1;
    f1 = f0;
    %     sw2 = sw1;
    %     sw1 = sw0;
    frame0 = frameT(:, columnIdx);

    %% 1. Spreading function.
    %% 2a. Hann windowing.
    sw0 = frame0 .* hannWindow;
    %% 2b. Magnitute and phase of sw's FFT.
    [r0, f0] = frameFFT(sw0);
    %% 3. Predictions for r and f.
    rpred = 2 * r1(w) - r2(w);
    fpred = 2 * f1(w) - f2(w);
    %% 4. Predictability of frame.
    c = sqrt( ...
        (r0(w) .* cos(f0(w)) - rpred(w) .* cos(fpred(w))).^2+ ...
        (r0(w) .* sin(f0(w)) - rpred(w) .* sin(fpred(w))).^2 ...
        ) ./ (r0(w) + abs(rpred(w)));
    %% 5. Energy for each band and weighted predictability.
    e = zeros(length(bands)-1, 1);
    cn = zeros(length(bands)-1, 1);
    for b = bb
        wLow = bands(b);
        wHigh = bands(b+1)-1;
        wLocal = wLow:wHigh;
        e(b) = sum(r0(wLocal).^2);
        cn(b) = sum(c(wLocal).*(r0(wLocal).^2));
    end
    c = cn;
    %% 6. Combine energy and predictability with the spreading function.
    ecb = zeros(size(bb));
    ct = zeros(size(bb));
    for b = bb
        ecb(b) = sum(e(bb) .* spreading(bb, b));
        ct(b) = sum(c(bb) .* spreading(bb, b));
    end
    cb = ct ./ ecb;
    en = ecb ./ sum(spreading(bb,:), 1);
    %% 7. Tonality index.
    tb = -0.299 - 0.43 * log(cb);
%     assert(all(tb > 0 && tb < 1), 'Tonality index out of bounds.');
    %% 8. SNR for each band.
    NMT = 6;
    TMN = 18;
    SNR = tb * TMN + (1 - tb) * NMT;
    %% 9. From dB to energy ratio.
    bc = 10.^(-SNR / 10);
    %% 10. Energy threshold.
    nb = en .* bc;
    %% 11.
    qthr = eps * N / 2 * 10.^(qthr / 10);
    npart = max(nb, qthr);
    %% 12. Signal to Mask Ratio.
    SMR(:, columnIdx) = e ./ npart.';
end

end


function x = spreadingFunction(i, j, bval)
compare = i >= j;
tmpx = (3 * compare + 1.5 * (~compare)) * (bval(j) - bval(i));
tmpz = 8 * min(0, (tmpx - 0.5)^2-2*(tmpx - 0.5));
tmpy = 15.811389 + 7.5 * (tmpx + 0.474) - 17.5 * sqrt(1+(tmpx + 0.474).^2);
x = (tmpy >= -100) * 10.^((tmpz + tmpy) / 10);
end

function [r, f] = frameFFT(frame)
y = fft(frame);
y = y(1:end/2);
r = abs(y); % Magnitude
f = angle(y); % Phase
end
