function daqLoop()
% A function to delay the stimuli which waits for the DAQ. Use Ports 1 &2 of
% the DAQ. Edit Voltages as necessary. Written: Griffin Kelly, 2015, griffinkelly2013@gmail.com
KbName('UnifyKeyNames');
exitkey = KbName('x');
v=0;
daq = DaqFind;

%waits for threshold less than -5 volts.
while -5<v
    [keydown, secs, keycode, deltasexcs] = KbCheck;
    v = DaqAIn(daq,0,1);
    %display Voltage
    
    disp(v);
    
    %If you press 'x' during the holding, it will break out of loop.
    if keycode(exitkey)
        Screen('CloseAll');
        return
    end
end
disp('end loop');

%If paused needed right after impulse, uncomment next line
%pause(.2);
end