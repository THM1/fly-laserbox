function util_plotpos(frame, xcoord, ycoord, bb)
%UTIL_PLOTPOS Plot laser coordinates in the image frame provided.
%
%    UTIL_PLOTPOS(FRAME, X, Y) plots the image FRAME provided and 
%    a set of cross hairs at the X and Y coordinates.
%

%    DH 2-16-03
%    Copyright 2001-2005 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date: 2006/06/02 20:06:21 $

% Display the image frame
imshow(frame);

% Superimpose cross hairs.
hold on
plot(xcoord, ycoord, 'yo')
plot([1 size(frame, 2)], [ycoord ycoord], 'y-')
plot([xcoord xcoord], [1 size(frame, 1)], 'y-')




bc = [xcoord, ycoord];
%bb = props.BoundingBox;
%bc = props.Centroid;
%ba = props.Area;
rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
plot(bc(1),bc(2), '-m+')
a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');

%b=text(bc(1)+15,bc(2)+15, strcat('A: ', num2str(round(ba(1)))));
%set(b, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');

hold off;
