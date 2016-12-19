function assertIsWinType(string, message)
%ASSERTISWINTYPE Assertion that given type is either 'KBD' or 'SIN'.

if ~exist('message', 'var')
    message = 'Invalid window type';
end
assert(any(strcmp(string, {'KBD', 'SIN'})), message);
end
