function AACSeq1 = AACoder1(fNameIn)
%AACODER1 AAC encoder for Level 1.
%   AACSEQ1 = AACODER1(FNAMEIN) will perform the AAC encoding for file with
%   filename FNAMEIN. AACSEQ1 is a struct that has the following elements:
%   - frameType: one of the 4 types of frames according to the assignment. From
%   SSC.
%   - winType: one of the 2 types of windows. From FILTERBANK.
%   - chl.frameF: frame of the left channel.
%   - chr.frameF: frame of the right channel.
%
%   See also IAACODER1, SSC, FILTERBANK, DEMOAAC1.

frameWidth = 2048;
overlap = 0.5;
winType = 'KBD';

%% Read file
input = audioread(fNameIn); % Assuming 48kHz.
N = length(input);
N = N - mod(N, frameWidth); % Number of elements should be divisible by frameWidth.
input = input(1:N,:);

%% Pad with zeros.
%TODO: remove or use.
% Add half a frame before and after.
% input = [zeros(frameWidth * overlap, 2); input(1:N, :); zeros(frameWidth * overlap, 2)];

%% Prepare the output.
AACSeq1 = struct('frameType', {}, 'winType', {}, ...
    'chl', struct('frameF', {}), ...
    'chr', struct('frameF', {}));

%% Perform the encoding
% numberOfFrames = N / (frameWidth * overlap); % <-- with padding %TODO: remove or use.
numberOfFrames = 1 / overlap * (N / frameWidth - 1);
prevType = 'OLS';
for frameIdx = 0:numberOfFrames - 1
    frameT = sliceFrame(input, frameIdx, frameWidth, overlap);
    nextFrameT = sliceFrame(input, frameIdx+1, frameWidth, overlap);

    prevType = SSC(frameT, nextFrameT, prevType);
    AACSeq1(frameIdx+1).frameType = prevType;
    AACSeq1(frameIdx+1).winType = winType;
    frameF = filterbank(frameT, prevType, winType);
    AACSeq1(frameIdx+1).chl.frameF = frameF(:, 1);
    AACSeq1(frameIdx+1).chr.frameF = frameF(:, 2);
end
end


function frameT = sliceFrame(array, idx, frameWidth, overlap)
% Frame with 50% overlaping.
frameStart = idx * frameWidth * overlap + 1;
frameEnd = frameStart + frameWidth - 1;
frameRange = frameStart:frameEnd;
frameT = array(frameRange,:);
end
