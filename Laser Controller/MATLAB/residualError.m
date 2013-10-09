% Ca
% Cb
% P
% T:   point [x0, y0, z0]
% Ra:  radius
% Rb:  radius
% z0
function E = residualError(Ca, Cb, Eb, P, T, Ra, Rb, z0)
    % Estimated point using forward kinematics
    [x0, y0, z0_, ~, ~, ~] = forwardKinematics(Ca, Ra, Cb, Rb, Eb, P, z0);
    Q = [x0, y0, z0_];
%if ~isreal(Q)
%    Q
%end
    
    % Calculate error from the original point
    E = sqrt(  (T(1)-Q(1))^2 + (T(2)-Q(2))^2 );
end