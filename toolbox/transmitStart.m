function reply = transmitStart(serialTPO)
%TRANSMITSTART Start transmission
%
% DESCRIPTION:
%     transmitStart initiates the TPO output, equivalent to pressing the
%     start/stop button on the TPO.
%
% USAGE:
%     transmitStart(serialTPO)
%
% INPUTS:
%     serialTPO     - serial connection to the TPO
%
% OUTPUTS:
%     reply         - reply from TPO after setting parameter
%
% ABOUT:
%     author        - Bradley Treeby
%     date          - 1st November 2019
%     last update   - 20th November 2020
%
% Function based on code provided by Sonic Concepts.

% initiate TPO output
fprintf(serialTPO, 'START');
reply = fscanf(serialTPO);

% check for error code
if strncmp(strip(reply), 'E', 1)
    error(['Transmission start not succesful. TPO error code: ' reply]);
end
