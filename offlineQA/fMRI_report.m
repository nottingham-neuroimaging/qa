% This script here is to calculate the tSNR, image SNR then generate a
% report showing these if needed. A work in progress ...

% function [tSNR_ROI,iSNR]=fMRI_report()


% Select the the scans taht we want to use.
[filenames,pathname] = uigetfile({'*.img;*.nii;*.nii.gz','Nifti/Analyze files'},'Select the scans you want a report on... ', 'multiselect', 'on');
if ischar(filenames)
  filenames = {filenames};
end

% Make a folder called QA_report, where the tSNR maps are calculated, and
% where the summary file will live once this is run.
cd(pathname);
if(~isdir('QA_report'));
    mkdir('QA_report');
end

% intialize intial parameters from the nifti headers.
scanParams = setInitialParams(filenames);

% Now run the GUI.
scanParams = fMRI_report_GUI(scanParams);

