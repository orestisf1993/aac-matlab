function frameF = iAACquantizer(S, sfc, G, frameType)
%IAACQUANTIZER IAACQUANTIZER Dequantize channel.
%   FRAMEF = IAACQUANTIZER(S, SFC, G, FRAMETYPE) will dequantize the MDCT symbols S according to
%   scalefactor coefficients SFC and frame type FRAMETYPE. The dequantized frame is FRAMEF.
%
%   See also AACQUANTIZER

%% Validate input.
assertIsFrameType(frameType);
assert(all(G == sfc(1, :)), 'sfc does not start with G.');

%% Initialize.
bands = initBands(frameType);
isESH = strcmp(frameType, 'ESH');
NSubFrames = 1 + isESH * 7;
frameFSize = [1024 / NSubFrames, NSubFrames];
frameF = zeros(frameFSize);

%% Loop through each frame.
for idx = 1:NSubFrames
    a = cumsum(sfc(:, idx));
    a = bandStretch(a, [1024 / NSubFrames, 1], bands);
    frameF(:, idx) = deQuantize(S(:, idx), a);
end

%% Validate output.
assertMDCTSize(frameF, frameType);
end
