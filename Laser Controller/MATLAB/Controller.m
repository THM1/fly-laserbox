%% Draw a circle
clear all;
s = serial('COM4');
s.BaudRate=57600;
fopen(s);

for i=1:5
    for a=0:pi/20:2*pi
        x = floor(50 + cos(a) * 40)
        y = floor(50 + sin(a) * 40)

        fprintf(s, 'TARGET 0 %d\n\r', x);
        data=fscanf(s)

        %pause(3);

        fprintf(s, 'TARGET 1 %d\n\r', y);
        data=fscanf(s)

        pause(1);
    end
end

fclose(s);

%% Draw a circle with inverse kinematics
clear all;
move = true;
%move = false;



if move
    s = serial('COM4');
    s.BaudRate=57600;
    fopen(s);
    
    %fprintf(s, '\n\r');
    fprintf(s, 'LASER 5\n\r');
    data=fscanf(s)

    pause(10);
end


% z0 = 0;
% z1 = 45;
% z2 = 175;
% 
% 
% Ca = [ 15, 185, z1];
% Cb = [190,  15, z1];
% P  = [230, 170, z2];
% 
% R_0   = 215;
% R_100 = 165;


z0 = 0;
z1 = 45;
z2 = 115;


Ca = [ 15, 185, z1];
Cb = [190,  15, z1];
P  = [180, 200, z2];

R_0   = 215;
R_100 = 165;


interval = 0:pi/20:2*pi;
Cs = zeros(length(interval),2);
Rs = zeros(length(interval),2);
Ms = zeros(length(interval),2);

figure;
hold on;
axis equal;
xlabel('x');
ylabel('y');

l = 300;

% Draw the box
% Floor
line([0, l],[0, 0], [z0, z0]);
line([0, 0],[0, l], [z0, z0]);
line([l, 0],[l, l], [z0, z0]);
line([l, l],[0, l], [z0, z0]);

% Ceil
line([0, l],[0, 0], [z2, z2]);
line([0, 0],[0, l], [z2, z2]);
line([l, 0],[l, l], [z2, z2]);
line([l, l],[0, l], [z2, z2]);

% Edges
line([0, 0],[0, 0], [z0, z2]);
line([0, 0],[l, l], [z0, z2]);
line([l, l],[0, 0], [z0, z2]);
line([l, l],[l, l], [z0, z2]);






for c=1:1
    for i=1:length(interval)
        a = interval(i);
        
        x = 200 + cos(a) * 25;
        y = 210 + sin(a) * 25;
        %x = 50;
        %y = 100;
        
        Cs(i, :) = [x, y];
        
        [Ra, Rb] = inverseKinematics(Ca, Cb, P, [x,y, z0]);
        Rs(i,:) = [Ra, Rb];
        
        
        
        %Ra_c = floor(   100+((Ra-170)*100/50) );
        %Rb_c = floor(   100+((Rb-170)*100/50) );
        %Ra_c = floor(   100-((-Ra-180)*100/50) );
        %Rb_c = floor(   100-((-Rb-180)*100/50) );
        
        %Ra_c = floor(   (50-(Ra-180))*100/50 );
        %Rb_c = floor(   (50-(Rb-180))*100/50 );
        
        %Ra_c = floor(   100 - (100*Ra/maxRadius)    );
        %Rb_c = floor(   100 - (100*Rb/maxRadius)    );
        
        %Ra_c = floor(   100 - (100*x/maxRadius)    );
        %Rb_c = floor(   100 - (100*y/maxRadius)    );

        %Vs = interp1([R_0, R_100], [0, 100], [Ra, Rb], 'linear', 'pp');
        %Ra_c = Vs(1);
        %Rb_c = Vs(2);
        Ra_c = linearInterpolation(R_0, 0, R_100, 100, Ra);
        Rb_c = linearInterpolation(R_0, 0, R_100, 100, Rb);
        
        
        Ms(i,:) = [Ra_c, Rb_c];
        
        
        %circle(Ca(1),Ca(2),Ca(3),Ra);
        %circle(Cb(1),Cb(2),Cb(3),Rb);
        
         %line([Ca(1)), x1],[Ca(2), y1], [Ca(3), z1]);
         line([P(1), x],[P(2), y], [P(3), z0]);
        
        %Ra, Ra_c, Rb, Rb_c
        
        [x0_, y0_, z0_, x1_, y1_, z1_] = forwardKinematics(Ca, Ra, Cb, Rb, P, z0);
        
        
        if (Ra_c >= 0 || Ra_c <= 100)
            line([Ca(1), x1_],[Ca(2), y1_], [Ca(3), z1_]);
        end
        if (Rb_c >= 0 || Rb_c <= 100)
            line([Cb(1), x1_],[Cb(2), y1_], [Cb(3), z1_]);
        end

