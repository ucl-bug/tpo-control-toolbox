function reply = setPhase(serialTPO, channel, phase)
%SETPHASE Set the output phase of the TPO channels
%
% DESCRIPTION:
%     setPhase sets the phase of the specified TPO channel.
%
% USAGE:
%     reply = setPhase(serialTPO, channel, phase)
%
% INPUTS:
%     serialTPO     - serial connection to the TPO
%     channel       - TPO channel to set
%     phase         - channel phase in degrees
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

% check inputs
validateattributes(channel, ...
    {'numeric'}, ...
    {'numel', 1, 'positive', 'integer'}, ...
    'setPhase', 'channel');
validateattributes(phase, ...
    {'numeric'}, ...
    {'numel', 1, 'finite'}, ...
    'setPhase', 'phase');

% wrap the phase to between 0 and 360 degrees
while phase < 0
    phase = phase + 360;
end
while phase >= 360
    phase = phase - 360;
end

% convert the phase to 0.1 of a degree increments
phase = round(phase * 10, 0);

% send command to the TPO
fprintf(serialTPO, ['PHASE' num2str(channel) '=' num2str(phase)]);

% check for reply
reply = fscanf(serialTPO);

% check for error code
if strncmp(strip(reply), 'E', 1)
    error(['Phase not set correctly. TPO error code: ' reply]);
end
