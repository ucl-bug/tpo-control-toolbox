function reply = setPowerSingleElementTx(serialTPO, power)
%SETPOWER Set the output power of the TPO for a single element transducer.
%
% DESCRIPTION:
%     setPower sets the power of the first channel of the TPO in 1 mW
%     increments. Other channels are set to a power of 0. The maximum power
%     level is specified in getTPOSettings.
%
% USAGE:
%     reply = setPowerSingleElementTx(serialTPO, power)
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
%     date          - 20th February 2023
%     last update   - 20th February 2023
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

% loop over channels and set power
for channel_index = 1:settings.number_channels

    % only set power for first channel
    if channel_index == 1
        setPower = power;
    else
        setPower = 0;
    end

    % send command to the TPO (duplicate for all channels)
    fprintf(serialTPO, ['POWER' num2str(channel_index) '=' num2str(setPower)]);

    % check for reply
    reply = fscanf(serialTPO);

    % check for error code
    if strncmp(strip(reply), 'E', 1)
        error(['Power not set correctly. TPO error code: ' reply]);
    end
    
end
