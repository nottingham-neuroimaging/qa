function[] = myFD(scanParams)
%myFD - This determines the framewise displacement a la Power et al 2012 doi:10.1016/j.neuroimage.2011.10.018
%
%      usage: [  ] = myFD(  )
%         by: ppzma, Michael Asghar
%       date: Mar 03, 2020
%        $Id$
%     inputs: scanParams (from the fMRI_report_app app)
%    outputs: 
%
%    purpose: Ideally, want to show some spike analysis, so this is a quick
%             way using image processing tools to determine framewise 
%              displacement using the translation and rotation matrices 
%               using imregister.m // 
%               This function will print out a plot of FD versus dynamics
%
%        See Also imregtform imregister

fprintf('Finding framewise displacement, this will take a minute... \n\n');
tic
clc
for xx = 1:length(scanParams)
    
    [data, ~] = cbiReadNifti(scanParams(xx).fileName);
    
    nX = size(data,1);
    nY = size(data,2);
    nS = size(data,3);
    %nV = size(data,4);
    nV = scanParams(xx).volumeSelect;
    
    moving_reg = zeros(nX,nY,nS,nV);
    
    %tform = zeros(1,nV);
    
    fixed = data(:,:,:,1);
    %fixed = mean(data,4);
    [optimizer, metric] = imregconfig('monomodal');
    %figure('Position',[100 100 1000 1000])
    %tic
    fprintf('\n%%')
    for ii = 1:nV
        
        moving = data(:,:,:,ii);
        %fixed = data(:,:,:,ii-1);
        %keyboard
        %[moving_reg(:,:,:,ii),R_reg] = imregister(moving,fixed,'rigid',optimizer,metric);
        if ii == 1
            fixed = moving;
        else
            fixed = data(:,:,:,ii-1); % between each frame / rolling window
        end
        % calculate the transformation of every frame to the previous frame
        tform(ii) = imregtform(moving,fixed,'rigid',optimizer,metric);
        %imshowpair(fixed(:,:,30), moving(:,:,30),'blend')
        %disp(ii)
        
        currPrc = (ii ./ nV ).* 100;
        
        fprintf('\b\b\b\b\b\b\b%.3f%%',currPrc)
        
        %clc
    end
    %toc
    
   
    tform_mat = cat(3,tform.T);
    tform_mat_diffs = zeros(4,4,length(tform));
    frame_trans_sum = zeros(length(tform),1);
    frame_rot_sum = zeros(length(tform),1);
    
    mysphere = 50;
    
    % here, calculate framewise displacment
    for ii = 1:length(tform_mat)
        
        % get absolute differences between each frame from the initial frame
        if ii == 1, a = 0; else a = 1; end
        tform_mat_diffs(:,:,ii) = abs( tform_mat(:,:,ii) - tform_mat(:,:,ii-a) );
        
        % translations
        trans_vec = tform_mat_diffs(4,1:3,ii);
        trans_vec = trans_vec(:);
        
        % should we do RMS of trans?
        trans_RMS = sqrt( (trans_vec(1).^2) + (trans_vec(2).^2) + (trans_vec(3).^2) );
        
        %frame_trans_sum(ii) = sum(trans_vec);
        frame_trans_sum(ii) = trans_RMS;
        
        % rotations
        %rot_vec = tform_mat_diffs(1:3,1:3,ii);
        rot_vec = [tform_mat_diffs(1,2:3,ii) tform_mat_diffs(2,3,ii)]';
        %rot_vec = rot_vec(:);
        
        % yaw pitch and roll correspond to Euler angles phi, theta, psi
        phi = rot_vec(1);
        theta = rot_vec(2);
        psi = rot_vec(3);
        % is this math right?
        % https://doi.org/10.1016/j.neuroimage.2011.07.044
        myeuler = acos((cos(phi).*cos(theta) + cos(phi).*cos(psi) + cos(theta).*cos(psi) + sin(phi).*sin(psi).*sin(theta) - 1)/2);
        myeuler_mm = mysphere .* myeuler;
        % convert radians to millimetres using arc length, sphere of 50 mm
        % arc length = radius .* angle
        
        %rot_vec_mm = mysphere .* rot_vec;
        %frame_rot_sum(ii) = sum(rot_vec_mm(:));
        frame_rot_sum(ii) = myeuler_mm;
        
    end
    
    %figure('Position',[100 100 1000 100])
    figure
    %axis([0 length 0 2])
    FD = frame_rot_sum + frame_trans_sum;
    X = 1:length(FD);
    %an = animatedline;
    %a = tic;
    %for k = 1:length(FD)
    %    addpoints(an, X(k), FD(k));
    %    drawnow
    %end
    plot(X,FD,'linewidth',2)
    xlabel('time (dynamics)')
    ylabel('Framewise displacement (mm)')
    ylim([0 2])
    
    
end


toc
end



