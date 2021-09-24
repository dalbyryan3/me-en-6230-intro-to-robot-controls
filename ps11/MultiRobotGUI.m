function varargout = MultiRobotGUI
% This function creates a simple user interface for running a Simulink
% model that simulates/controls a planar 2-DOF robot.
%
% This GUI is designed for use with the models developed in
% Intro to Robot Control (ME EN 5230/6230) at the University of Utah
% for simulating/controlling the Quanser 2-DOF serial robot arms
%
% It is adapted from a simple GUI by Phil Godddard found here:
% http://www.mathworks.com/matlabcentral/fileexchange/24294-simulink-signal-viewing-using-event-listeners-and-a-matlab-ui
%
% The GUI allows the model to be run in either simulation (normal mode) or
% as a real-time executable (external mode).
%
% The GUI is not smart enough to know whether you make any changes to the model
% before starting. The user must keep track of when a build/rebuild is required.
% Changing the speed does not require rebuilding, but changing the stop time does.
%
% Before running in real-time, make sure you have configured your model
% appropriately. Under Configuration Parameters:
% 1. Select a fixed sample-time (e.g. 0.002)
% 2. Select the proper system target file (e.g. quarc_win64.tlc)
%
% External Mode only allows event listeners to be attached to Scope blocks.
% This GUI looks for a scope block named 'Phi' in the model to attach the
% listener. 'Phi' should represent the absolute joint angles.
% The sampletime of your scope block determines the refresh rate of the GUI.
% It is advisable to use a Rate Transition block in front of the 
% Phi scope block, which allows you to set a slower sampletime on your scope
% than the rest of your model. Otherwise the GUI cannot refresh fast
% enough to keep up with the simulation.
% For example, set the model sampletime to 0.002 and scope sampletime to 0.02. 
%
% The Data Analysis Panel allows you to execute a custom script of your choice
% in the main MATLAB workspace. You can use this feature to analyze/plot/save
% the data sent to your workspace from any 'To Workspace' blocks in your model.
%
% Troubleshooting: When the Start button is pressed, the GUI inserts code into
% the 'StartFcn' callback of your model for attaching the event listener.
% Then when the simulation stops, the GUI clears out the 'StartFcn'.
% If some run-time error occurs that prevents the GUI from clearing the 'StartFcn',
% you may need to manually clear it out yourself.
% You can do this by right-clicking in your model and selecting 'Model Properties'
% and then navigating to the 'Callbacks' tab.
%
% Author: Stephen Mascaro, Ph.D.
% Date: April 2020
% Version: 2.3 This version allows two robots to cooperatively manipulate a
% block
%
% Tested on MATLAB version: R2018a


% Do some simple error checking on varargout
error(nargoutchk(0,1,nargout));

% Create the UI if one does not already exist.
% Bring the UI to the front if one does already exist.

hf = findall(0,'Tag',mfilename);
if isempty(hf)
    % Create a UI
    hf = localCreateUI;
else
    % Bring it to the front
    figure(hf);
end

% populate the output if required
if nargout > 0
    varargout{1} = hf;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to create the user interface
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hf = localCreateUI

