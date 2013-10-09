function [Ma, Mb, Ra, Rb] = inverseKinematicsRegressionOnly (L, TiltCorrection, R_0, R_100, Ra_prev, Rb_prev, Params)
  % From camera coordinates [px] to workspace coordinate [mm]
    W = tformfwd(TiltCorrection, L);

    Wx = W(1);
    Wy = W(2);
    
    % Correct the radiuses
    R = testRegressor([Ra_prev, Rb_prev, Wx, Wy], Params);
    
    Ra = R(1);
    Rb = R(2);
    
    % Find the radiuses [mm] and corrected
    % Return the motor strokes [%]
    Ma = linearInterpolation(R_0, 0, R_100, 100, Ra);       % Ma in %
    Mb = linearInterpolation(R_0, 0, R_100, 100, Rb);       % Mb in %
end

