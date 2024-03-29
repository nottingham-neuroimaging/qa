function [tsnrData, outputFilenameTSNR] = tSNR_app(dataFilename,varargin)

% tSNRmap- compute temporal SNR map for functional time series This was for debugging purposes.
% Outputs tSNR, noise scan, Mean across time and variance across time in a
% single file (as fisrt, second, third and foruth volume)
% If there is a dynamic noise scan (las volume of the time series), it will also compute image SNR
%      usage: [  ] = tSNRmap( dataFilename,  [varargin] )
%         by: sanchez-panchuelo, used some bits from project's students (Boreham)
%       date: 2015-03-30
%      Edited: by KM Aquino, for extra flags

%inputs:       - dataFilename: 4-D time series, last dynamic may be a noise scan or
%              - dynNOISEscan: flag to treat the last dynamic as noise,
%              default is 1
%              - temporalFilter: flag to use high pass temporal filter on
%              the time series to remove scanner dirft, default is 0
%    outputs: tSNRmap; temporal SNR map
%             It will rint tSNR and iSNR result if there is a dynamic noise scan
%

% 
% validInputArgs = {'dynNOISEscan', 'temporalFilter', 'cropTimeSeries', 'outputBaseName', 'cropSlices','imgScale',... % dyn NOISE scan at the end of time series to compute image SNR
%     };

%eval(evalargs(varargin,[],[],validInputArgs))


charidex = cellfun(@ischar,varargin);
numbidex = cellfun(@isnumeric,varargin);
chargin = varargin(charidex);
numbgin = varargin(numbidex);
numbgins = cell2mat(numbgin);


if sum(contains(chargin,'dynNOISEscan'))
    dynNOISEscan = numbgins(1);
else
    dynNOISEscan = 0;
end

if sum(contains(chargin,'cropTimeSeries'))
    cropTimeSeries = [numbgins(2) numbgins(3)];
else
    cropTimeSeries = [];
end

if sum(contains(chargin,'cropSlices'))
    cropSlices = [numbgins(4) numbgins(5)];
else
    cropSlices = [];
end

if sum(contains(chargin,'imgScale'))
    imgScale = numbgins(6);
end

if ~exist('dataFilename','var')
    [dataFilename,pathname] = uigetfile({'*.hdr';'*.nii';'*.img'},'Select file ');
end

if sum(contains(chargin,'outputBaseName'))
    outputBaseName = chargin{4};
else
    outputBaseName = [pathname stripext(dataFilename)];  
end


% check inputs for the required arguments
% if ieNotDefined('dynNOISEscan')
%     dynNOISEscan=1;
% end
% 
% if ieNotDefined('temporalFilter')
%     temporalFilter=0;
%     % Currently not used.
% end
% 
% if ieNotDefined('cropTimeSeries')
%     cropTimeSeries=[];
% end
% 
% if ieNotDefined('cropSlices'), cropSlices = []; end
% 
% if ieNotDefined('dataFilename')
%     % get data_filename
%     [dataFilename,pathname] = uigetfile({'*.hdr';'*.nii';'*.img'},'Select file ');
% end
% 
% if ieNotDefined('outputBaseName')
%     outputBaseName = [pathname stripext(dataFilename)];    
% end

% Reads the data from the file name.
%[Data, Hdr]=cbiReadNifti(dataFilename);
%mri = MRIread(dataFilename);
%Data = mri.vol;
Data = niftiread(dataFilename);


% if isfield(mri,'analyzehdr')
%     if ~isempty(mri.analyzehdr)
%         Hdr = mri;
%     else
%         Hdr = mri.niftihdr;
%     end
% else
%     Hdr = mri.niftihdr;
% end

Hdr = niftiinfo(dataFilename);

% get data dimensions
nX = size(Data,1);
nY = size(Data,2);
nS = size(Data,3);
nV = size(Data,4);

im_data = Data;

if ~isempty(cropSlices)
    im_data = im_data(:,:,cropSlices(1):cropSlices(2),:);
    nS = size(im_data,3);
    
    if dynNOISEscan==1
        noise_data=im_data(:,:,:,nV);
        im_data = im_data(:,:,:,1:nV-1);
        if ~isempty(cropTimeSeries)
            cropTimeSeries(2) = cropTimeSeries(2)-1;
        end
    else
        noise_data = zeros(nX,nY,nS);
    end
    
elseif isempty(cropSlices)
    
    
    if dynNOISEscan==1
        im_data=Data(:,:,:,1:nV-1);
        noise_data=Data(:,:,:,nV);
    else
        im_data=Data;
        noise_data = zeros(nX,nY,nS);
    end
    
end

if(~isempty(cropTimeSeries))
    im_data = im_data(:,:,:,cropTimeSeries(1):cropTimeSeries(2));
    nV = size(im_data,4);
