function [tsnrData, outputFilenameTSNR] = tSNR(dataFilename,varargin)

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


validInputArgs = {'dynNOISEscan', 'temporalFilter', 'cropTimeSeries', 'outputBaseName' ... % dyn NOISE scan at the end of time series to compute image SNR
    

};

eval(evalargs(varargin,[],[],validInputArgs))

% check inputs for the required arguments
if ieNotDefined('dynNOISEscan')
    dynNOISEscan=1;
end

if ieNotDefined('temporalFilter')
    temporalFilter=0;
    % Currently not used.
end

if ieNotDefined('cropTimeSeries')
    cropTimeSeries=[];
end

if ieNotDefined('dataFilename')
    % get data_filename
    [dataFilename,pathname] = uigetfile({'*.hdr';'*.nii';'*.img'},'Select file ');
end

if ieNotDefined('outputBaseName')
    outputBaseName = [pathname stripext(dataFilename)];    
end

% Reads the data from the file name, using MRIread's in-built function, note that this is different
data_struct = MRIread(dataFilename);
Data = data_struct.vol;

[fspec,~,fmt] = MRIfspec(dataFilename);
% Just a flag here to make sure it works properly.
switch fmt
    case {'img','hdr'},
        % Hdr = data_struct.analyzehdr;
        % Hdr.dim = Hdr.dime.dim;
        % Hdr.descrip = Hdr.hist.descrip;        
        % hdr = cbiReadNiftiHeader('scan10.hdr')
        [Data,Hdr] = cbiReadNifti(dataFilename);        
    case {'nii','nii.gz'},
        Hdr = data_struct.niftihdr;        
    otherwise 
        disp('Format not supported!!, change format to either analyze pair or nifti/niftigz');
end


% Hdr = data_struct.niftihdr;



% get data dimensions
nX = size(Data,1);
nY = size(Data,2);
nS = size(Data,3);
nV = size(Data,4);


if dynNOISEscan==1
    im_data=Data(:,:,:,1:nV-1);
    noise_data=Data(:,:,:,nV);
else
    im_data=Data;
    noise_data = zeros(nX,nY,nS);
end

if(~isempty(cropTimeSeries))
    im_data = im_data(:,:,:,cropTimeSeries(1):cropTimeSeries(2));
    nV = size(im_data,4);
end

%quick thing to check iSNR
% signalpugs = im_data(:,:,:,nV-1);
% noisepugs = im_data(:,:,:,nV);
% isnrpugs = mean(signalpugs,4)./noisepugs;
% isnrpugs2 = isnrpugs(~isnan(isnrpugs(:)) & ~isinf(isnrpugs(:)));
% fprintf('iSNR: %.4f\n', mean(isnrpugs2));

% To correct for scanner drift, we remove a linear and quadratic trend for the data
% (simplistic at the moment - compared to using high-pass filtering)
% 
% Here we reshape the data to vectorise it.
reshaped_data = reshape(im_data,nX*nY*nS,nV);
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
betas = P*(reshaped_data.');

% Now remove the linear and quadratic trend only..
detrended_data = (reshaped_data.' - X(:,2:3)*betas(2:3,:)).';
im_data = reshape(detrended_data,nX,nY,nS,nV);
% Now this is standard...

tsnrData=mean(im_data,4)./std(im_data,1,4);
tsnrData(tsnrData>1000) = 0; % This thresholds the tSNR so it's not super high

save('meanTSNR', 'tsnrData');

% save out temporal SNR map
Hdr.dim(5)=1;

outputFilenameTSNR = [outputBaseName '_tSNR'];

% now make a new structure to save the data, based on what MRIwrite needs.
data_struct_save = data_struct;
data_struct_save.niftihdr = Hdr;
data_struct_save.vol = tsnrData;
% MRIwrite(data_struct_save,outputFilenameTSNR);
save_nifti(fmt,Hdr,data_struct_save,outputFilenameTSNR);

disp(['Saved ' outputFilenameTSNR]);

% save out temporal SNR map and noise (as first and second volume)
Hdr.dim(5)=4;

output(:,:,:,1)=squeeze(tsnrData);
output(:,:,:,2)=squeeze(noise_data);
output(:,:,:,3)=squeeze(mean(im_data,4));
output(:,:,:,4)=squeeze(std(im_data,1,4));

outputFilename = [outputBaseName '_tSNR_N_M_V'];

% now make a new structure to save the data, based on what MRIwrite needs.
data_struct_save = data_struct;
data_struct_save.niftihdr = Hdr;
data_struct_save.vol = output;
save_nifti(fmt,Hdr,data_struct_save,outputFilename);
% MRIwrite(data_struct_save,outputFilename);

Hdr.dim(5)=1;
meanImg=squeeze(mean(im_data,4));
outputFilename = [outputBaseName '_Mean'];

% now make a new structure to save the data, based on what MRIwrite needs.
data_struct_save = data_struct;
data_struct_save.niftihdr = Hdr;
data_struct_save.vol = meanImg;
save_nifti(fmt,Hdr,data_struct_save,outputFilename);
% MRIwrite(data_struct_save,outputFilename);
fprintf('\n mean of mean image = %.4f \n', mean(meanImg(:)))
%fprintf('\n 

disp(['Saved ' outputFilename]);

return
end


% A function here to save a compressed nifti. Unforunately MRIread is having trouble saving an analyze formatted nifti, then saving it (i think it is assuming it is a SPM nifti, not sure)
% either way, we use mrTools to load in the nifti-pair, save it then use mri_convert to make a compressed nifti.
function save_nifti(fmt,Hdr,data_struct_save,outputFilename)
    switch fmt
    case {'img','hdr'},
        cbiWriteNifti([outputFilename '.hdr'],data_struct_save.vol,Hdr);
        unix_command  = ['mri_convert ' outputFilename '.hdr ' outputFilename '.nii.gz'];
        system(unix_command);
        % not removing the file just in case people want to load it into mrTools! they are small anyway.
        % unix_command = ['rm ' outputFilename '.nii'];
        % system(unix_command);
    case {'nii','nii.gz'},
        MRIwrite(data_struct_save,[outputFilename '.nii.gz']);
    end
end