%line([Cb(1), 0],[Cb(2), 0], [Cb(3), 0]);
        
        
        if move
            %if i==1
            %    pause(5);
            %end
            fprintf(s, 'LASER 5\n\r');
            data=fscanf(s)
            
            fprintf(s, 'TARGET 0 %d\n\r', Ra_c);
            data=fscanf(s)

            fprintf(s, 'TARGET 1 %d\n\r', Rb_c);
            data=fscanf(s)

            
            pause(0.8);
            
        end
    end
end

if move
    %pause(10);
    fclose(s);
end

Os = ones(length(Cs));
plot3(Cs(:,1), Cs(:,2), Os*0, 'red');
plot3(Rs(:,1), Rs(:,2), Os*z0,'blue');
plot3(Ms(:,1), Ms(:,2), Os*z0,'green');

goodIndices = Ms(:,1) < 0 | Ms(:,1) > 100 | Ms(:,2) < 0 | Ms(:,2) > 100;


Cs2 = Cs;
Cs2(goodIndices, :) = [];
plot3(Cs2(:,1), Cs2(:,2), ones(length(Cs2),1)*z0,'red', 'LineWidth',3);

Rs2 = Rs;
Rs2(goodIndices, :) = [];
plot3(Rs2(:,1), Rs2(:,2), ones(length(Rs2),1)*z0,'blue', 'LineWidth',3);

Ms2 = Ms;
Ms2(goodIndices, :) = [];
plot3(Ms2(:,1), Ms2(:,2), ones(length(Ms2),1)*z0,'green', 'LineWidth',3);





%% CALIBRATION
clear all;
close all;
%move = true;
move = false;


if move
    s = serial('COM4');
    s.BaudRate=57600;
    fopen(s);
    
    %fprintf(s, '\n\r');
    fprintf(s, 'LASER 5\n\r');
    data=fscanf(s)

    pause(10);
end



z0 = 0;
z1 = 45;
z2 = 110;


Ca = [ 15, 185, z1];
Cb = [190,  15, z1];
P  = [180, 200, z2];

R_0   = 227;
R_100 = 175;


interval = 0:pi/20:2*pi;
Cs = zeros(length(interval),2);
Rs = zeros(length(interval),2);
Ms = zeros(length(interval),2);


figure;
hold on;
axis equal;
xlabel('x');
ylabel('y');

l = 300;

% Draw the box
% Floor
line([0, l],[0, 0], [z0, z0]);
line([0, 0],[0, l], [z0, z0]);
line([l, 0],[l, l], [z0, z0]);
line([l, l],[0, l], [z0, z0]);

% Ceil
line([0, l],[0, 0], [z2, z2]);
line([0, 0],[0, l], [z2, z2]);
line([l, 0],[l, l], [z2, z2]);
line([l, l],[0, l], [z2, z2]);

% Edges
line([0, 0],[0, 0], [z0, z2]);
line([0, 0],[l, l], [z0, z2]);
line([l, l],[0, 0], [z0, z2]);
line([l, l],[l, l], [z0, z2]);



calibration_pt  = load('calibration_pt.txt');
originalPoints  = calibration_pt(:, 3:4);
projectedPoints = calibration_pt(:, 5:6);

calibration_all = load('calibration_all.txt');
%calibration_all  = calibration_all(1:8, :);

% Range: 0-100 (%)
Ras_motor = calibration_all(:,1);
Rbs_motor = calibration_all(:,2);
% Range R_0-R_100 (cm)





Ts_projected = calibration_all(:,3:4);
Ts_corrected = convertCalibrationPoints(originalPoints, projectedPoints, Ts_projected);
Ts = [Ts_corrected, ones(length(Ts_corrected),1)*z0];




% x(1): Ca x
% x(2): Ca y
% x(3): Cb x
% x(4): Cb y
% x(5): Ca,b z
% x(6): P  x
% x(7): P  y
% x(8): P  z
% x(9): R_0
% x(10): R_100
% Initial parameters
initial_params = [Ca(1), Ca(2), Cb(1), Cb(2), Ca(3), P(1), P(2), P(3), R_0, R_100];

