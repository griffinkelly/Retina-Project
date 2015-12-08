function timeNoise = BWNoise(seed, numRects, rectSize, scale, syncToVBL, dontclear, refresh_rate, contrast, duration,daqValue)
% MyBWNoise([numRects=1][, rectSize=128][, scale=1][, syncToVBL=1][, dontclear=0])
%
% Demonstrates how to generate and draw noise patches on-the-fly in a fast way. Can be
% used to benchmark your system by varying the load. If you like this demo
% then also have a look at FastMaskedNoiseDemo that shows how to
% efficiently draw a masked stimulus by use of alpha-blending.
%
% numRects = Number of random patches to generate and draw per frame.
%
% rectSize = Size of the generated random noise image: rectSize by rectSize
%            pixels. This is also the size of the Psychtoolbox noise
%            texture.
%
% scale = Scalefactor to apply to texture during drawing: E.g. if you'd set
% scale = 2, then each noise pixel would be replicated to draw an image
% that is twice the width and height of the input noise image. In this
% demo, a nearest neighbour filter is applied, i.e., pixels are just
% replicated, not bilinearly filtered -- Important to preserve statistical
% independence of the random pixel values!
%
% syncToVBL = 1=Synchronize bufferswaps to retrace. 0=Swap immediately when
% drawing is finished. Value zero is useful for benchmarking the whole
% system, because your measured framerate will not be limited by the
% monitor refresh rate -- Gives you a feeling of how much headroom is left
% in your loop.
%
% dontclear = If set to 1 then the backbuffer is not automatically cleared
% to background color after a flip. Can save up to 1 millisecond on old
% graphics hardware.
%
% Example results on a Intel Pentium-4 3.2 Ghz machine with a NVidia
% GeForce 7800 GTX graphics card, running under M$-Windows XP SP3:
%
% Two patches, 256 by 256 noise pixels each, scaled by any factor between 1
% and 5 yields a redraw rate of 100 Hz.
%
% One patch, 256 by 256 noise pixels, scaled by any factor between 1
% and 5 yields a redraw rate of 196 Hz.
%
% Two patches, 128 by 128 noise pixels each, scaled by any factor between 1
% and 5 yields a redraw rate of 360 - 380 Hz.
% 
% One patch, 128 by 128 noise pixels, scaled by any factor between 1
% and 5 yields a redraw rate of 670 Hz.
%
% Keyboard actions:
% Upperarrow: increase intensity amplitude;
% Downarrow : decrease intensity amplitude;
% Rightarrow: increase pixel and patch size by 20%;
% Leftarrow : increase pixel and patch size by 20%;
%        '-': decrese patch size by 25%;
%        '+': increase patch size by 25%;
% Letter 'w': make screen white until any key is pressed;
% Letter 'b': make screen black until any key is pressed;
% Letter 'g': make screen gray until any key is pressed;
% Letter 'o': turn screen on (white) and off (black) at 1 Hz until any 
%             key is pressed for longer than 1.5 seconds.
% Letter 'x': exit the program.
%

% Abort script if it isn't executed on Psychtoolbox-3:
AssertOpenGL;

% Assign default values for all unspecified input parameters:
if nargin < 1 || isempty(seed)
    seed = 0; % Draw one noise patch by default.
end
if nargin < 2 || isempty(numRects)
    numRects = 1; % Draw one noise patch by default.
end

if nargin < 3 || isempty(rectSize)
    rectSize = 128; % Default patch size is 128 by 128 noisels.
end

if nargin < 4 || isempty(scale)
    scale = 1; % Don't up- or downscale patch by default.
end

if nargin < 5 || isempty(syncToVBL)
    syncToVBL = 1; % Synchronize to vertical retrace by default.
end

if syncToVBL > 0
    asyncflag = 0;
else
    asyncflag = 2;
end

if nargin < 6 || isempty(dontclear)
    dontclear = 0; % Clear backbuffer to background color by default after each bufferswap.
end

if dontclear > 0
    % A value of 2 will prevent any change to the backbuffer after a
    % bufferswap. In that case it is your responsibility to take care of
    % that, but you'll might save up to 1 millisecond.
    dontclear = 2;
end

if nargin <7 || isempty(refresh_rate)
   refresh_rate=0.2;
   hz = 0;
   
end
if refresh_rate
    hz = refresh_rate - .01;
end

if nargin <8 || isempty(contrast)
    contrast = 100;
