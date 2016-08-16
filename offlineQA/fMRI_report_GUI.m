% fMRI_report_GUI.m
% This here is a GUI to:
% 1. Show the scans that were loaded
% 2. Set notes and values for each scan.
% 3. Run the report (with a run-report button)
% 4. Option to make a pdf? (future stuff)

function scanParams = fMRI_report_GUI(scanParams)


% create the figure
figureHeight = 60;
figureWidth = 110;
% position = [60 25 110 60];
gui_handle.main_fig = figure('Units','Character',...
    'windowstyle', 'normal', 'resize', 'off','visible','off',...
    'menubar','none','Toolbar','none','numbertitle','off', ...
    'name','fMRI report');
position = get(gui_handle.main_fig,'outerposition');
position(3) = figureWidth;
position(2) = position(2) + position(4) - figureHeight;
position(4) = figureHeight;
set(gui_handle.main_fig,'outerposition',position);

% intialize the position vector.
position_phys_pos = [1 position(4)/4 position(3)-2 position(4)*3/4-4];

% intializing the table
gui_handle.phys_panel = uipanel(gui_handle.main_fig,'units', ...
    'Character','Position',position_phys_pos,'title','Scans');

columnname =   {'Filename', 'Scan number', 'Scan notes','Noise Flag?','Last scan'};
columnformat = {'char', 'numeric', 'char','numeric','numeric'};
columneditable =  [false true true true true];

dat =  { 'fm',1,'Something is here',0,[1]};
gui_handle.scan_table = uitable(gui_handle.phys_panel,'RowStriping', ...
    'on','Data', dat,'ColumnName', columnname,'ColumnFormat', ...
    columnformat,'ColumnEditable', columneditable,'RowName',[], ...
    'Visible','on','FontSize',11,'ColumnWidth',{'auto','auto',310,'auto','auto'});

set(gui_handle.scan_table,'Units','Character','Position',[1 9 105 30]);

% Here we convert the scanParams array to a format read by uiTable.
dat = createCellArray(scanParams);

set(gui_handle.scan_table,'dat',dat);

gui_handle.roiEditbox = makeEditbox(gui_handle.main_fig,[15+10 7 30 3],'',@editROI);


% Passing data to the handle object.
data = guidata(gui_handle.main_fig);
data.scanParams = scanParams;
data.scan_table = gui_handle.scan_table;
data.main_fig = gui_handle.main_fig;
data.roiEditBox = gui_handle.roiEditbox;
guidata(gui_handle.main_fig,data);

% create the button to go set values to
gui_handle.returnButton = makeButton(gui_handle.main_fig,[12.5 18 25 3],'Run report',@runReport);

gui_handle.htmlButton = makeButton(gui_handle.main_fig,[44.5 18 25 3],'Redo HTML',@rerunHTML);

gui_handle.optionsButton = makeButton(gui_handle.main_fig,[75.5 18 25 3],'Options',@reportOptions);

gui_handle.roiButton = makeButton(gui_handle.main_fig,[45+10 7 25 3],'Draw ROI',@drawROI);

gui_handle.dynButton = makeButton(gui_handle.main_fig,[44.5 11 25 3],'Select Dynamics',@selectDynamics);

if isempty(which('selectCropRegion')) %check that selectCropRegion exists on the path
  set(gui_handle.roiButton,'enable','off');
end

% Make default options
generateDefaultOptions(gui_handle.main_fig);
set(gui_handle.main_fig,'visible','on');

drawnow;
end


function dat = createCellArray(scanParams)
dat = cell(length(scanParams),6);
% Here just assigning dat
for nf=1:length(scanParams),
    dat(nf,1:6) = [{scanParams(nf).fileName},{nf},{scanParams(nf).notes},{scanParams(nf).dynNOISEscan},{scanParams(nf).volumeSelectFirst},{scanParams(nf).volumeSelect}];
end
end


function buttonHandle = makeButton(parentPanel,position,boxStr,callBackStr)
fontSize = 14;
buttonHandle = uicontrol ( 'parent', parentPanel, 'style', 'pushbutton', ...
    'units', 'character', 'position', position, 'string', boxStr, ...
    'fontsize', fontSize,'CallBack',callBackStr);
end

function editboxHandle = makeEditbox(parentPanel,position,boxStr,callBackStr)
fontSize = 14;
editboxHandle = uicontrol ( 'parent', parentPanel, 'style', 'edit', ...
    'units', 'character', 'position', position, 'string', boxStr, ...
    'fontsize', fontSize,'CallBack',callBackStr);
end

function textHandle = makeText(parentPanel,position,textString)
  fontSize = 14;
  uicontrol( 'parent', parentPanel, 'style', 'text','units', 'character', 'position', position , 'string', textString, ...
    'fontsize', fontSize);
end

function resize_table(hObject,~)
% do nothing at the moment, but will add the feature later?
end

function editROI(hObject,toto)

