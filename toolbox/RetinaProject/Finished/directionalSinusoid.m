function directionalSinusoid(angle, cyclespersecond, gratingwidth, gratingsize, internalRotation, contrast, duration)
% function MyStimulator([angle=0][, cyclespersecond=1][, gratingwidth=360][, gratingsize=2400][, internalRotation=0])
% ___________________________________________________________________
%
% Display an animated grating, using the new Screen('DrawTexture') command.
% This demo demonstrates fast drawing of such a grating via use of procedural
% texture mapping. It only works on hardware with support for the GLSL
% shading language, vertex- and fragmentshaders. The demo ends if you press
% any key on the keyboard.
%
% The grating is not encoded into a texture, but instead a little algorithm - a
% procedural texture shader - is executed on the graphics processor (GPU)
% to compute the grating on-the-fly during drawing.
%
% This is very fast and efficient! All parameters of the grating can be
% changed dynamically. For a similar approach wrt. Gabors, check out
% ProceduralGaborDemo. For an extremely fast aproach for drawing many Gabor
% patches at once, check out ProceduralGarboriumDemo. That demo could be
% easily customized to draw many sine gratings by mixing code from that
% demo with setup code from this demo.
%
% Optional Parameters:
% 'angle' = Rotation angle of grating in degrees.
% 'internalRotation' = Shall the rectangular image patch be rotated
% (default), or the grating within the rectangular patch?
% gratingsize = Size of 2D grating patch in pixels.
% freq (1/gratingwidth) = Frequency of sine grating in cycles per pixel.
% cyclespersecond = Drift speed in cycles per second.
%
% Keyboard actions:
% Letter 'l': turn grating 90 degree anti-clockwise;
% Letter 'r': turn grating 90 degree clockwise;
%        '-': decrese moving speed;
%        '+': increase moving speed;
% Upperarrow: increase grating width;
% Downarrow : decrease grating width;
% Rightarrow: turn grating 5 degree to the right;
% Leftarrow : trun grating 5 degree to the left;
% Letter 'w': make screen white until any key is pressed;
% Letter 'b': make screen black until any key is pressed;
% Letter 'g': make screen gray until any key is pressed;
% Letter 'o': turn screen on (white) and off (black) at 1 Hz until any 
%             key is pressed for longer than 1.5 seconds.
% Letter 'x': exit the program.
%


% History:
% 3/1/9  mk   Written.

% Make sure this is running on OpenGL Psychtoolbox:
AssertOpenGL;

% Initial stimulus parameters for the grating patch:
if nargin < 7 || isempty(duration)
    duration = 10;
end
if nargin < 6 || isempty(contrast)
    contrast = 100;
end

if nargin < 5 || isempty(internalRotation)
    internalRotation = 0;
end

if internalRotation
    rotateMode = kPsychUseTextureMatrixForRotation;
else
    rotateMode = [];
end

if nargin < 4 || isempty(gratingsize)
    gratingsize = 2400;
end

% res is the total size of the patch in x- and y- direction, i.e., the
% width and height of the mathematical support:
res = [gratingsize gratingsize];

if nargin < 3 || isempty(gratingwidth)
    % Frequency of the grating in cycles per pixel: Here 0.01 cycles per pixel:
	gratingwidth = 360; 
%    freq = 1/gratingwidth;
end

if nargin < 2 || isempty(cyclespersecond)
    cyclespersecond = 1;
end

if nargin < 1 || isempty(angle)
    % Tilt angle of the grating:
    angle = 0;
end
Screen('Preference', 'VisualDebugLevel', 3);
% Amplitude of the grating in units of absolute display intensity range: A
% setting of 0.5 means that the grating will extend over a range from -0.5
% up to 0.5, i.e., it will cover a total range of 1.0 == 100% of the total
% displayable range. As we select a background color and offset for the
% grating of 0.5 (== 50% nominal intensity == a nice neutral gray), this
% will extend the sinewaves values from 0 = total black in the minima of
% the sine wave up to 1 = maximum white in the maxima. Amplitudes of more
% than 0.5 don't make sense, as parts of the grating would lie outside the
% displayable range for your computers displays:
contrast = contrast/200;
amplitude = contrast;

% Choose screen with maximum id - the secondary display on a dual-display
% setup for display:
screenid = max(Screen('Screens'));

% Open a fullscreen onscreen window on that display, choose a background
% color of 128 = gray, i.e. 50% max intensity:
win = Screen('OpenWindow', screenid, 128);

% Make sure the GLSL shading language is supported:
AssertGLSL;

% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', win);

% Phase is the phase shift in degrees (0-360 etc.)applied to the sine grating:
phase = 0;

% Compute increment of phase shift per redraw:
phaseincrement = (cyclespersecond * 360) * ifi;

% Build a procedural sine grating texture for a grating with a support of
% res(1) x res(2) pixels and a RGB color offset of 0.5 -- a 50% gray.
gratingtex = CreateProceduralSineGrating(win, res(1), res(2), [0.5 0.5 0.5 0.0]);

% Wait for release of all keys on keyboard, then sync us to retrace:
KbReleaseWait;
vbl = Screen('Flip', win);

% Animation loop: Repeats until keypress...

blackkey = KbName('b');
whitekey = KbName('w');
graykey = KbName('g');
onoffkey = KbName('o');
increasespeed = KbName('+');
decreasespeed = KbName('-');
rightturn = KbName('RightArrow');
leftturn = KbName('LeftArrow');
%reversekey = KbName('R') | KbName('r');
leftkey = KbName('l');
rightkey = KbName('r');
increasegratingwidth = KbName('UpArrow');
decreasegratingwidth = KbName('DownArrow');
%exitkey = KbName('X') | KbName('x');
exitkey = KbName('x');

