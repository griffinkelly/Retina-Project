function centeredSpot_minus(circleSize, contrast, repNum, pulseDuration,positionArray,daqValue,increment,numInc)
%A Function which shows a white spot in the center of a black background
%Circle Size: a scaling factor of circle size, 1, 2, etc.
%Contrast: 0-100%, contrast of black and white
%repNum: Number of times the circle will pulse
%Pulse Duration: Number of seconds the pulse will occur for
%position Array: a vector of x, y coordinates of where the circle will be
%centered
%Written: Griffin Kelly, 2015, griffinkelly2013@gmail.com


if nargin < 1 || isempty(circleSize)
    
    circleSize=1; 
end
if nargin < 2 || isempty(contrast)
    
    contrast=200; 
end
if nargin < 3 || isempty(repNum)
    
    repNum=5; 
end
if nargin < 4 || isempty(pulseDuration)
    
    pulseDuration=1; 
end
if nargin < 5 || isempty(daqValue)
    daqValue = 0;
end
if nargin < 6 || isempty(increment)
    increment = 0;
end
if nargin < 7 || isempty(numInc)
    numInc = 5;
end
contrast=contrast/100;
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
%Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 1);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if available
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey= white / 2;
greyer= white/4;
% Open an on screen window
%The last variable, 'black' is the background color. Alternate to change
%background color
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Get the size of the on screen wind  ow
[screenXpixels, screenYpixels] = Screen('WindowSize', window);


if nargin < 5 || isempty(positionArray)
    
   [xCenter,yCenter]=RectCenter(windowRect);
else
   xCenter=positionArray(1);
   yCenter=positionArray(2);
end
KbName('UnifyKeyNames');
exitkey = KbName('x');
spacekey = KbName('space');
rightArrow = KbName('RightArrow');
leftArrow = KbName('LeftArrow');
upArrow = KbName('UpArrow');
downArrow = KbName('DownArrow');
increaseSize = KbName('=+');
decreaseSize = KbName('-_');

% Get the centre coordinate of the window
%[xCenter, yCenter] = RectCenter(windowRect);

% Make a base Rect of 200 by 250 pixels
baseRect = [0 0 50 50];
baseSquare = [0 0 100 100];
maxSquare = max(baseSquare);
baseRect = baseRect *circleSize;

% For Ovals we set a miximum diameter up to which it is perfect for
maxDiameter = max(baseRect) * 1.00;

% Center the rectangle on the centre of the screen
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
corner = CenterRectOnPointd(baseSquare, screenXpixels, screenYpixels);
%amplitude of a sinusodial wave implementation

if contrast <= 0
    contrast = abs(contrast);
    amplitude = black + (white*contrast);
    amp_number = amplitude/2;
    % Set the color of the sinusoid peaks and troughs.  
    rectColor = black+amp_number;
    rectColor2 = grey;
elseif contrast>0
    %contrast = contrast-100;
    %amplitude of a sinusodial wave implmentation
    amplitude = white - (white*contrast);
    amp_number = amplitude/2;
    % Set the color of the sinusoid peaks and troughs.  
    rectColor = white-amp_number;
    rectColor2 = grey;
end

ifi = Screen('GetFlipInterval', window);

% Retreive the maximum priority number
topPriorityLevel = MaxPriority(window);

% Length of time and number of frames we will use for each drawing test

numFrames = round(pulseDuration / ifi);

% Numer of frames to wait when specifying good timing
waitframes = 1;
%KbStrokeWait;
if daqValue == 1
    daqLoop();
end
if increment == 1
    XpixelIncrement = screenXpixels/numInc;
    for totalRepeats = 1: numInc

        % Here we do exactly the same as the second example, but we additionally
        % first set the PTB prority level to maximum. This means PTB will take
        % processing priority over other system and applicaiton processes. It is
        % important to switch away from this after stimulus presentation and time
        % critical code in order to allow other processes to run.
        Priority(topPriorityLevel);
        vbl = Screen('Flip', window);
        Screen('FrameRect', window, [255 255 255], corner, maxSquare);
        for frame = 1:numFrames
            [keydown, secs, keycode, deltasexcs] = KbCheck;
            KbReleaseWait;
        centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
        corner = CenterRectOnPointd(baseSquare, screenXpixels, screenYpixels);
        Screen('FrameRect', window, [255 255 255], corner, maxSquare);
        % Draw the rect to the screen
        Screen('FillOval', window, rectColor, centeredRect, maxDiameter);
            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            if keycode(exitkey)
                Screen('CloseAll');
                return
            end
        end
        Priority(0);

        % Finally we do the same as the last example except now we additionally
        % tell PTB that no more drawing commands will be given between coloring the
        % screen and the flip command. This, under some circumstances, can help
        % acheive good timing.
        Priority(topPriorityLevel);
        vbl = Screen('Flip', window);
        %% Uncomment Below to make white square constant
        %Screen('FrameRect', window, [255 255 255], corner, maxSquare);
        for frame = 1:numFrames    
        %Screen('FrameRect', window, [255 255 255], corner, maxSquare);
        %%
        % Draw the rect to the screen
        Screen('FillOval', window, rectColor2, centeredRect, maxDiameter);

            % Tell PTB no more drawing commands will be issued until the next flip
            Screen('DrawingFinished', window);

            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            [keydown, secs, keycode, deltasexcs] = KbCheck;
            KbReleaseWait;
            if keycode(exitkey)
                Screen('CloseAll');
                return
            end

        centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
        corner = CenterRectOnPointd(baseSquare, screenXpixels, screenYpixels);
        end
        Priority(0);
        baseRect = baseRect + [0 0 XpixelIncrement XpixelIncrement];
        maxDiameter = max(baseRect) * 1.00;
        str = sprintf('X: %d, Y: %d, Diameter: %d', xCenter, yCenter,maxDiameter);
		disp(str);
    end