data = guidata(hObject);
if ~isempty(get(data.roiEditBox,'string'))
  dims=data.scanParams(1).dims ;
  for iScan = 2:length(data.scanParams)
    if ~isequal(dims,data.scanParams(iScan).dims)
      warndlg('All scans must have the same dimensions to use an ROI');
      return
    end
  end
else
  return
end

try
  roiCoords = eval(get(data.roiEditBox,'string'));
catch
  roiCoords = [];
end

if isequal(size(roiCoords),[3 2])
  for iScan = 1:length(data.scanParams)
    data.scanParams(iScan).ROI_box = mat2roiBox(roiCoords');
  end
  guidata(hObject,data);
else
  warndlg('ROI coordinates should be a 3x2 matrix');
end

end

function drawROI(hObject,~)
data = guidata(hObject);
dims=data.scanParams(1).dims ;
for iScan = 2:length(data.scanParams)
  if ~isequal(dims,data.scanParams(iScan).dims)
    warndlg('All scans must have the same dimensions to use an ROI');
    return
  end
end
volume = cbiReadNifti(data.scanParams(1).fileName);
roiCoords = selectCropRegion(volume(:,end:-1:1,:,1));


% Please note: this looks clunky because the image co-ords used later on
% uses co-ordinates based on the rotated images. However, what would make
% sense to the user is to include co-ordinates directly from the nifti 
% volume.

niftiCoords = roiCoords;
niftiCoords(:,2) = size(volume,2) - roiCoords([2:-1:1],2);

% Quote the nifti-coordinates
set(data.roiEditBox,'string',mat2str(niftiCoords'));

for iScan = 1:length(data.scanParams)
  data.scanParams(iScan).ROI_box = mat2roiBox(roiCoords);
end
guidata(hObject,data);

end

function ROI_box = mat2roiBox(roiCoords)

  ROI_box.x = roiCoords(1,1);
  ROI_box.width = roiCoords(2,1)-roiCoords(1,1);
  ROI_box.y = roiCoords(1,2);
  ROI_box.height = roiCoords(2,2)-roiCoords(1,2);
  ROI_box.slice = roiCoords(1,3):roiCoords(2,3);

end

function runReport(hObject,~)
data = guidata(hObject);
data.options.recaulculateTSNR = 1;
guidata(hObject,data);
scanParams = data.scanParams;
dat = get(data.scan_table,'dat');

scanParams = updateScanParams(scanParams,dat);
disp('Running report....');
[tSNR_ROI,iSNR] = tSNR_report(scanParams,data.main_fig);
mean_image_report(scanParams);

if any(~isnan(tSNR_ROI))
  tSNR_ROI
end
if any(~isnan(iSNR))
  iSNR
end

generateHTMLReport(scanParams);
% now get the data from the table and reset the scan Params

end

function reportOptions(hObject,~)
  % disp('Make an options menu');


  % create the panel
  figureHeight = 25;
  figureWidth = 50;
  % position = [60 25 110 60];
  option_fig = figure('Units','Character',...
      'windowstyle', 'normal', 'resize', 'off','visible','on',...
      'menubar','none','Toolbar','none','numbertitle','off', ...
      'name','Report options');
  position = get(option_fig,'outerposition');
  position(3) = figureWidth;
  position(2) = position(2) + position(4) - figureHeight;
  position(4) = figureHeight;
  set(option_fig,'outerposition',position);

  data = guidata(hObject);

  % Make the colorscale options
  colourScaleHandle = makeEditbox(option_fig,[28 18 15 3],data.options.imgScale,'');
  makeText(option_fig,[10 18 15 3],'Color scale (for tSNR)');

  % colourbar options
  colourbarScaleHandle = makeEditbox(option_fig,[28 12 15 3],data.options.cmap_str,'');
  makeText(option_fig,[10 12 15 3],'Colourmap (for tSNR)');

  % Make the Apply button
  optHandles.ApplyButton = makeButton(option_fig,[15 2 15 3],'Apply',@ApplyButton);

  % Set all the information to the guidata
  optHandles = struct;
  optHandles.colourScaleHandle = colourScaleHandle;
  optHandles.colourbarScaleHandle = colourbarScaleHandle;
  optHandles.main_fig = data.main_fig;
  guidata(option_fig,optHandles);


end

% Function here to apply the different colour scale options
function ApplyButton(hObject,~)
  optionData = guidata(hObject);
  data = guidata(optionData.main_fig);
  data.options.imgScale = str2num(get(optionData.colourScaleHandle,'string'));
  data.options.cmap_str = get(optionData.colourbarScaleHandle,'string');

  % Here we look at changing the colourmaps!
  try
    eval(['cmap =' data.options.cmap_str ';']);    
    if(size(cmap,2)==3)
      cmap = cmap.';
    elseif(size(cmap,1)==3)
      % Do nothing because this is right;
    else
      disp(['Error! cmap is not in the right format must be a matrix! e.g. hot(255).']);
      cmap = hot(255).';
      options.cmap_str = 'hot(255)';      
    end
  catch
    disp(['Error! cmap is not in the right format must be a matrix! e.g. hot(255).']);
    cmap = hot(255).';
    options.cmap_str = 'hot(255)';
  end  
  % This just resets the colourmap to whatever has been assigned (if we went back, do so on the string too)
  set(optionData.colourbarScaleHandle,'string',data.options.cmap_str);
  % Now set the new colourmap  
  data.options.cmap = cmap;
  guidata(optionData.main_fig,data);
end

function rerunHTML(hObject,~)
  % Function here to regenerate HTML page
  disp('Regenerating the HTML report ....');
  % Getting all the information from guidata..
  data = guidata(hObject);
  scanParams = data.scanParams;
  dat = get(data.scan_table,'dat');

  % Re-run the tSNR report and mean image report, but this time don't recalculate the tSNR maps as it doesn't make sense to.  
  data.options.recaulculateTSNR = 0; % Flag here makes sure we don't recalculate the maps, it is just to resave the figures.
  guidata(data.main_fig,data);

  scanParams = updateScanParams(scanParams,dat);
  [tSNR_ROI,iSNR] = tSNR_report(scanParams,data.main_fig);
  mean_image_report(scanParams);

  if any(~isnan(tSNR_ROI))
    tSNR_ROI
  end
  if any(~isnan(iSNR))
    iSNR
  end  
  generateHTMLReport(scanParams);

end

function selectDynamics(hObject, ~)

% create the panel
  figureHeight = 25;
  figureWidth = 50;
  % position = [60 25 110 60];
  option_fig = figure('Units','Character',...
      'windowstyle', 'normal', 'resize', 'off','visible','on',...
      'menubar','none','Toolbar','none','numbertitle','off', ...
      'name','Select Dynamics');
  position = get(option_fig,'outerposition');
  position(3) = figureWidth;
  position(2) = position(2) + position(4) - figureHeight;
  position(4) = figureHeight;
  set(option_fig,'outerposition',position);

  data = guidata(hObject);

  % Make the colorscale options
  
  if length(data.scanParams) > 1
      disp('!!!CAUTION, selecting dynamics for FIRST SCAN ONLY!!!')
  end
  
  dynSelectionHandle = makeEditbox(option_fig,[30 15 15 3],data.scanParams(1).volumeSelectFirst,'');
  makeText(option_fig,[14 15 15 3],'Select First Dynamic');
  
  dyn2SelectionHandle = makeEditbox(option_fig,[30 9 15 3],data.scanParams(1).volumeSelect,'');
  makeText(option_fig,[14 9 15 3],'Select Last Dynamic');
  

  % Make the Apply button
  optHandles.ApplyButtonDyn = makeButton(option_fig,[15 2 15 3],'Apply',@ApplyButtonDyn);

  % Set all the information to the guidata
  optHandles = struct;
  optHandles.dynSelectionHandle = dynSelectionHandle;
  optHandles.dyn2SelectionHandle = dyn2SelectionHandle;
 
  optHandles.main_fig = data.main_fig;
  guidata(option_fig,optHandles);
  
  fprintf('Dynamic scans chosen: %.d to %.d\n' ,data.scanParams(1).volumeSelectFirst, data.scanParams(1).volumeSelect)
end

function ApplyButtonDyn(hObject,~)
% Select Dynamics button
  optionData = guidata(hObject);
  data = guidata(optionData.main_fig);
  
  data.scanParams(1).volumeSelect = str2num(get(optionData.dyn2SelectionHandle, 'string'));
  data.scanParams(1).volumeSelectFirst = str2num(get(optionData.dynSelectionHandle, 'string'));

  set(optionData.dyn2SelectionHandle,'string',data.scanParams(1).volumeSelect);
  set(optionData.dynSelectionHandle,'string',data.scanParams(1).volumeSelectFirst);

  %data.scanParams(1).volumeSelect = dyns;
  guidata(optionData.main_fig,data);
  
end

function scanParams = updateScanParams(scanParams,dat)
for nf=1:length(scanParams)
    scanParams(nf).notes = dat{nf,3};
    scanParams(nf).dynNOISEscan = dat{nf,4};
    if scanParams(nf).dynNOISEscan %check if there is noise scan and user forgot to change the last scan number
      hdr = cbiReadNiftiHeader(scanParams(nf).fileName);
      if  dat{nf,6} == hdr.dim(6)
        dat{nf,6} = dat{nf,6}-1;
      end
    end
    %scanParams(nf).volumeSelect = dat{nf,5};
end
end

function generateDefaultOptions(main_fig)
  options = struct;
  options.recaulculateTSNR = 1;
  options.imgScale = 100;
  options.cmap = hot(255).';
  options.cmap_str = 'hot(255)';
  data = guidata(main_fig);
  % check
  data.options = options;
  guidata(main_fig,data);
end