try
    % Create the figure, setting appropriate properties
    hf = figure('Tag',mfilename,...
        'Toolbar','none',...
        'MenuBar','none',...
        'IntegerHandle','off',...
        'Units','normalized',...
        'Resize','on',...
        'NumberTitle','off',...
        'HandleVisibility','callback',...
        'Name',sprintf('Custom GUI for Simulating/Controlling Quanser 2-DOF Robot'),...
        'CloseRequestFcn',@localCloseRequestFcn,...
        'Visible','off',...
        'Position',[0 0 0.5 0.5]);
    
    % Create an axes on the figure
    ha = axes('Parent',hf,...
        'HandleVisibility','callback',...
        'Unit','normalized',...
        'OuterPosition',[0.15 0.275 0.9 0.7],...
        'Xlim',[-0.075 0.5],...
        'YLim',[-0.075 0.225],...
        'Tag','plotAxes');
    xlabel(ha,'X');
    ylabel(ha,'Y');
    title(ha,'Robot Configuration');
    %grid(ha,'on');
    box(ha,'on');
    
    % Create an edit box containing the model name
    hnl = uicontrol('Parent',hf,...
        'Style','text',...
        'Units','normalized',...
        'Position',[0.02 0.95 0.15 0.03],...
        'BackgroundColor',get(hf,'Color'),...
        'String','Model Name:',...
        'HandleVisibility','callback',...
        'Tag','modelNameLabel'); %#ok
    hn2 = uicontrol('Parent',hf,...
        'Style','edit',...
        'Units','normalized',...
        'Position',[0.02 0.87 0.15 0.06],...
        'String',sprintf(''),...
        'Backgroundcolor',[1 1 1],...
        'HandleVisibility','callback',...
        'KeyPressFcn',@localModelNameChanged,...
        'Tag','modelNameEdit'); %#ok
    
    % Create a Mode (Simulation or Real-Time) panel
    hbg = uibuttongroup('Parent',hf,...
        'Units','normalized',...
        'Position',[0.02 0.7 0.15 0.15],...
        'Title','Mode',...
        'BackgroundColor',get(hf,'Color'),...
        'HandleVisibility','callback',...
        'SelectionChangeFcn',@localModeChanged,...
        'Tag','modeGroup');
    strings = {'Simulation','Real-Time'};
    positions = [0.65 0.2];
    enable = {'on','on'};
    tags = {'modeRBSim','modeRBRT'};
    % The enable property is a function of whether an RTW license is
    % available
    if license('test','Real-Time_Workshop')
        visible = {'on','on'};
    else
        visible = {'on','off'};
        % Also pop-up a dialog telling the user what's happening
        str = sprintf('%s\n%s\n%s',...
            'A real-Time Workshop license isn''t available, or cannot be',...
            'checked out.  The UI is being rendered however only ',...
            'simulation functionality is being enabled.');
        hedlg = errordlg(str,'RTW License Error','modal');
        uiwait(hedlg);
    end
    for idx = 1:length(strings)
        uicontrol('Parent',hbg,...
            'Style','radiobutton',...
            'Units','normalized',...
            'Position',[0.15 positions(idx) 0.75 0.25],...
            'String',strings{idx},...
            'Enable',enable{idx},...
            'Visible',visible{idx},...
            'Backgroundcolor',get(hf,'Color'),...
            'HandleVisibility','callback',...
            'Tag',tags{idx});
    end
    
    % Create a parameter tuning panel
    htp = uipanel('Parent',hf,...
        'Units','normalized',...
        'Position',[0.02 0.38 0.15 0.3],...
        'Title','Parameter Tuning',...
        'BackgroundColor',get(hf,'Color'),...
        'HandleVisibility','callback',...
        'Tag','tunePanel');
    htt1 = uicontrol('Parent',htp,...
        'Style','text',...
        'Units','normalized',...
        'Position',[0.15 0.7 0.75 0.2],...
        'BackgroundColor',get(hf,'Color'),...
        'String','Speed (circle/s):',...
        'HorizontalAlignment','left',...
        'HandleVisibility','callback',...
        'Tag','modelSpeedLabel'); %#ok
    hte1 = uicontrol('Parent',htp,...
        'Style','edit',...
        'Units','normalized',...
        'Position',[0.15 0.55 0.7 0.2],...
        'String','',...
        'Backgroundcolor',[1 1 1],...
        'Enable','on',...
        'Callback',@localSpeedTuned,...
        'HandleVisibility','callback',...
        'Tag','tuneSpeed');
    htt2 = uicontrol('Parent',htp,...
        'Style','text',...
        'Units','normalized',...
        'Position',[0.15 0.25 0.7 0.2],...
        'BackgroundColor',get(hf,'Color'),...
        'String','Stop Time (s):',...
        'HorizontalAlignment','left',...
        'HandleVisibility','callback',...
        'Tag','modelStopTimeLabel'); %#ok
    hte2 = uicontrol('Parent',htp,...
        'Style','edit',...
        'Units','normalized',...
        'Position',[0.15 0.1 0.7 0.2],...
        'String','',...
        'Backgroundcolor',[1 1 1],...
        'Enable','on',...
        'Callback',@localStopTimeTuned,...
        'HandleVisibility','callback',...
        'Tag','tuneStopTime');
    
    % Create a panel for operations that can be performed
    hop = uipanel('Parent',hf,...
        'Units','normalized',...
        'Position',[0.02 0.02 0.15 0.35],...
        'Title','Operations',...
        'BackgroundColor',get(hf,'Color'),...
        'HandleVisibility','callback',...
        'Tag','tunePanel');
    strings = {'Load','Build','Start','Stop'};
    positions = [0.8 0.55 0.3 0.05];
    tags = {'loadpb','buildpb','startpb','stoppb'};
    callbacks = {@localLoadModel,@localBuildPressed, @localStartPressed, @localStopPressed};
    enabled ={'on','off','off','off'};
    for idx = 1:length(strings)
        uicontrol('Parent',hop,...
            'Style','pushbutton',...
            'Units','normalized',...
            'Position',[0.15 positions(idx) 0.7 0.175],...
            'BackgroundColor',get(hf,'Color'),...
            'String',strings{idx},...
            'Enable',enabled{idx},...
            'Callback',callbacks{idx},...
            'HandleVisibility','callback',...
            'Tag',tags{idx});
    end
    
    % Create a data-analysis panel
        hdap = uipanel('Parent',hf,...
        'Units','normalized',...
        'Position',[0.2 0.02 0.25 0.25],...
        'Title','Data Analysis',...
        'BackgroundColor',get(hf,'Color'),...
        'HandleVisibility','callback',...
        'Tag','dataPanel');
        hdapb = uicontrol('Parent',hdap,...
        'Style','pushbutton',...
        'Units','normalized',...
        'Position',[0.125 0.65 0.75 0.25],...
        'String','Execute',...
        'Backgroundcolor',get(hf,'Color'),...
        'Enable','on',...
        'Callback',@localDataAnalysisPressed,...
        'HandleVisibility','callback',...
        'Tag','dataAnalysisButton');
        hdat = uicontrol('Parent',hdap,...
        'Style','text',...
        'Units','normalized',...
        'Position',[0.125 0.3 0.35 0.25],...
        'Backgroundcolor',get(hf,'Color'),...
        'String','Script Name:',...
        'HandleVisibility','callback',...
        'Tag','scriptLabel'); %#ok
        hdae = uicontrol('Parent',hdap,...
        'Style','edit',...
        'Units','normalized',...
        'Position',[0.125 0.125 0.75 0.25],...
        'Backgroundcolor',[1 1 1],...
        'Callback',@localDataAnalysisPressed,...
        'HandleVisibility','callback',...
        'Tag','scriptNameEdit'); %#ok
    
    % Create a robot environment panel
        hrep = uipanel('Parent',hf,...
        'Units','normalized',...
        'Position',[0.48 0.02 0.25 0.25],...
        'Title','Robot Environment',...
        'BackgroundColor',get(hf,'Color'),...
        'HandleVisibility','callback',...
        'Tag','dataPanel');
        hrecb = uicontrol('Parent',hrep,...
        'Style','checkbox',...
        'Units','normalized',...
        'Position',[0.125 0.65 0.75 0.25],...
        'String','Display Wall/Block',...
        'Backgroundcolor',get(hf,'Color'),...
        'Enable','on',...
        'Callback',@localWallDisplayChecked,...
        'HandleVisibility','callback',...
        'Tag','wallDisplayCheckBox');
        hret = uicontrol('Parent',hrep,...
        'Style','text',...
        'Units','normalized',...
        'Position',[0.125 0.3 0.8 0.25],...
        'Backgroundcolor',get(hf,'Color'),...
        'String','Wall/Block Stiffness (N/mm):',...
        'HandleVisibility','callback',...
        'Tag','wallStiffnessLabel'); %#ok
        hree = uicontrol('Parent',hrep,...
        'Style','edit',...
        'Units','normalized',...
        'Position',[0.125 0.125 0.75 0.25],...
        'Backgroundcolor',[1 1 1],...
        'Callback',@localWallStiffnessTuned,...
        'HandleVisibility','callback',...
        'Tag','wallStiffnessEdit'); %#ok
    
    % Create a Help pull-down menu
    hhpd = uimenu('Parent',hf,...
        'Label','Help',...
        'Tag','helpmenu');
    labels = {'Application Help','About'};
    tags = {'apphelppd','aboutpd'};
    callbacks = {@localAppHelpPulldown,@localAboutPulldown};
    for idx = 1:length(labels)
        uimenu('Parent',hhpd,...
            'Label',labels{idx},...
            'Callback',callbacks{idx},...
            'Tag',tags{idx});
    end

    % Create the handles structure
    ad.handles = guihandles(hf);
  
    % Create the robot in it's initial configuration
    robot = initializeRobot(ad,0);
    ad.robot = robot;
    robot2 = initializeRobot(ad,0.35);
    ad.robot2 = robot2;
    % Save the application data
    guidata(hf,ad);
  
    % Position the UI in the centre of the screen
    movegui(hf,'center')
    % Make the UI visible
    set(hf,'Visible','on');
