function [s] = startMotors (port)
    global Ma_prev
    global Mb_prev

    fprintf('\t=> Starting connection with Arduino...\n');
    
    %try
        %s = serial(port);
        s = serial(port, 'BaudRate', 57600, 'DataBits', 8, 'Terminator','CR/LF', 'InputBufferSize', 1024, 'Timeout', 5);
        %s.BaudRate=57600;
        fopen(s);
    %catch err
        
    %end
    
    %'DataBits', 8, 'Terminator','CR/LF', 'InputBufferSize', 1024, 'Timeout', 5);

    pause(5);
    
    if s.BytesAvailable > 0
        data=fscanf(s);
        fprintf('\t\t[connect]\t%s', data);
    end

    fprintf(s, 'START\n');
    pause(0.01);
    if s.BytesAvailable > 0
        data=fscanf(s);
        fprintf('\t\t[START]  \t%s', data);
    end

    pause(15);

    fprintf(s, 'LASER 5\n');
    pause(0.01);
    if s.BytesAvailable > 0
        data=fscanf(s);
        fprintf('\t\t[LASER 5]\t%s', data);
    end
    
    pause (5);
    
    Ma_prev = 50;
    Mb_prev = 50;
end