function assertIsFrameType(string, message)
%ASSERTISFRAMETYPE Assertion that given type is one of 'OLS', 'LSS', 'ESH',
%'LPS'.
if ~exist('message', 'var')
    message = 'Wrong frame type';
end
assert(any(strcmp(string, {'OLS', 'LSS', 'ESH', 'LPS'})), message);
end