catch ME
    % Get rid of the figure if it was created
    if exist('hf','var') && ~isempty(hf) && ishandle(hf)
        delete(hf);
    end
    % Get rid of the model if it was loaded
    close_system('testmodel',0)   
    % throw up an error dialog
    estr = sprintf('%s\n%s\n\n',...
        'The UI could not be created.',...
        'The specific error was:',...
        ME.message);
    errordlg(estr,'UI creation error','modal');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to ensure that the model actually exists
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function modelExists = localValidateInputs(modelName)

num = exist(modelName,'file');
if num == 4
    modelExists = true;
else
    modelExists = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for Mode radio buttons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localModeChanged(hObject,eventdata)

% get the application data
ad = guidata(hObject);
% Make changes to the UI depending on whether Simulation or Real-Time is required
switch get(eventdata.NewValue,'String')
    case 'Simulation'
        % Turn off the Build button
        set(ad.handles.buildpb,'Enable','off');
        % set the simulation mode to normal
        set_param(ad.modelName,'SimulationMode','normal');
    case 'Real-Time'
        % Turn on the Build button
        set(ad.handles.buildpb,'Enable','on');
        % set the simulation mode to external
        set_param(ad.modelName,'SimulationMode','external');  
    otherwise
        % shouldn't be able to get in here
        errordlg('Selection Error',...
            'An illegal selection was made.', 'modal');
