function singlePulse(repNum, pulseDuration, restBefore, restAfter, contrastLevel)




Screen('Preference','VisualDebugLevel',1);
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer.
screens = Screen('Screens');

% To draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen.
screenNumber = max(screens);

% Define black and white (white will be 1 and black 0). This is because
% in general luminace values are defined between 0 and 1 with 255 steps in
% between. All values in Psychtoolbox are defined between 0 and 1
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Do a simply calculation to calculate the luminance value for grey. This
% will be half the luminace values for white
grey= white / 2;
contrastLevel=contrastLevel/100;
amplitude = white-(contrastLevel*white);
amp_number = amplitude/2;
contrast = white-amp_number;
 HideCursor;

% Open an on screen window using PsychImaging and color it grey.
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);


%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
downKey = KbName('DownArrow');
exitkey = KbName('x');

baseRect = [0 0 50 50];
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
corner = CenterRectOnPointd(baseRect, screenXpixels, screenYpixels);
maxDiameter = max(baseRect) * 1.00;

% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', window);

% Retreive the maximum priority number
topPriorityLevel = MaxPriority(window);

% Length of time and number of frames we will use for each drawing test

numFrames = round(pulseDuration / ifi);

restInterval = round(restBefore / ifi);
restIntervalAfter = round(restAfter / ifi);
% Numer of frames to wait when specifying good timing
waitframes = 1;
%KbStrokeWait;

for totalRepeats = 1: repNum

% First we will demonstrate a poor way in which to get good timing of
% visually presented stimuli. We generally use this way of presenting in
% the demos in order to allow the demos to run on potentially defective
% hardware. In this way of presenting we leave much to chance as regards
% when our stimuli get to the screen, so it is not reccomended that you use
% this approach.
for frame = 1:restIntervalAfter

    % Color the screen grey
    Screen('FillRect', window, black);
    Screen('FrameRect', window, [255 0 0], corner, maxDiameter);
    % Flip to the screen
    Screen('Flip', window);
    [keydown, secs, keycode, deltasexcs] = KbCheck;
    KbReleaseWait;
    if keycode(exitkey)
        Screen('CloseAll');
        return
    end

end


% Here we do exactly the same as the second example, but we additionally
% first set the PTB prority level to maximum. This means PTB will take
% processing priority over other system and applicaiton processes. It is
% important to switch away from this after stimulus presentation and time
% critical code in order to allow other processes to run.
Priority(topPriorityLevel);
vbl = Screen('Flip', window);
for frame = 1:numFrames

    % Color the screen white
    Screen('FillRect', window, contrast);
    Screen('FrameRect', window, [255 0 0], corner, maxDiameter);
    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    [keydown, secs, keycode, deltasexcs] = KbCheck;
    KbReleaseWait;
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
for frame = 1:restInterval

    % Color the screen grey
    Screen('FillRect', window, black);
    Screen('FrameRect', window, [255 0 0], corner, maxDiameter);
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

end
Priority(0);

end

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
%KbStrokeWait;


% Clear the screen.
clear all;
sca;
end