function reply = setFocus(serialTPO, focus)
%SETFOCUS Set the focal distance on the TPO
%
% DESCRIPTION:
%     setFocus sets the focal distance ("Focus" value on the front screen).
%
% USAGE:
%     reply = setFocus(serialTPO, focus)
%
% INPUTS:
%     serialTPO     - serial connection to the TPO
%     focus         - focus value in m
%
% OUTPUTS:
%     reply         - reply from TPO after setting parameter
%
% ABOUT:
%     author        - Bradley Treeby
%     date          - 3rd July 2023
%     last update   - 3rd July 2023
%
% Function based on code provided by Sonic Concepts.

% check input
settings = getTPOSettings;
validateattributes(focus, {'numeric'}, ...
    {'numel', 1, 'finite', 'nonnegative', '>=', settings.minimum_focus, '<=', settings.maximum_focus}, ...
    'setFocus', 'focus');

% convert to um and round to nearest 0.1 mm
focus = round(focus * 1e6, -2);

% send command to the TPO
fprintf(serialTPO, ['FOCUS=' num2str(focus)]);

% check for reply
reply = fscanf(serialTPO);

% check for error code
if strncmp(strip(reply), 'E', 1)
    error(['Frequency not set correctly. TPO error code: ' reply]);
end
