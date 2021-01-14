% Here is a function to obtain default parameters
function scanParams = setInitialParams_app(filenames)

% initialize the array.
scanParams = struct;
% get intial parameters from the


for nf=1:length(filenames)
    %hdr = cbiReadNiftiHeader(filenames{nf});
    hdr = MRIread(filenames{nf},1);
    scanParams(nf).fileName = filenames{nf};
    scanParams(nf).dynNOISEscan = 0;
    %scanParams(nf).volumeSelect = [hdr.dim(5)];
    scanParams(nf).volumeSelect = [hdr.nframes];
    %scanParams(nf).volumeSelectFirst = [hdr.dim(5)/hdr.dim(5)];
    scanParams(nf).volumeSelectFirst = [hdr.nframes/hdr.nframes];
    scanParams(nf).sliceSelectFirst = 1;
    %scanParams(nf).sliceSelectLast = [hdr.dim(4)];
    scanParams(nf).sliceSelectLast = [hdr.depth];
    %scanParams(nf).outputBaseName = hdr.hdr_name(1:end-4);
    scanParams(nf).outputBaseName = hdr.fspec(1:end-4);
    %scanParams(nf).slices = 1:hdr.dim(4);
    scanParams(nf).slices = 1:hdr.depth;
    %scanParams(nf).dims = hdr.dim(2:4);
    scanParams(nf).dims = [hdr.height;hdr.width;hdr.depth];
    scanParams(nf).ROI_box = [];
    % Some of the characters in this contain non-unicode characters, so
    % remove them here. 
    if isfield(hdr,'analyzehdr') % MRIread nuance
        unicodenotes = unicode2native(hdr.analyzehdr.hist.descrip);
        scanParams(nf).notes = hdr.analyzehdr.hist.descrip(setdiff(1:length(unicodenotes),find(~unicodenotes)));
    else
        unicodenotes = unicode2native(hdr.niftihdr.descrip);
        scanParams(nf).notes = hdr.niftihdr.descrip(setdiff(1:length(unicodenotes),find(~unicodenotes)));
    end
    scanParams(nf).orientation = 3;
end

end