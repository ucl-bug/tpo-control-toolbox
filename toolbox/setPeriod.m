function reply = setPeriod(serialTPO, period_length)
%SETPERIOD Set the period length of the TPO
%
% DESCRIPTION:
%     setPeriod sets the period length of the TPO in 10 microsecond
%     intervals.
%
% USAGE:
%     reply = setPeriod(serialTPO, period_length)
%
% INPUTS:
%     serialTPO     - serial connection to the TPO
%     period_length - length of the period in seconds
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
validateattributes(period_length, ...
    {'numeric'}, ...
    {'numel', 1, 'finite', 'positive'}, ...
    'setPeriod', 'period_length');

% convert the period length from seconds to microseconds, and round to
% nearest 10 microseconds
period_length = round(1e6 * period_length, -1);

% check the period length hasn't round to zero
if period_length == 0
    error('Period length must be 1e-5 or greater.');
end

% send command to the TPO
fprintf(serialTPO, ['PERIOD=' num2str(period_length)]);

% check for reply
reply = fscanf(serialTPO);

% check for error code
if strncmp(strip(reply), 'E', 1)
    error(['Period length not set correctly. TPO error code: ' reply]);
end
