function [window, windowRect, radialCheckerboardTexture, ifi, screenNumber] = setupV1Checkerboards(luminance)
% Function to setup the psych toolbox to display checkboards with the
% specified luminance value, based on demo by Peter Scarfe's.
%
% author: Tulika Nandi and Bradley Treeby
% date: 11th November 2019
% last update: 22nd November 2019

% =========================================================================
% SETUP PSYCH TOOLBOX
% =========================================================================

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Turn off splash screen
Screen('Preference', 'VisualDebugLevel', 1);

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer.
screens = Screen('Screens');

% To draw we select the maximum of these numbers. So in a situation where
% we have two screens attached to our monitor we will draw to the external
% screen.
screenNumber = max(screens);

% Define black and white (white will be 1 and black 0). This is because
% in general luminace values are defined between 0 and 1 with 255 steps in
% between. All values in Psychtoolbox are defined between 0 and 1
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Do a simply calculation to calculate the luminance value for grey. This
% will be half the luminace values for white
grey = white / 2;

% Open an on screen window using PsychImaging and color it grey.
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', window);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Retreive the maximum priority number and set max priority
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% =========================================================================
% DEFINE CHECKERBOARD
% =========================================================================

% Screen resolution in Y
screenYpix = windowRect(4);

% Number of white/black circle pairs
rcycles = 8;

% Number of white/black angular segment pairs (integer)
tcycles = 24;

% Define colors for 50% and 25% contrast boards
col_range25 = linspace(black, white, 7);
max25 = col_range25(1, 5);
min25 = col_range25(1, 3);

col_range50 = linspace(black, white, 5);
max50 = col_range50(1, 4);
min50 = col_range50(1, 2);

% Now we make our checkerboard pattern
xylim = 2 * pi * rcycles;
[x, y] = meshgrid(-xylim: 2 * xylim / (screenYpix - 1): xylim,...
    -xylim: 2 * xylim / (screenYpix - 1): xylim);
at = atan2(y, x);

% Luminanace 50% of total screen luminance range
checks50 = ((1 + sign(sin(at * tcycles) + eps)...
    .* sign(sin(sqrt(x.^2 + y.^2)))) / 2) * (max50 - min50) + min50;

% Luminanace 25% of total screen luminance range
checks25 = ((1 + sign(sin(at * tcycles) + eps)...
    .* sign(sin(sqrt(x.^2 + y.^2)))) / 2) * (max25 - min25) + min25;

circle = x.^2 + y.^2 <= xylim^2;
checks50 = circle .* checks50 + grey * ~circle;
checks25 = circle .* checks25 + grey * ~circle;

% Make four copies of each checkerboard, including two with a hot square
% for the photodiode to detect
sz = 25;
checks50_positive = checks50;
checks50_negative = 1 - checks50;
checks50_positive_with_hot_square = checks50_positive;
checks50_positive_with_hot_square(end - sz:end, 1:sz) = 1;
checks50_negative_with_hot_square = checks50_negative;
checks50_negative_with_hot_square(end - sz:end, 1:sz) = 1;

checks25_positive = checks25;
checks25_negative = 1 - checks25;
checks25_positive_with_hot_square = checks25_positive;
checks25_positive_with_hot_square(end - sz:end, 1:sz) = 1;
checks25_negative_with_hot_square = checks25_negative;
checks25_negative_with_hot_square(end - sz:end, 1:sz) = 1;

% Now we make this into a PTB texture
if (nargin == 0) || (luminance == 50)
    radialCheckerboardTexture(1)  = Screen('MakeTexture', window, checks50_positive_with_hot_square);
    radialCheckerboardTexture(2)  = Screen('MakeTexture', window, checks50_negative_with_hot_square);
    radialCheckerboardTexture(3)  = Screen('MakeTexture', window, checks50_positive);
    radialCheckerboardTexture(4)  = Screen('MakeTexture', window, checks50_negative);
elseif luminance == 25
    radialCheckerboardTexture(1)  = Screen('MakeTexture', window, checks25_positive_with_hot_square);
    radialCheckerboardTexture(2)  = Screen('MakeTexture', window, checks25_negative_with_hot_square);
    radialCheckerboardTexture(3)  = Screen('MakeTexture', window, checks25_positive);
    radialCheckerboardTexture(4)  = Screen('MakeTexture', window, checks25_negative);
else
    error('Unknown value for checkerboard luminence');
end
