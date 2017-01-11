function [SNR, bitrate, compression] = genericDemo(fNameIn, fNameOut, level, fnameAACoded)
%GENERICDEMO Summary of this function goes here
%   Detailed explanation goes here
%TODO

encodeFun = str2func(strcat('AACoder', num2str(level)));
decodeFun = str2func(strcat('iAACoder', num2str(level)));

fprintf('Encoding:');
tic;
if exist('fnameAACoded', 'var')
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
    bitsPerByte = 8;
    originalMetadata = dir(fNameIn);
    originalBytes = strcat(num2str(originalMetadata.bytes), ' bytes');
    originalBits = originalMetadata.bytes * bitsPerByte;
    compressedMetadata = dir(fnameAACoded);
    compressedSizeBytes = strcat(num2str(compressedMetadata.bytes), ' bytes');
    compressedSizeBits = compressedMetadata.bytes * bitsPerByte;
    compression = (compressedSizeBits / originalBits);
    compressionRatioTimes = originalBits / compressedSizeBits;
    bitrate = compressedSizeBits / (length(output) / fs);

    fprintf('Uncompressed audio: %s (%d bits).\n', originalBytes, originalBits);
    fprintf('Compressed struct : %s (%d bits).\n', compressedSizeBytes, compressedSizeBits);
    fprintf('Compression ratio : %f%% (x %f).\n', compression * 100, compressionRatioTimes);
    fprintf('Bitrate: %f kbits per second.\n', bitrate / 1000);
end

end