sigma = 25; % How much they differ from the original values (measurement inaccuracies for the chamber structure)
lb = initial_params-sigma;
ub = initial_params+sigma;

options = optimset('MaxFunEvals', 100000000, 'MaxIter', 1000000, 'TolFun',1e-8, 'TolX',1e-8, 'FinDiffType', 'central', 'FunValCheck', 'on');
%options = optimset('MaxFunEvals', 1000000, 'MaxIter', 10000, 'TolFun',1e-8, 'TolX',1e-8, 'FinDiffType', 'central', 'FunValCheck', 'on', 'PlotFcns', @optimplotfirstorderopt  );
[est_params, resnorm] = lsqnonlin(@(x)residualErrorVector([x(1),x(2),x(5)],[x(3),x(4),x(5)], [x(6),x(7),x(8)], Ts, Ras_motor, Rbs_motor, x(9), x(10), z0),initial_params, lb, ub, options);
%resnorm

%est_params = initial_params;

E_Ca = [est_params(1), est_params(2), est_params(5)];
E_Cb = [est_params(3), est_params(4), est_params(5)];
E_P  = [est_params(6), est_params(7), est_params(8)];

E_R_0   = est_params(9);
E_R_100 = est_params(10);

% Print difference after optimisation
resnorm
(initial_params - est_params)'


for c=1:1
    for i=1:length(interval)
        a = interval(i);
        
        x = 220 + cos(a) * 25;
        y = 220 + sin(a) * 25;
        %x = 50;
        %y = 100;
        
        Cs(i, :) = [x, y];
        
        [E_Ra, E_Rb] = inverseKinematics(E_Ca, E_Cb, E_P, [x,y, z0]);
        Rs(i,:) = [E_Ra, E_Rb];
        
        
        
        Ra_c = linearInterpolation(E_R_0, 0, E_R_100, 100, E_Ra);
        Rb_c = linearInterpolation(E_R_0, 0, E_R_100, 100, E_Rb);

        Ms(i,:) = [Ra_c, Rb_c];
        
        
        %circle(Ca(1),Ca(2),Ca(3),Ra);
        %circle(Cb(1),Cb(2),Cb(3),Rb);
        
         %line([Ca(1)), x1],[Ca(2), y1], [Ca(3), z1]);
         line([E_P(1), x],[E_P(2), y], [E_P(3), z0]);
        
        %Ra, Ra_c, Rb, Rb_c
        
        [x0_, y0_, z0_, x1_, y1_, z1_] = forwardKinematics(E_Ca, E_Ra, E_Cb, E_Rb, E_P, z0);
        line([E_Ca(1), x1_],[E_Ca(2), y1_], [E_Ca(3), z1_]);
        line([E_Cb(1), x1_],[E_Cb(2), y1_], [E_Cb(3), z1_]);

       % line([Ca(1), x1_],[Ca(2), y1_], [Ca(3), est_params(5)]);
       % line([Cb(1), x1_],[Cb(2), y1_], [Cb(3), est_params(5)]);

%line([Cb(1), 0],[Cb(2), 0], [Cb(3), 0]);
        
        
        if move
            %if i==1
            %    pause(5);
            %end
            fprintf(s, 'LASER 5\n\r');
            data=fscanf(s)
            
            fprintf(s, 'TARGET 0 %d\n\r', Ra_c);
            data=fscanf(s)

            fprintf(s, 'TARGET 1 %d\n\r', Rb_c);
            data=fscanf(s)

            
            pause(0.8);
            
        end
    end
end

if move
    fclose(s);
end

Os = ones(length(Cs));
plot3(Cs(:,1), Cs(:,2), Os*0, 'red');
plot3(Rs(:,1), Rs(:,2), Os*z0,'blue');
plot3(Ms(:,1), Ms(:,2), Os*z0,'green');

goodIndices = Ms(:,1) < 0 | Ms(:,1) > 100 | Ms(:,2) < 0 | Ms(:,2) > 100;


Cs2 = Cs;
Cs2(goodIndices, :) = [];
plot3(Cs2(:,1), Cs2(:,2), ones(length(Cs2),1)*z0,'red', 'LineWidth',3);

Rs2 = Rs;
Rs2(goodIndices, :) = [];
plot3(Rs2(:,1), Rs2(:,2), ones(length(Rs2),1)*z0,'blue', 'LineWidth',3);

Ms2 = Ms;
Ms2(goodIndices, :) = [];
plot3(Ms2(:,1), Ms2(:,2), ones(length(Ms2),1)*z0,'green', 'LineWidth',3);

