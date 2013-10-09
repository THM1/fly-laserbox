close all;

l = 500;

z0 = 0 + l/8;
z1 = l/2;
z2 = l/2 + l/8;

Ca = [l/4, 0,   z1];
Cb = [0,   l/4, z1];
P  = [l/4, l/4, z2];

Eb = [10, 0, 10];

figure
hold on;
axis equal;

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

% FORWARD ---------------------------
Ra = 120;
Rb = 125;

[x0, y0, z0, x1, y1, z1_, Ix, Iy, Iz] = forwardKinematics(Ca, Ra, Cb, Rb, Eb, P, z0);

circle(Ca(1),Ca(2),Ca(3),Ra);
circle(Cb(1),Cb(2),Cb(3),Rb);
line([Ca(1), Ix],[Ca(2), Iy], [Ca(3), Iz]);
line([Cb(1), Ix],[Cb(2), Iy], [Cb(3), Iz]);

Q = extendSegment(Cb(1:2), [Ix, Iy], Eb(1));
line([Ix, Q(1)],[Iy, Q(2)], [Iz, Iz]);

line([Q(1), x1],[Q(2), y1], [Iz, z1_]);


line([P(1), x0], [P(2), y0], [P(3), z0]);


% INVERSE ----------------------
T = [x0, y0, z0];
[I_Ra, I_Rb, I_Q, I_I] = inverseKinematics (Ca, Cb, Eb, P, T);


Ra-I_Ra
Rb-I_Rb
[Q,z1]-I_Q
[Ix, Iy, Iz]-I_I