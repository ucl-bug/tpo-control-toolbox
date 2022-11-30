function f = countdownTimer(time)
%COUNTDOWNTIMER Pause with countdown
%
% DESCRIPTION:
%     countdownTime pauses code execution with a countdown timer displayed.
%
% USAGE:
%     countdownTimer(time)
%
% INPUTS:
%     time          - integer time in seconds
%
% ABOUT:
%     author        - Bradley Treeby
%     date          - 20th November 2020
%     last update   - 20th November 2020

% set timer
time_remaining = ceil(time) + 1;

% setup display
f = figure(... 
    'Position', [300 300 300 180], ...
    'Name', 'Countdown Timer', ...
    'NumberTitle', 'off', ...
    'MenuBar', 'none', ...
    'Resize', 'on', ...
    'tag', 'UI');

% add display
num = uicontrol(f, ...
    'Style', 'text', ...
    'String', '0', ...
    'FontSize', 100, ...
    'FontWeight', 'bold', ...
    'Position', [10 10 280 160]);

% setup timer
t = timer(...
    'ExecutionMode', 'fixedRate', ...
    'Period', 1, ...
    'TasksToExecute', time_remaining, ...
    'TimerFcn', @updateDisplay, ...
    'StopFcn', @deleteDisplay);

start(t);

function updateDisplay(~, ~)
    time_remaining = time_remaining - 1;
    num.String = num2str(time_remaining);
    drawnow;
end

function deleteDisplay(~, ~)
    close(f);
    delete(t);
end

end