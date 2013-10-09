clear all;
close all;

% Real dynamics
l = 500;

z0 = 0 + l/8;
z1 = l/2;
z2 = l/2 + l/8;

Ca = [l/4, 0,   z1];
Cb = [0,   l/4, z1];
P  = [l/4, l/4, z2];




rangeA = 120:10:120+50;
rangeB = 120:10:120+50;

P0s = zeros(0,3);
Ts = zeros(0,3);
Ras = zeros(0,1);
Rbs = zeros(0,1);

sigma = 1.5; % 1 mm error in the detection of the laser position

for ia = 1:length(rangeA)
    Ra = rangeA(ia);
    
    for ib = 1:length(rangeB)
        Rb = rangeB(ib);
                
        [x0, y0, z0_, x1, y1, z1] = forwardKinematics(Ca, Ra, Cb, Rb, P, z0);
        
        % Simulate detection inaccuracy
        x0_n = x0 + randn()*sigma;
        y0_n = y0 + randn()*sigma;
        
        P0s = [ P0s ; [x0,   y0,   z0_]   ];
        Ts  = [ Ts  ; [x0_n, y0_n, z0_]   ];
        Ras = [ Ras ;  Ra];
        Rbs = [ Rbs ;  Rb];        
    end
end

figure
subplot(2,2,1);
hold on;
plot3(P0s(:,1),P0s(:,2),P0s(:,3), 'blue');
plot3(Ts(:,1),Ts(:,2),Ts(:,3), 'red');


%% PARAMETERS MINIMISATION
% x(1): Ca x
% x(2): Ca y
% x(3): Cb x
% x(4): Cb y
% x(5): Ca,b z
% x(6): P  x
% x(7): P  y
% x(8): P  z
options = optimset('MaxFunEvals', 100000, 'MaxIter', 100000);
sigma = 3;
initial_params = [Ca(1)+rand()*sigma, Ca(2)+rand()*sigma, Cb(1)+randn()*sigma, Cb(2)+randn()*sigma, Ca(3)+randn()*sigma, P(1)+rand()*sigma(), P(2)+rand()*sigma(), P(3)+rand()*sigma() ];
params = fminsearch(@(x)trainingSetError([x(1),x(2),x(5)],[x(3),x(4),x(5)], [x(6),x(7),x(8)], Ts, Ras, Rbs, z0),initial_params, options);

sqrt(   trainingSetError(Ca,Cb, P, Ts, Ras, Rbs, z0)    )

%% METROPOLIS / SIMULATED ANNELING

%% SYMBOLIC CALCULUS
clear all;
% Real dynamics
syms z0 z1 z2;

syms Ca_x Ca_y;
syms Cb_x Cb_y;
syms P_x P_y;

Ca = sym('[Ca_x, Ca_y, z1]');
Cb = sym('[Cb_x, Cb_y, z1]');
P  = sym('[P_x,  P_y,  z2]');


%[x0, y0, z0_, x1, y1, z1] = forwardKinematics(Ca, Ra, Cb, Rb, P, z0);

syms T_x T_y;
syms Ra Rb;

Ts = sym('[ [T_x, T_y, z0]    ]');
Ras = sym('[ [Ra]    ]');
Rbs = sym('[ [Rb]    ]');




trainingSetError(Ca,Cb, P, Ts, Ras, Rbs, z0)




%% NON LINEAR LEAST SQUARE FITTING
clear all;
close all;

% Real dynamics
l = 500;

z0 = 0 + l/8;
z1 = l/2;
z2 = l/2 + l/8;

Ca = [l/4, 0,   z1];
Cb = [0,   l/4, z1];
P  = [l/4, l/4, z2];




rangeA = 120:10:120+50;
rangeB = 120:10:120+50;

Ts = zeros(0,3);        % Target points (perfect)
Ts_e = zeros(0,3);      % Target points (noisy)

Ras = zeros(0,1);       % Radiuses (perfect)
Rbs = zeros(0,1);       % Radiuses (perfect)
Ras_e = zeros(0,1);     % Radiuses (noisy)
Rbs_e = zeros(0,1);     % Radiuses (noisy)

sigma = 1*2; % 2 mm error in the detection of the laser position (laser tracking inaccuracy)
sigma_2 = 1*2; % 2 mm inaccuracy on radius (motors inaccuracy)

