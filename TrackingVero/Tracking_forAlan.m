%% Created: 26/March/2012 by Vero over Teresa's and Aldo's template %%

% clc
% clear all
% close all

%% Creating Mask
mask=zeros(548,548);
mask(270,273)=1;
strelmask=strel('disk',282,8);
mask=uint8(imdilate(mask,strelmask));
% imshow(flymoviedata(:,:,1,1).*mask)
%% Loading frames from Video

flymovie=VideoReader([DirectoryPath filename])

param.nFrames = flymovie.NumberOfFrames;
param.vidHeight = flymovie.Height;
param.vidWidth = flymovie.Width;

%%% Creating cell arrays to store tracking info %%%

Bodytracks = cell(param.nFrames,1);

tic;

% JAC's code
MAX_FRAME = 500;
count = MAX_FRAME;
% ----

for lframe=1:param.nFrames
    
%     % JAC's code
    if( count == MAX_FRAME )
        if (lframe+count-1)<param.nFrames
            flymoviedataBatch = read(flymovie, [lframe lframe+count-1]);
            count = 1;
        else
            flymoviedataBatch=read(flymovie,[lframe param.nFrames]);
            count=1;
        end

    end
    flymoviedata = flymoviedataBatch(:,:,:,count);
    count = count + 1;
%     % -----
    %% Reading frame %%
       
    clear bodyData 
    
    %% Thresholding Fly body without wings:
    
    bodyData=not(im2bw(flymoviedata(:,:,1), param.bodyThreshold/255)) * 255;
    bodyData=uint8(bodyData).*mask;
        
    %Eliminating noise
%     SE=strel('disk',2);
%     bodyshapethin=imerode(bodyData,SE);
%     bshape=imdilate(bodyshapethin,SE);
        
    %% Tracking and saving parameters in cells%%
    bData2=bwconncomp(bodyData,8);
    Bodytracks{lframe}=regionprops(bData2,{'Centroid','Orientation','Area'});%,'MajorAxisLength','Area','ConvexHull','MinorAxisLength','ConvexImage'});
            
    %% Processing Time info %%
    if 0==mod(lframe,100)
        CurrentFrame=[lframe]
        toc;
        percentComplete = [lframe/param.nFrames*100]
    end
        
    %% Saving Backup at 2000 frames %%
    if 0==mod(lframe,2000)
        save([trackingPath 'traking' filename(1:end-4) '.mat'],'Bodytracks','param','filename')
    end
         
    
end

save([DirectoryPath 'Totaltraking-' filename(1:end-4) '.mat'],'Bodytracks','param','filename')

