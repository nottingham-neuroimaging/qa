% Function to plot meica metrics taking in two images, calculating the DVARS
function plot_metrics(img1,img2,mask,movementFile,customTitle,regressors)

	% Here just something to regress -- the option is just here.
	if(nargin<6)
		regressors = 'none';
	end
	subplot(4,1,1)
	% FD plotting using the movement file
	mov = motion_read(movementFile);
	FD = GetFDPower(mov);
	plot(FD);
	xlabel('frame');
	ylabel('FD');
	title(['Framewise displacement: ' customTitle]);
	set(gca,'fontSize',18);
	axis tight

	subplot(4,1,2)
	% DVARS plots

	switch regressors
		case 'motion'
			opt.regressor = mov.';
		otherwise 
			opt.regressor = [];			
			% do nothing
	end
	opt.normalization = 'mode1000';

	% keyboard
	dvars1 = dvars_rsfMRI(img1,mask,opt);
	dvars2 = dvars_rsfMRI(img2,mask,opt);
	plot(dvars1,'b');hold on;
	plot(dvars2,'r');
	legend({'unc','MEICA'},'Location','SouthEast','Orientation','horizontal')
	ylabel('DVARS');
	xlabel('frame');
	set(gca,'fontSize',18);
	axis tight;


	% Load up the mask Structure
	maskVol = MRIread(mask);
	maskVol = maskVol.vol;

	% Here are generic indices for freesurfer for GM (left and right hemis)
	GMInds = union(find(maskVol==3),find(maskVol==42));
	WMInds = union(find(maskVol==2),find(maskVol==41));
	rsdata1 = MRIread(img1);
	nframes = rsdata1.nframes;
	rsdata1 = reshape(rsdata1.vol,[prod(rsdata1.volsize),rsdata1.nframes]);;	

	%now work out zero inds in the mask
	zeroInds = find(rsdata1(:,2)==0);
	GMInds = setdiff(GMInds,zeroInds);
	WMInds = setdiff(WMInds,zeroInds);

	subplot(4,1,3)
	%  optimally combined echoes
	
	totalInds = length(GMInds) + length(WMInds);
	imageMatrix(1:length(WMInds),:) = rsdata1(WMInds,:);
	imageMatrix(length(WMInds)+1:length(GMInds)+length(WMInds),:) = rsdata1(GMInds,:);	
% 	keyboard
	% imageMatrix = RegressNoiseSignal(imageMatrix.',mov).';
	%here to test
	imagesc(zscore(imageMatrix,[],2));
	set(gca,'YDir','normal');
	set(gca,'YTick',[])
	hold on;
	line([1 nframes],[length(WMInds) length(WMInds)],'Color','red','LineWidth',2);	
	colormap gray;
	% colorbar
	xlabel('frame');
	ylabel('voxels');
	title('optimally combined')
	set(gca,'fontSize',18);
	
	subplot(4,1,4)
	% denoised meica
	rsdata2 = MRIread(img2);
	nframes = rsdata2.nframes;
	rsdata2 = reshape(rsdata2.vol,[prod(rsdata2.volsize),rsdata2.nframes]);
	imageMatrix(1:length(WMInds),:) = rsdata2(WMInds,:);
	imageMatrix(length(WMInds)+1:length(GMInds)+length(WMInds),:) = rsdata2(GMInds,:);
	% imageMatrix = RegressNoiseSignal(imageMatrix,mov.');
	%here to test
	imagesc(zscore(imageMatrix,[],2));
	hold on;
	set(gca,'YDir','normal');
	set(gca,'YTick',[])
	line([1 nframes],[length(WMInds) length(WMInds)],'Color','red','LineWidth',2);
	colormap gray;
	% colorbar 
	xlabel('frame');
	ylabel('voxels');
	title('MEICA')
	set(gca,'fontSize',18);


	% Plot denoised meica
end