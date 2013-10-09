function [Ma, Mb, Ra, Rb, WEx, WEy] = inverseKinematicsWithErrorCompensation (Ca, Cb, Eb, P, L, z0, TiltCorrection, R_0, R_100, Ra_prev, Rb_prev, ErrorParams)
    
    % From camera coordinates [px] to workspace coordinate [mm]
    W = tformfwd(TiltCorrection, L);

    Wx = W(1);
    Wy = W(2);
    
    %isnan(ErrorParams)
    if (nargin == 12)
        % Correct the radiuses
        WE = testRegressor([Ra_prev, Rb_prev, Wx, Wy], ErrorParams);
        %E = testRegressor([Ra_prev, Rb_prev, Ra, Rb], ErrorParams);
    else
        WE = [0, 0];
        %E = [0,0];
    end
    

    WEx = WE(1);
    WEy = WE(2);
    
    % Correct workspace coordinate!
    Wc = W - WE;
    
    
    % Find the radiuses [mm] and corrected
    [Ra, Rb] = inverseKinematics(Ca, Cb, Eb, P, [Wc, z0]);         % [Ra, Rb] in mm
    
    
    Ma = linearInterpolation(R_0, 0, R_100, 100, Ra);       % Ma in %
    Mb = linearInterpolation(R_0, 0, R_100, 100, Rb);       % Mb in %
    
    %Ra_c = Ra - Ex;
    %Rb_c = Rb - Ey;
    
    % Correct workspace coordinate!
    %Wc = W - E;
    %[Ra_c, Rb_c] = inverseKinematics(Ca, Cb, Eb, P, [Wc, z0]);         % [Ra, Rb] in mm
    
    % Return the motor strokes [%]
    %Ma = linearInterpolation(R_0, 0, R_100, 100, Ra_c);       % Ma in %
    %Mb = linearInterpolation(R_0, 0, R_100, 100, Rb_c);       % Mb in %
end