   function sinusoidInverting(morphType, showMaskOnly, degree, hertz, amplitude, duration, width, offset)
% SimpleImageMixingDemo([morphType=gaussian][, showMaskOnly=0])
%
% This is a simple demonstration of shader use to morph two images/textures 
% back and forth using a non-uniform transparency pattern (here illustrated 
% with gaussian and left-to-right ramp, but you can use virtually any
% transparency mask).
% 
% INPUTS:
% morphType - string, either 'gaussian' or 'ramp'
% showMaskOnly - 0/1 to either see the mask or the resulting morphing
% Degree - Shift out of a possible 360 deg
% Hertz - How many times it cycles per second, alternating sine waves
% Amplitude - also contrast, but its how far in amplitude the sine wave
% cycles out of a possible 1
% Duration- how long the program cycles for
% Width - width of grating
% Offset-- horizontal offset in pixels
%
% Made after ImageMixingTutorial.m by Mario Kleiner
% Written by Natalia Zaretskaya 25 Nov 2014
% Adapted by Griffin Kelly 2015


% Use normalized color range, ranging from 0 to 1
PsychDefaultSetup(2);

if nargin < 1 || isempty(morphType)
    % decide whether you want a ramp or a gaussian
    morphType = 'ramp'; % 'ramp' or 'gaussian'
end

if nargin < 2 || isempty(showMaskOnly)
    showMaskOnly = 0;
end
if nargin < 3 || isempty(degree)
    degree = 0;
end
if nargin < 4 || isempty(hertz)
    hertz = 0.03;
end
if nargin < 5 || isempty(amplitude)
    amplitude = 100;
end
if nargin < 6 || isempty(duration)
    duration = 100;
end
if nargin < 7 || isempty(width)
    width = 100 ;
end

if nargin < 8 || isempty(offset)
    offset = 0;
end
% open window
Screen('Preference', 'VisualDebugLevel', 1);
[w, wrect] = PsychImaging('OpenWindow',  max(Screen('Screens')), [0.5 0.5 0.5], []);
[cx, xy] = RectCenter(wrect);
Screen('TextSize', w, 20)


% Open an offscreen window the same size as the onscreen window. We use
% this to define the alpha/mixing weight channel used to later mix
% two images together:
masktex = Screen('OpenOffscreenWindow', w, [0 0 0 0]);
width=(1/width);

% -- make textures -- %
    s=min(2000, 2000 ) / 6;
	[x,y]=meshgrid(-s:s-1, -s:s-1);
	angle=degree*pi/180; % 30 deg orientation.
	f=width *2*pi; % cycles/pixel
    a=cos(angle)*f;
	b=sin(angle)*f;
    
    amplitude = amplitude/100;
    % Build grating texture:
    m=amplitude*sin(a*x+b*y+offset)+.5;
     m2=-amplitude*sin(a*x+b*y+offset)+.5;



tex1 = Screen('MakeTexture', w, m2,[],[], 2);
tex2 = Screen('MakeTexture', w, m,[],[], 2); % white background
redSquare = Screen('MakeTexture', w, 255,[],[], 2);

% Create a shader that allows to combine the up to four input channels
% of a texture into a weighted linear combination, using 'DrawTexture's
% modulateColor parameter to specify the weights. This is used for
% morphing between up to four alpha-masks, stored in the morphedAlphaTexture.
minimorphshader = CreateSinglePassImageProcessingShader(w, 'WeightedColorComponentSum');

% Create a texture with alpha pattern we want to morph between.
if strcmp(morphType, 'ramp')
    morphPattern = meshgrid(RectWidth(wrect./2):RectWidth(wrect./2), RectHeight(wrect./2):RectHeight(wrect./2));
    morphPattern = morphPattern./max(morphPattern(:));
    disp('using ramp!')
elseif strcmp(morphType, 'gaussian')
    xsd = 130; % standard deviation
    ysd = 130;
    x = -RectHeight(wrect./2)/2:RectHeight(wrect./2)/2;
    y = -RectHeight(wrect./2)/2:RectHeight(wrect./2)/2;
    [x,y] = meshgrid(x,y);
    morphPattern = max( abs((x / xsd))+ abs((y / ysd) )) ; % gauss
    disp('using gaussian!')
