% scanningParameterTable.m
% This function creates a table to look at stuff.
%
function scanParams = scanningParameterTable(scanParams)


% create the figure
position = [60 25 80 60];
param_handles.main_fig = figure('Units','Character','OuterPosition',...
    position,'windowstyle', 'normal', 'resize', 'off','visible','on',...
    'menubar','none','Toolbar','none','numbertitle','off', ...
    'name','.');

% intialize the position vector.
position_phys_pos = [1 position(4)/4 position(3)-2 position(4)*3/4-4];

% intializing the table
param_handles.phys_panel = uipanel(param_handles.main_fig,'units', ...
    'Character','Position',position_phys_pos,'title','Physiological Parameters');

columnname =   {'Parameter', 'Value', 'Units','Description'};
columnformat = {'char', 'numeric', 'char','char' };
columneditable =  [false true false false];

dat =  { symb('hemo_model'),0,'-','Hemodynamic model'};
param_handles.phys_table = uitable(param_handles.phys_panel,'RowStriping', ...
    'on','Data', dat,'ColumnName', columnname,'ColumnFormat', ...
    columnformat,'ColumnEditable', columneditable,'RowName',[], ...
    'Visible','on','FontSize',11,'ColumnWidth',{'auto','auto','auto',200});

set(param_handles.phys_table,'Units','Character','Position',[1 1 75 38]);


% create the struct array from params
params_array = create_params_array(params,param_handles.main_fig);



dat = squeeze(struct2cell(params_array));

% The way to make it is to do cell2mat then reverse that on the output!

set(param_handles.phys_table,'dat',dat);

data = guidata(param_handles.main_fig);

data.phys_table = param_handles.phys_table;
data.main_gui = main_gui;
data.main_fig = param_handles.main_fig;

guidata(param_handles.main_fig,data);

% create the button to go set values to
param_handles.returnButton = makeButton(param_handles.main_fig,[30 6 25 3],'Set Parameters',@returnButtonParams);

drawnow;
end


function params_array = create_params_array(params,parent)
% now go through each of the parameters and put them in a structure array.

params_array = struct;
non_table_data = struct;

fnames = fieldnames(params);
for j=1:length(fnames)
    
    if(numel(getfield(params,fnames{j}))>1)
        non_table_data = setfield(non_table_data,fnames{j},getfield(params,fnames{j}));
    else
        
        % setting up variables in the struct array ready for the table.
        params_array = setfield(params_array,{1},fnames{j},fnames{j});
        params_array = setfield(params_array,{2},fnames{j},getfield(params,fnames{j}));
        
        [units,description] = function_parameter_details(fnames{j});
        
        params_array = setfield(params_array,{3},fnames{j},units);
        params_array = setfield(params_array,{4},fnames{j},description);
    end
end

data.non_table_data = non_table_data;
guidata(parent,data);

end

function buttonHandle = makeButton(parentPanel,position,boxStr,callBackStr)
fontSize = 14;
buttonHandle = uicontrol ( 'parent', parentPanel, 'style', 'pushbutton', ...
    'units', 'character', 'position', position, 'string', boxStr, ...
    'fontsize', fontSize,'CallBack',callBackStr);
end

function resize_table(hObject,~)
% do nothing at the moment, but will add the feature in a future release.
end

function returnButtonParams(hObject,~)
data = guidata(hObject);
dat = get(data.phys_table,'dat');

% First instance take all the parameters from the table
params = cell2struct(dat(:,2),dat(:,1));

% Second instance take all the parameters that are vectors/cells and place
% them back in parameters (if there are any)
if(~isempty(data.non_table_data))
    fnames = fieldnames(data.non_table_data);
    for j=1:length(fnames)
        params = setfield(params,fnames{j},getfield(data.non_table_data,fnames{j}));
    end
end


if(~isempty(data.main_gui))
    gui_data = guidata(data.main_gui);
    gui_data.stimBOLD_output.params = params;
    guidata(data.main_gui,gui_data);
end

close(data.main_fig);
end

% Here we have a function that sets parameter details for the parameter
% table, its a neat implementation. To add any other parameters, please add
% it here.
%

% function [units,description] = function_parameter_details(fname)
% 
% end






