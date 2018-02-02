function [tSNR tSeries] = freesurferMetrics(fname_tSNR,fname_tSeries,subject,output,subjects_dir)
% This here is another part of the story, adding in freesurfer metrics. Will have to think about how it actually works.

% Firstly get the subject's file, then do mri_vol2surf assuming that the subject has already been aligned to its native space

% scanParams(nf).fileName

% fname_tSNR = [pwd '/QA_report/subject1_4_echoes_native_medn_tSNR.nii.gz'];
% fname_tSeries = 'subject1_4_echoes_native_medn.nii.gz';
% subject = 'S1_me';
% output = [pwd '/QA_report/surface'];
% subjects_dir = '/Applications/freesurfer/subjects/';

	if(~system(getenv('which freeview')));
		bash_path=getenv ('PATH');
		fs_home = getenv('FREESURFER_HOME');
		setenv('PATH',[bash_path,':',':' fs_home '/bin']);
		setenv('DYLD_LIBRARY_PATH',[fs_home '/lib/gcc/lib']);
		setenv('SUBJECTS_DIR',subjects_dir)
	end



	% these bottom two should be options to call
	parcellation = 'aparc.annot';

	% This section is clunky, could make more streamlined

	% transform the tSNR
	unix_string_lh = ['$FREESURFER_HOME/bin/mri_vol2surf --mov ' fname_tSNR ' --regheader ' subject ' --o ' output '.tSNR.lh.mgz --hemi lh'];
	unix_string_rh = ['$FREESURFER_HOME/bin/mri_vol2surf --mov ' fname_tSNR ' --regheader ' subject ' --o ' output '.tSNR.rh.mgz --hemi rh'];

	system(unix_string_lh);
	system(unix_string_rh);

	% transform the time series
	unix_string_lh = ['$FREESURFER_HOME/bin/mri_vol2surf --mov ' which(fname_tSeries) ' --regheader ' subject ' --o ' output '.tSeries.lh.mgz --hemi lh'];
	unix_string_rh = ['$FREESURFER_HOME/bin/mri_vol2surf --mov ' which(fname_tSeries) ' --regheader ' subject ' --o ' output '.tSeries.rh.mgz --hemi rh'];

	system(unix_string_lh);
	system(unix_string_rh);


	% Now that we have the tSNR onto the actual surface, the next step would be to take the parcellations (standard aparc) and then average the tSNR for that parcel


	tSNR_lh_struct = MRIread([output '.tSNR.lh.mgz']);
	tSNR_rh_struct = MRIread([output '.tSNR.rh.mgz']);

	tSNR.lh = tSNR_lh_struct.vol;
	tSNR.rh = tSNR_rh_struct.vol;

	tSeries_lh_struct = MRIread([output '.tSeries.lh.mgz']);
	tSeries_rh_struct = MRIread([output '.tSeries.rh.mgz']);

	tSeries.lh = tSeries_lh_struct.vol;
	tSeries.rh = tSeries_rh_struct.vol;


	[vertices_lh label_lh ctab_lh] = read_annotation([subjects_dir subject '/label/lh.' parcellation]);
	[vertices_rh label_rh ctab_rh] = read_annotation([subjects_dir subject '/label/rh.' parcellation]);

	% now for each hemispehre go through and grab the annotation files, get the time series perform tSNR qa, show the time series as a plot AND then 
	% do a simple correlation analysis. 

	for nr = 2:length(ctab_rh.struct_names),
		parcelInds = find(label_rh==ctab_rh.table(nr,5));
		% now work at the parcel level to do averaging, make sure no zero's are in there (thereby making mistakes)
		% just work off the tSNR as this is better to look at
		parcel_tSNR = tSNR.rh(parcelInds);		
		parcel_tSeries = squeeze(tSeries.rh(1,parcelInds,1,:));

		useInds = intersect(find(parcel_tSNR>0),find(~isnan(parcel_tSNR)));
		tSNR.parcelrh(nr-1,:) = mean(parcel_tSNR(useInds));
		tSeries.parcelrh(nr-1,:) = mean(parcel_tSeries(useInds,:));
	end

	for nr = 2:length(ctab_lh.struct_names),
		parcelInds = find(label_lh==ctab_lh.table(nr,5));
		% now work at the parcel level to do averaging, make sure no zero's are in there (thereby making mistakes)
		% just work off the tSNR as this is better to look at
		parcel_tSNR = tSNR.lh(parcelInds);
		parcel_tSeries = squeeze(tSeries.lh(1,parcelInds,1,:));
		useInds = intersect(find(parcel_tSNR>0),find(~isnan(parcel_tSNR)));
		tSNR.parcellh(nr-1,:) = mean(parcel_tSNR(useInds));
		tSeries.parcellh(nr-1,:) = mean(parcel_tSeries(useInds,:));
	end

end