end

function localModelNameChanged(hObject,eventdata)
ad = guidata(hObject);

set(ad.handles.loadpb,'Enable','on');
set(ad.handles.startpb,'Enable','off');
set(ad.handles.buildpb,'Enable','off');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for Build button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localBuildPressed(hObject,eventdata) %#ok

% get the application data
ad = guidata(hObject);

try
    % throw up a wait bar as this'll take a while
    wStr = sprintf('%s\n%s',...
        'Please wait while the model builds.',...
        'Be patient as this may take several minutes.');
    hw = waitbar(0.5,wStr);
    % Build the model
    rtwbuild(ad.modelName);
    % destroy the waitbar
    delete(hw);
    % Toggle the state of the buttons
catch ME
    % Get rid of the waitbar
    if exist('hw','var') && ~isempty(hw) && ishandle(hw)
        delete(hw);
        drawnow;
    end
    % throw up an error dialog
    estr = sprintf('%s\n%s\n\n',...
        'The model could not be built.',...
        'The specific error was:',...
        ME.message);
    errordlg(estr,'Build error','modal');
end

% store the changed app data
guidata(gcbo,ad);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for Start button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localStartPressed(hObject,eventdata) %#ok

% get the application data
ad = guidata(hObject);

set(ad.robot.path,'XData',[],'YData',[]);

% Load the model if required (it may have been closed manually).
if ~modelIsLoaded(ad.modelName)
    load_system(ad.modelName);
end

% toggle the buttons
% Turn off the load, build, start operations
set(ad.handles.startpb,'Enable','off');
set(ad.handles.loadpb,'Enable','off');
set(ad.handles.buildpb,'Enable','off');

% Turn on the Stop button
set(ad.handles.stoppb,'Enable','on');

% disable Mode changes
set(get(ad.handles.modeGroup,'Children'),'Enable','off');
set(ad.handles.modelNameEdit,'Enable','off');
set(ad.handles.tuneStopTime,'Enable','off');

% Push the current Speed value in the UI into the model
localSpeedTuned(ad.handles.tuneSpeed);
localStopTimeTuned(ad.handles.tuneStopTime);

% Perform a different operation depending on whether Simulation or Real-Time is
% required
switch get(get(ad.handles.modeGroup,'SelectedObject'),'Tag')
    case 'modeRBSim'
        % Set a listener on the Phi block in the model's StartFcn
        set_param(ad.modelName,'StartFcn','localAddEventListener');
        % start the model
        set_param(ad.modelName,'SimulationCommand','start');
    case 'modeRBRT'
        % Set a listener on the Phi block in the model's StartFcn
        set_param(ad.modelName,'StartFcn','localAddEventListener');
        % Connect to the code
        set_param(ad.modelName,'SimulationCommand','connect');
        % start the model
        set_param(ad.modelName,'SimulationCommand','start');
    otherwise
        % shouldn't be able to get in here
        errordlg('Selection Error',...
            'Neither simulation nor RT was attempted.', 'modal');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for Stopping the Simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localStopSimulation(ad)

% Remove the listener on the Phi block in the model's StartFcn
localRemoveEventListener;
% enable Mode changes
set(ad.handles.modelNameEdit,'Enable','on');
set(ad.handles.tuneStopTime,'Enable','on');
set(ad.handles.modeRBSim,'Enable','on')
set(ad.handles.modeRBRT,'Enable','on')
if strcmp(get_param(ad.modelName,'SimulationMode'),'external');
    set(ad.handles.buildpb,'Enable','on');
