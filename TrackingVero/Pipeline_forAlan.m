clc
clear all
close all

Files = {'testclose3.avi'} 

for m=1:length(Files)
         
    clear Bodytracks flymoviedata
    
    filename=[Files{m}]
         
    param.bodyThreshold=102;
    param.numFlies1arena=1;
    param.filename = filename;
  
   
    trackingPath = '.\'
    DirectoryPath ='X:\Alan Zucconi\TrackingVero\'

    Tracking_forAlan % Extracts Centroids of all blobs
    Centroids_Orientation_forAlan % Gives centroids of the flyblobs
end

