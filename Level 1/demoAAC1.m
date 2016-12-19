function SNR = demoAAC1(fNameIn, fNameOut)
%DEMOAAC1 Demo of the AAC encoder & decoder.
%   SNR = DEMOAAC1(FNAMEIN, FNAMEOUT) reads the files named FNAMEIN and FNAMEOUT and
%   performs the AAC encoding and decodign. SNR is the signal to noise ratio of the operation.

fprintf('Encoding:');
tic;
AACSeq = AACoder1(fNameIn);
toc;

fprintf('Decoding:');
tic;
output = iAACoder1(AACSeq, fNameOut);
toc;

input = audioread(fNameIn);
% output = audioread(fNameOut);

common_length = min(length(input), length(output));
input = input(1:common_length, :);
output = output(1:common_length, :);
noise = input - output;

SNR = snr(input, noise);
fprintf('Level 1: SNR for channel 1: %g.\n', snr(input(:, 1), noise(:, 1)));
fprintf('Level 1: SNR for channel 2: %g.\n', snr(input(:, 2), noise(:, 2)));
end