end
% toggle the buttons
% Turn on the Start button
set(ad.handles.startpb,'Enable','on');
% Turn off the Stop button
set(ad.handles.stoppb,'Enable','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for Stop button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localStopPressed(hObject,eventdata) %#ok
ad = guidata(hObject);

% Perform a different operation depending on whether Simulation or Real-Time was
% being performed
switch get(get(ad.handles.modeGroup,'SelectedObject'),'Tag')
    case 'modeRBSim'
        % stop the model
        set_param(ad.modelName,'SimulationCommand','stop');
    case 'modeRBRT'
        % stop the model
        set_param(ad.modelName,'SimulationCommand','stop');
        % disconnect from the code
        set_param(ad.modelName,'SimulationCommand','disconnect');
    otherwise
        % shouldn't be able to get in here
        errordlg('Selection Error',...
            'Neither simulation nor Real-Time was attempted.', 'modal');
end
localStopSimulation(ad);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for Speed tuning edit box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localSpeedTuned(hObject,eventdata) %#ok

% get the application data
ad = guidata(hObject);

% Check that a valid value has been entered
str = get(hObject,'String');
newValue = str2double(str);

% Do the change if it's valid
if ~isnan(newValue)
    % poke the new value into the model
    set_param(ad.tuning.blockName,ad.tuning.blockProp,str);
    
    % store the new value
    ad.SpeedValue = str;
    guidata(hObject,ad);
else
    % throw up an error dialog
    estr = sprintf('%s is an invalid Speed value.',str);
    errordlg(estr,'Speed Tuning Error','modal');
    % reset the edit box to the old value
    set(hObject,'String',ad.SpeedValue);
end

function localStopTimeTuned(hObject,eventdata) %#ok

% get the application data
ad = guidata(hObject);

% Check that a valid value has been entered
str = get(hObject,'String');
newValue = str2double(str);

% Do the change if it's valid
if (~isnan(newValue)&& (newValue>0))
    % poke the new value into the model
    set_param(ad.modelName,'StopTime',str);
    % store the new value
    ad.StopTime = str;
    guidata(hObject,ad);
else
    % throw up an error dialog
    estr = sprintf('%s is an invalid Stop Time Value.',str);
    errordlg(estr,'Stop Time Tuning Error','modal');
    % reset the edit box to the old value
    set(hObject,'String',ad.StopTime);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for deleting the UI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localCloseRequestFcn(hObject,eventdata) %#ok

% get the application data
ad = guidata(hObject);

% Can only close the UI if the model has been stopped
% Can only stop the model is it hasn't already been unloaded (perhaps
% manually).
    if (isfield(ad,'modelName') && modelIsLoaded(ad.modelName))
         switch get_param(ad.modelName,'SimulationStatus');
                 case 'stopped'
                     % close the Simulink model
                     % close_system(ad.modelName,0);
                     % destroy the window
                     delete(gcbo);
                 otherwise
                     errordlg('The model must be stopped before the UI is closed',...
                         'UI Close error','modal');
         end
     else
         % destroy the window
         delete(gcbo);
     end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for adding an event listener to the Speed block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localAddEventListener

% get the application data
ad = guidata(gcbo);

% execute any original startFcn that the model may have had
% if ~isempty(ad.originalStartFcn)
%     evalin('Base',ad.originalStartFcn);
% end

% Add the listener(s)
% For this example all events call into the same function
ad.eventHandle = cell(1,length(ad.viewing));
for idx = 1:length(ad.viewing)
    ad.eventHandle{idx} = ...
        add_exec_event_listener(ad.viewing(idx).blockName,...
        ad.viewing(idx).blockEvent, ad.viewing(idx).blockFcn);
end

% store the changed app data
guidata(gcbo,ad);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for executing the event listener on the Speed block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localEventListener(block, eventdata) %#ok

% Note: this callback is called by all the block listeners.  No effort has
% been made to time synchronise the data from each signal.  Rather it is
% assumed that since each block calls this function at every time step and
% hence the time synchronisation will come "for free".  This may not be the
% case for other models and additional code may be required for them to
% work/display data correctly.

% get the application data
hf = findall(0,'tag',mfilename);
ad = guidata(hf);

Time = block.CurrentTime;
phi = block.InputPort(1).Data;   



% update robot 1 configuration
R1 = [cos(phi(1)) -sin(phi(1)); sin(phi(1)) cos(phi(1))];
R2 = [cos(phi(2)) -sin(phi(2)); sin(phi(2)) cos(phi(2))];
link1points = R1*ad.robot.linkpoints;
link2points = R2*ad.robot.linkpoints;
beltpoints = R1*ad.robot.beltpoints;
org1 = R1*[ad.robot.a1;0];
org2 = org1+R2*[ad.robot.a2;0];
X = [get(ad.robot.path,'XData') org2(1)];
Y = [get(ad.robot.path,'YData') org2(2)];
hole = ad.robot.hole;
pulley = ad.robot.pulley;
set(ad.robot.link1,'XData',link1points(1,:),'YData',link1points(2,:));
set(ad.robot.joint2,'Position',[org1(1)-hole/2 org1(2)-hole/2 hole hole]);
set(ad.robot.belt,'XData',beltpoints(1,:),'YData',beltpoints(2,:));
set(ad.robot.pulley2,'Position',[org1(1)-pulley/2 org1(2)-pulley/2 pulley pulley]);
set(ad.robot.link2,'XData',link2points(1,:)+org1(1),'YData',link2points(2,:)+org1(2));
set(ad.robot.tool,'Position',[org2(1)-hole/2 org2(2)-hole/2 hole hole]);
set(ad.robot.path,'XData',X,'YData',Y);
set(ad.robot.time,'String',sprintf('%.2f',Time));

