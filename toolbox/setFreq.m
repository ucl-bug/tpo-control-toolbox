function reply = setFreq(serialTPO, frequency)
%SETFREQUENCY Set the transmit frequency of the TPO
%
% DESCRIPTION:
%     setFrequency sets the transmit frequency of the TPO in 1 Hz
%     increments. All channels are set to equal values. The number of
%     channels and minimum and maximum frequency values are defined in
%     getTPOSettings.
%
% USAGE:
%     reply = setFreq(serialTPO, frequency)
%
% INPUTS:
%     serialTPO     - serial connection to the TPO
%     frequency     - transmit frequency in Hz
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
validateattributes(frequency, ...
    {'numeric'}, ...
    {'numel', 1, 'finite', 'nonnegative', '>=', settings.minimum_frequency, '<=', settings.maximum_frequency}, ...
    'setFrequency', 'frequency');

% round to the nearest Hz
frequency = round(frequency);

% send command to the TPO
fprintf(serialTPO, ['GLOBALFREQ=' num2str(frequency)]);

% check for reply
reply = fscanf(serialTPO);

% check for error code
if strncmp(strip(reply), 'E', 1)
    error(['Frequency not set correctly. TPO error code: ' reply]);
end
