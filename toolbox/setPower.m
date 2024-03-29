function reply = setPower(serialTPO, power)
%SETPOWER Set the output power of the TPO
%
% DESCRIPTION:
%     setPower sets the power of the TPO in 1 mW increments. All channels
%     are set to equal values. The maximum power level is specified in
%     getTPOSettings.
%
% USAGE:
%     reply = setPower(serialTPO, power)
%
% INPUTS:
%     serialTPO     - serial connection to the TPO
%     power         - electrical power value in watts
%
% OUTPUTS:
%     reply         - reply from TPO after setting parameter
%
% ABOUT:
%     author        - Bradley Treeby
%     date          - 18th November 2019
%     last update   - 3rd July 2023
%
% Function based on code provided by Sonic Concepts.

% check input
settings = getTPOSettings;
validateattributes(power, ...
    {'numeric'}, ...
    {'numel', 1, 'finite', 'nonnegative', '<=', settings.maximum_power_value}, ...
    'setPower', 'power');

% convert the power from watts to milliwatts, and round to the nearest
% milliwatt
power = round(1e3 * power);

% send command to the TPO
fprintf(serialTPO, ['GLOBALPOWER=' num2str(power)]);

% check for reply
reply = fscanf(serialTPO);

% check for error code
if strncmp(strip(reply), 'E', 1)
    error(['Power not set correctly. TPO error code: ' reply]);
end
