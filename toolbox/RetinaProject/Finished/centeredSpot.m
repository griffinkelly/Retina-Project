function centeredSpot(circleSize, contrast)


if nargin < 1 || isempty(circleSize)
    
    circleSize=1; 
end
if nargin < 2 || isempty(contrast)
    
    contrast=1; 
end

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey= white / 2;
% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Get the size of the on screen wind  ow
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Make a base Rect of 200 by 250 pixels
baseRect = [0 0 200 200];
baseRect = baseRect *circleSize;

% For Ovals we set a miximum diameter up to which it is perfect for
maxDiameter = max(baseRect) * 1.00;

% Center the rectangle on the centre of the screen
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);

amplitude = white-(contrast*white);
amp_number = amplitude/2;
% Set the color of the rect to red  
rectColor = white-amp_number;
rectColor2 = amp_number;


ifi = Screen('GetFlipInterval', window);

% Retreive the maximum priority number
topPriorityLevel = MaxPriority(window);

% Length of time and number of frames we will use for each drawing test

numFrames = round(2 / ifi);

% Numer of frames to wait when specifying good timing
waitframes = 1;
KbStrokeWait;

for totalRepeats = 1: 2

% Here we do exactly the same as the second example, but we additionally
% first set the PTB prority level to maximum. This means PTB will take
% processing priority over other system and applicaiton processes. It is
% important to switch away from this after stimulus presentation and time
% critical code in order to allow other processes to run.
Priority(topPriorityLevel);
vbl = Screen('Flip', window);
for frame = 1:numFrames

% Draw the rect to the screen
Screen('FillOval', window, rectColor, centeredRect, maxDiameter);

    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

end
Priority(0);

% Finally we do the same as the last example except now we additionally
% tell PTB that no more drawing commands will be given between coloring the
% screen and the flip command. This, under some circumstances, can help
% acheive good timing.
Priority(topPriorityLevel);
vbl = Screen('Flip', window);
for frame = 1:numFrames    

% Draw the rect to the screen
Screen('FillOval', window, rectColor2, centeredRect, maxDiameter);

    % Tell PTB no more drawing commands will be issued until the next flip
    Screen('DrawingFinished', window);

    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

end
Priority(0);

end




% Wait for a key press
KbStrokeWait;

% Clear the screen
sca;
end