function reply = armTransmit(serialTPO)
%ARMTRANSMIT Arm system ready for transmission
%
% DESCRIPTION:
%     armTransmit arms the TPO to wait for the next character to come into
%     the serial parser. The moment the next character is received, the TPO
%     will then act as if a "START" command was executed. This gives a much
%     faster response time and less timing variance compared to calling
%     transmitStart.
%
% USAGE:
%     armTransmit(serialTPO);       % arm the TPO
%     fprintf(serialTPO, '\r');     % trigger transmit
%
% INPUTS:
%     serialTPO     - serial connection to the TPO
%
% OUTPUTS:
%     reply         - reply from TPO after setting parameter
%
% ABOUT:
%     author        - Bradley Treeby
%     date          - 4th December 2020
%     last update   - 4th December 2020
%
% Function based on code provided by Sonic Concepts.

% initiate sham TPO output
fprintf(serialTPO, 'ARM');
reply = fscanf(serialTPO);

% check for error code
if strncmp(strip(reply), 'E', 1)
    error(['Arm transmit not succesful. TPO error code: ' reply]);
end