else
for totalRepeats = 1: repNum

% Here we do exactly the same as the second example, but we additionally
% first set the PTB prority level to maximum. This means PTB will take
% processing priority over other system and applicaiton processes. It is
% important to switch away from this after stimulus presentation and time
% critical code in order to allow other processes to run.
Priority(topPriorityLevel);
vbl = Screen('Flip', window);
Screen('FrameRect', window, [255 255 255], corner, maxSquare);
for frame = 1:numFrames
    [keydown, secs, keycode, deltasexcs] = KbCheck;
    KbReleaseWait;
    if keycode(exitkey)
        Screen('CloseAll');
        return
    elseif keycode(upArrow)
        yCenter = yCenter - 5;
        str = sprintf('X: %d, Y: %d, Diameter: %d', xCenter, yCenter,maxDiameter);
		disp(str);
    elseif keycode(downArrow)
        yCenter = yCenter + 5;
        str = sprintf('X: %d, Y: %d, Diameter: %d', xCenter, yCenter,maxDiameter);
		disp(str);
    elseif keycode(rightArrow)
        xCenter = xCenter + 5;
        str = sprintf('X: %d, Y: %d, Diameter: %d', xCenter, yCenter,maxDiameter);
		disp(str);
    elseif keycode(leftArrow)
        xCenter = xCenter - 5;
        str = sprintf('X: %d, Y: %d, Diameter: %d', xCenter, yCenter,maxDiameter);
		disp(str);
    elseif keycode(decreaseSize)
        baseRect = baseRect - [0 0 5 5];
        maxDiameter = max(baseRect) * 1.00;
        str = sprintf('X: %d, Y: %d, Diameter: %d', xCenter, yCenter,maxDiameter);
		disp(str);
    elseif keycode(increaseSize)
         baseRect = baseRect + [0 0 5 5];
        maxDiameter = max(baseRect) * 1.00;
        str = sprintf('X: %d, Y: %d, Diameter: %d', xCenter, yCenter,maxDiameter);
		disp(str);
    end
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
corner = CenterRectOnPointd(baseSquare, screenXpixels, screenYpixels);
Screen('FrameRect', window, [255 255 255], corner, maxSquare);
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
%% Uncomment Below to make white square constant
%Screen('FrameRect', window, [255 255 255], corner, maxSquare);
for frame = 1:numFrames    
%Screen('FrameRect', window, [255 255 255], corner, maxSquare);
%%
% Draw the rect to the screen
Screen('FillOval', window, rectColor2, centeredRect, maxDiameter);

    % Tell PTB no more drawing commands will be issued until the next flip
    Screen('DrawingFinished', window);

    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    [keydown, secs, keycode, deltasexcs] = KbCheck;
    KbReleaseWait;
    if keycode(exitkey)
        Screen('CloseAll');
        return
    elseif keycode(upArrow)
        yCenter = yCenter - 5;
        str = sprintf('X: %d, Y: %d, Diameter: %d', xCenter, yCenter,maxDiameter);
		disp(str);
    elseif keycode(downArrow)
        yCenter = yCenter + 5;
        str = sprintf('X: %d, Y: %d, Diameter: %d', xCenter, yCenter,maxDiameter);
		disp(str);
    elseif keycode(rightArrow)
        xCenter = xCenter + 5;
        str = sprintf('X: %d, Y: %d, Diameter: %d', xCenter, yCenter,maxDiameter);
		disp(str);
    elseif keycode(leftArrow)
        xCenter = xCenter - 5;
        str = sprintf('X: %d, Y: %d, Diameter: %d', xCenter, yCenter,maxDiameter);
		disp(str);
    elseif keycode(decreaseSize)
        baseRect = baseRect - [0 0 5 5];
        maxDiameter = max(baseRect) * 1.00;
        str = sprintf('X: %d, Y: %d, Diameter: %d', xCenter, yCenter,maxDiameter);
		disp(str);
    elseif keycode(increaseSize)
         baseRect = baseRect + [0 0 5 5];
        maxDiameter = max(baseRect) * 1.00;
        str = sprintf('X: %d, Y: %d, Diameter: %d', xCenter, yCenter,maxDiameter);
		disp(str);
    end
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
corner = CenterRectOnPointd(baseSquare, screenXpixels, screenYpixels);
end
Priority(0);

end
end



% Wait for a key press
%KbStrokeWait;

% Clear the screen
sca;
end