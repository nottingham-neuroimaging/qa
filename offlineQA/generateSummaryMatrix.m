function generateSummaryMatrix(image_data,[rows columns])


if(nargin<4)
    rc_flag = 'columns';
end



for j=1:length(strings),
    fnames{j} = [fileprefix strings{j}];
end

% get the sizes ready
file_eg = imread(fnames{1});
nw = size(file_eg,2);
nh = size(file_eg,1);

switch rc_flag
    case 'columns'
        im_matrix = uint8(zeros(nh,nw*length(strings),3));
    case 'rows'
        im_matrix = uint8(zeros(nh*length(strings),nw,3));
end

for j=1:length(strings),
    dat = imread(fnames{j});
    
    % Add this switch in case we are working with grayscale
    if(size(dat,3)==1)
        im_matrix = im_matrix(:,:,1);
    end
    
    switch rc_flag
        case 'columns'
            im_matrix(1:nh,(j-1)*nw+1:(j-1)*nw+nw,:) = dat;
        case 'rows'
            im_matrix((j-1)*nh+1:(j-1)*nh+nh,1:nw,:) = dat;
    end
    
end

imwrite(im_matrix,[file_output '.png'],'PNG');end