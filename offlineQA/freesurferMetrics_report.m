function freesurferMetrics_report(figHandle)

	data = guidata(figHandle)
	scanParams = data.scanParams;
	subjects_dir = data.subjects_dir;

	% A parameter that needs to be inputted really in the GUI	
	data.freesurfersubject = 'S1_me';			


	if(data.options.recaulculateTSNR)
    	for nf=1:length(scanParams)
    		output = [pwd '/QA_report/' data.scanParams(nf).outputBaseName '_surface'];
    		fname_tSNR = [pwd '/QA_report/' data.scanParams(nf).outputBaseName '_tSNR.nii.gz'];
    		fname_tSeries = data.scanParams(nf).fileName;
    		subject = data.freesurfersubject;
    		[tSNR tSeries] = freesurferMetrics(fname_tSNR,fname_tSeries,subject,output,subjects_dir);

    		tSNR_across_scans{nf}.parcelrh = tSNR.parcelrh;
    		tSNR_across_scans{nf}.parcellh = tSNR.parcellh;

    		tSeries_across_scans{nf} = [tSeries.parcellh;tSeries.parcelrh];

    	end
	end

	% next thing after this is to generate PNGs etc
end