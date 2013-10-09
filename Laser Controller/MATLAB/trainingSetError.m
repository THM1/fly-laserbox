% Estimation:
% Ca
% Cb
% P
% Given from training set:
% Ts:   [] of points [x0i, y0i, z0]
% Ras:  [] of radius
% Rbs:  [] of radius
% z0
function E = trainingSetError(Ca, Cb, P, Ts, Ras, Rbs, z0)
    E = 0;
    for i = 1:length(Ts)
        % Estimated point using forward kinematics
        [x0, y0, z0_, ~, ~, ~] = forwardKinematics(Ca, Ras(i), Cb, Rbs(i), P, z0);
        Q = [x0, y0, z0_];
        
        
        
        % Calculate error from the original point
        T = Ts(i,:);
        
        %T-Q
        
        Ei = sqrt(  (T(1)-Q(1))^2 + (T(2)-Q(2))^2 );
        E = E + Ei^2;
    end
    E = 1/length(Ts) * E;
end