function x = iAACoder2(AACSeq2, fNameOut)
%IAACODER2 AAC decoder for Level 2.
%   X = IAACODER2(AACSEQ2, FNAMEOUT) will decode aac sequence AACSEQ2 and save the
%   output on file FNAMEOUT. X, if present, will contain the decoded sequence.
%
%   See also AACODER2, IAACODER1, ITNS, DEMOAAC1.

lengthAAC = length(AACSeq2);
decodedLength = (lengthAAC + 1) * 1024;
decoded = zeros(decodedLength, 2);

for i = 1:lengthAAC
    frameFL = iTNS(AACSeq2(i).chl.frameF, AACSeq2(i).frameType, AACSeq2(i).chl.TNScoeffs);
    frameFR = iTNS(AACSeq2(i).chr.frameF, AACSeq2(i).frameType, AACSeq2(i).chr.TNScoeffs);
    isESH = strcmp(AACSeq2(i).frameType, 'ESH');
    if isESH
        frameFL = reshape(frameFL, [1024, 1]);
        frameFR = reshape(frameFR, [1024, 1]);
    end
    frameF = [frameFL, frameFR];
    frameT = iFilterbank(frameF, AACSeq2(i).frameType, AACSeq2(i).winType);

    decodedRange = (i - 1) * 1024 + 1:(i + 1) * 1024;
    decoded(decodedRange,:) = decoded(decodedRange,:) + frameT(1:2048,:);
end

fs = 48000; % Frequency defined by assignment.
audiowrite(fNameOut, decoded, fs);

if nargout == 1
    x = decoded;
end
end
