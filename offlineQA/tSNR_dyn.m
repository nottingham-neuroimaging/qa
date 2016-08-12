function [] = tSNR_dyn(dataFilename, varargin)
%tSNR_dyn - easy way to quickly get tSNR for different dynamic length
% 

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