end
if contrast
    toAdd = ((contrast/100) * 127.5)-127.5;
    int_amplitude = 127.5 + toAdd;
end
if nargin < 9 || isempty(duration)
    duration = 10; 
end
if nargin <10 || isempty(daqValue)
    daqValue = 0;
end

Screen('Preference', 'VisualDebugLevel', 1);
KbName('UnifyKeyNames');
blackkey = KbName('b');
whitekey = KbName('w');
graykey = KbName('g');
onoffkey = KbName('o');
increasepatchsize = KbName('+');
decreasepatchsize = KbName('-');
increasepixelsize = KbName('RightArrow');
decreasepixelsize = KbName('LeftArrow');
%reversekey = KbName('R') | KbName('r');
leftkey = KbName('l');
rightkey = KbName('r');
increaseint_amplitude = KbName('UpArrow');
decreaseint_amplitude = KbName('DownArrow');
%exitkey = KbName('X') | KbName('x');
exitkey = KbName('x');

%[keydown, secs, keycode, deltasecs] = KbCheck;

keepdisplay = 1;
%int_amplitude = 127.5;
maxSize = 1080;
minpixel = 1;

try
    % Find screen with maximal index:
    screenid = max(Screen('Screens'));

    % Open fullscreen onscreen window on that screen. Background color is
    % gray, double buffering is enabled. Return a 'win'dowhandle and a
    % rectangle 'winRect' which defines the size of the window:
    [win, winRect] = Screen('OpenWindow', screenid, 128);

	black = BlackIndex(win);
	white = WhiteIndex(win);
    baseRect = [0 0 50 50];
    [screenXpixels, screenYpixels] = Screen('WindowSize', win);
    corner = CenterRectOnPointd(baseRect, screenXpixels, screenYpixels);
    maxDiameter = max(baseRect) * 1.00;
    
    % Compute destination rectangle locations for the random noise patches:

    % 'objRect' is a rectangle of the size 'rectSize' by 'rectSize' pixels of
    % our Matlab noise image matrix:
    objRect = SetRect(0,0, rectSize, rectSize);

    % ArrangeRects creates 'numRects' copies of 'objRect', all nicely
    % arranged / distributed in our window of size 'winRect':
    dstRect = ArrangeRects(numRects, objRect, winRect);

    % Now we rescale all rects: They are scaled in size by a factor 'scale':
    for i=1:numRects
        % Compute center position [xc,yc] of the i'th rectangle:
        [xc, yc] = RectCenter(dstRect(i,:));
        % Create a new rectange, centered at the same position, but 'scale'
        % times the size of our pixel noise matrix 'objRect':
        dstRect(i,:)=CenterRectOnPoint(objRect * scale, xc, yc);
%		rectSize = rectSize/scale;
    end

    if daqValue == 1
         daqLoop();
    end
    % Init framecounter to zero and take initial timestamp:
    count = 0;    
    tstart = GetSecs;

    % Run noise image drawing loop for 1000 frames:
    count = 1;    
    tstart = GetSecs;
    
while keepdisplay

		[keydown, secs, keycode, deltasexcs] = KbCheck;
		KbReleaseWait;	
%		Screen('FillRect', win, 128);
%		Screen(win, 'Flip'); 
        seed_size = size(seed);
        if seed_size(1)>1
            disp('entered');
            for i = 1:length(seed(1,1,1,:))
                noiseimg(:, :, 1) = seed(:,:,1,i);
                tex=Screen('MakeTexture', win, noiseimg);
                Screen('DrawTexture', win, tex, [], dstRect(1,:), [], 0);
                Screen('Flip', win, 0, dontclear, asyncflag);
                Screen('FrameRect', win, [255 255 255], corner, maxDiameter);
                pause(hz);
                if i == length(seed(1,1,1,:))
                    Screen('CloseAll');
                    return
                end
            end
        else
		% Generate and draw 'numRects' noise images:
        for i=1:numRects
            % Compute noiseimg noise image matrix with Matlab:
            % Normally distributed noise with mean 128 and stddev. 50, each
            % pixel computed independently:
            noiseimg=(int_amplitude*(floor(2*rand(rectSize, rectSize))*2-1) + 127.5); 
