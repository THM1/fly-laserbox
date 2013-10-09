clear all;
close all;

l = 500;

z0 = 0 + l/8;
z1 = l/2;
z2 = l/2 + l/8;

Ca = [l/4, 0,   z1];
Cb = [0,   l/4, z1];
P  = [l/4, l/4, z2];

Eb = [10, 0, 2];

figure
subplot(1,2,1);
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

rangeA = 120:10:120+50;
rangeB = 120:10:120+50;



%rangeA = [120,];
%rangeB = [120,];

P0s = zeros(0,3);
P1s = zeros(0,3);


%plot3();


hline = findobj(gcf, 'type', 'line');

i = 0;
for ia = 1:length(rangeA)
    Ra = rangeA(ia);
    circle(Ca(1),Ca(2),Ca(3),Ra);
    
    for ib = 1:length(rangeB)
        Rb = rangeB(ib);
        
        
        
        circle(Cb(1),Cb(2),Cb(3),Rb);
        
        
        [x0, y0, z0_, x1, y1, z1, Ix, Iy, Iz] = forwardKinematics(Ca, Ra, Cb, Rb, Eb, P, z0);
        
        P0s = [ P0s; [x0, y0, z0_]   ];
        P1s = [ P1s; [x1, y1, z1 ]   ];
        
        %set(gca,'Color','red','LineWidth',2)
        %set(gca,'Color','blue')
        line([Ca(1), Ix],[Ca(2), Iy], [Ca(3), Iz]);
        %set(hline(end),'Color','yellow')
        
        line([Cb(1), Ix],[Cb(2), Iy], [Cb(3), Iz]);
        %set(hline(end),'Color','orange')
        
        %set(gca,'Color','green')
        line([Ix, x1],[Iy, y1], [Iz, z1]);
        %set(hline(end),'Color','black')
        
        %line([Ca(1), x1],[Ca(2), y1], [Ca(3), z1]);
        %line([Cb(1), x1],[Cb(2), y1], [Cb(3), z1]);
        
        %set(gca,'Color','magenta')
        line([P(1), x1],[P(2), y1], [P(3), z1]);
        %set(hline(end),'Color','blue')
        line([x0, x1],[y0, y1], [z0_, z1]);
        %set(hline(end),'Color','green')
        
        i = i+1;
        
        %pause(300);
    end
end




subplot(2,2,2);
axis equal;
plot3(P0s(:,1),P0s(:,2),P0s(:,3), '.');



%% CIRCLE
rangeA = 120 + 50/2 + sin(0:pi/10:2*pi)*50/2;
rangeB = 120 + 50/2 + cos(0:pi/10:2*pi)*50/2;

P0s = zeros(0,3);
P1s = zeros(0,3);
for i = 1:length(rangeA)
    Ra = rangeA(i);
    Rb = rangeB(i);

    [x0, y0, z0_, x1, y1, z1] = forwardKinematics(Ca, Ra, Cb, Rb, Eb, P, z0);

    P0s = [ P0s; [x0, y0, z0_]   ];
    P1s = [ P1s; [x1, y1, z1 ]   ];

    %line([Ca(1), x1],[Ca(2), y1], [Ca(3), z1]);
    %line([Cb(1), x1],[Cb(2), y1], [Cb(3), z1]);

    %line([P(1), x1],[P(2), y1], [P(3), z1]);
    %line([x0, x1],[y0, y1], [z0_, z1]);
end

subplot(2,2,4);
axis equal;
plot3(P0s(:,1),P0s(:,2),P0s(:,3));



%% INVERSE KINEMATICS
figure;
subplot(2,2,1);
hold on;
T = [200, 150, z0];
[Ra, Rb] = inverseKinematics(Ca, Cb, Eb, P, T);


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

circle(Ca(1),Ca(2),Ca(3),Ra);
circle(Cb(1),Cb(2),Cb(3),Rb);

line ([P(1),T(1)],[P(2),T(2)],[P(3),T(3)]);

%% CIRCLE IN INVERSE KINEMATICS
subplot(1,2,2);
axis equal;
hold on;

x = 150 + 150/2 + sin(0:pi/10:2*pi)*150/2;
y = 150 + 150/2 + cos(0:pi/10:2*pi)*150/2;



P0s = zeros(0,3);
P1s = zeros(0,3);

for i=1:length(x)
    T = [x(i),y(i), z0];
    [Ra, Rb] = inverseKinematics(Ca, Cb, Eb, P, T);

    circle(Ca(1),Ca(2),Ca(3),Ra);
    circle(Cb(1),Cb(2),Cb(3),Rb);
    
%     [x0, y0, z0_, x1, y1, z1] = forwardKinematics(Ca, Ra, Cb, Rb, Eb, P, z0);
% 
%     P0s = [ P0s; [x0, y0, z0_]   ];
%     P1s = [ P1s; [x1, y1, z1 ]   ];
%     
%     line([Ca(1), x1],[Ca(2), y1], [Ca(3), z1]);
%     line([Cb(1), x1],[Cb(2), y1], [Cb(3), z1]);
% 
%     line([P(1), x1],[P(2), y1], [P(3), z1]);
%     line([x0, x1],[y0, y1], [z0_, z1]);

        [x0, y0, z0_, x1, y1, z1, Ix, Iy, Iz] = forwardKinematics(Ca, Ra, Cb, Rb, Eb, P, z0);
        
        P0s = [ P0s; [x0, y0, z0_]   ];
        P1s = [ P1s; [x1, y1, z1 ]   ];
        
        line([Ca(1), Ix],[Ca(2), Iy], [Ca(3), Iz]);
        line([Cb(1), Ix],[Cb(2), Iy], [Cb(3), Iz]);
        
        %line([Ix, x1],[Iy, y1], [Iz, z1]);
        line([Ix, x1],[Iy, y1], [Iz, z1-Eb(3)]);
        line([x1, x1],[y1, y1], [z1, z1-Eb(3)]);
        
        %line([Ca(1), x1],[Ca(2), y1], [Ca(3), z1]);
        %line([Cb(1), x1],[Cb(2), y1], [Cb(3), z1]);
        
        line([P(1), x1],[P(2), y1], [P(3), z1]);
        line([x0, x1],[y0, y1], [z0_, z1]);
        
        %pause(300);
    
end

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

subplot(2,2,3);
plot3(P0s(:,1),P0s(:,2),P0s(:,3));
axis equal;