% Clear the workspace
close all;
clear all;
sca;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
inc = white - grey;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);






% Loop until a key is pressed
while ~KbCheck

   

    % Hide Cursor
    HideCursor;
    
    noiseimg=(50*randn(screenXpixels, screenYpixels) + 128);

   % Convert it to a texture 'tex':
   tex=Screen('MakeTexture', window, noiseimg);

 Screen('DrawTexture', window, tex, [], [], [], 0, 1, [128 255 0]);

            % After drawing, we can discard the noise texture.
            Screen('Close', tex);
            
    % Flip to the screen on the next vertical retrace
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

end

% Clear the screen
sca;
clear all;
close all;