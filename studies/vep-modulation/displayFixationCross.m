function displayFixationCross(window, windowRect, cross_color, num_seconds)
% Function to display a fixation cross using the psych toolbox.
%
% author: Tulika Nandi and Bradley Treeby
% date: 11th November 2019
% last update: 11th November 2019

% get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% set the size of the arms of our fixation cross
fixCrossDimPix = 40;

% set the coordinates (these are all relative to zero we will let the
% drawing routine center the cross in the center of our monitor for us) 
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% set the line width for our fixation cross
lineWidthPix = 4;

% draw the fixation cross
Screen('DrawLines', window, allCoords,...
        lineWidthPix, cross_color, [xCenter yCenter], 2);
    
% flip to screen
Screen('Flip', window);

% re-draw the fixation cross (only because we flip again below)
Screen('DrawLines', window, allCoords,...
        lineWidthPix, cross_color, [xCenter yCenter], 2);

% wait for required time
WaitSecs(num_seconds);
