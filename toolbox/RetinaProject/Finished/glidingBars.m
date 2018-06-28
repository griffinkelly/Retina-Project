function glidingBars(barWidth, vx, barColor, angle, daqValue)
%Gliding Bars(barWidth=60, vx=1,barColor=1 daqValue=0)
%bar color is a percentage 0-1, .5 being gray.


%Written: Griffin Kelly, 2018, griffinkelly2013@gmail.com
if nargin <3 || isempty(barColor)
    barColor = 1;
end
if nargin <4 || isempty(angle)
    angle = 0;
end
if nargin <5 || isempty(daqValue)
    daqValue = 0;
end
if nargin < 2 || isempty(vx)
    % Tilt angle of the gratingx
    vx = 500;
end
if nargin < 1 || isempty(barWidth)
    % Tilt angle of the grating:
    barWidth = 60;
end


% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
% Get the screen numbers
screens = Screen('Screens');

if daqValue == 1
    daqLoop();
end


KbName('UnifyKeyNames');
exitkey = KbName('x');
spacekey = KbName('space');
rightArrow = KbName('RightArrow');
leftArrow = KbName('LeftArrow');


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

% Dimension of our texure (it will be this value +1 pixel
dim = 100;

% Make a second dimension value which is increased by a factor of the
% squareroot of 2. We need to do this because in this demo we will be using
% internal texture rotation. We round this to the nearest pixel.
dim2 = ceil(dim * sqrt(2));

% Define a simple spiral texture by defining X and Y coordinates with the
% meshgrid command, converting these to polar coordinates and finally
% defining the spiral texture. Not here we use dim2 NOT dim.
color = white;

% Make our sprial texure into a screen texture for drawing
spiralTexture = Screen('MakeTexture', window, [barColor barColor barColor]);

% Define the destination rectangles for our spiral textures. This will be
% the same size as the window we use to view our texture.
ndim = dim * 2 + 1;
baseRectDst = [0 0 ndim ndim];
dstRects = nan(4, 4);


% Now we create a window through which we will view our texture. This is
% the same size as our destination rectangles. But we shift it in X and Y
% by a value of dim2 - dim. This makes sure our window is centered on the
% middle of the enlarged texture we made for internal texture rotation.
srcRect = baseRectDst + (dim2 - dim);
baseRect2 = [0 0 100 100];
corner = CenterRectOnPointd(baseRect2, screenXpixels, screenYpixels);
maxDiameter = max(baseRect2) * 1.00;
% Query the frame duration
ifi = Screen('GetFlipInterval', window);

%get  pixels per advancement, multiply by 1/refresh rate of monitor. 
vx = vx*ifi;

x=0;
y=0;
counter = 0;
keepdisplay = 1;

while keepdisplay
    Screen('FrameRect', window, [255 255 255], corner, maxDiameter);

    if (angle==0)
        %done
        x=mod(x+vx, screenXpixels);
        y=mod(y+vx, screenYpixels*2);   
        x1 = 0-screenXpixels;
        y1 = y;
        x2 = screenXpixels*3;
        y2 = y+barWidth;
        anglePerformed=0;

    elseif (angle==30)
        %done based on 0
        x=mod(x+vx, screenXpixels);
        y=mod(y+vx, screenYpixels*2);   
        x1 = 0-screenXpixels;
        y1 = y;
        x2 = screenXpixels*3;
        y2 = y+barWidth;
        anglePerformed=30;
    elseif (angle==60)
        x=mod(x-vx, screenXpixels*2);
        y=mod(y-vx, screenYpixels);
        x1=x;
        y1=0-screenYpixels;
        x2=x+barWidth;
        y2=screenYpixels*3;
        anglePerformed = -30;
    elseif (angle==90)
        %done
        x=mod(x-vx, screenXpixels*2);
        y=mod(y-vx, screenYpixels);
        x1=x;
        y1=0-screenYpixels;
        x2=x+barWidth;
        y2=screenYpixels*3;
        anglePerformed = 0;
    elseif (angle==120)
        %doxne
        x=mod(x-vx, screenXpixels*2);
        y=mod(y-vx, screenYpixels);
        x1=x-screenXpixels;
        y1=0-screenYpixels;
        x2=x+barWidth-screenXpixels;
        y2=screenYpixels*3;
        anglePerformed = 30;
        
    elseif (angle==150)
        %done
        x=mod(x+vx, screenXpixels*2);
        y=mod(y-vx, screenYpixels*2);   
        x1 = 0-screenXpixels;
        y1 = y-screenYpixels;
        x2 = screenXpixels*3;
        y2 = y+barWidth-screenYpixels;
        anglePerformed=-30;        

    elseif (angle==180)
        %done
        x=mod(x-vx, screenXpixels);
        y=mod(y-vx, screenYpixels*2);   
        x1 = 0-screenXpixels;
        y1 = y;
        x2 = screenXpixels*3;
        y2 = y+barWidth;
        anglePerformed=0;
    elseif (angle==210)
        %done
        x=mod(x-vx, screenXpixels);
        y=mod(y-vx, screenYpixels*2);   
        x1 = 0-screenXpixels;
        y1 = y;
        x2 = screenXpixels*3;
        y2 = y+barWidth;
        anglePerformed=30;
    elseif (angle==240)
        %done
        x=mod(x+vx, screenXpixels*2);
        y=mod(y+vx, screenYpixels);
        x1=x;
        y1=0-screenYpixels;
        x2=x+barWidth;
        y2=screenYpixels*3;
        anglePerformed = -30;

    elseif (angle==270)
        %done
        x=mod(x+vx, screenXpixels*2);
        y=mod(y+vx, screenYpixels);
        x1=x;
        y1=0-screenYpixels;
        x2=x+barWidth;
        y2=screenYpixels*3;
        anglePerformed = 0;
    elseif (angle==300)
        %done
        x=mod(x+vx, screenXpixels*2);
        y=mod(y+vx, screenYpixels);
        x1=x;
        y1=0-screenYpixels;
        x2=x+barWidth;
        y2=screenYpixels*3;
        anglePerformed = 30; 

    elseif (angle==330)
        %done, based on 0
        x=mod(x+vx, screenXpixels);
        y=mod(y+vx, screenYpixels*2);   
        x1 = 0-screenXpixels;
        y1 = y-screenYpixels;
        x2 = screenXpixels*3;
        y2 = y+barWidth-screenYpixels;
        anglePerformed=-30;
    end    
    
    if (angle == 390)
       sca;
       break
    end
    % Draw the first two textuxes using whole "external" texture rotation
    Screen('DrawTextures', window, spiralTexture, srcRect,...
         [x1;y1;x2;y2], anglePerformed, [], [], []);

    % Flip to the screen
    Screen('Flip', window);
    
    [keydown, secs, keycode, deltasexcs] = KbCheck;
    KbReleaseWait;
    if keycode(rightArrow)
       angle = angle+30;
    elseif keycode(leftArrow)
        angle = angle-30;
    elseif keycode(exitkey)
        sca;
        break
    end
% 
%     % Increment the angle
%     angle = angle + angleInc;

end

% Clear the screen
sca;