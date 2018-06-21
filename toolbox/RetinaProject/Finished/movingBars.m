function movingBars(numberofbars, skipX, daqValue)
%Moving Bars is a function which will segement a black screen into a
%specific number of white flashing bars. Will wait for key press before
%moving on to next flash of bar. Each bar will flash for one second.
%numberofbars: the number of bars that will display in both the x and y
%directions.
%Written: Griffin Kelly, 2015, griffinkelly2013@gmail.com
if nargin <3 || isempty(daqValue)
    daqValue = 0;
end
if nargin < 2 || isempty(skipX)
    % Tilt angle of the grating:
    skipX = 0;
end
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
rightArrow = KbName('RightArrow');
leftArrow = KbName('LeftArrow');

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);


% Set the width for our rectangle 
baseRect = [0 0 screenXpixels/numberofbars screenYpixels];

baseRect2 = [0 0 100 100];
corner = CenterRectOnPointd(baseRect2, screenXpixels, screenYpixels);
maxDiameter = max(baseRect2) * 1.00;
% Center the rectangle on the centre of the screen using fractional pixel
% values.
% For help see: CenterRectOnPointd
if daqValue == 1
    daqLoop();
end

ifi = Screen('GetFlipInterval', window);
timedInterval = round(1/ ifi);
xCount = numberofbars-1;
ii = xCount/2;

if(skipX == 1)
    baseRect = [0 0 screenXpixels screenYpixels/numberofbars];

    yCount = numberofbars - 1 ;
    ii = yCount/2;
    while ii<yCount

        centeredRect = CenterRectOnPointd(baseRect, xCenter, ((screenYpixels/numberofbars)*ii));
        % Draw the fixation cross in white, set it to the center of our screen and
        % set good quality antialiasing  
        for frame = 1:timedInterval
            [keydown, secs, keycode, deltasexcs] = KbCheck;
            KbReleaseWait;
            if keycode(exitkey)
                Screen('CloseAll');
                return
            elseif keycode(rightArrow)
                ii = ii + 1;
                str = sprintf('Y: %d',((screenYpixels/numberofbars)*ii));
                disp(str); 
            elseif keycode(leftArrow)
                ii = ii - 1;
                str = sprintf('Y: %d',((screenYpixels/numberofbars)*ii));
                disp(str); 
            end
            Screen('FrameRect', window, [255 255 255], corner, maxDiameter);
            Screen('FillRect', window, white, centeredRect);
            Screen('Flip', window);

        end
        for frame = 1:timedInterval
            [keydown, secs, keycode, deltasexcs] = KbCheck;
            KbReleaseWait;
            if keycode(exitkey)
                Screen('CloseAll');
                return
            elseif keycode(rightArrow)
                ii = ii + 1;
                str = sprintf('Y: %d',((screenYpixels/numberofbars)*ii));
                disp(str); 
            elseif keycode(leftArrow)
                ii = ii - 1;
                str = sprintf('Y: %d',((screenYpixels/numberofbars)*ii));
                disp(str);              

            end
            Screen('FrameRect', window, [255 255 255], corner, maxDiameter);
            % Flip to the screen
            Screen('Flip', window);

        end

    end
    
else
    
while ii < xCount


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
        elseif keycode(rightArrow)
            ii = ii + 1;
            str = sprintf('X: %d',((screenXpixels/numberofbars)*ii));
            disp(str);
        elseif keycode(leftArrow)
            ii = ii - 1;
            str = sprintf('X: %d',((screenXpixels/numberofbars)*ii));
            disp(str);
        end
        Screen('FrameRect', window, [255 255 255], corner, maxDiameter);
        Screen('FillRect', window, white, centeredRect);               
        Screen('Flip', window);               

    end
    for frame = 1:timedInterval
        [keydown, secs, keycode, deltasexcs] = KbCheck;
        KbReleaseWait;
        if keycode(exitkey)
            Screen('CloseAll');
            return
        elseif keycode(rightArrow)
            ii = ii + 1;
            str = sprintf('X: %d',((screenXpixels/numberofbars)*ii));
            disp(str);
        elseif keycode(leftArrow)
            ii = ii - 1;
            str = sprintf('X: %d',((screenXpixels/numberofbars)*ii));
            disp(str);
        end
        Screen('FrameRect', window, [255 255 255], corner, maxDiameter);
        % Flip to the screen
        Screen('Flip', window);
        Screen('FillRect', window, black);               
        
    end


end

baseRect = [0 0 screenXpixels screenYpixels/numberofbars];

yCount = numberofbars - 1 ;
ii = yCount/2;
while ii<yCount

    centeredRect = CenterRectOnPointd(baseRect, xCenter, ((screenYpixels/numberofbars)*ii));
    % Draw the fixation cross in white, set it to the center of our screen and
    % set good quality antialiasing  
    for frame = 1:timedInterval
        [keydown, secs, keycode, deltasexcs] = KbCheck;
        KbReleaseWait;
        if keycode(exitkey)
            Screen('CloseAll');
            return
        elseif keycode(rightArrow)
            ii = ii + 1;
            str = sprintf('Y: %d',((screenYpixels/numberofbars)*ii));
            disp(str); 
        elseif keycode(leftArrow)
            ii = ii - 1;
            str = sprintf('Y: %d',((screenYpixels/numberofbars)*ii));
            disp(str); 
        end
        Screen('FrameRect', window, [255 255 255], corner, maxDiameter);
        Screen('FillRect', window, white, centeredRect);
        Screen('Flip', window);

    end
    for frame = 1:timedInterval
        [keydown, secs, keycode, deltasexcs] = KbCheck;
        KbReleaseWait;
        if keycode(exitkey)
            Screen('CloseAll');
            return
        elseif keycode(rightArrow)
            ii = ii + 1;
            str = sprintf('Y: %d',((screenYpixels/numberofbars)*ii));
            disp(str); 
        elseif keycode(leftArrow)
            ii = ii - 1;
            str = sprintf('Y: %d',((screenYpixels/numberofbars)*ii));
            disp(str); 
        end
        Screen('FrameRect', window, [255 255 255], corner, maxDiameter);
        % Flip to the screen
        Screen('Flip', window);
         
    end
    
end
end


% Clear the screen
sca; 