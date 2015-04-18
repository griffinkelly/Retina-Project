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

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);


% Set the width for our rectangle 
baseRect = [0 0 screenXpixels/numberofbars screenYpixels];

% Center the rectangle on the centre of the screen using fractional pixel
% values.
% For help see: CenterRectOnPointd



for ii = 0:numberofbars 


% Draw the fixation cross in white, set it to the center of our screen and
% set good quality antialiasing
%Screen('DrawLines', window, allCoords,lineWidthPix, white, [(ii*lineWidthPix) 0], 2);
centeredRect = CenterRectOnPointd(baseRect, ((screenXpixels/numberofbars)*ii), yCenter);

Screen('FillRect', window, white, centeredRect);
% Flip to the screen 
Screen('Flip', window);
disp('X Coordinate');
disp(((screenXpixels/numberofbars)*ii));
KbStrokeWait;       

end

baseRect = [0 0 screenXpixels screenYpixels/numberofbars];

for ii = 0:numberofbars

centeredRect = CenterRectOnPointd(baseRect, xCenter, ((screenYpixels/numberofbars)*ii));
% Draw the fixation cross in white, set it to the center of our screen and
% set good quality antialiasing

Screen('FillRect', window, white, centeredRect);

% Flip to the screen
Screen('Flip', window);
disp('Y Coordinate');               
disp(((screenYpixels/numberofbars)*ii));
KbStrokeWait;             
    
end



% Wait for a key press
KbStrokeWait;

% Clear the screen
sca; 