%myfile = 'MBtest4_WIP_MB1_TR2_S2_HS_0_8_SENSE_6_1.PAR';
function[] = mads(myfile, filename)
[data,info] = loadPARREC(myfile,'scale','DV','verbose',true);
data = squeeze(data);
cbiWriteNifti(filename, data);





end