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

fprintf('Decoding:');
tic;
output = decodeFun(AACSeq, fNameOut);
toc;

input = audioread(fNameIn);
% output = audioread(fNameOut);

common_length = min(length(input), length(output));
input = input(1:common_length,:);
output = output(1:common_length,:);
noise = input - output;

SNR = snr(input, noise);
fprintf('Level %d: SNR for channel 1: %g.\n', level, snr(input(:, 1), noise(:, 1)));
fprintf('Level %d: SNR for channel 2: %g.\n', level, snr(input(:, 2), noise(:, 2)));
if level >= 3 && nargout > 1
    bitrate = 1;%TODO
    compression = 1;%TODO
end

end
