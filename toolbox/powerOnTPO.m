function powerOnTPO(serialTPO, power_level)
%POWERONTPO Turn TPO power on to predefined power level
%
% DESCRIPTION:
%     powerOnTPO sets the power level of the TPO to a predefined power
%     level, or to a fraction (<1) of this predefined level. Using this
%     function within scripts avoids errors with settings the maximum power
%     level, as the power value is only defined once within this function.
%     Change the value of tpo_maximum_power to change the power set by
%     power_level = 1.
%
% USAGE:
%     powerOnTPO(serialTPO, power_level)
%
% INPUTS:
%     serialTPO     - serial connection to the TPO
%
% OPTIONAL INPUTS:
%     power_level   - value between 0 and 1 used to scale the max power
%                     (defaul = 1).
%
% OUTPUTS:
%     reply         - reply from TPO after setting parameter
%
% ABOUT:
%     author        - Bradley Treeby
%     date          - 1st November 2019
%     last update   - 20th Novemer 2020

% maximum setting for TPO power in W
tpo_maximum_power = 4.78;

% check for user defined power level setting
if nargin < 2
    power_level = 1;
else
    validateattributes(power_level, ...
        {'numeric'}, ...
        {'numel', 1, 'nonnegative', '>=', 0, '<=', 1}, ...
        'tpoPowerOn', 'power_level');
end
    
% apply scaling and truncate to required precision (value is truncated to
% the correct precision within setPower)
tpoPower = power_level * tpo_maximum_power;

% idiot check
if tpoPower > tpo_maximum_power
    error('Power level set greater than 1.');
end

% set power (always set power after frequency or you may limit TPO)
setPower(serialTPO, tpoPower); 

% seting the ultrasound power has a time constant of ~50-70ms, so wait for
% a bit
pause(0.2);