%repeat for robot2
x0 = 0.35;
R1 = [cos(phi(3)) -sin(phi(3)); sin(phi(3)) cos(phi(3))];
R2 = [cos(phi(4)) -sin(phi(4)); sin(phi(4)) cos(phi(4))];
link1points = R1*ad.robot2.linkpoints;
link2points = R2*ad.robot2.linkpoints;
beltpoints = R1*ad.robot2.beltpoints;
org1 = [x0;0]+R1*[ad.robot2.a1;0];
org2b = org1+R2*[ad.robot2.a2;0];
%X = [get(ad.robot2.path,'XData') org2(1)];
%Y = [get(ad.robot2.path,'YData') org2(2)];
hole = ad.robot2.hole;
pulley = ad.robot2.pulley;
set(ad.robot2.link1,'XData',link1points(1,:)+x0,'YData',link1points(2,:));
set(ad.robot2.joint2,'Position',[org1(1)-hole/2 org1(2)-hole/2 hole hole]);
set(ad.robot2.belt,'XData',beltpoints(1,:)+x0,'YData',beltpoints(2,:));
set(ad.robot2.pulley2,'Position',[org1(1)-pulley/2 org1(2)-pulley/2 pulley pulley]);
set(ad.robot2.link2,'XData',link2points(1,:)+org1(1),'YData',link2points(2,:)+org1(2));
set(ad.robot2.tool,'Position',[org2b(1)-hole/2 org2b(2)-hole/2 hole hole]);
%set(ad.robot2.path,'XData',X,'YData',Y);

% update block configuration
w = 0.025;
blockpoints = [-w -w 0.1+w 0.1+w;w -w -w w];
beta = atan2(org2b(2)-org2(2),org2b(1)-org2(1));
R = [cos(beta) -sin(beta); sin(beta) cos(beta)];
blockpoints = R*blockpoints;
set(ad.robot.block,'XData',blockpoints(1,:)+org2(1),'YData',blockpoints(2,:)+org2(2));




drawnow;
if (Time>=(str2double(ad.StopTime)))%-ad.viewing(1).refreshRate))
    localStopSimulation(ad);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for removing the event listener from the Speed block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localRemoveEventListener

% get the application data
hf = findall(0,'tag',mfilename);
ad = guidata(hf);

% remove the startFcn
set_param(ad.modelName,'StartFcn','');

% delete the listener(s)
if (isfield(ad,'eventHandle'))
    for idx = 1:length(ad.eventHandle)
        if ishandle(ad.eventHandle{idx})
            delete(ad.eventHandle{idx});
        end
    end
% remove this field from the app data structure
    ad = rmfield(ad,'eventHandle');
end
%save the changes
guidata(hf,ad);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to check that model is still loaded
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function modelLoaded = modelIsLoaded(modelName)

try
    modelLoaded = ...
        ~isempty(find_system('Type','block_diagram','Name',modelName));
catch ME %#ok
    % Return false if the model can't be found
    modelLoaded = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to load model and get certain of its parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localLoadModel(hObject,eventdata)

% Get modelname from textbox
ad = guidata(hObject);
%ad.handles %display GUI handles when debugging

modelName = get(ad.handles.modelNameEdit,'String');

% Do some simple error checking on the input
if ~localValidateInputs(modelName)
    estr = sprintf('The model %s.mdl cannot be found.',modelName);
    errordlg(estr,'Model not found error','modal');
    return
end

% Load the simulink model
if ~modelIsLoaded(modelName)
    load_system(modelName);
end

% Create some application data storing various
% pieces of information about the model's initial state.
ad.modelName = modelName;
ad.tuning.blockName = sprintf('%s/Speed',ad.modelName);
ad.tuning.blockProp = 'Value';
ad.SpeedValue = get_param(ad.tuning.blockName,ad.tuning.blockProp);
ad.StopTime = get_param(ad.modelName,'Stoptime');

switch (get_param(ad.modelName,'SimulationMode'));
    case 'normal'
        set(ad.handles.modeRBSim,'Value',1);
        set(ad.handles.buildpb,'Enable','off');
    case 'external'
        set(ad.handles.modeRBRT,'Value',1);
        set(ad.handles.buildpb,'Enable','on');
    otherwise
        set_param(ad.modelName,'SimulationMode','normal');
end

% The Speed and Stop Time needs to be poked into the UI
set(ad.handles.tuneSpeed,'String',ad.SpeedValue);
set(ad.handles.tuneStopTime,'String',ad.StopTime);

