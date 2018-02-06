%% IntensityNormalise: 
function normalizedTimeSeries = mode1000Normalization(ts)
	% This function performs modal intensity normalisation to the value of 1000
	% Adapted from Linden Parkes' Code
	% but why 1000? not sure but this is power's method
	%
	% ------------------------------------------------------------------------------
	% Generate brain mask
	% ------------------------------------------------------------------------------
	% I do this by finding voxels (columns) that are all-zero
	% This is why it is important to input 4d epi file that has brain masked BEFORE
	% inputting to this function
	% Leaving these voxels in will guarantee a mode value of 0...not useful...
	
	N = size(ts,1);
	% Find zeros voxels
	mask = ts == 0;
	% sum across rows (time points) to find voxels with all-zero voxels
	mask = sum(mask);
	% Retain only those sums that equal length of times
	mask(mask == N) = 1;
	% Invert to brain voxels
	mask = ~mask;
	% Make logical
	mask = logical(mask);

	% ------------------------------------------------------------------------------
	% Mask out non brain voxels
	% ------------------------------------------------------------------------------
	ts = ts(:,mask);

	% ------------------------------------------------------------------------------
	% Get modal value
	% ------------------------------------------------------------------------------
	tsMode = mode(ts(:));

	% ------------------------------------------------------------------------------
	% Normalise by mode
	% ------------------------------------------------------------------------------
	if tsMode == 0
		fprintf(1, 'NOTE, modal value is 0! exiting...\n');
	else
		ts = (ts./tsMode)*1000;
	end

	% ------------------------------------------------------------------------------
	% Reshape back to 4D
	% ------------------------------------------------------------------------------
	% Add non brain voxels back in
	numVoxels = numel(mask);
	tsTemp = zeros(N,numVoxels);
	
	idx = find(mask);
	numBrainVoxels = length(idx);

	% loop over each brain voxel column
	for i = 1:numBrainVoxels
		% write it to the corresponding column in tsTemp
		tsTemp(:,idx(i)) = ts(:,i);
	end

	normalizedTimeSeries = tsTemp;

end