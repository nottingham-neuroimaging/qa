function [] = stability_app(im_data,imgScale,outputBaseName,noise_data)
%stability_app subfunction of tSNR_app.m, part of fMRI_report_app.m
% add a plot to look at signal and std in a patch
%
% See Also tSNR_app fMRI_report_app


if ~isempty(noise_data)
    runISNR = 1;
else
    runISNR = 0;
end

tsnrData=mean(im_data,4)./std(im_data,0,4);

nX = size(im_data,1);
nY = size(im_data,2);
nS = size(im_data,3);
nV = size(im_data,4);

thr = 0.05.*max(im_data(:));
im_data_vec = im_data(:);
clean = im_data_vec>thr;
cleaned = im_data_vec.*clean;

cleaned_data = reshape(cleaned,[nX,nY,nS,nV]);


patchsize = [14 14];
xpos = round(nX./2)+12; %-20
ypos = round(nY./2)-8; %+10
xpatch = xpos+patchsize(1);
ypatch = ypos+patchsize(2);


montage=12; % for tiles
theRound = round(nS./montage);

% we dont care about top and bottom
% take middle 80%

sliceVec = round(0.2*nS):theRound:round(0.8*nS);
tiles = length(sliceVec);

grid = factork(length(sliceVec),3);

%grid = factor(length(sliceVec));
mylims = [0 100];
% BROKEN
%thisSlice = round(size(cleaned_data,3).*0.5);
%thisSlice = round(size(cleaned_data,3).*(2./3));
thisSlice = round(size(cleaned_data,3).*0.57);
%thisSlice = round(size(cleaned_data,3)./2);
%thisSlice = 19;
quickCrop = [xpos,xpatch,ypos,ypatch,thisSlice];
mypatch = cleaned_data(quickCrop(1):quickCrop(2),quickCrop(3):quickCrop(4),quickCrop(5),:);
squatch = squeeze(mypatch);


% here third dim is time, so it's ok
patch_tSNR = mean(squatch,3)./std(squatch,0,3);
patch_tSNR_mean = nanmean(patch_tSNR(:));


if runISNR
    %keyboard
    %ricianFactor = 0.655;
    ricianFactor = sqrt(2-pi/2);
    %noise_data_corr = noise_data ./ ricianFactor;
    %noise_data_corr_std = std(double(noise_data(:))) ./ ricianFactor;
    msig = mean(im_data,4);
    stdsig = std(im_data,0,4);
    %iSNR = msig./noise_data_corr_std;

    
    %iSNR = (msig ./ double(noise_data)).*ricianFactor;
    
    iSNR = (msig ./ stdsig).*ricianFactor;

    isnrfig = figure('Position',[100 100 800 600]);

    if verLessThan('matlab', '9.7')
        % Put code to run under MATLAB older than MATLAB 9.7 (2019b) here
        for ii = 1:tiles
            subplot(grid(1),grid(2),ii)
            imagesc(iSNR(:,:,sliceVec(ii)))
            colormap plasma
            c = colorbar;
            c.Label
            clim([mylims(1) mylims(2)])
            axis square
            title(sprintf('slice %d, iSNR',sliceVec(ii)))
        end
        print(isnrfig,[outputBaseName '_iSNR.png'],'-dpng');

    else
        % Put code to run under MATLAB 9.7 (2019b) and newer here

        tiledlayout(grid(1),grid(2))
        for ii = 1:tiles
            nexttile
            imagesc(iSNR(:,:,sliceVec(ii)))
            colormap plasma
            c = colorbar;
            c.Label
            %c.Label.String = 'Hz';
            clim([mylims(1) mylims(2)])
            axis square
            title(sprintf('slice %d, iSNR',sliceVec(ii)))
        end
        print(isnrfig,[outputBaseName '_iSNR.png'],'-dpng');

    end
end


bloop = figure('Position',[100 100 850 500]);

if verLessThan('matlab', '9.7')
    subplot(2,3,1)
else
    tiledlayout(2,3)
    nexttile
end
imagesc(tsnrData(:,:,quickCrop(5)))
title(sprintf('tSNR, slice %d',quickCrop(5)))
clim([0 imgScale])
hold on
rectangle('Position',[quickCrop(3),quickCrop(1),patchsize],...
    'LineWidth',2,'LineStyle','--')
colormap inferno
colorbar

if verLessThan('matlab', '9.7')
    subplot(2,3,2)
else
    nexttile
end

imagesc(patch_tSNR)
title(sprintf('patch tSNR = %d',round(patch_tSNR_mean)))
colormap inferno
colorbar
clim([0 imgScale])

% is this silly? Take the mean and std of the patch slice, as we want a
% single number over time to plot.
squatch_t = squeeze(mean(squatch,[1 2]));
squatch_std = squeeze(std(squatch,0,[1 2]));

a = squatch_t-mean(squatch_t);
b = squatch_std-mean(squatch_std);
% demean
% from classic

if verLessThan('matlab', '9.7')
    subplot(2,3,[4 5])
else
    nexttile([1 2])
end

plot(1:length(a),a,'LineWidth',2)
hold on
plot(1:length(b),b,'LineWidth',2)
legend('Mean patch','STD patch','FontSize',9,'Location','southeast')
%title(sprintf('mean of signal %.0f, mean of std %.0f',mean(squatch_t), mean(squatch_std)));
title('mean and std dev')
ylim([-10 10])
xlabel('time (s)')
ylabel('demeaned signal')
%print(bloop,[outputBaseName '_signal_std.png'],'-dpng');

if verLessThan('matlab', '9.7')
    ff = subplot(2,3,3);
else
    ff = nexttile;
end


stat_mean = mean(cleaned_data,4);
imagesc(stat_mean(:,:,quickCrop(5)));



%title(sprintf('mean across time = %d',round(mean(nonzeros(stat_mean(:))))));
title(sprintf('mean across time'))
colormap(ff,viridis)
colorbar(ff)
%clim([0 imgScale])

if verLessThan('matlab', '9.7')
    ff = subplot(2,3,6);
else
    ff = nexttile;
end

oddSlices = 1:2:size(cleaned_data,4);
evenSlices = 2:2:size(cleaned_data,4);
ODD = cleaned_data(:,:,:,oddSlices);
EVEN = cleaned_data(:,:,:,evenSlices);
sumODD = sum(ODD,4);
sumEVEN = sum(EVEN,4);
thisDIFF = sumODD-sumEVEN;
% stat_std_noise = std(cleaned_data,0,4);
% imagesc(stat_std_noise(:,:,quickCrop(5)));
% title(sprintf('std across time = %d',round(mean(nonzeros(stat_std_noise(:))))));
stat_spatial_noise = thisDIFF(:,:,quickCrop(5));
%imagesc(stat_spatial_noise(:,:,quickCrop(5)));
imagesc(stat_spatial_noise);
%title(sprintf('Static Spatial Noise Image, mean=%d',round(mean(stat_spatial_noise(:)))) );
title(sprintf('Static Spatial Noise Image'));
colormap(ff,viridis)
colorbar(ff)
%clim([-1000000 1000000])
print(bloop,[outputBaseName '_signal_std.png'],'-dpng');






end




