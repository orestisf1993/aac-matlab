function AACSeq2 = AACoder2(fNameIn)
%AACODER2 AAC encoder for Level 2.
%   AACSEQ2 = AACODER2(FNAMEIN) will perform the AAC encoding for file with
%   filename FNAMEIN. AACSEQ2 is a struct that has the following elements:
%   - frameType: one of the 4 types of frames according to the assignment. From
%   SSC.
%   - winType: one of the 2 types of windows. From FILTERBANK.
%   - chl.frameF: frame of the left channel.
%   - chr.frameF: frame of the right channel.
%   - chl.TNScoeffs: Quantised TNS coefficients for the left channel.
%   - chr.TNScoeffs: Quantised TNS coefficients for the right channel.
%
%   See also IAACODER2, AACODER1, TNS, DEMOAAC2.

frameWidth = 2048;
overlap = 0.5;
winType = 'SIN';

%% Read file
input = audioread(fNameIn); % Assuming 48kHz.
N = length(input);
N = N - mod(N, frameWidth); % Number of elements should be divisible by frameWidth.
input = input(1:N,:);

%% Pad with zeros.
input = [zeros(frameWidth/2, 2); input; zeros(frameWidth/2, 2)];
N = N + 2048;

%% Prepare the output.
AACSeq2 = struct('frameType', {}, 'winType', {}, ...
    'chl', struct('frameF', {}, 'TNScoeffs', {}), ...
    'chr', struct('frameF', {}, 'TNScoeffs', {}));

%% Perform the encoding
numberOfFrames = 1 / overlap * (N / frameWidth - 1);
prevType = 'OLS';
for frameIdx = 0:numberOfFrames - 1
    frameT = sliceFrame(input, frameIdx, frameWidth, overlap);
    nextFrameT = sliceFrame(input, frameIdx+1, frameWidth, overlap);

    prevType = SSC(frameT, nextFrameT, prevType);
    AACSeq2(frameIdx+1).frameType = prevType;
    AACSeq2(frameIdx+1).winType = winType;
    frameF = filterbank(frameT, prevType, winType);
    isESH = strcmp(prevType, 'ESH');
    if isESH
        AACSeq2(frameIdx+1).chl.frameF = reshape(frameF(:, 1), [128, 8]);
        AACSeq2(frameIdx+1).chr.frameF = reshape(frameF(:, 2), [128, 8]);
    else
        AACSeq2(frameIdx+1).chl.frameF = frameF(:, 1);
        AACSeq2(frameIdx+1).chr.frameF = frameF(:, 2);
    end
    [AACSeq2(frameIdx+1).chl.frameF, AACSeq2(frameIdx+1).chl.TNScoeffs] = ...
        TNS(AACSeq2(frameIdx+1).chl.frameF, prevType);
    [AACSeq2(frameIdx+1).chr.frameF, AACSeq2(frameIdx+1).chr.TNScoeffs] = ...
        TNS(AACSeq2(frameIdx+1).chr.frameF, prevType);
end
end


function frameT = sliceFrame(array, idx, frameWidth, overlap)
% Frame with 50% overlaping.
frameStart = idx * frameWidth * overlap + 1;
frameEnd = frameStart + frameWidth - 1;
frameRange = frameStart:frameEnd;
frameT = array(frameRange,:);
end
