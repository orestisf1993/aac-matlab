function AACSeq1 = AACoder1(fNameIn)
%AACODER1 AAC encoder for Level 1.
%   AACSEQ1 = AACODER1(FNAMEIN) will perform the AAC encoding for file with
%   filename FNAMEIN. AACSEQ1 is a struct that has the following elements:
%   - frameType
%   - winType
%   - chl.frameF
%   - chr.frameF

%TODO: doc struct

frameWidth = 2048;
overlap = 0.5;

%% Read file
input = audioread(fNameIn);
N = length(input);
N = N - mod(N, frameWidth); % Number of elements should be divisible by frameWidth.

%% Pad with zeros.
% Add half a frame before and after.
% input = [zeros(frameWidth * overlap, 2); input(1:N, :); zeros(frameWidth * overlap, 2)];

%% Prepare the output.
AACSeq1 = struct('frameType', {}, 'winType', {}, ...
    'chl', struct('frameF', {}), ...
    'chr', struct('frameF', {}));

%% Perform the encoding
% numberOfFrames = N / (frameWidth * overlap); % <-- with padding
numberOfFrames = 1 / overlap * (N / frameWidth - 1);
prevType = 'OLS';
for frameIdx = 0:numberOfFrames - 1
    frameT = sliceFrame(input, frameIdx, frameWidth, overlap);
    nextFrameT = sliceFrame(input, frameIdx+1, frameWidth, overlap);

    prevType = SSC(frameT, nextFrameT, prevType);
    AACSeq1(frameIdx+1).frameType = prevType;
    %     display(prevType); %TODO:del
end
end


function frameT = sliceFrame(array, idx, frameWidth, overlap)
% Frame with 50% overlaping.
frameStart = idx * frameWidth * overlap + 1;
frameEnd = frameStart + frameWidth - 1;
frameRange = frameStart:frameEnd;
frameT = array(frameRange,:);
end
