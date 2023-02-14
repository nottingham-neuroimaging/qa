function [] = myDiffShot(scanParams)
%myDiffShot Perform difference between dynamics, and divide by mean
%   
%
% 2023 Michael Asghar

tic
clc

for xx = 1:length(scanParams)
    data_orig = niftiread(scanParams(xx).fileName);

    data = data_orig(:,:,:,scanParams(xx).volumeSelectFirst:scanParams(xx).volumeSelect);
    
    nX = size(data,1);
    nY = size(data,2);
    nS = size(data,3);
    


    %keyboard
    
    %% run the formula

    % by default remove last dynamic as it might be a noise scan
    data = double(data);
    data = data(:,:,:,1:end-1);
    nV = size(data,4);

    stack_mean = mean(abs(data),4);
    
    diffShot_stack = zeros(nX,nY,nV-1);
    for ii = 1:nV-1
       
        %diffShot_stack(:,:,ii) = sum(data(:,:,:,ii)-data(:,:,:,(ii+1)) ./ stack_mean ,3);
        diffShot_stack(:,:,ii) = sum(abs(data(:,:,:,ii)-data(:,:,:,(ii+1))), 3 );

        

       
        imagesc(diffShot_stack(:,:,ii))
        colormap(viridis)
        colorbar
        %myclim = max(max(diffShot_stack(:,:,ii)));
        myclim = max(max(diffShot_stack(:,:,1)));
        
        clim([0 myclim])
        exportgraphics(gca,[scanParams.mypath extractBefore(scanParams(xx).fileName,'.') 'diffShot_stack_nodiv.gif'],'Append',true)
    end



end
figure
imagesc(diffShot_stack(:,:,1))
disp('Made a shot to shot diff gif...')
toc



























end