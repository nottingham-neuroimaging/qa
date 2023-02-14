function cmap = spectral(varargin)

if ~nargin
    ncols = 256;
else
    ncols = varargin{1};
end

cmaptemp = circshift(flipud(hsv(13)),-2);
cmaptemp(12:13,:) = [];

len = length(cmaptemp);
oldsteps = linspace(0, 1, len);
newsteps = linspace(0, 1, ncols);
cmap = zeros(ncols, 3);

for i=1:3
    % Interpolate over RGB spaces of colormap
    cmap(:,i) = min(max(interp1(oldsteps, cmaptemp(:,i), newsteps)', 0), 1);
end