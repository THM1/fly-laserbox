% Ca: [x, y, z1] Centre of the first circle
% Cb: [x, y, z1] Centre of the second circle
% Ra: radius first circle
% Rb: radius second circle
% P: [x, y, z2] Point where the laser is attached to
% z0: where to project the laser

% Eb: extension where the joint ball is attached, on motor 2
%   Eb(1):  extension parallel to end of motor
%   Eb(2):  extension orthogonal to end of motor
%   Eb(3):  extension vertical (positive = towards laser point P)

function [x0, y0, z0, x1, y1, z1, Ix, Iy, Iz] = forwardKinematics(Ca, Ra, Cb, Rb, Eb, P, z0)

% Find 2D intersections on the z plane
% where the motors are places
[I2, I1] = circleIntersects(Ca(1:2), Ra, Cb(1:2), Rb);
%if  ~isreal(I2 )
%    I2
%end
% Intersection
I = [I1(1), I1(2), Ca(3)];
Ix = I(1);
Iy = I(2);
Iz = I(3);



% Extends over the second motor
Q = extendSegment(Cb(1:2), I(1:2), Eb(1));
x1 = Q(1);
y1 = Q(2);
z1 = Ca(3) + Eb(3);

% Reject one of the intersection
%x1 = I1(1);
%y1 = I1(2);
%z1 = Ca(3);

%I = [x1, y1, z1];

% 3D line passwing trough two 3D points
%   x = x1 + (x2-x1)*t
%   y = y1 + (y2-y1)*t
%   z = z1 + (z2-z1)*t
% We find the t0 at wich it intersects z0
x2 = P(1);
y2 = P(2);
z2 = P(3);

t0 = (z0 - z1)/(z2 - z1);

x0 = x1 + (x2-x1)*t0;
y0 = y1 + (y2-y1)*t0;

end