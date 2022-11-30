% Script to run experiment 3 of the auditory artefact study.
%
% KEY  PRF      DURAT   RAMP        MASK        TRIALS
%   0: sham     -       -           -           30 trials
%   1: -        150 ms  -           -           10 trials
%   2: -        150 ms  20 ms       -           10 trials
%
% author: Bradley Treeby
% date:  20th November 2020
% last update: 19th May 2021

% clear the workspace and the screen
close all;
clear all; %#ok<CLALL>

% =========================================================================
% DEFINE LITERALS
% =========================================================================

% number of repeats of each condition (there are four active conditions)
active_repeats = 10;
num_active_conditions = 2;
sham_repeats = 20;

% duration between stimulation [s]
wait_time = 3;

% transducer parameters
xdrCenterFreq = 270e3;      % in Hertz
xdrPhaseElem1 = 0;          % in degrees
xdrPhaseElem2 = 66.3;       % in degrees

% power scaling factor
power_scaling = 1;

% initialise with no ramp (no pulsing)
tpoBurstLength  = 150e-3;         % in seconds
tpoBurstPeriod  = 150e-3;         % in seconds
tpoRampLength   = 0;              % in seconds
tpoTimer        = 150e-3;         % in seconds, 0 for indefinite
tpoRampMode     = 0;              % 0 = none, 1 = linear, 2 = Tukey, 3 = log, 4 = exp

% =========================================================================
% SETUP PULSE SEQUENCE
% =========================================================================

% generate empty array
seq_length = num_active_conditions * active_repeats + sham_repeats;
pulse_sequence = zeros(1, seq_length);

% generate random numbers
for num_ind = 1:num_active_conditions
    for counter = 1:active_repeats

        % infinite while loop
        while true

            % generate random index, but force the first pulse to be
            % active (TPO won't let first pulse be sham)
            if (num_ind == 1) && (counter == 1)
                rand_index = 1;
            else
                rand_index = randi([1, seq_length], 1);
            end
            
            % set value if not already set, and exit while loop
            if pulse_sequence(rand_index) == 0
                pulse_sequence(rand_index) = num_ind;
                break;
            end

        end

    end
end

% initialise empty response
response = nan(1, seq_length);

% =========================================================================
% ASSIGN COMMON SETTINGS
% =========================================================================

% connect to TPO
serialTPO = connectTPO();

% set transmit frequency 
setFreq(serialTPO, xdrCenterFreq);

% power on
powerOnTPO(serialTPO, power_scaling);

% set phase
setPhase(serialTPO, 1, xdrPhaseElem1);
setPhase(serialTPO, 2, xdrPhaseElem2);

% set burst properties
setTimer (serialTPO,  tpoTimer);
setPeriod(serialTPO,  300e-3);
setBurst (serialTPO,  1e-3);
setPeriod(serialTPO,  tpoBurstPeriod);
setBurst (serialTPO,  tpoBurstLength);
setRampMode(serialTPO, tpoRampMode);
if tpoRampMode ~= 0
    setRampLength(serialTPO, tpoRampLength);
end

% =========================================================================
% STIMULATION LOOP
% =========================================================================

% wait to make sure power level is reached
pause(1);

% send stimulation on button press
for ind = 1:length(pulse_sequence)
    
    % display trial number
    disp(['Trial ' num2str(ind) ' of ' num2str(length(pulse_sequence))]);
    
    % wait for designated length of time
    win = countdownTimer(wait_time);
    uiwait(win);

    if pulse_sequence(ind) == 0

        % short pause with jitter
        pause(rand(1) * 0.5 + 0.5);

        % transmit sham
        transmitSham(serialTPO);

    else

        %   Notes:
        %      - Timer >= Period >= Burst
        %      - burst length includes the ramp
        %      - the integral of the ramp^2 is 3/8
        %      - to give constant Ispta, burst length can be calculated as follows:
        %
        %           2 * ramp_length * 3/8 + middle_length = 4
        %           middle_length = 4 - 2 * ramp_length * 3/8
        %           burst_length = middle_length + 2 * ramp_length
        %           burst_length = 4 - 2 * ramp_length * 3/8 + 2 * ramp_length
        %           burst_length = 4 + 2 * ramp_length * 5/8

        % set pulsing parameters for active conditions
        switch pulse_sequence(ind)
            case 1

                % no ramp, 50pc DC
                tpoBurstLength  = 150e-3;           % in seconds
                tpoBurstPeriod  = 150e-3;
                tpoTimer        = 150e-3;
                tpoRampLength   = 0;               % in seconds
                tpoRampMode     = 0;               % 0 = none, 1 = linear, 2 = Tukey, 3 = log, 4 = exp
                
                % set transmit properties (all parameters getting smaller)
                setBurst   (serialTPO, tpoBurstLength);
                setPeriod  (serialTPO, tpoBurstPeriod);
                setTimer   (serialTPO, tpoTimer);
                
                setRampMode(serialTPO, tpoRampMode);
                
            case 2

                % set ramp length
                tpoRampLength = 20e-3;
                tpoRampMode   = 2;      % 0 = none, 1 = linear, 2 = Tukey, 3 = log, 4 = exp

                % want on-time to be 150 ms / 300 ms if no ramp
                % 150 = middle_length + 2 * 3/8 * ramp_length
                % burst_length = middle_length + 2 * ramp_length
                % burst_length = 150 - 2 * 3/8 * ramp_length + 2 * ramp_length
                % burst_length = 150 + 1.25 * ramp_length

                % calculate burst length
                tpoBurstLength = 150e-3 + 1.25 * tpoRampLength;

                % we only want a single burst, so set the period and timer to match
                tpoBurstPeriod = tpoBurstLength;
                tpoTimer       = tpoBurstLength;
                
                % set transmit properties (all parameters getting bigger)
                setTimer   (serialTPO, tpoTimer);
                setPeriod  (serialTPO, tpoBurstPeriod);
                setBurst   (serialTPO, tpoBurstLength);
                
                setRampMode(serialTPO, tpoRampMode);
                setRampLength(serialTPO, tpoRampLength);

        end

        % short pause with jitter
        pause(rand(1) * 0.5 + 0.5);

        % transmit
        transmitStart(serialTPO);
                 
    end
    
    % short pause with jitter
    pause(rand(1) * 0.5 + 0.5);
    
    % get response
    response_answer = questdlg('Did you hear a sound?', ...
    'Transmit Ultrasound', ...
    'Yes', 'No', 'Cancel', 'Yes');

    % store response
    switch response_answer
        case 'Yes'
            response(ind) = 1;
        case 'No'
            response(ind) = 0;
        case 'Cancel'
            break;
    end
            
end
    
% stop ultrasound for belt and braces
transmitAbort(serialTPO);

% get a filename for the data 
subject_ref = inputdlg('Enter subject reference to save data, cancel to exit');

% save data
if ~isempty(subject_ref)
    filename = [subject_ref{1} ' - ' strrep(datestr(clock), ':', '-') ' - auditory artefact study III'];
    save(filename, 'pulse_sequence', 'response');
end

% clean up
clear serialTPO;