%[keydown, secs, keycode, deltasecs] = KbCheck;

black = BlackIndex(win);
white = WhiteIndex(win);

keepdisplay = 1;
tstart = GetSecs;

while keepdisplay
		[keydown, secs, keycode, deltasexcs] = KbCheck;
		phase = phase + phaseincrement;
		freq = 1/gratingwidth;
		Screen('DrawTexture', win, gratingtex, [], [], angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
		vbl = Screen('Flip', win, vbl + 0.5 * ifi);
	
	if keycode(exitkey)
		Screen('CloseAll');
		str = sprintf('%d, %d, %d', angle, cyclespersecond, gratingwidth);
		disp(str);
		break
	elseif keycode(increasespeed) 
		cyclespersecond = cyclespersecond + 1;
		phaseincrement = (cyclespersecond * 360) * ifi;
%		[keydown, secs, keycode, deltasecs] = KbCheck;
		
		% Update some grating animation parameters:
		
		% Increment phase by 1 degree:
		phase = phase + phaseincrement;
		
		% Draw the grating, centered on the screen, with given rotation 'angle',
		% sine grating 'phase' shift and amplitude, rotating via set
		% 'rotateMode'. Note that we pad the last argument with a 4th
		% component, which is 0. This is required, as this argument must be a
		% vector with a number of components that is an integral multiple of 4,
		% i.e. in our case it must have 4 components:
%%		Screen('DrawTexture', win, gratingtex, [], [], angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);

		% Show it at next retrace:
%%		vbl = Screen('Flip', win, vbl + 0.5 * ifi);
	
		KbReleaseWait;
	elseif keycode(leftkey)
		angle = angle - 90;
		phase = phase + phaseincrement;
%		freq = 1/gratingwidth;
%%		Screen('DrawTexture', win, gratingtex, [], [], angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
%%		vbl = Screen('Flip', win, vbl + 0.5 * ifi);
		KbReleaseWait;
	elseif keycode(rightkey)
		angle = angle + 90;
		phase = phase + phaseincrement;
%		freq = 1/gratingwidth;
%%		Screen('DrawTexture', win, gratingtex, [], [], angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
%%		vbl = Screen('Flip', win, vbl + 0.5 * ifi);
		KbReleaseWait;
	elseif keycode(decreasespeed)
		cyclespersecond = cyclespersecond - 1;
		phaseincrement = (cyclespersecond * 360) * ifi;
		phase = phase + phaseincrement;
%%		Screen('DrawTexture', win, gratingtex, [], [], angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
%%		vbl = Screen('Flip', win, vbl + 0.5 * ifi);
		KbReleaseWait;
	elseif keycode(increasegratingwidth)
		gratingwidth = gratingwidth + gratingwidth*0.1;
		freq = 1/gratingwidth;
%		freq = 1/(1/freq + 5);
		phase = phase + phaseincrement;
%%		Screen('DrawTexture', win, gratingtex, [], [], angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
%%		vbl = Screen('Flip', win, vbl + 0.5 * ifi);
		KbReleaseWait;
	elseif keycode(decreasegratingwidth)
		gratingwidth = gratingwidth - gratingwidth*0.1;
		freq = 1/gratingwidth;
%		freq = 1/(1/freq - 5);
		phase = phase + phaseincrement;
%%		Screen('DrawTexture', win, gratingtex, [], [], angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
%%		vbl = Screen('Flip', win, vbl + 0.5 * ifi);
		KbReleaseWait;
	elseif keycode(leftturn)
		angle = angle - 5;
		phase = phase + phaseincrement;
%%		Screen('DrawTexture', win, gratingtex, [], [], angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
%%		vbl = Screen('Flip', win, vbl + 0.5 * ifi);
		KbReleaseWait;
	elseif keycode(rightturn)
		angle = angle + 5;
		phase = phase + phaseincrement;
%%		Screen('DrawTexture', win, gratingtex, [], [], angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
%%		vbl = Screen('Flip', win, vbl + 0.5 * ifi);
		KbReleaseWait;
	elseif keycode(blackkey)
		Screen('FillRect', win, black);
		Screen(win, 'Flip');
		KbReleaseWait;
			while ~KbCheck
				pause();
			end	
	elseif keycode(whitekey)
		Screen('FillRect', win, white);
		Screen(win, 'Flip');	
		KbReleaseWait;	
			while ~KbCheck
				pause();
			end	
	elseif keycode(graykey)
		Screen('FillRect', win, 128);
		Screen(win, 'Flip');
		KbReleaseWait;
			while ~KbCheck
				pause();
			end	
	elseif keycode(onoffkey)
		KbReleaseWait;
			while ~KbCheck
				Screen('FillRect', win, black);
				Screen(win, 'Flip');
				WaitSecs(1);
				Screen('FillRect', win, whitexx);
				Screen(win, 'Flip');
				WaitSecs(1);
			end	
		KbReleaseWait;

    end
    
    telapsed = GetSecs - tstart;
    
    if telapsed>duration
        break
    end
end

%if key ~= exitkey 
%	keydown == 0;
%	[keydown, secs, keycode, deltasecs] = KbCheck;
	
%	key = keycode;

%while ~keydown

%		keydown == 0;
	%	exitkey = 0
		
	%if keycode(reversekey)
%		angle = angle+180;
%		phase = phase + phaseincrement;
%		Screen('DrawTexture', win, gratingtex, [], [], angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
%		vbl = Screen('Flip', win, vbl + 0.5 * ifi);
		
%		[keydown, secs, keycode, deltasecs] = KbCheck;
	
	%end
%end


%end

% We're done. Close the window. This will also release all other ressources:
Screen('CloseAll');

% Bye bye!
return;