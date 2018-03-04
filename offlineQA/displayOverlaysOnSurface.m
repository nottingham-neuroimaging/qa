function [figure_handle,cam_handle] = displayOverlaysOnSurface(surfaceOverlay,subject,subjectsFolder)
	% subjectsFolder = ['/Applications/freesurfer/subjects/'];	
	figure_handle = figure('color','black','visible','on');
	% set(figure_handle
	hold on;
	[surfaceHandle_left] = visualizeInflatedMapFreesurfer(subject,'lh',subjectsFolder);
	[surfaceHandle_right] = visualizeInflatedMapFreesurfer(subject,'rh',subjectsFolder);
	cam_handle = camlight;		
	material('dull');

	view([0 90]);
	cam_handle.Position = [0 0 1.1945e+03];

	% LH
	faceVDataCurv_left = get(surfaceHandle_left,'FaceVertexCData'); % Here always keep!
	% RH
	faceVDataCurv_right = get(surfaceHandle_right,'FaceVertexCData'); % Here always keep!

	data_left = MRIread([surfaceOverlay '.lh.mgz']);
	data_right = MRIread([surfaceOverlay '.rh.mgz']);

	cmap = hot(256).';
	% cmap = cmap(:,end:-1:1);

	FaceVData_left = faceVDataCurv_left;
	FaceVData_right = faceVDataCurv_right;

	data_left = data_left.vol(1,:,1,1);
	data_right = data_right.vol(1,:,1,1);
	
	cols_left = meshData2Colors(data_left, cmap, [0 300], 1).';
	cols_right = meshData2Colors(data_right, cmap, [0 300], 1).';

	inds_left = find(data_left>0);
	inds_right = find(data_right>0);

	FaceVData_left(inds_left,:) = cols_left(inds_left,:);
	FaceVData_right(inds_right,:) = cols_right(inds_right,:);


	set(surfaceHandle_left,'FaceVertexCData',FaceVData_left);
	set(surfaceHandle_right,'FaceVertexCData',FaceVData_right);

end

function [surfaceHandle] = visualizeInflatedMapFreesurfer(subject,hemi,subjectsFolder)	
	
	[vertFull facesFull] = read_surf([subjectsFolder subject '/surf/' hemi '.inflated']);
	switch hemi
		case 'lh'
			vertFull(:,1) = vertFull(:,1) - 50;
		case 'rh'
			vertFull(:,1) = vertFull(:,1) + 50;
	end
		
	% curvData = read_curv([subjectsFolder subject '/surf/' hemi '.curv']);	
	curvData = read_curv([subjectsFolder subject '/surf/' hemi '.curv']);
	% figure_handle = figure;
	msh_curvature           = -curvData.';
	mod_depth               = 0.5;
	curvatureColorValues    = ((2*msh_curvature>0) - 1) * mod_depth * 128 + 127.5;

	curvatureColorValues(find(curvatureColorValues == 63.5)) = 85;
	curvatureColorValues(find(curvatureColorValues == 127.5)) = 130;
	% keyboard
	curvData = [curvatureColorValues;curvatureColorValues;curvatureColorValues].';
	curvData = curvData/255;
	% keyboard
	surfaceHandle = patch('Vertices',vertFull,'Faces',facesFull+1,'FaceVertexCdata',curvData,'FaceColor','interp','EdgeColor','none','FaceAlpha',1);
	axis image;
	axis off;
end