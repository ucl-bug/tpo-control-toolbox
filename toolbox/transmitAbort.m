function reply = transmitAbort(serialTPO)
%TRANSMITABORT Abort transmission
%
% DESCRIPTION:
%     transmitStart stops/aborts the TPO output, equivalent to pressing the
%     start/stop button on the TPO.
%
% USAGE:
%     transmitStop(serialTPO)
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

% stop TPO output
fprintf(serialTPO, 'ABORT');
reply = fscanf(serialTPO);

% check for error code
if strncmp(strip(reply), 'E', 1)
    error(['Transmission abort not succesful. TPO error code: ' reply]);
end
