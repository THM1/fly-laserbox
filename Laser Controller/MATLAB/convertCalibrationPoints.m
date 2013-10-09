% Given points in camera space (projectedPoints) and knowing their real
% position (originalPoints), this code converts a sets of points (points)
% from the camera coordinates to the original ones.
function [correctedPoints] = convertCalibrationPoints(originalPoints, projectedPoints, points)
    %http://www.mathworks.com/matlabcentral/answers/5802
    %ImagePoints = [10 10; 110 10; 10 310; 110 310];
    %RealPoints = [0 0;100 0;0 60;100 60]; 
    %T = cp2tform(ImagePoints,RealPoints,'projective')
    %ImageMeasurePoint = [60 160];
    %RealMeasurePoint = tformfwd(T,ImageMeasurePoint)
    
    T = cp2tform(projectedPoints,originalPoints,'projective');
    correctedPoints = tformfwd(T, points);
end