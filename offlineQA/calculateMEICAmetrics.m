% calculate meica metrics -- just for now doing it in this way, probably hard to do so for something else. 

% load up each image, do it for each of them:


meica_folders = {'meica.e1_A_P_Con_3_mbep2d_boldnative_3_echoes','meica.e1_A_P_Con_4_mbep2d_boldnative_4_echoes','meica.e1_A_P_Con_5_mbep2d_boldnative_5_echoes'};
analyses = {'_3_echoes_native_','_4_echoes_native_','_5_echoes_native_'};
echo_string = {'3','4','5'};


for subject = 1:3,
	subjectFolder = ['/Users/kevinaquino/projects/multiecho/pilot/MRH021_ME0' num2str(subject) '_MR01'];
	cd(subjectFolder);
	for analysis = 1:3,
		file=['subject' num2str(subject) analyses{analysis} 'medn.nii.gz'];
		freesurferID = ['S' num2str(subject) '_me'];
		unix_string = ['$FREESURFER_HOME/bin/mri_vol2vol --mov $SUBJECTS_DIR/' freesurferID '/mri/ribbon.mgz --targ ' file ' --o QA_report/temp_mask.mgz --regheader --interp nearest'];
		system(unix_string);

		figH = figure('color','white','visible','off');
		file1=['subject' num2str(subject) analyses{analysis} 'tsoc.nii.gz'];
		file2=['subject' num2str(subject) analyses{analysis} 'medn.nii.gz'];
		plot_metrics(file1,file2,'QA_report/temp_mask.mgz',[meica_folders{analysis} '/motion.1D'],['S' num2str(subject) ' ' echo_string{analysis} ' echoes']);
		% unix_string_rh = [ ' which(fname_tSeries)
		% after this is done, get the WM and GM voxels to show in a plot, show mask movement, and then DVARS of the two		
		set(figH,'PaperPosition',[0.25 0.25 40 60],'units','character');	
		output_png = [pwd '/QA_report/' echo_string{analysis} '_echoes.png'];
		print(figH,output_png,'-dpng');
		close(figH);
	end
end

