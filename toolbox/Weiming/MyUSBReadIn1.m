function MyStimulatorUSB(angle, cyclespersecond, gratingwidth, gratingsize, internalRotation)
% function MyStimulatorUSB([angle=0][, cyclespersecond=1][, gratingwidth=360][, gratingsize=2400][, internalRotation=0])
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
% USB-1208FS Interface: 
%    Pin #20 high will resume pattern stimulation when blanked 
%    with black screen (key "b" was pressed once)  
%


% Make sure this is running on OpenGL Psychtoolbox:
AssertOpenGL;

% Wait for release of all keys on keyboard:
KbReleaseWait;

acquisitionkey = KbName('a');
exitkey = KbName('x');

channel = 9; % use #2 CH1 IN on USB-1208FS
range = 0; % set to use +/- 10V
v = 0;

keepwaiting = 1;

fp=fopen('DataTxt.txt', 'w');
fprintf(fp, 'Counter	   Running time	  Voltage\n');
%fprintf(fp, '\n');
disp(sprintf("Counter	   Running time	  Voltage"));

while keepwaiting
	    [keydown, secs, keycode, deltasexcs] = KbCheck;
	if keycode(exitkey)
		Screen('CloseAll');
%		str = sprintf('%d, %d, %d', angle, cyclespersecond, gratingwidth);
%		disp(str);
		break
	elseif keycode(acquisitionkey)
	    % Init counter to zero and take initial timestamp:
        count = 0;    
        tstart = GetSecs;
 
		device = DaqFind;
		err = DaqReset(device);
		device = DaqDeviceIndex;
		err = DaqCInit(device);
		
		KbReleaseWait; 
		
		while ~KbCheck
		     v=DaqAIn(device,channel,range);
			 telapsed = GetSecs - tstart;
%		     updaterate = count / telapsed;
		     fprintf(fp, '%d\t, %.2f\t\t, %.2f\t\n', count, telapsed, v);
			 str = sprintf('%d, %.2f, %.2f', count, telapsed, v);
% 		     disp(sprintf("	Counter	   Running time	  Voltage"));
		     disp(str);
			 count = count + 1;
			 
			 if KbCheck, break, end
		end
	end
end

% We're done. Close the window. This will also release all other ressources:
fclose(fp);
Screen('CloseAll');

% Bye bye!
return