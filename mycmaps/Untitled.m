function cmap = spectral(varagin)

if ~nargin
    ncols = 256;
else
    ncols = argin{1};
end

cmaptemp = circshift(flipud(hsv(13)),-2);

len = cmaptemp;
    oldsteps = linspace(0, 1, len);
    newsteps = linspace(0, 1, ncols);
    cmap = zeros(ncols, 3);
    
    for i=1:3
        % Interpolate over RGB spaces of colormap
       cmap(:,i) = min(max(interp1(oldsteps, cmaptemp(:,i), newsteps)', 0), 1);
    end