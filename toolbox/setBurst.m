function reply = setBurst(serialTPO, burst_length)
%SETBURST Set the burst length of the TPO
%
% DESCRIPTION:
%     setBurst sets the burst length of the TPO in 10 microsecond
%     intervals.
%
% USAGE:
%     reply = setBurst(serialTPO, burst_length)
%
% INPUTS:
%     serialTPO     - serial connection to the TPO
%     burst_length  - length of the burst in seconds
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
validateattributes(burst_length, ...
    {'numeric'}, ...
    {'numel', 1, 'finite', 'positive'}, ...
    'setBurst', 'burst_length');

% convert the burst length from seconds to microseconds, and round to
% nearest 10 microseconds
burst_length = round(1e6 * burst_length, -1);

% check the burst length hasn't round to zero
if burst_length == 0
    error('Burst length must be 1e-5 or greater.');
end

% send command to the TPO
fprintf(serialTPO, ['BURST=' num2str(burst_length)]);

% check for reply
reply = fscanf(serialTPO);

% check for error code
if strncmp(strip(reply), 'E', 1)
    error(['Burst length not set correctly. TPO error code: ' reply]);
end