% if model contains a wall stiffness, set GUI to display wall
if (~isempty(find_system(ad.modelName,'Name','WallStiffness')))
    set(ad.handles.wallDisplayCheckBox,'Value',1);
    set(ad.robot.wall,'Visible','on');
    set(ad.handles.wallStiffnessEdit,'Enable','on');
    blockName = sprintf('%s/WallStiffness',ad.modelName);
    blockProp = 'Value';
    ad.WallStiffnessValue = get_param(blockName,blockProp);
    set(ad.handles.wallStiffnessEdit,'String',ad.WallStiffnessValue);
elseif (~isempty(find_system(ad.modelName,'Name','BlockStiffness')))
    set(ad.handles.wallDisplayCheckBox,'Value',1);
    set(ad.robot.block,'Visible','on');
    set(ad.handles.wallStiffnessEdit,'Enable','on');
    blockName = sprintf('%s/BlockStiffness',ad.modelName);
    blockProp = 'Value';
    ad.WallStiffnessValue = get_param(blockName,blockProp);
    set(ad.handles.wallStiffnessEdit,'String',ad.WallStiffnessValue);
else
    set(ad.handles.wallDisplayCheckBox,'Value',0);
    set(ad.robot.wall,'Visible','off');
    set(ad.handles.wallStiffnessEdit,'String','');
    set(ad.handles.wallStiffnessEdit,'Enable','off');
end

% List the blocks that are to have listeners applied
ad.viewing = struct(...
    'blockName','',...
    'blockHandle',[],...
    'blockEvent','',...
    'blockFcn',[]);
% Every block has a name
ad.viewing(1).blockName = sprintf('%s/Phi',ad.modelName);

% That block has a handle
% (This will be used in the graphics drawing callback, and is done here
% as it should speed things up rather than searching for the handle
% during every event callback.)
ad.viewing(1).blockHandle = get_param(ad.viewing(1).blockName,'Handle');

% List the block event to be listened for
ad.viewing(1).blockEvent = 'PostOutputs';
ad.viewing(1).refreshRate = str2double(get_param(ad.viewing(1).blockName,'SampleTime'));

% List the function to be called
% (These must be subfunctions within this mfile).
ad.viewing(1).blockFcn = @localEventListener;

guidata(gcbo,ad);
set(ad.handles.startpb,'Enable','on');
set(ad.handles.loadpb,'Enable','off');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for viewing the documentation/help
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localAppHelpPulldown(hObject,eventdata) %#ok

