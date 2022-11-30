function powerOffTPO(serialTPO)
%POWEROFFTPO Turn TPO power off
%
% DESCRIPTION:
%     powerOffTPO sets the power level of the TPO to zero. Using this
%     function within scripts avoids errors with settings the power
%     level. 
%
% USAGE:
%     powerOffTPO(serialTPO)
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

% set power (always set power after frequency or you may limit TPO)
setPower(serialTPO, 0);