else
    sca
    error('Undefined morph pattern');
end
morphTex = Screen('MakeTexture', w, morphPattern, [], [], [], [], minimorphshader);

baseRect = [0 0 50 50];
[screenXpixels, screenYpixels] = Screen('WindowSize', w);
corner = CenterRectOnPointd(baseRect, screenXpixels, screenYpixels);
maxDiameter = max(baseRect) * 1.00;

daqLoop();

c = 1;
vector=[];
morphVector=[];
tstart = GetSecs;
while 1
    
    % check keyboard:
    keyIsDown = KbCheck;
    if keyIsDown
        break
    end
    
    % for simplicity: sine modulation
    % morph values range from 0 (image A) to 2 (image B)
    % 1 corresponds to intermediate stage
    morphValue =  0.5*(sin(hertz*c))+.5 ;
    morphVector = [morphVector, morphValue];
    % A mask morphing from all-zero to a gauss blob to all-one and back:
    if morphValue < 1.0  
        weights = [morphValue, 0, 0, 0];
        vector = [vector,0];
    else
        eweight = morphValue - 1;
        weights = [1-eweight, 0, 0, eweight];
         vector = [vector,2];
    end
    Screen('DrawTexture', masktex, morphTex, [], CenterRectOnPoint(wrect./1, cx, xy), [], [], [], weights);
    
    % First clear framebuffer to backgroundcolor, not using
    % alpha blending (== GL_ONE, GL_ZERO). Enable all channels
    % for writing [1 1 1 1], so everything gets cleared to good
    % starting values:
    Screen('BlendFunction', w, GL_ONE, GL_ZERO, [0 0 0 1]);
    Screen('FillRect', w, [0.5 0.5 0.5]);
    
    % Then keep alpha blending disabled and draw the mask
    % texture, but *only* into the alpha channel. Don't touch
    % the RGB color channels but use the channel mask vi a
    % [R G B A] = [0 0 0 1] to only enable the alpha-channel
    % for drawing into it. Use of modulateColor = [1 0 0 0] and
    % the minimorphshader causes the red channel to be copied into
    % the alpha channel. As red == luminance this means the grayscale
    % luminance value of masktext directly defines the final mask weights.
    
    if showMaskOnly
        Screen('BlendFunction', w, GL_ONE, GL_ZERO, [1 1 1 1]); % => use [1 1 1 1] without drawing the images to visualize the mask        
        Screen('DrawTexture', w, masktex, [], [], [], [], [], [1 0 0 0], minimorphshader);
    else
        Screen('BlendFunction', w, GL_ONE, GL_ZERO, [0 0 0 1]); % => use [1 1 1 1] without drawing the images to visualize the mask
        Screen('DrawTexture', w, masktex, [], [], [], [], [], [1 0 0 0], minimorphshader);
        
        % draw first image
        Screen('BlendFunction', w, GL_DST_ALPHA, GL_ZERO, [1 1 1 0]);
        Screen('DrawTexture', w, tex1, [], CenterRectOnPoint(wrect./1, cx, xy));
        Screen('DrawTexture', w, redSquare, [], corner);
        % draw second image
        Screen('BlendFunction', w, GL_ONE_MINUS_DST_ALPHA, GL_ONE, [1 1 1 0]);
        Screen('DrawTexture', w, tex2, [], CenterRectOnPoint(wrect./1, cx, xy));
        
        %draw white square
        Screen('DrawTexture', w, redSquare, [], corner);
        
    end
    
    % show morphing stage as value:x
    %myString = sprintf('morph stage 0 to 2: %1.1f ', morphValue);
    %DrawFormattedText(w, myString, 0, 0, [1 0 0 ]);
    Screen('FrameRect', w, [255 255 255], corner, maxDiameter);
    Screen('Flip', w); 
    
    c = c+1; % update the count
    telapsed = GetSecs - tstart;
    
    if telapsed>duration
        disp(telapsed);
		break
    end
end

sca
 end
 