function x = iAACoder1(AACSeq1, fNameOut)
%IAACODER1 AAC decoder for Level 1.
%   X = IAACODER1(AACSEQ1, FNAMEOUT) will decode aac sequence AACSEQ1 and save the
%   output on file FNAMEOUT. X, if present, will contain the decoded sequence.
%
%   See also AACODER1, SSC, IFILTERBANK, DEMOAAC1.

frameWidth = 2048;
lengthAAC = length(AACSeq1);
decodedLength = (lengthAAC + 1) * 1024;
decoded = zeros(decodedLength, 2);

for i = 1:lengthAAC
    frameF = [AACSeq1(i).chl.frameF, AACSeq1(i).chr.frameF];
    frameT = iFilterbank(frameF, AACSeq1(i).frameType, AACSeq1(i).winType);

    decodedRange = (i - 1) * 1024 + 1:(i + 1) * 1024;
    decoded(decodedRange,:) = decoded(decodedRange,:) + frameT(1:2048,:);
end

%% Remove padded zeros.
N = length(decoded);
decoded = decoded(frameWidth/2+1:end-frameWidth/2, :);
assert(length(decoded) == N - frameWidth);


%% Save results.
fs = 48000; % Frequency defined by assignment.
audiowrite(fNameOut, decoded, fs);

if nargout == 1
    x = decoded;
end
end
