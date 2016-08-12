function [] = tSNR_dyn(dataFilename, varargin)
%tSNR_dyn - easy way to quickly get tSNR for different dynamic length
%         - call it like:
%         - tSNR_dyn([], 'croppedTimeSeries=[1 20]'
%         - Where [1 20] specified the dynamic range  
%         - This is all possible to do with the function tSNR, but
%         difficult to get it to print info out, so I made this.
%         - K. Aquino's qa function only allows a slice selection, not a
%         dynamic selection (through the GUI at least).
%
% ma 2016/08/12 
%
% see also tSNR, tSNR_report, cbiReadNifti, varargin

validInputArgs = {'cropTimeSeries'};
eval(evalargs(varargin, validInputArgs))

if ieNotDefined('cropTimeSeries')
    cropTimeSeries=[];
end


[tsnrData, outputFilenameTSNR] = tSNR(dataFilename, varargin{:}); % need the {:}, syntax issue

fname = outputFilenameTSNR;
data = cbiReadNifti(fname);
data2 = data(~isnan(data(:)) & ~isinf(data(:)));

fprintf('Max TSNR: %.4f\n', max(data2))
fprintf('Mean TSNR: %.4f across dynamics %.d to %.d\n', mean(data2), cropTimeSeries)

end

