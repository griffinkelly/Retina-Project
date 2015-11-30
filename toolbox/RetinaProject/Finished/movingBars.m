function movingBars(numberofbars)

if nargin < 1 || isempty(numberofbars)
    % Tilt angle of the grating:
    numberofbars = 6;
end
Screen('Preference', 'VisualDebugLevel', 3);               
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber); 

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 36);
KbName('UnifyKeyNames');
exitkey = KbName('x');
spacekey = KbName('space');

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);


% Set the width for our rectangle 
baseRect = [0 0 screenXpixels/numberofbars screenYpixels];

baseRect2 = [0 0 50 50];
corner = CenterRectOnPointd(baseRect2, screenXpixels, screenYpixels);
maxDiameter = max(baseRect2) * 1.00;
% Center the rectangle on the centre of the screen using fractional pixel
% values.
% For help see: CenterRectOnPointd


ifi = Screen('GetFlipInterval', window);
timedInterval = round(1/ ifi);

for ii = 0:numberofbars 


% Draw the fixation cross in white, set it to the center of our screen and
% set good quality antialiasing
%Screen('DrawLines', window, allCoords,lineWidthPix, white, [(ii*lineWidthPix) 0], 2);
centeredRect = CenterRectOnPointd(baseRect, ((screenXpixels/numberofbars)*ii), yCenter);
for frame = 1:timedInterval  
    [keydown, secs, keycode, deltasexcs] = KbCheck;
    KbReleaseWait;
    if keycode(exitkey)
        Screen('CloseAll');
        return
    end
    Screen('FrameRect', window, [255 0 0], corner, maxDiameter);
    Screen('FillRect', window, white, centeredRect);               
    Screen('Flip', window);               

end
    Screen('FrameRect', window, [255 0 0], corner, maxDiameter);
    % Flip to the screen
    Screen('Flip', window);
    Screen('FillRect', window, black);               
    disp('X Coordinate');
    disp(((screenXpixels/numberofbars)*ii));


KbTriggerWait(spacekey);
                
end

baseRect = [0 0 screenXpixels screenYpixels/numberofbars];
               
for ii = 0:numberofbars

centeredRect = CenterRectOnPointd(baseRect, xCenter, ((screenYpixels/numberofbars)*ii));
% Draw the fixation cross in white, set it to the center of our screen and
% set good quality antialiasing  
for frame = 1:timedInterval
    [keydown, secs, keycode, deltasexcs] = KbCheck;
    KbReleaseWait;
    if keycode(exitkey)
        Screen('CloseAll');
        return
    end
    Screen('FrameRect', window, [255 0 0], corner, maxDiameter);
    Screen('FillRect', window, white, centeredRect);
    Screen('Flip', window);

end
Screen('FrameRect', window, [255 0 0], corner, maxDiameter);
% Flip to the screen
Screen('Flip', window);
disp('Y Coordinate');               
disp(((screenYpixels/numberofbars)*ii));
KbTriggerWait(spacekey);             
    
end



% Wait for a key press
KbTriggerWait(spacekey);

% Clear the screen
sca; 