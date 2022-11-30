function reply = setControlMode(serialTPO, control_mode)
%SETCONTROLMODE Set control mode of the TPO
%
% DESCRIPTION:
%     setControlMode sets the TPO into either remote control mode (0) or
%     local control mode (1).
%
% USAGE:
%     reply = setPeriod(serialTPO, period_length)
%
% INPUTS:
%     serialTPO     - serial connection to the TPO
%     control_mode  - contrl mode, where
%                         0: Remote mode (TPO is controlled remotely)
%                         1: Local mode (TPO is controlled via front face)
%
% OUTPUTS:
%     reply         - reply from TPO after setting parameter
%
% ABOUT:
%     author        - Bradley Treeby
%     date          - 24th October 2019
%     last update   - 30th November 2022
%
% Function based on code provided by Sonic Concepts.

% check input
validateattributes(control_mode, ...
    {'numeric'}, ...
    {'numel', 1, 'integer', '>=', 0, '<=', 1}, ...
    'setLocal', 'local')

% send command to the TPO
fprintf(serialTPO, ['LOCAL=' num2str(control_mode)]);

% check for reply
reply = fscanf(serialTPO);

% check for error code
if strncmp(strip(reply), 'E', 1)
    error(['Period length not set correctly. TPO error code: ' reply]);
end
