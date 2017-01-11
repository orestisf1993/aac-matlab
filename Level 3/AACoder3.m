function AACSeq3 = AACoder3(fNameIn, fnameAACoded)
%AACODER3 AAC encoder for Level 3.
%   AACSEQ3 = AACODER3(FNAMEIN, FNAMEAACODED) will perform the AAC encoding for file with
%   filename FNAMEIN and save the encoding in .mat file named FNAMEAACODED.
%   AACSEQ3 is a struct that has the following elements:
%   - frameType: one of the 4 types of frames according to the assignment. From
%   SSC.
%   - winType: one of the 2 types of windows. From FILTERBANK.
%   - chl.TNScoeffs: Quantised TNS coefficients for the left channel.
%   - chr.TNScoeffs: Quantised TNS coefficients for the right channel.
%   - chl.T: Loudness thresholds for the left channel.
%   - chr.T: Loudness thresholds for the right channel.
%   - chl.G: Quantized global gains for the left channel.
%   - chr.G: Quantized global gains for the right channel.
%   - chl.sfc: Encoded sfc for the left channel.
%   - chr.sfc: Encoded sfc for the right channel.
%   - chl.stream: Encoded MDCT sequence for the left channel.
%   - chr.stream: Encoded MDCT sequence for the right channel.
%   - chl.codebook: The Huffman codebook for the left channel.
%   - chr.codebook: The Huffman codebook for the right channel.
%
%   See also IAACODER3, AACODER2, DEMOAAC3.

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
createChStruct = @() struct('TNScoeffs', {}, 'T', {}, 'G', {}, 'sfc', {}, 'stream', {}, 'codebook', {});
AACSeq3 = struct('frameType', {}, 'winType', {}, 'chl', createChStruct(), 'chr', createChStruct());

%% Perform the encoding
numberOfFrames = 1 / overlap * (N / frameWidth - 1);
prevType = 'OLS';
huffLUT = loadLUT();
frameT = zeros(frameWidth, 2);
frameTprev1 = zeros(frameWidth, 2);
for frameIdx = 0:numberOfFrames - 1
    frameTprev2 = frameTprev1;
    frameTprev1 = frameT;
    frameT = sliceFrame(input, frameIdx, frameWidth, overlap);
    nextFrameT = sliceFrame(input, frameIdx+1, frameWidth, overlap);

    prevType = SSC(frameT, nextFrameT, prevType);
    AACSeq3(frameIdx+1).frameType = prevType;
    AACSeq3(frameIdx+1).winType = winType;
    frameF = filterbank(frameT, prevType, winType);
    isESH = strcmp(prevType, 'ESH');
    if isESH
        frameFL = reshape(frameF(:, 1), [128, 8]);
        frameFR = reshape(frameF(:, 2), [128, 8]);
    else
        frameFL = frameF(:, 1);
        frameFR = frameF(:, 2);
    end
    [frameFL, AACSeq3(frameIdx+1).chl.TNScoeffs] = TNS(frameFL, prevType);
    [frameFR, AACSeq3(frameIdx+1).chr.TNScoeffs] = TNS(frameFR, prevType);
%
%     chs = {AACSeq3(frameIdx+1).chl, AACSeq3(frameIdx+1).chr};
%     frameFs = {frameFL, frameFR};
%     for chIdx = 1:2
%     ch = chs{chIdx};
%     frameF = frameFs{chIdx};

    SMR = psycho(frameT(:, 1), prevType, frameTprev1(:, 1), frameTprev2(:, 1));
    [S, sfc, AACSeq3(frameIdx+1).chl.G] = AACquantizer(frameFL, prevType, SMR);
    AACSeq3(frameIdx+1).chl.sfc = encodeHuff(sfc(:), huffLUT, 12);
    [AACSeq3(frameIdx+1).chl.stream, AACSeq3(frameIdx+1).chl.codebook] = encodeHuff(S, huffLUT);

    SMR = psycho(frameT(:, 2), prevType, frameTprev1(:, 2), frameTprev2(:, 2));
    [S, sfc, AACSeq3(frameIdx+1).chr.G] = AACquantizer(frameFR, prevType, SMR);
    AACSeq3(frameIdx+1).chr.sfc = encodeHuff(sfc(:), huffLUT, 12);
    [AACSeq3(frameIdx+1).chr.stream, AACSeq3(frameIdx+1).chr.codebook] = encodeHuff(S, huffLUT);
%     end
end

if exist('fnameAACoded', 'var')
    fprintf('Saving encoding in file %s.\n', fnameAACoded);
    save(fnameAACoded, 'AACSeq3');
end
end


function frameT = sliceFrame(array, idx, frameWidth, overlap)
% Frame with 50% overlaping.
frameStart = idx * frameWidth * overlap + 1;
frameEnd = frameStart + frameWidth - 1;
frameRange = frameStart:frameEnd;
frameT = array(frameRange,:);
end
