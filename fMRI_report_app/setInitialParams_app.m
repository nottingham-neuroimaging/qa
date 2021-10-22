% Here is a function to obtain default parameters
function scanParams = setInitialParams_app(filenames)

% initialize the array.
scanParams = struct;
% get intial parameters from the


for nf=1:length(filenames)
    %hdr = cbiReadNiftiHeader(filenames{nf});
    %hdr = MRIread(filenames{nf},1);
    
    hdr = niftiinfo(filenames{nf});
    
    
    scanParams(nf).fileName = filenames{nf};
    scanParams(nf).dynNOISEscan = 0;
    %scanParams(nf).volumeSelect = [hdr.dim(5)];
    %scanParams(nf).volumeSelect = [hdr.nframes];
    scanParams(nf).volumeSelect = [hdr.ImageSize(4)];
    
    %scanParams(nf).volumeSelectFirst = [hdr.dim(5)/hdr.dim(5)];
    %scanParams(nf).volumeSelectFirst = [hdr.nframes/hdr.nframes];
    scanParams(nf).volumeSelectFirst = 1;
    scanParams(nf).sliceSelectFirst = 1;
    %scanParams(nf).sliceSelectLast = [hdr.dim(4)];
    %scanParams(nf).sliceSelectLast = [hdr.depth];
    scanParams(nf).sliceSelectLast = [hdr.ImageSize(3)];
    
    %scanParams(nf).outputBaseName = hdr.hdr_name(1:end-4);
    %scanParams(nf).outputBaseName = hdr.fspec(1:end-4);
    bloop = filenames{nf};
    scanParams(nf).outputBaseName = bloop(1:end-7);
    %scanParams(nf).slices = 1:hdr.dim(4);
    %scanParams(nf).slices = 1:hdr.depth;
    scanParams(nf).slices = 1:hdr.ImageSize(3);
    %scanParams(nf).dims = hdr.dim(2:4);
    %scanParams(nf).dims = [hdr.height;hdr.width;hdr.depth];
    scanParams(nf).dims = [hdr.ImageSize(1:3)];
    
    scanParams(nf).ROI_box = [];
    % Some of the characters in this contain non-unicode characters, so
    % remove them here. 
%     if isfield(hdr,'analyzehdr') && ~isempty(hdr.analyzehdr) % MRIread nuance
%         unicodenotes = unicode2native(hdr.analyzehdr.hist.descrip);
%         scanParams(nf).notes = hdr.analyzehdr.hist.descrip(setdiff(1:length(unicodenotes),find(~unicodenotes)));
%     else
%         unicodenotes = unicode2native(hdr.niftihdr.descrip);
%         scanParams(nf).notes = hdr.niftihdr.descrip(setdiff(1:length(unicodenotes),find(~unicodenotes)));
%     end
    %keyboard
    unicodenotes = unicode2native(hdr.Filemoddate);
    scanParams(nf).notes = hdr.Filemoddate(setdiff(1:length(unicodenotes),find(~unicodenotes)));
    
    scanParams(nf).orientation = 3;
end

end