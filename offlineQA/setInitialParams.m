% Here is a function to obtain default parameters
function scanParams = setInitialParams(filenames)

% initialize the array.
scanParams = struct;
% get intial parameters from the


for nf=1:length(filenames)
    hdr = cbiReadNiftiHeader(filenames{nf});
    scanParams(nf).fileName = filenames{nf};
    scanParams(nf).dynNOISEscan = 0;
    scanParams(nf).volumeSelect = [hdr.dim(5)];
    scanParams(nf).volumeSelectFirst = [hdr.dim(5)/hdr.dim(5)];
    scanParams(nf).outputBaseName = hdr.hdr_name(1:end-4);
    scanParams(nf).slices = 1:hdr.dim(4);
    scanParams(nf).dims = hdr.dim(2:4);
    scanParams(nf).ROI_box = [];
    % Some of the characters in this contain non-unicode characters, so
    % remove them here. 
    unicodenotes = unicode2native(hdr.descrip);
    scanParams(nf).notes = hdr.descrip(setdiff(1:length(unicodenotes),find(~unicodenotes)));    
end

end