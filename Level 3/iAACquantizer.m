function frameF = iAACquantizer(S, sfc, G, frameType)
%IAACQUANTIZER IAACQUANTIZER Dequantize channel.
%   FRAMEF = IAACQUANTIZER(S, SFC, G, FRAMETYPE) will dequantize the MDCT symbols S according to
%   scalefactor coefficients SFC and frame type FRAMETYPE. The dequantized frame is FRAMEF.
%
%   See also AACQUANTIZER

%% Validate input.
assertIsFrameType(frameType);
assert(G == sfc(1), 'sfc does not start with G.');

%%
bands = initBands();
a = cumsum(sfc);
a = bandStretch(a, size(S), bands);
frameF = deQuantize(S, a);

%% Validate output.
%TODO
end
