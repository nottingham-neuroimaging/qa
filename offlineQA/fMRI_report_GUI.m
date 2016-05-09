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
    'windowstyle', 'normal', 'resize', 'off','visible','on',...
    'menubar','none','Toolbar','none','numbertitle','off', ...
    'name','.');
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

set(gui_handle.scan_table,'Units','Character','Position',[1 1 105 38]);

% Here we convert the scanParams array to a format read by uiTable.
dat = createCellArray(scanParams);

set(gui_handle.scan_table,'dat',dat);

% Passing data to the handle object.
data = guidata(gui_handle.main_fig);
data.scanParams = scanParams;
data.scan_table = gui_handle.scan_table;
data.main_fig = gui_handle.main_fig;
guidata(gui_handle.main_fig,data);

% create the button to go set values to
gui_handle.returnButton = makeButton(gui_handle.main_fig,[42.5 2 25 3],'Run report',@runReport);


drawnow;
end


function dat = createCellArray(scanParams)
dat = cell(length(scanParams),5);
% Here just assigning dat
for nf=1:length(scanParams),
    dat(nf,1:5) = [{scanParams(nf).fileName},{nf},{scanParams(nf).notes},{scanParams(nf).dynNOISEscan},{scanParams(nf).volumeSelect}];
end
end


function buttonHandle = makeButton(parentPanel,position,boxStr,callBackStr)
fontSize = 14;
buttonHandle = uicontrol ( 'parent', parentPanel, 'style', 'pushbutton', ...
    'units', 'character', 'position', position, 'string', boxStr, ...
    'fontsize', fontSize,'CallBack',callBackStr);
end

function resize_table(hObject,~)
% do nothing at the moment, but will add the feature later?
end

function runReport(hObject,~)
data = guidata(hObject);
scanParams = data.scanParams;
dat = get(data.scan_table,'dat');

scanParams = updateScanParams(scanParams,dat);
[tSNR_ROI,iSNR] = tSNR_report(scanParams);
mean_image_report(scanParams);

disp(tSNR_ROI);
disp(iSNR);

generateHTMLReport(scanParams);
% now get the data from the table and reset the scan Params

end

function scanParams = updateScanParams(scanParams,dat)
for nf=1:length(scanParams)
    scanParams(nf).notes = dat{nf,3};
    scanParams(nf).dynNOISEscan = dat{nf,4};
    scanParams(nf).volumeSelect = dat{nf,5};
    scanParams(nf).cropTimeSeries = [1 dat{nf,5}];
end
end
