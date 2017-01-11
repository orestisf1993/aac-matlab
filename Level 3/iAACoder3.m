function x = iAACoder3(AACSeq3, fNameOut)
%IAACODER3 AAC decoder for Level 3.
%   X = IAACODER3(AACSEQ2, FNAMEOUT) will decode aac sequence AACSEQ3 and save the
%   output on file FNAMEOUT. X, if present, will contain the decoded sequence.
%
%   See also AACODER3, IAACODER2, DEMOAAC2.

frameWidth = 2048;
lengthAAC = length(AACSeq3);
decodedLength = (lengthAAC + 1) * 1024;
decoded = zeros(decodedLength, 2);
huffLUT = loadLUT();
for frameIdx = 1:lengthAAC
    frameType = AACSeq3(frameIdx).frameType;
    isESH = strcmp(frameType, 'ESH');

    chs = {AACSeq3(frameIdx).chl, AACSeq3(frameIdx).chr};
    frameFs = cell(1, 2);
    for chIdx = 1:2
        ch = chs{chIdx};

        sfc = decodeHuff(ch.sfc, 12, huffLUT);
        S = decodeHuff(ch.stream, ch.codebook, huffLUT);
        if isESH
            sfc = reshape(sfc, [42, 8]);
            S = reshape(S, [128, 8]);
        else
            sfc = reshape(sfc, [69, 1]);
            S = reshape(S, [1024, 1]);
        end
        frameFs{chIdx} = iAACquantizer(S, sfc, ch.G, frameType);
    end

    frameFs{1} = iTNS(frameFs{1}, AACSeq3(frameIdx).frameType, AACSeq3(frameIdx).chl.TNScoeffs);
    frameFs{2} = iTNS(frameFs{2}, AACSeq3(frameIdx).frameType, AACSeq3(frameIdx).chr.TNScoeffs);
    if isESH
        frameFs{1} = reshape(frameFs{1}, [frameWidth / 2, 1]);
        frameFs{2} = reshape(frameFs{2}, [frameWidth / 2, 1]);
    end
    frameF = [frameFs{1}, frameFs{2}];
    frameT = iFilterbank(frameF, AACSeq3(frameIdx).frameType, AACSeq3(frameIdx).winType);

    decodedRange = (frameIdx - 1) * frameWidth / 2 + 1:(frameIdx + 1) * frameWidth / 2;
    decoded(decodedRange,:) = decoded(decodedRange,:) + frameT(1:frameWidth,:);
end

%% Remove padded zeros.
N = length(decoded);
decoded = decoded(frameWidth/2+1:end-frameWidth/2,:);
assert(length(decoded) == N-frameWidth);


%% Save results.
fs = 48000; % Frequency defined by assignment.
audiowrite(fNameOut, decoded, fs);

if nargout == 1
    x = decoded;
end
end
