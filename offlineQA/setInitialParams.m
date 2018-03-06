% Here is a function to obtain default parameters
function scanParams = setInitialParams(filenames)

% initialize the array.
scanParams = struct;
% get intial parameters from the


for nf=1:length(filenames)
    % Only read the nifti header from freesurfer's MRIread.
    data_struct = MRIread(filenames{nf},1);

    [fspec,~,fmt] = MRIfspec(filenames{nf});
    switch fmt
        case {'img','hdr'},
            hdr = data_struct.analyzehdr;
            hdr.dim = hdr.dime.dim;
            hdr.descrip = hdr.hist.descrip;
            outputBaseName = fspec(1:end-4);
        case {'nii','nii.gz'},
            hdr = data_struct.niftihdr;
            outputBaseName = fspec(1:end-7);
        otherwise 
            disp('Format not supported!!, change format to either analyze pair or nifti/niftigz');
    end
                
    hdr.hdr_name = data_struct.fspec;

    scanParams(nf).fileName = filenames{nf};
    scanParams(nf).dynNOISEscan = 0;
    scanParams(nf).volumeSelect = [hdr.dim(5)];
    scanParams(nf).volumeSelectFirst = [hdr.dim(5)/hdr.dim(5)];
    scanParams(nf).outputBaseName = outputBaseName;
    scanParams(nf).slices = 1:hdr.dim(4);
    scanParams(nf).dims = hdr.dim(2:4);
    scanParams(nf).ROI_box = [];
    % Some of the characters in this contain non-unicode characters, so
    % remove them here. 
    unicodenotes = unicode2native(hdr.descrip);
    scanParams(nf).notes = hdr.descrip(setdiff(1:length(unicodenotes),find(~unicodenotes)));
    scanParams(nf).orientation = 3;
end

    scanParams(1).createFSreport_html = 0;
end

