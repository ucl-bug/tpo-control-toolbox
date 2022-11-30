function reply = setRampLength(serialTPO, ramp_length)
%SETRAMPLENGTH Set the ramp length of the TPO
%
% DESCRIPTION:
%     setRampLength sets the length of the ramp up/down in seconds. Both
%     channels are set to equal values. The burst length needs to be at
%     least 2x the ramplength to ensure the ramp will be fully executed.
%     The number of points in the ramp is proportional to ramp_length /
%     10e-6 (the resolution is 10 us).
%
% USAGE:
%     reply = setRampLength(serialTPO, ramp_length)
%
% INPUTS:
%     serialTPO     - serial connection to the TPO
%     ramp_length   - ramp length in seconds
%
% OUTPUTS:
%     reply         - reply from TPO after setting parameter
%
% ABOUT:
%     author        - Bradley Treeby & Elly Martin
%     date          - 17th September 2020
%     last update   - 9th October 2020
%
% Function based on code provided by Sonic Concepts.

% set literals
minimum_ramp_length = 10e-6;
maximum_ramp_length = 20000e-6;

% check input
validateattributes(ramp_length, ...
    {'numeric'}, ...
    {'numel', 1, 'finite', 'nonnegative', '>=', minimum_ramp_length, '<=', maximum_ramp_length}, ...
    'setRampLength', 'ramp_length');

% convert the timer length from seconds to microseconds, and round to
% nearest 10 microseconds
ramp_length = round(1e6 * ramp_length, -1);

% send command to the TPO 
fprintf(serialTPO, ['ramplength=' num2str(ramp_length)]);

% check for reply
reply = fscanf(serialTPO);

% check for error code
if strncmp(strip(reply), 'E', 1)
    error(['Ramp length not set correctly. TPO error code: ' reply]);
end
