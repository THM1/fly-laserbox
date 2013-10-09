%% CENTROIDS & ORIENTATION %%
%%%% This script loads the tracking files.m and extracts centroids, heads
%%%% and orientations, saving them in a file "Centroids-filename.m" and
%%%% also saves a report of the tracking: "QualityReport.txt":
%%%% How many centroids were discarded and a rough estimation of how
%%%% accurate is the Head estimation.

% clc
% close all
% clear all

%% Setting Parameters for fly blob selection

maxareabody=350; % If a blob has a higher area than 350 using body threshold, then it may not be a fly.
minareabody=70;

tic;

%% Loading video and file with raw tracks info %%%
%Uncomment both to run independently on another file
% DirectoryPath='X:\Alan Zucconi\TrackingVero\' %Folder path with video, raw tracking file and where centroids and report file will be 
% file='testclose3.avi'; 
% load([DirectoryPath 'Totaltraking-' file(1:end-4) '.mat'])

nFrames=length(Bodytracks);
Center1=[277 270]; % center of the arena, determined by clicking on the image

%% Preallocating space for vectors
CentroidsBody=nan(nFrames,2); % Vector that saves all centroids [x y]

for frame=1:nFrames;
    %% ANALYSIS FOR BODYTRACKS: Centroids %%
    
    %%% There are 2 main scenarios:
    %%% 1) # blobs found = # of flies expected (One for now): The blob is saved
    %%% as centroid unless it is outside the arena, in which case is a missing centroid=problem frame.
    
    NumberofBodyBlobs=length(Bodytracks{frame});
    clear SelectedKBody
    if NumberofBodyBlobs==param.numFlies1arena
        SelectedKBody=1;
        CentroidsBody(frame,1:2)=Bodytracks{frame}.Centroid;
        
        
        %%% 2)Several blobs others than the fly are detected: # blobs found > # of flies expected (one for now).
        %%% The centroid corresponds to the biggest of the blobs that fit these conditions:
        %%% a) MinAreaBody<AreaBlob<MaxAreaBody
        %%% b) There must be only one max (not 0, not 2 or more).
        %%% If all conditions are not satisfied, it is a missing centroid=nan
   
    elseif NumberofBodyBlobs>param.numFlies1arena
        clear AreaB CentroidsBlobsBody 
        CentroidsBlobsBody=nan(NumberofBodyBlobs,2);
        AreaB=nan(NumberofBodyBlobs,1);
        
        for k=1:NumberofBodyBlobs
            CentroidsBlobsBody(k,:)=Bodytracks{frame}(k).Centroid;
            if Bodytracks{frame}(k).Area<maxareabody && Bodytracks{frame}(k).Area>minareabody
                AreaB(k)=Bodytracks{frame}(k).Area;
            end
        end
        
        if sum(find(max(AreaB)))==1 && ~isnan(max(AreaB))
            SelectedKBody=find(AreaB==max(AreaB));
            CentroidsBody(frame,1:2)=Bodytracks{frame}(SelectedKBody).Centroid;
        end
        
    end
    
    if 0==mod(frame,50000)
        CurrentFrame=[frame]
        toc;
        percentComplete = [frame/nFrames*100]
    end
    
end

%% Saving
variables={'CentroidsBody','param'};
save([DirectoryPath 'Centroids-' filename(1:end-4) '.mat'],variables{:})

%% Plotting

% flymovie=VideoReader([DirectoryPath file]); flymoviedata=read(flymovie,1); %uncomment to run the script independently
imshow(flymoviedata)
hold on
plot(CentroidsBody(:,1),CentroidsBody(:,2))


