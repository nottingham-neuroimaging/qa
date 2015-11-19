function tsnrData = tSNR(dataFilename,varargin)
% tSNRmap- compute temporal SNR map for functional time series
% Outputs tSNR, noise scan, Mean across time and variance across time in a
% single file (as fisrt, second, third and foruth volume)
% If there is a dynamic noise scan (las volume of the time series), it will also compute image SNR  
%      usage: [  ] = tSNRmap( dataFilename,  [varargin] )
%         by: sanchez-panchuelo, used some bits from project's students (Boreham)
%       date: 2015-03-30

%inputs:       - dataFilename: 4-D time series, last dynamic may be a noise scan or              
%              - dynNOISEscan: flag to treat the last dynamic as noise,
%              default is 1
%              - temporalFilter: flag to use high pass temporal filter on
%              the time series to remove scanner dirft, default is 0
%    outputs: tSNRmap; temporal SNR map 
%             It will rint tSNR and iSNR result if there is a dynamic noise scan 
%    


validInputArgs = {'dynNOISEscan', 'temporalFilter', ... % dyn NOISE scan at the end of time series to compute image SNR
   
		  
         }; 
 
eval(evalargs(varargin,[],[],validInputArgs))

% check input 
if ieNotDefined('dynNOISEscan')
   dynNOISEscan=1; 
end

% check input 
if ieNotDefined('temporalFilter')
   temporalFilter=0; 
end


if ieNotDefined('data_filename') 
    % get data_filename
    [dataFilename,pathname] = uigetfile({'*.hdr';'*.nii';'*.img'},'Select file ');
end        
    [Data, Hdr]=cbiReadNifti(dataFilename);   
    %Data=load_untouch_nii([pathname,filenames]); %If sbi not working

 %% Read file data
% This uses the function f_read to extract how many dynamics and slices
% there are in a scan, as well as labelling the last dynamic noise_dynamic

%[Num_d noise_dynamic Num_slices] = f_read(data);   
    
    
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
end
   
   tsnrData=mean(im_data,4)./std(im_data,1,4);

  % save out temporal SNR map
Hdr.dim(5)=1;
outputFilename = [pathname stripext(dataFilename) '_tSNR.hdr'];
cbiWriteNifti(outputFilename,tsnrData,Hdr);
disp(['Saved ' outputFilename]);

% save out temporal SNR map and noise (as first and second volume)
Hdr.dim(5)=4;

output(:,:,:,1)=squeeze(tsnrData);
output(:,:,:,2)=squeeze(noise_data);
output(:,:,:,3)=squeeze(mean(im_data,4));
output(:,:,:,4)=squeeze(std(im_data,1,4));

outputFilename = [pathname stripext(dataFilename) '_tSNR_N_M_V.hdr'];
cbiWriteNifti(outputFilename,output,Hdr);
disp(['Saved ' outputFilename]);

     
 return