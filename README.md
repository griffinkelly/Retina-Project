# Retina-Project

Psychtoolbox MATLAB Programs
=============================================================
A Graphical User Interface that can be used with 8 routines:
- Pulse
- Square Wave
- Inverting Sinusoid
- Directional Sinusoid
- Black & White Noise
- Colored White Noise
- Circle Pulse
- Moving Bars

<br><br> The pulse is an alternating gradient of black and white that can be set for a specific number of repititions and time. It will only progress when keyed to do so. 
<br><br> The square wave is similar to the pulse, but moves on without waiting for a key.
<br><br> Inverting Sinusoid is a B/W overlay of two sinusoids. Sinusoid position is static. 
<br><br> Diretional Sinusoid is a single wave drifting left or right and is B/W.
<br><br> B/W Noise is self explanatory.
<br><br> Colored Noise is in the Blue/Green Color, can be changed to show all if necessary.
<br><br> Circle Pulse is similar to pulse, however only a specific circular position alternates color.
<br><br> Moving Bars are white bars on a black background, allowing you to vary the number of bars. The number of bars chosen will be used for both the X & Y directions. It starts with bars in the X direction, then goes through the Y direction. It will wait for a key press before moving to the next bar. 
<br><br> Note: All stimuli can be exited by pressing the "x" key on the keyboard. For the stimuli that need a keypress to continue, Spacebar is the preferred key. 
<br><br> Saving A Record: If run through the GUI, a stimulus record will be saved to a file, stimulus_record.txt within the same directory as the GUI. It will save all files from when the GUI is opened until it is closed. If the filename is not changed, it will be overwritten the next time the GUI is opened. 
<br><br> Other Notes: The bottom right corner has a solid colored square; this ensures that the photodiode can detect the onset of the stimulus regardless if that section originally would be black or colorless. 
