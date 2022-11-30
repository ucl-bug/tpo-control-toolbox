function reply = setTimer(serialTPO, timer_length)
%SETTIMER Set the timer length of the TPO
%
% DESCRIPTION:
%     setTimer sets the timer length of the TPO in 10 microsecond
%     intervals. Setting the timer to zero turns the TPO on indefinitely.
%
% USAGE:
%     reply = setTimer(serialTPO, timer_length)
%
% INPUTS:
%     serialTPO     - serial connection to the TPO
%     timer_length  - length of the timer in seconds
%
% OUTPUTS:
%     reply         - reply from TPO after setting parameter
%
% ABOUT:
%     author        - Bradley Treeby
%     date          - 18th November 2019
%     last update   - 18th November 2019
%
% Function based on code provided by Sonic Concepts.

% check input
validateattributes(timer_length, ...
    {'numeric'}, ...
    {'numel', 1, 'finite', 'nonnegative'}, ...
    'setTimer', 'timer_length');

% convert the timer length from seconds to microseconds, and round to
% nearest 10 microseconds
timer_length = round(1e6 * timer_length, -1);

% send command to the TPO
fprintf(serialTPO, ['TIMER=' num2str(timer_length)]);

% check for reply
reply = fscanf(serialTPO);

% check for error code
if strncmp(strip(reply), 'E', 1)
    error(['Timer length not set correctly. TPO error code: ' reply]);
end
