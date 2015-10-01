clear all
close all
clc

%InputPathName='C:\PSIR\';
%OutputPathName='C:\PSIR\';
InputPathName='G:\patch\pride\tempinputseries\';
OutputPathName='G:\patch\pride\tempoutputseries\';
FileName='DBIEX.REC';

%% Read in the xml file
xml_file = strcat(InputPathName,strtok(FileName,'.'),'.xml');
s = xml2struct(xml_file);
b1 = s.PRIDE_V5.Series_Info.Attribute;
b2 = s.PRIDE_V5.Image_Array.Image_Info;

q = 0; % quit variable

%% This checks that the image has 2 phases
for g=1:length(b1)
    c=b1{g}.Attributes;
    if strcmp(c.Name, 'Max No Phases')
        
        if strcmp(b1{g}.Text,'2')==0
            q=1;
            disp('Need two inversion times for PSIR reconstruction'); %display the error
        end
    end
end

%% THis checks that there are modulus and phase images and stores the position of the first modulus and phase image
m1=1000;p1=m1;M=0;P=0;
imagetype=zeros(1,length(b2));
imageTI=zeros(1,length(b2));
for count=1:length(b2)
    c = b2{count}.Key.Attribute;
    for counter=1:length(c);
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
        elseif strcmp(c{counter}.Attributes.Name,'Phase')
            if strcmp(c{counter}.Text,'1');
                imageTI(count)=1;
            elseif strcmp(c{counter}.Text,'2');
                imageTI(count)=2;
            end
        end
    end
end


if P~=1 || M~=1
    q=1;
    disp('Need modulus and phase images'); %display the error
end

if q==0 %providing neither of the quit criteria have been met, execute the rest of the code
    for g=1:length(b1)
        c=b1{g}.Attributes;
        if strcmp(c.Name, 'Max No Slices') %compare to findLabel to see if match
            zdim=str2double(char(b1{g}.Text));
        end
    end
    %% Find the X and y dim
    c=b2{p1}.Attribute;
    for g2=1:length(c)
        d=c{g2}.Attributes;
        if strcmp(d.Name, 'Resolution X') %compare to findLabel to see if match
            xdim=str2double(char(c{g2}.Text));
        elseif strcmp(d.Name, 'Resolution Y') %compare to findLabel to see if match
            ydim=str2double(char(c{g2}.Text));
        elseif strcmp(d.Name, 'Rescale Intercept') %compare to findLabel to see if match
            rescale_interc_phase=str2double(char(c{g2}.Text));
        elseif strcmp(d.Name, 'Rescale Slope') %compare to findLabel to see if match
            rescale_slope_phase=str2double(char(c{g2}.Text));
        elseif strcmp(d.Name, 'Scale Slope') %compare to findLabel to see if match
            scale_slope_phase=str2double(char(c{g2}.Text));
        end
    end    
    %% Read in the Modulus Data
    data_file1 = strcat(InputPathName,FileName);
    file_id = fopen(data_file1,'r','l');
    IM=fread(file_id,xdim*ydim*zdim*4,'int16');
    IM = reshape(IM,xdim,ydim,zdim*4);

    
    MOD1=IM(:,:,imagetype==1 & imageTI==1);
    PHA1=IM(:,:,imagetype==2 & imageTI==1);
    MOD2=IM(:,:,imagetype==1 & imageTI==2);
    PHA2=IM(:,:,imagetype==2 & imageTI==2);
    PHA1=((PHA1*rescale_slope_phase)+rescale_interc_phase)/rescale_slope_phase/scale_slope_phase;
    PHA2=((PHA2*rescale_slope_phase)+rescale_interc_phase)/rescale_slope_phase/scale_slope_phase;
    clear IM   
    %% Create PSIR
    S=abs(MOD2)+abs(MOD1); %need to determine best here
    clear MOD2
    S=smooth3(S,'gaussian',[9 9 9],150);
    
    PSIRim=MOD1./S;
    clear MOD1
    
    pha = PHA1 - PHA2;
    clear PHA1 PHA2
    P = find(pha<0);
    pha(P)=pha(P)+(2*pi);
    P = find(pha<0);
    pha(P)=pha(P)+(2*pi);
    f = find(pha>1.57 & pha<4.71);
    clear pha
    PSIRim(f)=-PSIRim(f);
    clear f     
    %% Rescale the Images to be between 0 and 4095 for writing out    
    PSIRim(isnan(PSIRim))=0;
    PSIRim(PSIRim<-3)=0;
    PSIRim(PSIRim>3)=0;
    PSIRim=(PSIRim+3);
    PSIRim(S<1)=0;
    
    sc = 4095 /max(max(max(PSIRim))); %scale the output between 0 and 4095
    PSIRim = sc*PSIRim;
    PSIRim=round(PSIRim);
end

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

% Remove the Phase = 2 images
rem=[];
for count=1:length(b2)
    
    c = b2{count}.Key.Attribute;
    
    for counter=1:length(c);
        if strcmp(c{counter}.Attributes.Name,'Phase')
            if strcmp(c{counter}.Text,'2')
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
outfile = strcat(OutputPathName,strtok(FileName,'.'),'_PSIR.xml');
struct2xml( s, outfile )

%write out the rec file
outfile1 = strcat(OutputPathName,strtok(FileName,'.'),'_PSIR.rec');
file_id = fopen(outfile1,'w','l');
fwrite(file_id,PSIRim,'int16');
