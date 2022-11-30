% Script to run experiment 4 of the auditory artefact study.
%
% KEY  PRF      DURAT   RAMP        MASK        TRIALS
%   0: sham     -       -           -           15 trials
%   1: sham     -       -           mask        15 trials
%   2: 250 Hz   300 ms  -           mask        10 trials
%   3: 250 Hz   300 ms  1 ms        mask        10 trials
%   4: 250 Hz   300 ms  1 ms        -           10 trials
%
% Computer volume on 70%
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

% number of repeats of each condition
active_repeats = 10;
num_active_conditions = 3;
sham_mask_repeats = 15;
sham_no_mask_repeats = 15;

% duration between stimulation [s]
wait_time = 3;

% transducer parameters
xdrCenterFreq = 270e3;      % in Hertz
xdrPhaseElem1 = 0;          % in degrees
xdrPhaseElem2 = 66.3;       % in degrees

% power scaling factor
power_scaling = 1;

% initialise (250 Hz PRF)
tpoBurstLength  = 2e-3;           % in seconds
tpoBurstPeriod  = 4e-3;           % in seconds
tpoRampLength   = 0;              % in seconds
tpoTimer        = 300e-3;         % in seconds, 0 for indefinite
tpoRampMode     = 0;              % 0 = none, 1 = linear, 2 = Tukey, 3 = log, 4 = exp

% =========================================================================
% SETUP PULSE SEQUENCE
% =========================================================================

% generate empty array
seq_length = num_active_conditions * active_repeats + sham_mask_repeats + sham_no_mask_repeats;
pulse_sequence = zeros(1, seq_length);

% generate random numbers for active conditions
for num_ind = 2:(num_active_conditions + 1)
    for counter = 1:active_repeats

        % infinite while loop
        while true

            % generate random index, but force the first pulse to be
            % active (TPO won't let first pulse be sham)
            if (num_ind == 2) && (counter == 1)
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

% generate random numbers for masked sham
num_ind = 1;
for counter = 1:sham_mask_repeats
    while true

        % generate random index
        rand_index = randi([1, seq_length], 1);

        % set value if not already set, and exit while loop
        if pulse_sequence(rand_index) == 0
            pulse_sequence(rand_index) = num_ind;
            break;
        end

    end
end

% initialise empty response
response = nan(1, seq_length);

% =========================================================================
% SETUP AUDIO SIGNAL
% =========================================================================

% set literals
Fs          = 40000;
dt          = 1/Fs;
burst       = 2e-3;
repeats     = 250;      % gives total of 1 second
offset_pre  = 0.4;      % start sound 100 ms before stimulus
offset_post = 0.7;      % stimulus is 300 ms, pause for 700 ms after

% create time axis for one burst
t = 0:dt:burst-dt;

% add zero time
sig_on    = ones(1, length(t));
sig_off   = zeros(1, length(t));
sig_block = [sig_on, sig_off];

% replicate
audio_signal = repmat(sig_block, [1, repeats]);

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
setTimer (serialTPO, tpoTimer);
setPeriod(serialTPO, 200e-3);
setBurst (serialTPO, 1e-3);
setPeriod(serialTPO, tpoBurstPeriod);
setBurst (serialTPO, tpoBurstLength);
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
        pause(rand(1) * 0.25 + 0.25);
        
        % fixed pause 100 ms
        pause(offset_pre);
        
        % transmit sham 300 ms
        transmitSham(serialTPO);
        
        % fixed pause
        pause(offset_post);

    elseif pulse_sequence(ind) == 1
        
        % short pause with jitter
        pause(rand(1) * 0.25 + 0.25);        
        
        % mask on (1 second in total)
        soundsc(audio_signal, Fs);
        
        % fixed pause 100 ms
        pause(offset_pre);
        
        % transmit sham 300 ms
        transmitSham(serialTPO);
        
        % fixed pause
        pause(offset_post);
        
    else

        % reset burst and period (avoids error with the period <
        % burst when switching later on) 
        setPeriod(serialTPO,  10e-3);

        % set pulsing parameters
        switch pulse_sequence(ind)
            case 2

                % Pulsed with 250 Hz PRF
                tpoBurstLength  = 2e-3;           % in seconds
                tpoBurstPeriod  = 4e-3;           % in seconds
                tpoRampLength   = 0;              % in seconds
                tpoRampMode     = 0;              % 0 = none, 1 = linear, 2 = Tukey, 3 = log, 4 = exp

            case {3, 4}

                % 1ms ramp with 250 Hz PRF
                tpoBurstLength  = 3.25e-3;        % in seconds
                tpoBurstPeriod  = 4e-3;           % in seconds
                tpoRampLength   = 1e-3;           % in seconds
                tpoRampMode     = 2;              % 0 = none, 1 = linear, 2 = Tukey, 3 = log, 4 = exp
                
        end

        % set transmit properties
        setBurst(serialTPO, tpoBurstLength);
        setPeriod(serialTPO, tpoBurstPeriod);
        setRampMode(serialTPO, tpoRampMode);
        if tpoRampMode ~= 0
            setRampLength(serialTPO, tpoRampLength);
        end

        % short pause with jitter
        pause(rand(1) * 0.25 + 0.25);
        
        % mask on (1 second in total)
        if (pulse_sequence(ind) == 2) || (pulse_sequence(ind) == 3)
            soundsc(audio_signal, Fs);
        end
        
        % fixed pause 100 ms
        pause(offset_pre);
        
        % transmit stimulus 300 ms
        transmitStart(serialTPO);
        
        % fixed pause
        pause(offset_post);
     
    end
   
    % short pause with jitter
    pause(rand(1) * 0.25 + 0.25);
    
    % get response
    response_answer = questdlg('Do you think you were stimulated?', ...
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
    filename = [subject_ref{1} ' - ' strrep(datestr(clock), ':', '-') ' - auditory artefact study IV'];
    save(filename, 'pulse_sequence', 'response');
end

% clean up
clear serialTPO;
