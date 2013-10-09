%% CAMERA INITIALISATION =================================================
a = imaqhwinfo;
[camera_name, camera_id, format] = getCameraInfo(a);

% Capture the video frames using the videoinput function
% You have to replace the resolution & your installed adaptor name.
%vid = videoinput(camera_name, camera_id, format);
vid = videoinput(camera_name, camera_id, 'RGB24_640x480');

% Set the properties of the video object
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')
vid.FrameGrabInterval = 2;
%vid.FrameRate = 30;

% http://www.mathworks.co.uk/help/imaq/examples/logging-data-at-constant-intervals.html

%start the video aquisition here
start(vid)

global Ra_prev;
global Rb_prev;

%% FLY INITIALISATION
fly.x = 190;
fly.y = 260;
fly.a = 0;
fly.va = (2*pi)/5;
fly.v = 8*1;
fly.time = clock;

arena.x = 190;
arena.y = 260;
arena.r = 50;
%arena.r = 75;
%% OBJECT DETECTION ======================================================

useLaser = true;
%frame = getsnapshot(vid);
if useLaser == true
    % Starts the motors
    s = startMotors(port);
    
end
iterations = 100;
%dataSet = zeros(0, 12);
dataSet = zeros(iterations, 12);
    %   Wx_fly,   Wy_fly
    %   Lx_fly,   Ly_fly
    %   Wx_laser, Wy_laser
    %   Lx_laser, Ly_laser
    %   WEx,      WEy
    %   LEx,      LEy
%flyPos = zeros(0,2);
flyPos = zeros(iterations, 2);
%for i = 1:size(tiltCalibration,1)
for i = 1:1:iterations
    % Gets the current frame
    frame = getsnapshot(vid);
    
    % Update fly position
    fly = updateFly(fly, arena);
    %fly = updateFly(fly);
    W = [fly.x, fly.y];
    Wx = fly.x;
    Wy = fly.y;
    [Lx, Ly] = tforminv(TiltCorrection, W);
    %flyPos = [flyPos; Lx, Ly];
    flyPos(i,:) = [Lx, Ly];
    
    % Prediction of fly position at next step
    elapsedTime = etime(fly.time, fly.time_prev)*1; % put to 0 for no prediction at all
    Wx_next = fly.x + fly.v * elapsedTime * cos(fly.a);
    Wy_next = fly.y + fly.v * elapsedTime * sin(fly.a);
    [Lx_next, Ly_next] = tforminv(TiltCorrection, [Wx_next,Wy_next]);
    %currentTime = clock;
    %elapsedTime = etime(clock,fly.time); % sec
    %L_next = extendSegment([fly.x_prev, fly.y_prev], [fly.x, fly.y],fly.v * elapsedTime);
    
    
    
    if useLaser == true
        % Move the motors
        [Ma, Mb, Ra, Rb] = inverseKinematicsWithErrorCompensation (Ca, Cb, Eb, P, [Lx_next, Ly_next], z0, TiltCorrection, R_0, R_100, Ra_prev, Rb_prev);    % Inverse kineamtics - NO error correction
        %[Ma, Mb, Ra, Rb] = inverseKinematicsWithErrorCompensation (Ca, Cb, Eb, P, [Lx, Ly], z0, TiltCorrection, R_0, R_100, Ra_prev, Rb_prev);    % Inverse kineamtics - NO error correction
        
        %[Ma, Mb, Ra, Rb] = inverseKinematicsWithErrorCompensation (Ca, Cb, Eb, P, [Lx, Ly], z0, TiltCorrection, R_0, R_100, Ra_prev, Rb_prev, ErrorParams);    % Inverse kineamtics + error correction
        %[Ma, Mb, Ra, Rb] = inverseKinematicsRegressionOnly([Lx, Ly], TiltCorrection, R_0, R_100, Ra_prev, Rb_prev, p1); % Regression only
        moveMotors(s, Ma, Mb, false);
        
        % Gets the current laser position
        [Lx_laser, Ly_laser, boundingBox] = util_findlaser(frame);
    else
        % Nothing to show!
        Lx_laser = NaN;
        Ly_laser = NaN;
        boundingBox = NaN;
    end
    
    % Plot
    if ~(isnan(Lx_laser) || isnan(Ly_laser))
        util_plotpos(frame, Lx_laser, Ly_laser, boundingBox);
        [Wx_laser, Wy_laser] = tformfwd(TiltCorrection, [Lx_laser, Ly_laser]);
    else
        imshow(frame);
        Wx_laser = NaN;
        Wy_laser = NaN;
    end
   
    
    
%     Wx_laser = 0;
%     Wy_laser = 0;
%     Lx_laser = NaN;
%     Ly_laser = NaN;
% 

    %Lx_laser = Lx -20;
    %Ly_laser = Ly -20;

    WEx = Wx - Wx_laser;
    WEy = Wy - Wy_laser;
    
    LEx = Lx - Lx_laser;
    LEy = Ly - Ly_laser;

    % Saves information
    %dataSet =                       ...
    %    [   dataSet;                ...
    dataSet(i, :) = ...
        [   ...
            Wx,       Wy,           ...
            Lx,       Ly,           ...
            Wx_laser, Wy_laser,     ...
            Lx_laser, Ly_laser,     ...
            WEx,      WEy,          ...
            LEx,      LEy           ...
        ];
        %   Wx_fly,   Wy_fly
        %   Lx_fly,   Ly_fly
        %   Wx_laser, Wy_laser
        %   Lx_laser, Ly_laser
        %   WEx,      WEy
        %   LEx,      LEy
    hold on;
    drawgrid(gridSpace);
    quiver(dataSet(1:i, 3), dataSet(1:i, 4), -dataSet(1:i, 11), -dataSet(1:i, 12),0, 'g.');
    plot(   flyPos (1:i,1), flyPos (1:i,2), 'blue', 'LineWidth', 2  );
    plot(   dataSet(1:i,7), dataSet(1:i,8), 'red'  , 'LineWidth', 2  );
    
    %set(q,'HeadStyle','none', 'LineColor', 'green');
    %l = line([Lx,Lx_laser],[Ly, Ly_laser]);
    %set(l, 'color', 'green');
    
    hold off;
    
    
    
    
    drawnow;
    
    flushdata(vid);
    %pause(0.01);
    % Maybe too slow because of dataSet being copied and plots
end

% Data (remove the first points)
ELx_avg = sqrt( mean(dataSet(20:end,11).^2)    );
ELy_avg = sqrt( mean(dataSet(20:end,12).^2)    );

EWx_avg = sqrt( mean(dataSet(20:end, 9).^2)  );
EWy_avg = sqrt( mean(dataSet(20:end,10).^2)  );

fprintf('\tAverage error:\n');
fprintf('\t\tLE: [%6.2f %6.2f][px]\n', ELx_avg, ELy_avg);
fprintf('\t\tWE: [%6.2f %6.2f][mm]\n', EWx_avg, EWy_avg);

%mean(dataSet(10:end,9))
%mean(dataSet(10:end,10))

%% === STOP ==============================================================
disp('=== STOP ===');
stop(vid); flushdata(vid); %fclose(s);
diary off;
fprintf('\tStopped.\n');
%% Stop the motors
%fprintf(s, 'STOP\n');
%data=fscanf(s);
stopMotors(s);