function [Ra, Rb, Q, I] = inverseKinematics (Ca, Cb, Eb, P, T)

% Laser
x2 = P(1);
y2 = P(2);
z2 = P(3);

% Target
x0 = T(1);
y0 = T(2);
z0 = T(3);

% 3D line passwing trough two 3D points
%   x = x1 + (x2-x1)*t
%   y = y1 + (y2-y1)*t
%   z = z1 + (z2-z1)*t
% We find the t1 at wich it intersects z1
z1 = Ca(3) + Eb(3);

t1 = (z1 - z0) / (z2-z0);

x1 = x0 + (x2-x0)*t1;
y1 = y0 + (y2-y0)*t1;

Q = [x1, y1, z1 - Eb(3)];

W = extendSegment(Cb(1:2), Q(1:2), -Eb(1));
I = [W(1), W(2), Q(3)];



%Ra = norm([Ca(1:2), W(1:2)]);
%Rb = norm([Cb(1:2), W(1:2)]);

Ra = sqrt( (Ca(1)-I(1))^2 + (Ca(2)-I(2))^2     );
Rb = sqrt( (Cb(1)-I(1))^2 + (Cb(2)-I(2))^2     );

end