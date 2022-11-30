% Script to perform ultrasound stimulation using the Sonic Concepts TPO.
% The timing is provided using the psych toolbox. The EEG acquisition is
% synchronised using the sync out from the TPO. 
%
% author: Bradley Treeby
% date: 25th June 2021
% last update: 1st July 2021

% clear the workspace and the screen
sca;
close all;
clear all; %#ok<CLALL>

% =========================================================================
% DEFINE LITERALS
% =========================================================================

% number of stimuli
num_active_pulses   = 50;
num_sham_pulses     = 50;

% time to display the fixation cross before the ultrasound starts [s]
fixation_cross_time = 3;

% option to blind output
blind = true;

% prompt
opts = struct('WindowStyle', 'modal', 'Interpreter', 'none');
waitfor(warndlg({...
    'Check g.Recorder is recording.', ...
    ' ', ...
    ['Number of active pulses = ' num2str(num_active_pulses)], ...
    ['Number of sham pulses = ' num2str(num_sham_pulses)]}, ...
    'Start-up Checks', opts));

% =========================================================================
% DEFINE FIXED LITERALS
% =========================================================================

% time between trials [s]
time_between_trials = 2;

% luminance value for fixation cross [%]
luminance = 50;

% stimulus length (only used to set timing, stimulus length is hard coded
% into setupTPOV1 function) [s]
us_stimulus_length = 0.3;

% =========================================================================
% SETUP PSYCH TOOLBOX AND TPO
% =========================================================================

% visual stimulus setup
[window, windowRect, radialCheckerboardTexture, ifi, screenNumber] = setupV1Checkerboards(luminance);

% total number of trials
num_trials = num_active_pulses + num_sham_pulses;

% random numbers for active and sham conditions
us_on = getRandBinarySeq(num_trials, num_active_pulses);

% preallocate vectors to store time stamps
us_before_timestamp = zeros(1, num_trials);
us_after_timestamp  = zeros(1, num_trials);

% setup the TPO (this sets the pulsing conditions)
serialTPO = setupTPOV1;

% =========================================================================
% STIMULATION LOOP
% =========================================================================

% define white value for fixation cross
white = WhiteIndex(screenNumber);

% display white fixation cross
displayFixationCross(window, windowRect, white, fixation_cross_time);
Screen('Flip', window);

% wait before ultrasound starts
WaitSecs(fixation_cross_time);
reference_time = GetSecs;

% put in try-catch loop in case of psychtoolbox problems
try
    
    % loop through trials
    for ind = 1:num_trials
           
        % update display
        disp(['TRIAL NUM ' num2str(ind)]);
        
        % flush the previous TPO commands
        if ind ~= 1
            fprintf(serialTPO, 'ABORT');
        end
        
        % arm the TPO
        if us_on(ind)
            fprintf(serialTPO, 'ARM');
            if ~blind
                fprintf('Transmit...');
            end
        else
            fprintf(serialTPO, 'SHAMARM');
            if ~blind
                fprintf('Sham...');
            end
        end
        
        if blind
            fprintf('Trial...');
        end        
        
        % wait until stimulus time
        start_time = reference_time + ind * time_between_trials;
        WaitSecs('UntilTime', start_time);
        
        % trigger the ultrasound
        us_before_timestamp(ind) = GetSecs;
        fprintf(serialTPO, '\r');
        fprintf(' Complete.\n');
        us_after_timestamp(ind) = GetSecs;
        if ind > 1
            disp(['Time between trials = ' num2str(1e3 * (us_before_timestamp(ind) - us_before_timestamp(ind - 1))) ' ms']);
        end
        disp(['US command duration = ' num2str(1e3 * (us_after_timestamp(ind) - us_before_timestamp(ind))) ' ms']);
             
        % short pause
        WaitSecs(2 * us_stimulus_length);
        
    end
    
catch ME
    
    % close the PTB window, clear Screen, and rethrow message error
    clear Screen;
    sca;
    rethrow(ME);
    
end 

% close the PTB window
sca;

% stop ultrasound for belt and braces
transmitAbort(serialTPO);

% get a filename for the data
answer = inputdlg('Enter filename to save data, cancel to exit');

% save data
if ~isempty(answer)
    filename = [strrep(datestr(clock), ':', '-') ' - ultrasound only - ' answer{1}];
    save(filename, ...
        'us_before_timestamp', ...
        'us_after_timestamp', ...
        'us_on', ...
        'luminance', ...
        'time_between_trials', ...
        'fixation_cross_time', ...
        'num_active_pulses', ...
        'num_sham_pulses', ...
        'num_trials');
end

% clear tpo connection
clear serialTPO;