% Just view the help for the primary function in this file
doc(mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for viewing an about box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localAboutPulldown(hObject,eventdata) %#ok

% Create an about box
str = {[mfilename,' version 2.1 was written by Stephen Mascaro.'];...
    'University of Utah';...
    ' '};
msgbox(str,'About Box','Help','modal');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function for initializing drawing objects for robot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function robot = initializeRobot(ad,x0)

ha = ad.handles.plotAxes;
axis(ha,'equal');
a1 = 0.15; % link lengths
a2 = 0.15;
w = 0.025; % link width
hole = 0.007; % hole diameter
base = 0.0635; % base width
pulley = 0.04; % pulley diameter

linkpoints = [0;-w/2];
for phi = -90:10:90
    pnew = [a1+w/2*cos(phi*pi/180); w/2*sin(phi*pi/180)];
    linkpoints = [linkpoints pnew];
end
for phi = 90:10:270
    pnew = [w/2*cos(phi*pi/180); w/2*sin(phi*pi/180)];
    linkpoints = [linkpoints pnew];
end

beltpoints = [0 a1 a1 0;-pulley/2 -pulley/2 pulley/2 pulley/2];
Uxpoints = [1 10 10 8 8 4 -4 -8 -8 -10 -10 -1 -1 -3 -3 3 3 1 1]/700;
Uypoints = [19 19 13 13 4 0 0 4 13 13 19 19 13 13 6 6 13 13 19]/700;
blockpoints = [-w -w 0.1+w 0.1+w;w -w -w w];

robot.a1 = a1;
robot.a2 = a2;
robot.hole = hole;
robot.pulley = pulley;
robot.linkpoints = linkpoints;
robot.beltpoints = beltpoints;

robot.block = patch('Parent',ha,'XData',blockpoints(1,:)+a1,'YData',blockpoints(2,:)+a1,'FaceColor',[0.7 0.5 0.25],'Visible','off');
robot.wall = rectangle('Parent',ha,'Position',[0.1125 -base 0.175 base-0.025-w/2],'FaceColor',[0.7 0.5 0.25],'Visible','off');
robot.base = rectangle('Parent',ha,'Position',[-base+x0 -base 2*base 2*base],'Curvature',[0.1 0.1],'FaceColor','k');
robot.belt = line('Parent',ha,'XData',beltpoints(2,:)+x0,'YData',beltpoints(1,:),'Color',[0.7 0.5 0.25]);
robot.pulley1 = rectangle('Parent',ha,'Position',[-pulley/2+x0 -pulley/2 pulley pulley],'Curvature',[1 1],'FaceColor',[0.5 0.5 0.5]);
robot.pulley2 = rectangle('Parent',ha,'Position',[-pulley/2+x0 a1-pulley/2 pulley pulley],'Curvature',[1 1],'FaceColor',[0.5 0.5 0.5]);
robot.link2 = patch('Parent',ha,'XData',linkpoints(1,:)+x0,'YData',a1+linkpoints(2,:),'Facecolor',[0.8 0 0]);
robot.link1 = patch('Parent',ha,'XData',linkpoints(2,:)+x0,'YData',linkpoints(1,:),'FaceColor',[0.8 0 0]);
robot.joint1 = rectangle('Parent',ha,'Position',[-hole/2+x0 -hole/2 hole hole],'Curvature',[1 1],'FaceColor',[0.8 0.8 0.8]);
robot.joint2 = rectangle('Parent',ha,'Position',[-hole/2+x0 a1-hole/2 hole hole],'Curvature',[1 1],'FaceColor',[0.8 0.8 0.8]);
robot.tool = rectangle('Parent',ha,'Position',[a1-hole/2+x0 a1-hole/2 hole hole],'Curvature',[1 1],'FaceColor','b','EdgeColor','w');

text('Parent',ha,'Position',[-0.05+x0 -0.05],'String','Q','Color','w');
text('Parent',ha,'Position',[-0.039+x0 -0.0525],'String','UANSER','Color','w','FontSize',6);
patch('Parent',ha,'XData',Uxpoints+0.04+x0,'YData',Uypoints-0.055,'FaceColor',[0.8 0 0],'EdgeColor',[1 1 1]);
if (x0==0) 
robot.path = line('Parent',ha,'XData',0.25+x0,'YData',0,'Color','b');
text('Parent',ha,'Position',[0.2125+x0 0.21],'String','Clock:');
robot.time = text('Parent',ha,'Position',[0.26+x0 0.21],'String','0.00');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback Function for analyzing the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localDataAnalysisPressed(hObject,eventdata)

    ad = guidata(hObject);
    
    script = get(ad.handles.scriptNameEdit,'String');
    evalin('base',script);
   
function localWallDisplayChecked(hObject,eventdata)

    ad = guidata(hObject);
    
    checked = get(hObject,'Value');
    if (checked)
        if (~isempty(find_system(ad.modelName,'Name','WallStiffness')))
            set(ad.robot.wall,'Visible','on');
            set(ad.handles.wallStiffnessEdit,'Enable','on');
            blockName = sprintf('%s/WallStiffness',ad.modelName);
            blockProp = 'Value';
            ad.WallStiffnessValue = get_param(blockName,blockProp);
            set(ad.handles.wallStiffnessEdit,'String',ad.WallStiffnessValue);
        elseif (~isempty(find_system(ad.modelName,'Name','BlockStiffness')))
            set(ad.robot.block,'Visible','on');
            set(ad.handles.wallStiffnessEdit,'Enable','on');
            blockName = sprintf('%s/BlockStiffness',ad.modelName);
            blockProp = 'Value';
            ad.WallStiffnessValue = get_param(blockName,blockProp);
            set(ad.handles.wallStiffnessEdit,'String',ad.WallStiffnessValue);
        else
            set(ad.handles.wallStiffnessEdit,'String','No wall/block found in model');
        end
    else
        set(ad.robot.wall,'Visible','off');
        set(ad.robot.block,'Visible','off');
        set(ad.handles.wallStiffnessEdit,'String','');
        set(ad.handles.wallStiffnessEdit,'Enable','off');
    end
    
function localWallStiffnessTuned(hObject,eventdata)
 
% get the application data
ad = guidata(hObject);

% Check that a valid value has been entered
str = get(hObject,'String');
newValue = str2double(str);

% Do the change if it's valid
if ~isnan(newValue)
    % poke the new value into the model
    blockName = sprintf('%s/WallStiffness',ad.modelName);
    blockProp = 'Value';
    set_param(blockName,blockProp,str);
    
    % store the new value
    ad.WallStiffnessValue = str;
    guidata(hObject,ad);
else
    % throw up an error dialog
    estr = sprintf('%s is an invalid Wall Stiffness Value.',str);
    errordlg(estr,'Wall Stiffness Error','modal');
    % reset the edit box to the old value
    set(hObject,'String',ad.WallStiffnessValue);
end