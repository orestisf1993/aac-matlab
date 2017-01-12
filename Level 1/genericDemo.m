function [SNR, bitrate, compression] = genericDemo(fNameIn, fNameOut, level, fnameAACoded, useDirOnCompressed)
%GENERICDEMO Generic demo code for all 3 levels of the project.
%   SNR = GENERICDEMO(FNAMEIN, FNAMEOUT, LEVEL) will encode audio file FNAMEIN with AAC of level
%   LEVEL and save the output in FNAMEOUT. SNR is the signal to noise ratio.
%   GENERICDEMO(FNAMEIN, FNAMEOUT, LEVEL, FNAMEAACODED) will save the AAC structure in FNAMEAACODED.
%   Only for level 3.
%   [SNR, BITRATE, COMPRESSION] = GENERICDEMO(FNAMEIN, FNAMEOUT, LEVEL) will also return the bitrate
%   BITRATE and the compression rate (compressed size / original size) COMPRESSION. Only for level
%   3.
%
%   See also DEMOAAC1, DEMOAAC2, DEMOAAC3.

assert(any(level == [1, 2, 3]), 'Unsupported level.');

encodeFun = str2func(strcat('AACoder', num2str(level)));
decodeFun = str2func(strcat('iAACoder', num2str(level)));

%% Encode.
fprintf('Encoding:');
tic;
if exist('fnameAACoded', 'var')
    assert(level == 3, 'fnameAACoded supported only by level 3.');
    AACSeq = encodeFun(fNameIn, fnameAACoded);
else
    AACSeq = encodeFun(fNameIn);
end
toc;

%% Decode.
fprintf('Decoding:');
tic;
output = decodeFun(AACSeq, fNameOut);
toc;

[input, fs] = audioread(fNameIn);
% output = audioread(fNameOut);

%% Calculate noise and SNR.
common_length = min(length(input), length(output));
input = input(1:common_length,:);
output = output(1:common_length,:);
noise = input - output;

SNR = snr(input, noise);

%% Results.
fprintf('Level %d: SNR for channel 1: %g.\n', level, snr(input(:, 1), noise(:, 1)));
fprintf('Level %d: SNR for channel 2: %g.\n', level, snr(input(:, 2), noise(:, 2)));
if level >= 3
    if ~exist('useDirOnCompressed', 'var')
        useDirOnCompressed = false;
    end

    bitsPerByte = 8;
    originalMetadata = dir(fNameIn);
    originalBytes = strcat(num2str(originalMetadata.bytes), ' bytes');
    originalBits = originalMetadata.bytes * bitsPerByte;
    if useDirOnCompressed
        compressedMetadata = dir(fnameAACoded);
        compressedSizeBytes = strcat(num2str(compressedMetadata.bytes), ' bytes');
        compressedSizeBits = compressedMetadata.bytes * bitsPerByte;
    else
        compressedSizeBits = 0;
        bytesPerDouble = 8;
        bitsPerDouble = bytesPerDouble * bitsPerByte;
        bytesPerInt = 4;
        bitsPerInt = bytesPerInt * bitsPerByte;
        for idx = 1:length(AACSeq)
            compressedSizeBits = compressedSizeBits ...
                +numel(AACSeq(idx).chl.sfc) ...
                + numel(AACSeq(idx).chr.sfc) ...
                + numel(AACSeq(idx).chl.stream) ...
                + numel(AACSeq(idx).chr.stream) ...
                + (numel(AACSeq(idx).chl.TNScoeffs) + 1) * bitsPerDouble ...
                + (numel(AACSeq(idx).chr.TNScoeffs) + 1) * bitsPerDouble ...
                + numel(AACSeq(idx).chl.codebook) * bitsPerInt ...
                + numel(AACSeq(idx).chr.codebook) * bitsPerInt ...
                + 2 + 1;
        end
        compressedSizeBytes = strcat(num2str(compressedSizeBits*bitsPerByte), ' bytes');
    end

    compression = (compressedSizeBits / originalBits);
    compressionRatioTimes = originalBits / compressedSizeBits;
    bitrate = compressedSizeBits / (length(output) / fs);

    fprintf('Uncompressed audio: %s (%d bits).\n', originalBytes, originalBits);
    fprintf('Compressed struct : %s (%d bits).\n', compressedSizeBytes, compressedSizeBits);
    fprintf('Compression ratio : %f%% (x %f).\n', compression*100, compressionRatioTimes);
    fprintf('Bitrate: %f kbits per second.\n', bitrate/1000);
end

end
