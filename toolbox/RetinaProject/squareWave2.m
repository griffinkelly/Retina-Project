function squareWave2()

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

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Grating size in pixels
gratingSizePix = screenXpixels;

% Grating frequency in cycles / pixel
freqCyclesPerPix = 0.01;

% Drift speed cycles per second
cyclesPerSecond = 1;

% Define Half-Size of the grating image.
texsize = gratingSizePix / 2;

% First we compute pixels per cycle rounded to the nearest pixel
pixPerCycle = ceil(1 / freqCyclesPerPix);

% Frequency in Radians
freqRad = freqCyclesPerPix * 2 * pi;

% This is the visible size of the grating
visibleSize = 2 * texsize + 1;

% Define our grating. Note it is only 1 pixel high. PTB will make it a full
% grating upon drawing
x = meshgrid(-texsize:texsize + pixPerCycle, 1);
grating = grey * square(freqRad*x) + grey;

% Make a two layer mask filled with the background colour
mask = ones(1, numel(x), 2) * black;

% Contrast for our contrast modulation mask: 0 = mask has no effect, 1 = mask
% will at its strongest part be completely opaque frameCounter.e. 0 and 100% contrast
% respectively
contrast = 0.8;

% Place the grating in the 'alpha' channel of the mask
mask(:, :, 2)= grating .* contrast;

% Make our grating mask texture
gratingMaskTex = Screen('MakeTexture', window, mask);



% Define our grating. Note it is only 1 pixel high. PTB will make it a full
% grating upon drawing
x2 = meshgrid(-texsize:texsize + pixPerCycle, 1);
grating2 = grey * -square(freqRad*x2) + grey;

% Make a two layer mask filled with the background colour
mask = ones(1, numel(x2), 2) * black;

% Contrast for our contrast modulation mask: 0 = mask has no effect, 1 = mask
% will at its strongest part be completely opaque frameCounter.e. 0 and 100% contrast
% respectively
contrast2 = 0.8;

% Place the grating in the 'alpha' channel of the mask
mask2(:, :, 2)= grating2 .* contrast2;


gratingMaskTex2 = Screen('MakeTexture', window, mask2);

% Make a black and white noise mask half the size of our grating. This will
% be scaled upon drawing to make a "chunky" noise texture which our grating
% will mask
%noise = round(rand(visibleSize / 2)) .* white;

% Make our noise texture
noiseTex = Screen('MakeTexture', window, white);

% Make a destination rectangle for our textures and center this on the
% screen
dstRect = [0 0 visibleSize visibleSize];
dstRect = CenterRect(dstRect, windowRect);

% We set PTB to wait one frame before re-drawing
waitframes = 1;

% Sync us to the vertical retrace
vbl = Screen('Flip', window);

numSecs = 1;
numFrames = round(numSecs / ifi);

% Loop until a key is pressed

for reps =1:2
    KbStrokeWait;
for frame = 1:numFrames
    % Draw noise texture to the screen
    Screen('DrawTexture', window, noiseTex, [], dstRect, []);

    % Hide Cursor
    HideCursor;
    
    % Draw grating mask
     % Alternate last number to vary angle of grating
    Screen('DrawTexture', window, gratingMaskTex, [], dstRect, []);

    % Flip to the screen on the next vertical retrace
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

end
vbl = Screen('Flip', window);
for frame = 1:numFrames
    % Draw noise texture to the screen
    Screen('DrawTexture', window, noiseTex, [], dstRect, []);

    % Hide Cursor
    HideCursor;
    
    % Draw grating mask
     % Alternate last number to vary angle of grating
    Screen('DrawTexture', window, gratingMaskTex2, [], dstRect, []);

    % Flip to the screen on the next vertical retrace
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

end
end

% Clear the screen
sca;
clear all;

end