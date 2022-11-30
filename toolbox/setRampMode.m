function reply = setRampMode(serialTPO, ramp_mode)
%SETRAMPMODE Set the ramp mode of the TPO
%
% DESCRIPTION:
%     setRampMode sets the mode of the ramp up/down of 
%     the TPO pulse. 
%
% USAGE:
%     reply = setRampMode(serialTPO, ramp_mode)
%
% INPUTS:
%     serialTPO     - serial connection to the TPO
%     ramp_mode     - ramp mode: 
%                         0 = no ramp
%                         1 = linear ramp
%                         2 = Tukey ramp
%                         3 = log ramp
%                         4 = exp ramp
%
% OUTPUTS:
%     reply         - reply from TPO after setting parameter
%
% ABOUT:
%     author        - Bradley Treeby & Elly Martin
%     date          - 17th September 2020
%     last update   - 17th September 2020
%
% Function based on code provided by Sonic Concepts.

% set literals
minimum_ramp_mode = 0;
maximum_ramp_mode = 4;

% check input
validateattributes(ramp_mode, ...
    {'numeric'}, ...
    {'numel', 1, 'finite', 'integer', 'nonnegative', '>=', minimum_ramp_mode, '<=', maximum_ramp_mode}, ...
    'setRampMode', 'ramp_mode');

% send command to the TPO 
fprintf(serialTPO, ['rampmode=' num2str(ramp_mode)]);

% check for reply
reply = fscanf(serialTPO);

% % display reply
% disp(['TPO reply to set ramp length = ' reply]);

% check for error code
if strncmp(strip(reply), 'E', 1)
    error(['Ramp mode not set correctly. TPO error code: ' reply]);
end
