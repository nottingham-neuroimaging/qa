function freesurferMetrics_report(figHandle)

	data = guidata(figHandle)
	scanParams = data.scanParams;
	subjects_dir = data.subjects_dir;

	% A parameter that needs to be inputted really in the GUI	
	data.freesurfersubject = 'S1_me';			


	% if(data.options.recaulculateTSNR)
    	for nf=1:length(scanParams)
    		output = [pwd '/QA_report/' data.scanParams(nf).outputBaseName '_surface'];
    		fname_tSNR = [pwd '/QA_report/' data.scanParams(nf).outputBaseName '_tSNR.nii.gz'];
    		fname_tSeries = data.scanParams(nf).fileName;
    		subject = data.freesurfersubject;
    		[tSNR tSeries] = freesurferMetrics(fname_tSNR,fname_tSeries,subject,output,subjects_dir);

    		tSNR_across_scans{nf}.parcelrh = tSNR.parcelrh;
    		tSNR_across_scans{nf}.parcellh = tSNR.parcellh;

    		tSeries_across_scans{nf} = [tSeries.parcellh;tSeries.parcelrh];
    		scanNames{nf} = scanParams(nf).fileName;
    	end
	% end

	left_bar = [];
	right_bar = [];
	for nf=1:length(scanParams)
		left_bar = [left_bar tSNR_across_scans{nf}.parcellh];
		right_bar = [right_bar tSNR_across_scans{nf}.parcelrh];
	end
	% next thing after this is to generate PNGs etc
	
	figH = figure('color','white','visible','off');
	barh([1:35],left_bar);
	set(gca,'YTickLabel',tSNR.struct_names_lh(2:end),'YTick',[1:length(tSNR.struct_names_lh(2:end))]);
	xlabel('tSNR');
	ylabel('Regions')
	legend(scanNames,'Location','SouthOutside','Interpreter','none');
	title(['LH ' data.freesurfersubject],'Interpreter','none')
	set(gca,'fontSize',18)
	set(figH,'PaperPosition',[0.25 0.25 30 50],'units','character');	
	print(figH,['QA_report/tSNR_bar_left.png'],'-dpng');
	close(figH);

	figH = figure('color','white','visible','off');
	barh([1:35],right_bar);
	set(gca,'YTickLabel',tSNR.struct_names_rh(2:end),'YTick',[1:length(tSNR.struct_names_rh(2:end))]);
	xlabel('tSNR');
	ylabel('Regions')
	legend(scanNames,'Location','SouthOutside','Interpreter','none');
	title(['RH ' data.freesurfersubject],'Interpreter','none');
	set(gca,'fontSize',18)
	set(figH,'PaperPosition',[0.25 0.25 30 50],'units','character');	
	print(figH,['QA_report/tSNR_bar_right.png'],'-dpng');
	close(figH);
	for nf=1:length(scanParams)	
		% Make a 3-way plot here
		figH = figure('color','white','visible','off');
		corrs = corr(zscore(tSeries_across_scans{nf}.'));

		subplot(3,1,1)
		imagesc(zscore(tSeries_across_scans{nf}.').');
		xlabel('Volumes')
		ylabel('Regions')		
		colorbar
		set(gca,'fontSize',18)
		h = title([data.freesurfersubject ' ' scanNames{nf}]);
		set(h,'Interpreter','none');
		subplot(3,1,3)		
		bins = linspace(-0.5,1,100);
		hist(corrs(:),bins);
		xlabel('Corr');ylabel('count');
		set(gca,'fontSize',18)
		subplot(3,1,2)
		imagesc(corrs);caxis([-0.5 1]);axis image;axis off;colorbar
		set(gca,'fontSize',18)
		set(figH,'PaperPosition',[0.25 0.25 20 40],'units','character');	
		output_png = [pwd '/QA_report/' data.scanParams(nf).outputBaseName '_connectivity.png'];
		print(figH,output_png,'-dpng');
		close(figH);

	end

	
end