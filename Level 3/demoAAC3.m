function [SNR, bitrate, compression] = demoAAC3(fNameIn, fNameOut, fnameAACoded)
%DEMOAAC3 Demo of the level 3 AAC encoder & decoder.
%   [SNR, BITRATE, COMPRESSION] = DEMOAAC1(FNAMEIN, FNAMEOUT, FNAMEAACODED) reads the files named
%   FNAMEIN and FNAMEOUT and performs the AAC encoding and decoding. SNR is the signal to noise
%   ratio of the operation.

[SNR, bitrate, compression] = genericDemo(fNameIn, fNameOut, 3, fnameAACoded);
end
