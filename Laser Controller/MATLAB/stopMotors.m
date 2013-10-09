function stopMotors(s)
    fprintf('\t=> Stopping connection with Arduino...\n');
    
    % Stop
    try
        fprintf(s, 'STOP\n');
        if s.BytesAvailable > 0
            data=fscanf(s);
        end
    catch err
        getReport(err, 'extended')
    end
    
    pause(1);
    
    % Close the port
    try
        fclose(s);
    catch err
        getReport(err, 'extended')
    end
    pause(5);
end

