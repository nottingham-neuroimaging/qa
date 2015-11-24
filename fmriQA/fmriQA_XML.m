function fmriQA()
%% fmriQA - script. to be compiled to run as standalone EXE on scanner
%
% computes tSNR from functional dataset (escluding last dynamic(
%
% based on PSIR example code from andrew peters / emma hall.
% modified by Denis Schluppeck and Julien Besle
% 2015/11/23
%
%    a couple of notes: function should be able to be compiled (not script)
%      
%                       should break more stuff out into sub-functions to
%                       make it easier to read / debug.
%
%
%% define locations on scanner
InputPathName='G:\patch\pride\tempinputseries\';
OutputPathName='G:\patch\pride\tempoutputseries\';
% InputPathName='N:\data\testSNRPride\';
% OutputPathName='N:\data\testSNRPride\';
% InputPathName='/home/julien/data/testSNRPride/';
% OutputPathName='/home/julien/data/testSNRPride/';

% and the exported filename
FileName='DBIEX.REC';
% FileName='DBIEX_P.REC';

%% Read in the xml file
xml_file = strcat(InputPathName,strtok(FileName,'.'),'.xml');
% tic  %converting the xml file for a functional dataset takes a
% significant amount of time...
s = xml2struct(xml_file);
% toc

% info about the series
b1 = s.PRIDE_V5.Series_Info.Attribute;

% info about the image arrays
b2 = s.PRIDE_V5.Image_Array.Image_Info;
s.PRIDE_V5.Image_Array.Image_Info = []; %save some memory (this can be quite large for functional data)

% q = 0; % quit variable % deal with this in another way [ds]


%% Identify modulus and phase images 
m1=inf;
M=0;
p1=inf;
P=0;

imagetype = zeros(1,length(b2));

% count through the files:
for count=1:length(b2)
    % get the attributes for each one
    c = b2{count}.Key.Attribute;
    for counter=1:length(c);
        % and check
        if strcmp(c{counter}.Attributes.Name,'Type')
            if strcmp(c{counter}.Text,'M');
                M=1;
                m1=min(m1,count);
                imagetype(count)=1;
            elseif strcmp(c{counter}.Text,'P');
                P=1;
                p1=min(p1,count);
                imagetype(count)=2;
            end
            if P==1 && M==1
            end
        end
    end
end

%% check / the code should not go beyond this if this is not met
assert(M == 1, 'Need to have at least one set of magnitude images');

% if q==0 %providing neither of the quit criteria have been met, execute the rest of the code
for g=1:length(b1)
    c=b1{g}.Attributes;
    if strcmp(c.Name, 'Max No Slices') %compare to findLabel to see if match
        zdim=str2double(char(b1{g}.Text));
    end
    if strcmp(c.Name, 'Max No Dynamics')
        tdim=str2double(char(b1{g}.Text));
    end
end

%% Find the X and y dim
c=b2{m1}.Attribute;
for g2=1:length(c)
    d=c{g2}.Attributes;
    if strcmp(d.Name, 'Resolution X') %compare to findLabel to see if match
        xdim=str2double(char(c{g2}.Text));
    elseif strcmp(d.Name, 'Resolution Y') %compare to findLabel to see if match
        ydim=str2double(char(c{g2}.Text));
    end
end

%% Read in the Modulus Data
% (need to do slightly different things if M images and/or P images are present)

data_file1 = strcat(InputPathName,FileName);
file_id = fopen(data_file1,'r','l');

if isinf(p1) %if no phase has been found
  IM = fread(file_id,xdim*ydim*tdim*zdim,'int16');
  IM = permute(reshape(IM,xdim,ydim,tdim,zdim),[1 2 4 3]);
else  %if there is both phase and magnitude, twice the amount of data
  IM = fread(file_id,xdim*ydim*tdim*zdim*2,'int16');
  IM = reshape(IM,xdim,ydim,tdim*zdim*2);
%   PH = permute(reshape(IM(:,:,imagetype==2),xdim,ydim,tdim,zdim),[1 2 4 3]);
  IM = permute(reshape(IM(:,:,imagetype==1),xdim,ydim,tdim,zdim),[1 2 4 3]);
end
fclose(file_id);

%remove last dynamic (might be a noise scan)
IM = IM(:,:,:,1:tdim-1);

%% Create tSNR image
%  could also think of something to check how the phase images look?
% tic
tsnrIM = calcTSNR(IM);
% toc

%% Rescale the Images to be between 0 and 4095 for writing out    
tsnrIM(isnan(tsnrIM))=0;
maxValue = max(max(max(tsnrIM(~isinf(tsnrIM))))); %any voxel with constant value across dynamics will have infinite tSNR
tsnrIM(isinf(tsnrIM)) = maxValue;
sc = 4095 / maxValue; %scale the output between 0 and 4095
tsnrIM = sc*tsnrIM;
tsnrIM=round(tsnrIM);

%% Now to alter the xml file for the output
% Remove the phase images
rem=[];
for count=1:length(b2)
    c = b2{count}.Key.Attribute;
    for counter=1:length(c);
        if strcmp(c{counter}.Attributes.Name,'Type')
            if strcmp(c{counter}.Text,'P')
                rem =[rem count];
            end
        end
    end
end
b2(rem)=[];

% Remove the dynamic scans after the first one
rem=[];
for count=1:length(b2)
    c = b2{count}.Key.Attribute;
    for counter=1:length(c);
        if strcmp(c{counter}.Attributes.Name,'Dynamic')
            if ~strcmp(c{counter}.Text,'1')
                rem =[rem count];
            end
        end
    end
end
b2(rem)=[];

% Change the Index to be consecutive numbers
for count=1:length(b2)
    c = b2{count}.Key.Attribute;
    for counter=1:length(c);
        if strcmp(c{counter}.Attributes.Name,'Index')
            c{counter}.Text = count-1;
        end
    end
    b2{count}.Key.Attribute=c;
end

% Change the scaling factors
for count=1:length(b2)
    c = b2{count}.Attribute;
    for counter=1:length(c);
        if strcmp(c{counter}.Attributes.Name,'Rescale Intercept')
            c{counter}.Text=0;
        elseif strcmp(c{counter}.Attributes.Name,'Rescale Slope')
            %ANDY          c{counter}.Text=0;
            c{counter}.Text=num2str(sc/1000);
        elseif strcmp(c{counter}.Attributes.Name,'Scale Slope')
            c{counter}.Text=num2str(sc/1000);
        end
    end
    b2{count}.Attribute=c;
end

%% Update the structure
s.PRIDE_V5.Image_Array.Image_Info = b2;

%write out the new xml file
outfile = strcat(OutputPathName,strtok(FileName,'.'),'_tSNR.xml');
struct2xml( s, outfile )

%write out the rec file
outfile1 = strcat(OutputPathName,strtok(FileName,'.'),'_tSNR.rec');
file_id = fopen(outfile1,'w','l');
fwrite(file_id,tsnrIM,'int16');
fclose(file_id);

end


function tsnrIM = calcTSNR(IM)
% calcTSNR - calculate TSNR for a time series image

meanData=mean(IM,4);
stdData=std(IM,1,4);
tsnrIM=meanData./stdData;

% pick out relevant stats, maybe prctile(tSNR(:), [5, 95]) or similar.

end

