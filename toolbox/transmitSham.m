function reply = transmitSham(serialTPO)
%TRANSMITSHAM Start sham transmission
%
% DESCRIPTION:
%     transmitSham initiates the TPO output but with the signal generators
%     not started, and the amplitude modulation routines not activated.
%     This allows a sham condition (i.e., no output) to be used in scripts
%     without having to set the output power to zero.
%
% USAGE:
%     transmitSham(serialTPO)
%
% INPUTS:
%     serialTPO     - serial connection to the TPO
%
% OUTPUTS:
%     reply         - reply from TPO after setting parameter
%
% ABOUT:
%     author        - Bradley Treeby
%     date          - 20th November 2020
%     last update   - 20th November 2020
%
% Function based on code provided by Sonic Concepts.

% initiate sham TPO output
fprintf(serialTPO, 'sham');
reply = fscanf(serialTPO);

% check for error code
if strncmp(strip(reply), 'E', 1)
    error(['Transmission sham not succesful. TPO error code: ' reply]);
end
