% The residual error for every point in the training set
% Estimation:
% Ca
% Cb
% P
% Given from training set:
% Ts:   [] of points [x0i, y0i, z0]
% Ras:  [] of radius
% Rbs:  [] of radius
% z0
%function [F] = residualErrorVector(Ca, Cb, P, Ts, Ras_motor, Rbs_motor, R_0, R_100, z0)
function [F] = residualErrorVector(Ca, Cb, Eb, P, trainingSet, R_0, R_100, z0)
    %global G_Ca;
    %global G_Cb;
    %global G_P;
    %global G_z0;

    % Range: 0-100 (%)
    %Ras_motor
    %Rbs_motor
    % Range R_0-R_100 (cm)
    
    %Ts, Ras_motor, Rbs_motor, 
    Ts = trainingSet(:, 3:4);
    Ras_motor = trainingSet(:,1);
    Rbs_motor = trainingSet(:,2);
    
    Ras = linearInterpolation(0, R_0, 100, R_100, Ras_motor);
    Rbs = linearInterpolation(0, R_0, 100, R_100, Rbs_motor);
    
    F = zeros(length(Ts),1);
    for i=1:length(Ts)
        F(i) = residualError(Ca, Cb, Eb, P, Ts(i,:), Ras(i), Rbs(i), z0);
        %if ~isreal( F(i) )
        %    G_Ca = Ca
        %    G_Cb = Cb
        %    G_P = P
        %    G_z0 = z0
        %end
    end
end