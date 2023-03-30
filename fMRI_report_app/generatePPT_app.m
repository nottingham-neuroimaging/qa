function generatePPT_app(scanParams)
% create a programmatic powerpoint to store the means and images

import mlreportgen.ppt.*;
ppt_path = 'QA_report/';
%cd(ppt_path)
ppt = Presentation('QA_report_slides_mean.pptx'); %ppt_path,
open(ppt);
slide1 = add(ppt,'Title Slide');
replace(slide1,'Title','Mean images');
replace(slide1,'Subtitle','QA_report_output');

for nf=1:length(scanParams)
    thisImage = Picture([ppt_path scanParams(nf).outputBaseName '_Mean_IMAGE.png']);
    thisImage.X = '300'; thisImage.Y = '150';
    pictureSlide = add(ppt,'Title Only');
    replace(pictureSlide,'Title',scanParams(nf).outputBaseName);
    contents = find(pictureSlide,'Title');
    contents.FontSize = '12';
    add(pictureSlide,thisImage);
end
close(ppt);

%%
import mlreportgen.ppt.*;
ppt_path = 'QA_report/';
%cd(ppt_path)
ppt = Presentation('QA_report_slides_tSNR.pptx'); %ppt_path,
open(ppt);
slide1 = add(ppt,'Title Slide');
replace(slide1,'Title','tSNR images');
replace(slide1,'Subtitle','QA_report_output');

for nf = 1:length(scanParams)
    thisImage = Picture([ppt_path scanParams(nf).outputBaseName '_tSNR_IMAGE.png']);
    thisImage.X = '300'; thisImage.Y = '150';
    pictureSlide = add(ppt,'Title Only');
    replace(pictureSlide,'Title',scanParams(nf).outputBaseName);
    contents = find(pictureSlide,'Title');
    contents.FontSize = '12';
    add(pictureSlide,thisImage);

    thisImage2 = Picture([ppt_path 'cbar.png']);
    thisImage2.X = '0'; thisImage2.Y = '600';
    thisImage2.Width = '200'; thisImage2.Height = '40'; 
    add(pictureSlide,thisImage2);
end
close(ppt);


end