% Script to display a visual checkboard using the psych toolbox
% synchronised with ultrasound stimulation using the Sonic Concepts TPO.
% The EEG acquisition is synchronised using the sync out from the TPO.
%
% author: Bradley Treeby and Tulika Nandi
% date: 11th November 2019
% last update: 1st July 2021

% clear the workspace and the screen
sca;
Screen('CloseAll');
close all;
clear all; %#ok<CLALL>

% =========================================================================
% DEFINE LITERALS
% =========================================================================

% number of checkboard and ultrasound pulsess
num_active_pulses   = 50;
num_sham_pulses     = 50;

% time to display the fixation cross [s]
fixation_cross_time = 5;

% option to blind output
blind = true;

% prompt
opts = struct('WindowStyle', 'modal', 'Interpreter', 'none');
waitfor(warndlg({...
    '1. Check photodiode on and battery ok', ...
    '2. Check g.Recorder is recording.', ...
    ' ', ...
    ['Number of active pulses = ' num2str(num_active_pulses)], ...
    ['Number of sham pulses = ' num2str(num_sham_pulses)]}, ...
    'Start-up Checks', opts));

% =========================================================================
% DEFINE FIXED LITERALS
% =========================================================================

% offset between ultrasound and visual stimulus (ultrasound is before the
% screen flip) [s] 
us_stimulation_offset = 100e-3;

% time between checkboard flips [s]
time_between_flips = 0.5;

% time to display the final checkboard before closing [s]
closing_time = 2;

% luminance value for checkboards [%]
luminance = 50;

% how often to pulse the ultrasound (4 flips for every ultrasound trial)
us_trial_flip_count = 4;

% stimulus length (only used to set timing, stimulus length is hard coded
% into setupTPOV1 function) [s]
us_stimulus_length = 0.3;

% =========================================================================
% SETUP PSYCH TOOLBOX AND TPO
% =========================================================================

% visual stimulus setup
[window, windowRect, radialCheckerboardTexture, ifi, screenNumber] = setupV1Checkerboards(luminance);

% get monitor refresh rate
refresh_rate = Screen('GetFlipInterval', window);

% round the time between flips to be a multiple of the refresh rate
time_between_flips = round(time_between_flips / refresh_rate) * refresh_rate;

% define a wait time before turning off hot pixel for photodiode
end_of_loop_wait_time = round( 0.25 / refresh_rate) * refresh_rate;

% random numbers for sham condition
us_on = getRandBinarySeq(num_active_pulses + num_sham_pulses, num_active_pulses);

% counter for ultrasound trials
us_ind = 0;

% total number of screen flips (ultrasound is on every us_trial_flip_count
% flips)
num_flips = (num_active_pulses + num_sham_pulses) * us_trial_flip_count;

% preallocate vectors to store time stamps
flip_begin_timestamp    = zeros(1, num_flips);
flip_end_timestamp      = zeros(1, num_flips);
wake_timestamp          = zeros(1, num_flips);
us_before_timestamp     = zeros(1, num_flips);
us_after_timestamp      = zeros(1, num_flips);

% setup the TPO
serialTPO = setupTPOV1;

% =========================================================================
% STIMULATION LOOP
% =========================================================================

% define white value for fixation cross
white = WhiteIndex(screenNumber);

% display white fixation cross
displayFixationCross(window, windowRect, white, fixation_cross_time);

% return sync to vertical retrace for later use
vbl = Screen('Flip', window);

% put in try-catch loop in case of psychtoolbox problems
try
    
    % loop through trials
    for ind = 1:num_flips
           
        % update display
        disp(['FLIP NUM ' num2str(ind)]);
        
        % only use ultrasound every fourth flip
        if rem(ind, 4) == 0
        
            % increment trial index (starts at 0)
            us_ind = us_ind + 1;
            
            % flush the previous TPO commands
            if ind ~= 1
                fprintf(serialTPO, 'ABORT');
            end

            % arm the TPO
            if us_on(us_ind)
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
            
        end
        
        % draw checkboard to the screen (different pattern for even and
        % odd values of ind)
        Screen('DrawTexture', window, radialCheckerboardTexture(rem(ind, 2) + 1));
               
        % set the flip time (offset from static baseline)
        next_flip_time = vbl + ind * time_between_flips;
        
        % schedule the flip to the screen, offset by half the refresh rate
        Screen('AsyncFlipBegin', window, next_flip_time - 0.5 * refresh_rate); 
        
        % wait until time for ultrasound, accounting for offset between
        % ultrasound and checkboard flip (ultrasound starts before
        % checkboard flip) 
        wake_timestamp(ind) = WaitSecs('UntilTime', next_flip_time - us_stimulation_offset);        
        
        % only use ultrasound every fourth flip
        if rem(ind, 4) == 0
        
            % trigger the ultrasound
            us_before_timestamp(ind) = GetSecs;
            fprintf(serialTPO, '\r');
            fprintf(' Complete.\n');
            us_after_timestamp(ind) = GetSecs;
            
        end
                
        % synchronise and collect timing information
        [flip_begin_timestamp(ind), ~, flip_end_timestamp(ind)] = Screen('AsyncFlipEnd', window);
        
        % flip back the hot pixel for the photodiode (the StimTrack device
        % only triggers on positive signals) and make sure the length of
        % the stimulus has passed before restarting loop
        Screen('DrawTexture', window, radialCheckerboardTexture(rem(ind, 2) + 3));
        Screen('Flip', window, next_flip_time + end_of_loop_wait_time - 0.5 * refresh_rate);
        
        % display some timings
        if ind > 1
            disp(['Time between flips     = ' num2str(1e3 * (flip_begin_timestamp(ind) - flip_begin_timestamp(ind - 1))) ' ms']);
        end
        disp(['Screen flip duration   = ' num2str(1e3 * (flip_end_timestamp(ind) - flip_begin_timestamp(ind))) ' ms']);
        if rem(ind, 4) == 0
            disp(['US->flip offset        = ' num2str(1e3 * (flip_begin_timestamp(ind) - us_before_timestamp(ind))) ' ms']);
            disp(['US command duration    = ' num2str(1e3 * (us_after_timestamp(ind) - us_before_timestamp(ind))) ' ms']);
        end
        disp('');
        
    end
    
catch ME
    
    % close the PTB window, clear Screen, and rethrow message error
    clear Screen;
    sca;
    rethrow(ME);
    
end 

% wait some time before closing the window
WaitSecs(closing_time);

% close the PTB window
sca;

% stop ultrasound for belt and braces
transmitAbort(serialTPO);

% get a filename for the data
answer = inputdlg('Enter filename to save data, cancel to exit');

% save data
if ~isempty(answer)
    filename = [strrep(datestr(clock), ':', '-') ' - ultrasound + checkboards - ' answer{1}];
    save(filename, ...
        'flip_begin_timestamp', ...
        'flip_end_timestamp', ...
        'us_before_timestamp', ...
        'us_after_timestamp', ...
        'wake_timestamp', ...
        'us_on', ...
        'luminance', ...
        'refresh_rate', ....
        'time_between_flips', ...
        'fixation_cross_time', ...
        'num_active_pulses', ...
        'num_sham_pulses', ...
        'num_flips', ...
        'us_stimulation_offset', ...
        'us_trial_flip_count');
end

% clear tpo connection
clear serialTPO;
