function frameType = SSC(frameT, nextFrameT, prevFrameType)
%SSC Sequence Segmentation Control step.
%   SSC(FRAMET, NEXTFRAMET, PREVFRAMETYPE) is the frame type for the i-th frame
%   FRAMET which has NEXTFRAMET as it's next frame and PREVFRAMETYPE as it's
%   previous frame type.
%   Frame type is one of 4 string values:
%   - 'OLS': ONLY_LONG_SEQUENCE
%   - 'LSS': LONG_START_SEQUENCE
%   - 'ESH': EIGHT_SHORT_SEQUENCE
%   - 'LPS': LONG_STOP_SEQUENCE

%% Check input validity.
% Check prevFrameType in acceptable values.
assertIsFrameType(prevFrameType, 'invalid prevFrameType');
assertIsFullFrame(frameT, 'invalid frameT size');
assertIsFullFrame(nextFrameT, 'invalid frameT size');

%% Instantly return result for ESH, LPS.
if strcmp(prevFrameType, 'LSS')
    frameType = 'ESH';
    return;
elseif strcmp(prevFrameType, 'LPS')
    frameType = 'OLS';
    return;
end

%% Check (i + 1)-th frame type.
isESH1 = nextFrameIsESH(nextFrameT(:, 1));
isESH2 = nextFrameIsESH(nextFrameT(:, 2));

%% Current frame type.
type1 = typeFromAdjacent(isESH1, prevFrameType);
type2 = typeFromAdjacent(isESH2, prevFrameType);
map = decisionTable();
key = strcat(type1, '-', type2);
frameType = map(key);

%% Check output.
assertIsFrameType(frameType, 'invalid frameType result');
end


function isESH = nextFrameIsESH(frame)
%% 1. Filter nextFrameT with a highpass filter.
frame = filterFrame(frame);

%% 2. Energy of each area.
% We will split nextFrameT in 8 equal areas: starting from 576 to 1600 with
% length of 128.
energyIdx = reshape(577:1600, [128, 8]);
s2 = sum(frame(energyIdx).^2, 1);

%% 3. Attack values.
ds2 = zeros(size(s2));
for idx = 2:length(ds2)
    meanPreviousEnergy = sum(s2(1:idx-1)) / idx;
    ds2(idx) = s2(idx) / meanPreviousEnergy;
end

%% 4. Check for ESH conditions.
isESH = any((s2 > 1e-3) & (ds2 > 10));
end


function frameType = typeFromAdjacent(nextIsESH, previousType)
switch previousType
    case 'OLS'
        if nextIsESH
            frameType = 'LSS';
        else
            frameType = 'OLS';
        end
    case 'ESH'
        if nextIsESH
            frameType = 'ESH';
        else
            frameType = 'LPS';
        end
    otherwise
        error('Code should not reach this point.');
end
end


function map = decisionTable()
keys = cell(1, 16);
idx = 1;
types = {'OLS', 'LSS', 'ESH', 'LPS'};
for key1 = types
    for key2 = types
        cat = strcat(key1, '-', key2);
        keys{idx} = cat{:}; % strcat result here is a 1x1 cell array.
        idx = idx + 1;
    end
end
values = {'OLS', 'LSS', 'ESH', 'LPS', 'LSS', 'LSS', 'ESH', 'ESH', 'ESH', 'ESH', 'ESH', 'ESH', 'LPS', 'ESH', 'ESH', 'LPS'};

map = containers.Map(keys, values);
end


function frame = filterFrame(frame)
% filter(b, a, x) uses a rational transfer function.
% https://www.mathworks.com/help/matlab/ref/filter.html#buagwwg-2
% We will be using H(z) = (0.7548 - 0.7548 z ^ -1) / (1 - 0.5095 z ^ -1) to
% filter nextFrameT.
b = [0.7548, -0.7548];
a = [1, -0.5095];
frame = filter(b, a, frame);
end