%           noiseimg=(int_amplitude*floor(3*rand(rectSize, rectSize)-1) + 128);
            % Convert it to a texture 'tex':
            tex=Screen('MakeTexture', win, noiseimg);

            % Draw the texture into the screen location defined by the
            % destination rectangle 'dstRect(i,:)'. If dstRect is bigger
            % than our noise image 'noiseimg', PTB will automatically
            % up-scale the noise image. We set the 'filterMode' flag for
            % drawing of the noise image to zero: This way the bilinear
            % filter gets disabled and replaced by standard nearest
            % neighbour filtering. This is important to preserve the
            % statistical independence of the noise pixels in the noise
            % texture! The default bilinear filtering would introduce local
            % correlations when scaling is applied:
            Screen('DrawTexture', win, tex, [], dstRect(i,:), [], 0);
            Screen('FrameRect', win, [255 255 255], corner, maxDiameter);

            % After drawing, we can discard the noise texture.
%            Screen('Close', tex);
%			KbReleaseWait;
        end
%		KbReleaseWait;
        pause(hz);
        timeNoise(:,:,:,count)=noiseimg;
        end
  	if keycode(exitkey)
		Screen('CloseAll');
		str = sprintf('%d, %d, %d', int_amplitude, rectSize, scale);
		disp(str);
%		psychrethrow(psychlasterror);
		break
	elseif keycode(increaseint_amplitude) 
		for i=1:numRects
			int_amplitude = int_amplitude + 5;
%%			noiseimg=(int_amplitude*(floor(2*rand(rectSize, rectSize))*2-1) + 128); 
				%with only black and white)
%           noiseimg=(int_amplitude*floor(3*rand(rectSize, rectSize)-1) + 128); 
				%with gray in addition to black and white)
%			noiseimg=(int_amplitude*randn(rectSize, rectSize) + 128); 
				%with shades
%%			tex=Screen('MakeTexture', win, noiseimg);
%%			Screen('DrawTexture', win, tex, [], dstRect(i,:), [], 0);
			KbReleaseWait;
		end
	elseif keycode(decreaseint_amplitude) 
		for i=1:numRects
			int_amplitude = int_amplitude - 5;
%%			noiseimg=(int_amplitude*(floor(2*rand(rectSize, rectSize))*2-1) + 128);
%			noiseimg=(int_amplitude*randn(rectSize, rectSize) + 128);
%%			tex=Screen('MakeTexture', win, noiseimg);
%%			Screen('DrawTexture', win, tex, [], dstRect(i,:), [], 0);
			KbReleaseWait;
		end
	elseif keycode(increasepixelsize) 
		for i=1:numRects
			scale = scale + scale*0.2 ;
%			newSize = rectSize*scale;
%			rectSize = rectSize/scale;
			dstRect(i,:)=CenterRectOnPoint(objRect * scale, xc, yc);
%			if newSize > maxSize
%				objRect = SetRect(0,0, maxSize, maxSize);
%				dstRect(i,:)=CenterRectOnPoint(objRect * scale, xc, yc);
%				noiseimg=(int_amplitude*randn(maxSize, maxSize) + 128);
%				tex=Screen('MakeTexture', win, noiseimg);
%				Screen('DrawTexture', win, tex, [], dstRect(i,:), [], 0);
%			end
%			dstRect(i,:)=CenterRectOnPoint(objRect * scale, xc, yc);
%%			noiseimg=(int_amplitude*(floor(2*rand(rectSize, rectSize))*2-1) + 128);
%           noiseimg=(int_amplitude*floor(3*rand(rectSize, rectSize)-1) + 128);
%			noiseimg=(int_amplitude*randn(rectSize, rectSize) + 128);
%%			tex=Screen('MakeTexture', win, noiseimg);
%%			Screen('DrawTexture', win, tex, [], dstRect(i,:), [], 0);
			KbReleaseWait;
		end
	elseif keycode(decreasepixelsize) 
		for i=1:numRects
			scale = scale - scale*0.2 ;
			dstRect(i,:)=CenterRectOnPoint(objRect * scale, xc, yc);
            
            if keycode(exitkey)
                break
            end
%%			noiseimg=(int_amplitude*(floor(2*rand(rectSize, rectSize))*2-1) + 128);
%			noiseimg=(int_amplitude*floor(3*rand(rectSize, rectSize)-1) + 128);
%			noiseimg=(int_amplitude*randn(rectSize, rectSize) + 128);
%			rectSize = rectSize/scale;
%%			tex=Screen('MakeTexture', win, noiseimg);
%%			Screen('DrawTexture', win, tex, [], dstRect(i,:), [], 0);
			KbReleaseWait;
		end
	elseif keycode(increasepatchsize) 
		for i=1:numRects
			rectSize = rectSize + rectSize*0.25;
			objRect = SetRect(0,0, rectSize, rectSize);
			dstRect(i,:)=CenterRectOnPoint(objRect * scale, xc, yc);
            if keycode(exitkey)
                break
            end
