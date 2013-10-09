function h = circle(x,y,z,r)

%hold on
th = 0:pi/10:2*pi;
xunit = r * cos(th) + x;
yunit = r * sin(th) + y;
zunit = ones(length(th),length(th))*z;
h = plot3(xunit, yunit, zunit, 'red');
%hold off