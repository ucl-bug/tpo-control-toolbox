function reply = setTriggerMode(serialTPO, trigger_mode)
%SETTIMER Set the trigger mode of the TPO
%
% DESCRIPTION:
%     setTriggerMode sets the trigger mode of the TPO, where 0 is off, 1 is
%     standard, and 2 is high-speed.
%
% USAGE:
%     reply = setTriggerMode(serialTPO, trigger_mode)
%
% INPUTS:
%     serialTPO     - serial connection to the TPO
%     trigger_mode  - trigger mode
%
% OUTPUTS:
%     reply         - reply from TPO after setting parameter
%
% ABOUT:
%     author        - Bradley Treeby
%     date          - 9th October 2020
%     last update   - 9th October 2020
%
% Function based on code provided by Sonic Concepts.

% check input
validateattributes(trigger_mode, ...
    {'numeric'}, ...
    {'numel', 1, 'integer', '>=', 0, '<=', 2}, ...
    'setTriggerMode', 'trigger_mode');

% send command to the TPO
fprintf(serialTPO, ['TRIGGERMODE=' num2str(trigger_mode)]);

% check for reply
reply = fscanf(serialTPO);

% check for error code
if strncmp(strip(reply), 'E', 1)
    error(['Trigger mode not set correctly. TPO error code: ' reply]);
end
