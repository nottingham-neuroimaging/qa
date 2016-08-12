% This script here is to calculate the tSNR, image SNR then generate a
% report showing these if needed. 

function fMRI_report()


	% Select the the scans that we want to use.
	[filenames,pathname] = uigetfile({'*.img;*.nii;*.nii.gz','Nifti/Analyze files'},'Select the scans you want a report on... ', 'multiselect', 'on');
	if ischar(filenames)
	  filenames = {filenames};
	elseif isnumeric(filenames)
	  return;
	end

	% Make a folder called QA_report, where the tSNR maps are calculated, and
	% where the summary file will live once this is run.
	cd(pathname);
	if(~isdir([pathname '/QA_report']));
	    mkdir('QA_report');
	end

	% intialize intial parameters from the nifti headers.
	scanParams = setInitialParams(filenames);

	% Now run the GUI.
	scanParams = fMRI_report_GUI(scanParams);

end