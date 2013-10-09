%% OPENCV XML > MATLAB MAT ===============================================
%   This part converts the OpenCV XML files produced by the HAAR training
%   in a MATLAB compatible format.
addpath ViolaJones
addpath ViolaJones\HaarCascades
filename='cascade700b';
ConvertHaarcasadeXMLOpenCV(filename);

%% CAMERA INITIALISATION =================================================
a = imaqhwinfo;
[camera_name, camera_id, format] = getCameraInfo(a);

% Capture the video frames using the videoinput function
% You have to replace the resolution & your installed adaptor name.
%vid = videoinput(camera_name, camera_id, format);
vid = videoinput(camera_name, camera_id, 'RGB24_640x480');

% Set the properties of the video object
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')
vid.FrameGrabInterval = 5;

%start the video aquisition here
start(vid)

%% OBJECT DETECTION ======================================================
%for i = 1:size(tiltCalibration,1)
while true
    % Gets the current frame
    frame = getsnapshot(vid);
    
    Options.Resize=false;
    Objects = ObjectDetection(frame,'cascade700b.mat',Options);
    hold on;
    ShowDetectionResult(frame,Objects);
    hold off;
    
    pause(1);
    
end