%			if rectSize > maxSize
%				objRect = SetRect(0,0, maxSize, maxSize);
%				dstRect(i,:)=CenterRectOnPoint(objRect * scale, xc, yc);
%				noiseimg=(int_amplitude*randn(maxSize, maxSize) + 128);
%				tex=Screen('MakeTexture', win, noiseimg);
%				Screen('DrawTexture', win, tex, [], dstRect(i,:), [], 0);
%			end
%			dstRect(i,:)=CenterRectOnPoint(objRect * scale, xc, yc);
%%			noiseimg=(int_amplitude*(floor(2*rand(rectSize, rectSize))*2-1) + 128);
%			noiseimg=(int_amplitude*floor(3*rand(rectSize, rectSize)-1) + 128);
%			noiseimg=(int_amplitude*randn(rectSize, rectSize) + 128);
%%			tex=Screen('MakeTexture', win, noiseimg);
%%			Screen('DrawTexture', win, tex, [], dstRect(i,:), [], 0);
			KbReleaseWait;
		end
	elseif keycode(decreasepatchsize) 
		for i=1:numRects
			rectSize = rectSize - rectSize*0.25;
			if rectSize < minpixel
				rectSize = minpixel;
            end
            if keycode(exitkey)
                break
            end
            
			objRect = SetRect(0,0, rectSize, rectSize);
			dstRect(i,:)=CenterRectOnPoint(objRect * scale, xc, yc);
%%			noiseimg=(int_amplitude*(floor(2*rand(rectSize, rectSize))*2-1) + 128);
%			noiseimg=(int_amplitude*floor(3*rand(rectSize, rectSize)-1) + 128);
%			noiseimg=(int_amplitude*randn(rectSize, rectSize) + 128);
%%			tex=Screen('MakeTexture', win, noiseimg);
%%			Screen('DrawTexture', win, tex, [], dstRect(i,:), [], 0);
			KbReleaseWait;
		end
	elseif keycode(blackkey)
		Screen('FillRect', win, black);
		Screen(win, 'Flip');
		KbReleaseWait;
			while ~KbCheck
				pause();
			end
		Screen('FillRect', win, 128);
		Screen(win, 'Flip');    	
	elseif keycode(whitekey)
		Screen('FillRect', win, white);
		Screen(win, 'Flip');	
		KbReleaseWait;	
			while ~KbCheck
				pause();
			end	
		Screen('FillRect', win, 128);
		Screen(win, 'Flip');   
	elseif keycode(graykey)
		Screen('FillRect', win, 128);
		Screen(win, 'Flip');
%		KbReleaseWait;
			while ~KbCheck
				KbReleaseWait;
				pause();
			end
		KbReleaseWait;
	elseif keycode(onoffkey)
		while ~KbCheck
				Screen('FillRect', win, black);
				Screen(win, 'Flip');
				WaitSecs(1);
				Screen('FillRect', win, white);
				Screen(win, 'Flip');
				WaitSecs(1);
			end	
		KbReleaseWait;
		Screen('FillRect', win, 128);
		Screen(win, 'Flip');   
	end
		
        % Done with drawing the noise patches to the backbuffer: Initiate
        % buffer-swap. If 'asyncflag' is zero, buffer swap will be
        % synchronized to vertical retrace. If 'asyncflag' is 2, bufferswap
        % will happen immediately -- Only useful for benchmarking!
        Screen('Flip', win, 0, dontclear, asyncflag);

        % Increase our frame counter:
    count = count + 1;
    telapsed = GetSecs - tstart;

    if telapsed>duration
        Screen('CloseAll');
		str = sprintf('%d, %d, %d', rectSize, scale, int_amplitude);
		disp(str);
%		psychrethrow(psychlasterror);
		break
    end
end

    % We're done: Output average framerate:
%    telapsed = GetSecs - tstart
%    updaterate = count / telapsed
    
    % Done. Close Screen, release all ressouces:
%    Screen('CloseAll');
catch
    % Our usual error handler: Close screen and then...
    Screen('CloseAll');
    % ... rethrow the error.
    psychrethrow(psychlasterror);
end