for ia = 1:length(rangeA)
    Ra = rangeA (ia);
    
    for ib = 1:length(rangeB)
        Rb = rangeB(ib);
        
        Ra_e = Ra + randn()*sigma_2;
        Rb_e = Rb + randn()*sigma_2;
        [x0_r, y0_r, z0_r ] = forwardKinematics(Ca, Ra,   Cb, Rb,   P, z0);
        [x0,   y0,   z0_  ] = forwardKinematics(Ca, Ra_e, Cb, Rb_e, P, z0);
        
        % Simulate detection inaccuracy
        x0_n = x0 + randn()*sigma;
        y0_n = y0 + randn()*sigma;
        
        Ts    = [ Ts    ; [x0_r, y0_r, z0_r]   ];
        Ts_e  = [ Ts_e  ; [x0_n, y0_n, z0_]   ];
        Ras   = [ Ras   ;  Ra];
        Rbs   = [ Rbs   ;  Rb];
        
        Ras_e = [ Ras_e ;  Ra_e];
        Rbs_e = [ Rbs_e ;  Rb_e];
        
        
    end
end

% x(1): Ca x
% x(2): Ca y
% x(3): Cb x
% x(4): Cb y
% x(5): Ca,b z
% x(6): P  x
% x(7): P  y
% x(8): P  z
% Initial parameters
real_params = [Ca(1), Ca(2), Cb(1), Cb(2), Ca(3), P(1), P(2), P(3)];

sigma = 250; % How much they differ from the original values (measurement inaccuracies for the chamber structure)
lb = real_params-sigma;
ub = real_params+sigma;

initial_params = [Ca(1)+rand()*sigma, Ca(2)+rand()*sigma, Cb(1)+randn()*sigma, Cb(2)+randn()*sigma, Ca(3)+randn()*sigma, P(1)+rand()*sigma(), P(2)+rand()*sigma(), P(3)+rand()*sigma() ];

options = optimset('MaxFunEvals', 10000, 'MaxIter', 10000, 'TolFun',1e-8, 'TolX',1e-8);
[est_params, resnorm] = lsqnonlin(@(x)residualErrorVector([x(1),x(2),x(5)],[x(3),x(4),x(5)], [x(6),x(7),x(8)], Ts_e, Ras_e, Rbs_e, z0),initial_params, lb, ub, options);

E_Ca = [est_params(1), est_params(2), est_params(5)];
E_Cb = [est_params(3), est_params(4), est_params(5)];
E_P  = [est_params(6), est_params(7), est_params(8)];

%sigma = 20;
%real_params = [Ca(1),Ca(2)];
%initial_params = [Ca(1)+rand()*sigma, Ca(2)+rand()*sigma];
%[est_params, resnorm] = lsqnonlin(@(x)residualErrorVector([x(1),x(2),Ca(3)],Cb, P, Ts, Ras, Rbs, z0),initial_params);


% Use the estimated parameters to recalculate the points
Ms = zeros(length(Ts),3);
Gs = zeros(length(Ts),3);
for i=1:length(Ts)
    % Simulate the kinematics to see which point is hitten with the
    % estimated parameters
    [x0_, y0_, z0_, ~, ~, ~] = forwardKinematics(E_Ca, Ras(i), E_Cb, Rbs(i), E_P, z0);
    Ms(i,:) = [x0_, y0_, z0_];
    
    % Use the model to predict where the point is going to be
    [E_Ra, E_Rb] = inverseKinematics (E_Ca, E_Cb, E_P, Ts(i,:));
    [x0_, y0_, z0_] = forwardKinematics(E_Ca, E_Ra, E_Cb, E_Rb, E_P, z0);
    Gs(i,:) = [x0_, y0_, z0_];
end




figure
hold on;
axis equal;
plot3(Ts(:,1),Ts(:,2),Ts(:,3)+10, 'blue');
plot3(Ts_e(:,1),Ts_e(:,2),Ts_e(:,3)+20, 'red');
plot3(Ms(:,1),Ms(:,2),Ms(:,3)+30, 'green');
plot3(Gs(:,1),Gs(:,2),Gs(:,3)+40, 'black');

mean(abs(Ts - Gs))