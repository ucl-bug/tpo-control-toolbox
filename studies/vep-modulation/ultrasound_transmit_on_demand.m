% Script to transmit a single burst of ultrasound triggered by a dialog
% box. Can be used to test acoustic coupling when using Lee parameters
% (setting = 1), as this is always audible to subjects.
%
% author: Bradley Treeby
% date: 18th November 2019
% last update: 7th May 2021

% clear the workspace and the screen
close all;
clear all; %#ok<CLALL>

% =========================================================================
% DEFINE LITERALS
% =========================================================================

% transducer parameters
xdrCenterFreq   = 270e3;  	% in Hertz
xdrPhaseElem1   = 0;        % in degrees
xdrPhaseElem2   = 66.3;     % in degrees

% power scaling factor
power_scaling = 1;

% parameter settings
setting = 1;

% set desired parameters
switch setting
    case 1
        
        % Lee paper
        tpoBurstLength  = 1e-3;           % in seconds
        tpoBurstPeriod  = 2e-3;           % in seconds
        tpoTimer        = 300e-3;         % in seconds, 0 for indefinite
        tpoRampMode     = 0;              % 0 = none, 1 = linear, 2 = Tukey, 3 = log, 4 = exp

    case 2
        
        % lower duty cycle
        tpoBurstLength  = 1e-3;           % in seconds
        tpoBurstPeriod  = 3e-3;           % in seconds
        tpoTimer        = 450e-3;         % in seconds, 0 for indefinite
        tpoRampMode     = 0;              % 0 = none, 1 = linear, 2 = Tukey, 3 = log, 4 = exp
        
    case 3
        
        % higher duty cycle
        tpoBurstLength  = 1e-3;           % in seconds
        tpoBurstPeriod  = 1.5e-3;         % in seconds
        tpoTimer        = 225e-3;         % in seconds, 0 for indefinite
        tpoRampMode     = 0;              % 0 = none, 1 = linear, 2 = Tukey, 3 = log, 4 = exp
        
    case 4
        
        % 1 ms ramp, otherwise Lee
        tpoRampLength   = 1e-3;          % in seconds
        burstOnTime     = 1e-3;          % in seconds
        burstOffTime    = 1e-3;          % in seconds
        tpoBurstLength  = tpoRampLength*2 + burstOnTime;           % in seconds
        tpoBurstPeriod  = tpoBurstLength + burstOffTime;           % in seconds
        tpoTimer        = 300e-3;         % in seconds, 0 for indefinite
        tpoRampMode     = 2;              % 0 = none, 1 = linear, 2 = Tukey, 3 = log, 4 = exp
        
    case 5
        
        % auditory artefact study 2

        % common settings
        tpoBurstPeriod  = 8e-3;           % in seconds
        tpoTimer        = 300e-3;         % in seconds, 0 for indefinite

%         % no ramp, 50pc DC (125 Hz PRF)
%         tpoBurstLength  = 4e-3;           % in seconds
%         tpoRampLength   = 0;              % in seconds
%         tpoRampMode     = 0;              % 0 = none, 1 = linear, 2 = Tukey, 3 = log, 4 = exp
% 
%         % 1 ms ramp
%         tpoBurstLength  = 5.25e-3;        % in seconds
%         tpoRampLength   = 1e-3;           % in seconds
%         tpoRampMode     = 2;              % 0 = none, 1 = linear, 2 = Tukey, 3 = log, 4 = exp
% 
%         % 1.5 ms ramp
%         tpoBurstLength  = 5.875e-3;       % in seconds
%         tpoRampLength   = 1.5e-3;         % in seconds
%         tpoRampMode     = 2;              % 0 = none, 1 = linear, 2 = Tukey, 3 = log, 4 = exp

        % 2 ms ramp
        tpoBurstLength  = 6.5e-3;         % in seconds
        tpoRampLength   = 2e-3;           % in seconds
        tpoRampMode     = 2;              % 0 = none, 1 = linear, 2 = Tukey, 3 = log, 4 = exp
        
    case 6
        
        % long ramp with no pulsing
        
        % set ramp length
        tpoRampLength = 20e-3;
        tpoRampMode   = 2;      % 0 = none, 1 = linear, 2 = Tukey, 3 = log, 4 = exp
        
        % want on-time to be 150 ms / 300 ms if no ramp
        % 150 = middle_length + 2 * 3/8 * ramp_length
        % middle_length = 
        % burst_length = middle_length + 2 * ramp_length
        % burst_length = 150 - 2 * 3/8 * ramp_length + 2 * ramp_length
        % burst_length = 150 + 1.25 * ramp_length
        
        % calculate burst length
        tpoBurstLength = 150e-3 + 1.25 * tpoRampLength;
        
        % we only want a single burst, so set the period and timer to match
        tpoBurstPeriod = tpoBurstLength;
        tpoTimer       = tpoBurstLength;
        
    case 7
        
        % pulsed but with long pulses
               
        % ---------------------------
        % set pulse characteristics
        tpoRampLength = 1e-3;
        equivalent_pulse_time = 2e-3;
        % ---------------------------
        
        % set ramp mode
        tpoRampMode = 2;      % 0 = none, 1 = linear, 2 = Tukey, 3 = log, 4 = exp
        
        % calculate burst length
        tpoBurstLength = equivalent_pulse_time + 1.25 * tpoRampLength;
        
        % we only want a single burst, so set the period and timer to match
        tpoBurstPeriod = 2 * equivalent_pulse_time;
        tpoTimer       = tpoBurstPeriod * floor(300e-3 / tpoBurstPeriod);
        
        % check values are ok
        if tpoBurstLength > tpoBurstPeriod
            error('Ramp too long');
        end
        
        % display the prf
        disp(['PRF = ' num2str(1/tpoBurstPeriod) ' Hz']);
        
    otherwise
        
        error('Unknown setting');
        
end

% =========================================================================
% ASSIGN SETTINGS
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

% reset burst values
setTimer(serialTPO, 0);
setPeriod(serialTPO, 1);
setBurst(serialTPO, 1e-3);

% set burst and period
setBurst(serialTPO,  tpoBurstLength);
setPeriod(serialTPO, tpoBurstPeriod);

% set burst properties
setTimer(serialTPO,  tpoTimer);
setRampMode(serialTPO, tpoRampMode);
if tpoRampMode ~= 0
    setRampLength(serialTPO, tpoRampLength);
end

% =========================================================================
% STIMULATION LOOP
% =========================================================================

% wait to make sure power level is reached
pause(1);

% count how many pulses were delivered
number_delivered_pulses = 0;

% send stimulation on button press
run_loop = true;
while run_loop
    
    % wait for user input
    answer = questdlg('Transmit Ultrasound?', ...
	'Transmit Ultrasound', ...
	'Transmit', 'Sham', 'Cancel', 'Cancel');

    % Handle response
    switch answer
        case 'Transmit'

            % transmit
            transmitStart(serialTPO);
            
            % update pulse count
            number_delivered_pulses = number_delivered_pulses + 1;
            
        case 'Sham'
            
            % transmit sham
            transmitSham(serialTPO);
            
        case 'Cancel'
            
            % exit the program
            run_loop = false;
            break;
            
    end
    
end
    
% stop ultrasound for belt and braces
transmitAbort(serialTPO);

% get a filename for the data
answer = inputdlg('Enter filename to save data, cancel to exit');

% save data
if ~isempty(answer)
    filename = [strrep(datestr(clock), ':', '-') ' - ultrasound only transmit on deman - ' answer{1}];
    save(filename, 'number_delivered_pulses', 'power_scaling');
end

% clean up
clear serialTPO;