end
% To correct for scanner drift, we remove a linear and quadratic trend for the data
% (simplistic at the moment - compared to using high-pass filtering)
% 
% Here we reshape the data to vectorise it.
if nV ~= 1
    reshaped_data = reshape(im_data,nX*nY*nS,nV);
    reshaped_data = double(reshaped_data);
    % The next thing to do is to make a GLM, with just a linear and quadratic regressor (see Hutton et al. Neuroimage
    % 2011) i.e. solve
    %
    % Y = X*betas + error
    %
    % Where X has the model - otherwise known as the design matrix
    % and betas is a column vector that has the co-efficients for the elements in the design matrix (to be estimated)
    X1 =[1:nV].';X2 = X1.^2;
    X = [ones(size(X1)),X1,X2]; %Design matrix
    P = (X'*X)\X'; % Proj. matrix (also pinv(X))
    % find solution of GLM
    betas = P*(double(reshaped_data).');
    
    % Now remove the linear and quadratic trend only..
    detrended_data = (reshaped_data.' - X(:,2:3)*betas(2:3,:)).';
    im_data = reshape(detrended_data,nX,nY,nS,nV);
    % Now this is standard...
else
    im_data = double(im_data);
end

tsnrData=mean(im_data,4)./std(im_data,0,4);
tsnrData(tsnrData>1000) = 0; % This thresholds the tSNR so it's not super high

%% send to stability app

if dynNOISEscan == 1
    stability_app(im_data,imgScale,outputBaseName,noise_data);
else
    stability_app(im_data,imgScale,outputBaseName,[]);
end


%%


save('meanTSNR', 'tsnrData');


%quick thing to check iSNR
if dynNOISEscan == 1
    %signalpugs = im_data(:,:,:,1:nV);
    meansignalpugs = mean(im_data,4);
    %meansignalpugs = meansignalpugs(:);
    %noisepugs = im_data(:,:,:,nV);
    % meansignalpugs = meansignalpugs(:);
    % noisepugs = noisepugs(:);
    % isnr_vec = meansignalpugs./noisepugs;
    
    % compute std across noise
    %noise_data_vec = noise_data(:);
    noise_data = normalize(noise_data,'range');
    std_noise=std(noise_data);
    meansignalpugs = normalize(meansignalpugs,'range');

    %std_noise = std(noise_data_vec);
    iSNR=meansignalpugs./std_noise;
    

    
    %isnrpugs2 = reshape(isnr_vec,nX,nY,nS);
    %isnrpugs2(isnrpugs2>1000) = 0; % This thresholds the tSNR so it's not super high
    
    %fprintf('iSNR: %.4f\n',nanmean(isnrpugs2(:)));
    a = iSNR(~isinf(iSNR));
    b = a(~isnan(a));
    fprintf('mean iSNR: %.4f\n', mean(b));
    %fprintf('mean iSNR: %.4f\n',nanmean(iSNR(:)));
    
end

% save('meanTSNR', 'tsnrData'); This was for debugging purposes.

% save out temporal SNR map
Hdr.dim(5)=1;

outputFilenameTSNR = [outputBaseName '_tSNR.hdr'];
%cbiWriteNifti(outputFilenameTSNR,tsnrData,Hdr);

% mri.nframes = 1;
% mri.vol = tsnrData;
% mri.niftihdr = Hdr;

outputFilenameTSNRmri = [outputBaseName '_tSNR.nii'];
%MRIwrite(mri,outputFilenameTSNRmri);
niftiwrite(tsnrData, outputFilenameTSNRmri);

disp(['Saved ' outputFilenameTSNR]);

% save out temporal SNR map and noise (as first and second volume)
Hdr.dim(5)=4;

output(:,:,:,1)=squeeze(tsnrData);
output(:,:,:,2)=squeeze(noise_data);
output(:,:,:,3)=squeeze(mean(im_data,4));
output(:,:,:,4)=squeeze(std(im_data,1,4));

%outputFilename = [outputBaseName '_tSNR_N_M_V.hdr'];

% mri.nframes = 1;
% mri.vol = output;
% mri.niftihdr = Hdr;
outputFilenamemri = [outputBaseName '_tSNR_N_M_V.nii'];
%MRIwrite(mri,outputFilenamemri);
niftiwrite(output,outputFilenamemri);

%cbiWriteNifti(outputFilename,output,Hdr);

Hdr.dim(5)=1;
meanImg=squeeze(mean(im_data,4));
outputFilename = [outputBaseName '_Mean.hdr'];

% mri.nframes = 1;
% mri.vol = meanImg;
% mri.niftihdr = Hdr;
outputFilenamemri = [outputBaseName '_Mean.nii'];
%MRIwrite(mri,outputFilenamemri);
niftiwrite(meanImg,outputFilenamemri);

%cbiWriteNifti(outputFilename,meanImg,Hdr);


%disp stuff
% mymean = mean(im_data,4);
% mystd = std(im_data,1,4);
%mytsnrval = mymean ./ mystd;
%fprintf('\n mean of mean image = %.4f \n', mean(mymean(:)))
%fprintf('\n std of mean image = %.4f \n', mean(mystd(:)))

%fprintf('\n 

disp(['Saved ' outputFilename]);

return