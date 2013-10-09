close all
clear all
clc

%% Creating Mask
mask=zeros(548,548);
mask(278,269)=1;
strelmask=strel('disk',269,8);
mask=uint8(imdilate(mask,strelmask));
% imshow(flymoviedata(:,:,1).*mask)

%%
file='testclose3.avi';

flymovie = VideoReader(['X:\Alan Zucconi\TrackingVero\' file]);

%% Defining Frame and Threshold to Use
lframe=2;

arenaThreshold = 142;
bodyThreshold=arenaThreshold-40;
flymoviedata=flymovie.read(lframe);

%% Thresholding Fly %%

% Thresholding fly body without wings:
bodyData=uint8(not(im2bw(flymoviedata(:,:,1), bodyThreshold/255)) * 255).*mask;
% Thresholding the whole fly white and background black:
flyData = uint8(not(im2bw(flymoviedata(:,:,1), arenaThreshold/255)) * 255).*mask;

%Eliminating noise
SE=strel('disk',2);
flyshapethin=imerode(flyData,SE);
flyshape=imdilate(flyshapethin,SE);

%% Tracking

%%% Obtaining whole fly image parameters %%%
fData= bwconncomp(flyshape,8);
flytracks = regionprops(fData,{'Centroid','BoundingBox','Orientation',...
    'MajorAxisLength','MinorAxisLength','ConvexHull','Area'}) % flytracks is a structure array
% which contains thresholded flies parameters. 

%%% Obtaining fly body (without wings) parameters %%%
bodyData2=bwconncomp(bodyData,8);
bodytracks=regionprops(bodyData2,{'Centroid','ConvexHull','Orientation','MajorAxisLength','MinorAxisLength','ConvexImage','Area'})


figure
imshow(flyshape)
figure
imshow(bodyData)

%% Head %%
BodyLength=bodytracks.MajorAxisLength;
Orientation=bodytracks.Orientation;
Majoraxisbody(1,1)=bodytracks.Centroid(1)-BodyLength/2.3*cosd(Orientation);
Majoraxisbody(2,1)=bodytracks.Centroid(1)+BodyLength/2.3*cosd(Orientation);
Majoraxisbody(1,2)=bodytracks.Centroid(2)+BodyLength/2.3*sind(Orientation);
Majoraxisbody(2,2)=bodytracks.Centroid(2)-BodyLength/2.3*sind(Orientation);

T1=pdist2(Majoraxisbody(1,:),flytracks.Centroid);
T2=pdist2(Majoraxisbody(2,:),flytracks.Centroid);

if T1>T2
    Head=Majoraxisbody(1,:);
else
    Head=Majoraxisbody(2,:);
    
end

%% Plotting

%%% Smoothing Surrounding Polygons %%%% 

smoothpolbody=fastsmooth(bodytracks(1).ConvexHull(:,1),3,1,1);
smoothpolbody(:,2)=fastsmooth(bodytracks(1).ConvexHull(:,2),3,1,1);
smoothpolbody(length(smoothpolbody)+1,:)=smoothpolbody(1,:);

smoothpolfly=fastsmooth(flytracks(1).ConvexHull(:,1),3,1,1);
smoothpolfly(:,2)=fastsmooth(flytracks(1).ConvexHull(:,2),3,1,1);
smoothpolfly(length(smoothpolfly)+1,:)=smoothpolfly(1,:);


figure
imshow(flymoviedata)
hold on

plot(flytracks(1).Centroid(1),flytracks(1).Centroid(2),'*m')
plot(bodytracks(1).Centroid(1),bodytracks(1).Centroid(2),'*c')
plot(smoothpolbody(:,1),smoothpolbody(:,2),'--g')
plot(smoothpolfly(:,1),smoothpolfly(:,2),'-g')
plot(Head(1),Head(2),'*y')
