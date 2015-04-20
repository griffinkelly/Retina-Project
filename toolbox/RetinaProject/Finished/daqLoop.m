v=0;
daq = DaqFind;
while v<5
    v = DaqAIn(daq,0,1);
    disp(v);
end
disp('end loop');