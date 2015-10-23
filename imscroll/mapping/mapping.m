function varargout = mapping(varargin)
% MAPPING M-file for mapping.fig
%      MAPPING, by itself, creates a new MAPPING or raises the existing
%      singleton*.
%
%      H = MAPPING returns the handle to a new MAPPING or the handle to
%      the existing singleton*.
%
%      MAPPING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAPPING.M with the given input arguments.
%
%      MAPPING('Property','Value',...) creates a new MAPPING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mapping_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mapping_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help mapping

% Last Modified by GUIDE v2.5 12-May-2012 19:05:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mapping_OpeningFcn, ...
                   'gui_OutputFcn',  @mapping_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
%if nargin && ishandle(varargin{1})                  % Changed to  make this a subgui from imscroll
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
   
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% Copyright 2015 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.

% --- Executes just before mapping is made visible.
function mapping_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mapping (see VARARGIN)

% Choose default command line output for mapping
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
handles.parenthandles_fig = varargin{1};            % Get the handle for the parent gui figure *********
guidata(hObject,handles);                               % Save the handles structure ***********


handles.MappingPoints=[];                           % Add a handle for the points used to map the two fields
    % [framenumber1 ave1 x1pt y1pt pixnum1 aoinumber framenumber2 ave2 x2pt y2pt pixnum2 aoinumber]
                                                    %
handles.FitParameters=[];                           % Add a handle for the fit parameters =[mx21 bx21
                                                     %                                     my21 by21]
                                                    %                          where     x2= mx21*x1 + bx21
                                                    %                                    y2= my21*y1 + by21
load OverlapInfo.dat -mat                           % Loads the structure OverlapInfo
                 % OverlapInfo.ColorMap1 ==false color colormap for field1
                 % OverlapInfo.ColorMap2 ==false color colormap for field2
handles.ColorMap1=OverlapInfo.ColorMap1;
handles.ColorMap2=OverlapInfo.ColorMap2;
                 % Images and min/max values displayed in the two axes of this gui need to
                 % accessed from within different callbacks
handles.avefrm1=[];         % averaged image frame
handles.avefrm2=[];
handles.clowval1=[];        % low limit to display image in field 1
handles.clowval2=[];        % low limit to display image in field2
handles.chival1=[];         % high limit to display image in field1
handles.chival2=[];         % high limit to display image in field2
handles.limitsxy1=[];       % display 1 pixel limits (for magnifying)
handles.limitsxy2=[];       % display 2 pixel limits (for magnifying)

guidata(hObject,handles);

% UIWAIT makes mapping wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mapping_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%OutputStructure.MappingPoints=handles.MappingPoints;
%OutputStructure.FitParameters=handles.FitParameters;
%handles.output=OutputStructure;
handles.FitParameters
varargout{1} = handles.output;


% --- Executes on slider movement.
function SliderFrame1_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to SliderFrame1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'SliderMaxIntensity1') to determine range of slider

%dum1=varargin{1};
%images1=varargin{2};                            % Get mages1=images from command mode
%folder1=varargin{3};
parenthandles=guidata(handles.parenthandles_fig);       % Get handle structure from top gui

imagenum1=get(handles.SliderFrame1,'value');        % Retrieve the value of the slider
val1= round(imagenum1);                                 % Integer frame number
userdat1=get(handles.SliderFrame1,'UserData');

if imagenum1>userdat1                                      % userdata contains last value of slider
    
    
    if val1-userdat1 <1
        val1=val1+1;                              % Must increment frame index by at least 1
     end
elseif imagenum1 < userdat1 
    
    if userdat1-val1 <1
        val1=val1-1;                              % Must decrement frame index by at least 1
     end
end
%val=round(val);
set(handles.SliderFrame1,'UserData',val1) % Reset UserData to reflect newest value
set(handles.SliderFrame1,'value',val1)    % Force slider value to reflect current frame#
set(handles.FrameNumber1,'String',num2str(val1 ) );     % Alter the displayed frame number
axes(handles.axes1);

%avefrm1=getframes1(dum1,images1,folder1,handles,parenthandles);
avefrm1=getframes1_v1(handles,parenthandles);
handles.avefrm1=avefrm1;        % Use this for doing the gaussian fit
guidata(gcbo,handles);
clowval1=round(double(min(min(avefrm1))));chival1=round(double(max(max(avefrm1))));     % Frame max and min values,
                               % same as auto values for scaling image

                                    % Now test whether to manually scale images
if get(handles.AutoScale1,'Value')==1          % =1 for manual scale
    clowval1=round(get(handles.SliderMinIntensity1,'Value'));  % set minimum display intensity
    chival1=round(get(handles.SliderMaxIntensity1,'Value'));   % set maximum display intensity
else
                                      % If auto scaling is on, label the
                                      % Maxscale and MinScale text
                                      % with the auto values
                                                
    set(handles.MaxIntensity1,'String',num2str(chival1));
    set(handles.MinIntensity1,'String',num2str(clowval1));
   
end
                                      % Now display the proper image
                                      % First set axis limits (mag or no magnify) 
axes(handles.axes1);
if get(handles.Magnify1,'Value')==1   % ==1 to magnify image
    limitsxy1=get(handles.MouseInput1,'UserData');
else
    [rose cols]=size(avefrm1);
    limitsxy1=[1 cols 1 rose];         % Full screen limits of image
end
                                    % Get the value off the popup menu
                                    % MappingChoice
MappingChoiceValue=get(handles.MappingChoice,'Value');
switch MappingChoiceValue
    case 1
                                    % Here just to draw the normal figure
imagesc(avefrm1,[clowval1 chival1]);colormap(gray(256));axis('equal');axis(limitsxy1)

% *************************************************************************
    case 2
                                    % Here to false color both fields
              % Map the current image between between chival1 and clowval1
              % to 0 to 255 so as to properly index into our rgb table
              % listed in ColorMap1
    axes(handles.axes1)
    map_avefrm1=(avefrm1-clowval1)*255/(chival1-clowval1);
    image(ind2rgb(map_avefrm1,handles.ColorMap1));axis('equal');axis(limitsxy1)
    axes(handles.axes2)
    map_avefrm2=(handles.avefrm2-handles.clowval2)*255/(handles.chival2-handles.clowval2);
    image(ind2rgb(map_avefrm2,handles.ColorMap2));axis('equal');axis(handles.limitsxy2)
 
    if get(handles.OverlapImageFigure,'Value') ==1
                                 % Here if button is pushed requesting that a figure be made
        figure(24);image(ind2rgb(map_avefrm1,handles.ColorMap1));axis('equal');axis(limitsxy1)
        figure(25);image(ind2rgb(map_avefrm2,handles.ColorMap2));axis('equal');axis(handles.limitsxy2)
    end
    
    
% ************************************************************************
    case 3 
                                    % Here to false color both fields and
                                    % overlap field 1 onto field 2
    handles.avefrm1=avefrm1;        % Update the handles structure before
    handles.clowval1=clowval1;      % calling the OverlapMapping(handles)
    handles.chival1=chival1;        % function that will map the fields
    handles.limitsxy1=limitsxy1;
    guidata(gcbo,handles);
     axes(handles.axes1)            % Show the false color image in field1
    map_avefrm1=(avefrm1-clowval1)*255/(chival1-clowval1);
    image(ind2rgb(map_avefrm1,handles.ColorMap1));axis('equal');axis(limitsxy1)
    
     axes(handles.axes2) 
                                    % Get the field1 falsecolor image1 mapped to field2
    mapped_falsecolor_image=OverlapMapping(handles);
                                    % False color the image2 in field2
   map_avefrm2=(handles.avefrm2-handles.clowval2)*255/(handles.chival2-handles.clowval2);
                                    % Show the sum of mapped image1 (colormap1)
                                    % plus image2 (colormap2)
 
    image( mapped_falsecolor_image+ind2rgb(map_avefrm2,handles.ColorMap2) );axis('equal');axis(handles.limitsxy2)
    if get(handles.OverlapImageFigure,'Value')==1
        figure(24);image(ind2rgb(map_avefrm1,handles.ColorMap1));axis('equal');axis(limitsxy1)
        figure(25);image( mapped_falsecolor_image+ind2rgb(map_avefrm2,handles.ColorMap2) );axis('equal');axis(handles.limitsxy2)
    end
    
%    imagesc(avefrm1,[clowval1 chival1]);colormap(ColorMap1);axis('equal');axis(limitsxy1)
% *************************************************************************
end                               % end of switch for MappingChoice
                                      % Draw boxes around the aois
[aoinumber parameters]=size(handles.MappingPoints);
for indx=1:aoinumber
     draw_box(handles.MappingPoints(indx,3:4),(handles.MappingPoints(indx,5)-1)/2,(handles.MappingPoints(indx,5)-1)/2,'b');
end

if length(parenthandles.Time1)>val1       % If we have loaded a timebase that extends as far as the current frame number
    set(handles.Time1Text,'String',num2str( (parenthandles.Time1(val1)-parenthandles.Time1(1))*1e-3));
end
handles.avefrm1=avefrm1;
handles.clowval1=clowval1;
handles.chival1=chival1;
handles.limitsxy1=limitsxy1;
guidata(gcbo,handles);





% --- Executes during object creation, after setting all properties.
function SliderFrame1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderFrame1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function SliderFrame2_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to SliderFrame2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'SliderMaxIntensity1') to determine range of slider

%dum2=varargin{1};
%images2=varargin{2};                            % Get mages1=images from command mode
%folder2=varargin{3};
parenthandles=guidata(handles.parenthandles_fig);       % Get handle structure from top gui
imagenum2=get(handles.SliderFrame2,'value');        % Retrieve the value of the slider

val2= round(imagenum2);                                 % Integer frame number
userdat2=get(handles.SliderFrame2,'UserData');

if imagenum2>userdat2                                      % userdata contains last value of slider
    
    
    if val2-userdat2 <1
        val2=val2+1;                              % Must increment frame index by at least 1
     end
elseif imagenum2 < userdat2 
    
    if userdat2-val2 <1
        val2=val2-1;                              % Must decrement frame index by at least 1
     end
end
%val=round(val);
set(handles.SliderFrame2,'UserData',val2) % Reset UserData to reflect newest value
set(handles.SliderFrame2,'value',val2)    % Force slider value to reflect current frame#
set(handles.FrameNumber2,'String',num2str(val2 ) );     % Alter the displayed frame number
axes(handles.axes2);                                    
%avefrm2=getframes2(dum2,images2,folder2,handles,parenthandles);
avefrm2=(getframes2_v1(handles,parenthandles));
handles.avefrm2=avefrm2;        % Use this when doing the gaussian fit
guidata(gcbo,handles);
clowval2=round(double(min(min(avefrm2))));chival2=round(double(max(max(avefrm2))));     % Frame max and min values,
                               % same as auto values for scaling image

                                    % Now test whether to manually scale images
if get(handles.AutoScale2,'Value')==1          % =1 for manual scale
    clowval2=round(get(handles.SliderMinIntensity2,'Value'));  % set minimum display intensity
    chival2=round(get(handles.SliderMaxIntensity2,'Value'));   % set maximum display intensity
else
                                      % If auto scaling is on, label the
                                      % Maxscale and MinScale text
                                      % with the auto values
                                                
    set(handles.MaxIntensity2,'String',num2str(chival2));
    set(handles.MinIntensity2,'String',num2str(clowval2));
   
end
                                      % Now display the proper image 
                                      % First set axis limits (mag or no
                                      % mag)
axes(handles.axes2);
if get(handles.Magnify2,'Value')==1   % ==1 to magnify image
    limitsxy2=get(handles.MouseInput2,'UserData');
else
    [rose cols]=size(avefrm2);
    limitsxy2=[1 cols 1 rose];         % Full screen limits of image
end
                                    % Get the value off the popup menu
                                    % MappingChoice
MappingChoiceValue=get(handles.MappingChoice,'Value');
switch MappingChoiceValue
    case 1
                                    % Here just to draw the normal figure
imagesc(avefrm2,[clowval2 chival2]);colormap(gray(256));axis('equal');axis(limitsxy2)

% *************************************************************************
    case 2
                                    % Here to false color both fields
              % Map the current image between between chival1 and clowval1
              % to 0 to 255 so as to properly index into our rgb table
              % listed in ColorMap1
    axes(handles.axes2)
    map_avefrm2=(avefrm2-clowval2)*255/(chival2-clowval2);
    image(ind2rgb(map_avefrm2,handles.ColorMap2));axis('equal');axis(limitsxy2)
    
    axes(handles.axes1)
    map_avefrm1=(handles.avefrm1-handles.clowval1)*255/(handles.chival1-handles.clowval1);
    image(ind2rgb(map_avefrm1,handles.ColorMap1));axis('equal');axis(handles.limitsxy1)
    if get(handles.OverlapImageFigure,'Value')==1
                                        % Here if button is pushed
                                        % requesting that a figure be made
        figure(24); image(ind2rgb(map_avefrm1,handles.ColorMap1));axis('equal');axis(handles.limitsxy1)
        figure(25);image(ind2rgb(map_avefrm2,handles.ColorMap2));axis('equal');axis(limitsxy2)
    end
% ************************************************************************
    case 3 
                                     % Here to false color both fields and
                                    % overlap field 1 onto field 2
    handles.avefrm2=avefrm2;        % Update the handles structure before
    handles.clowval2=clowval2;      % calling the OverlapMapping(handles)
    handles.chival2=chival2;        % function that will map the fields
    handles.limitsxy2=limitsxy2;
    guidata(gcbo,handles);
     axes(handles.axes1)            % Show the false color image in field1
    map_avefrm1=(handles.avefrm1-handles.clowval1)*255/(handles.chival1-handles.clowval1);
    image(ind2rgb(map_avefrm1,handles.ColorMap1));axis('equal');axis(handles.limitsxy1)
    
     axes(handles.axes2) 
                                    % Get the field1 falsecolor image1 mapped to field2
    mapped_falsecolor_image=OverlapMapping(handles);
                                    % False color the image2 in field2
   map_avefrm2=(handles.avefrm2-handles.clowval2)*255/(handles.chival2-handles.clowval2);
                                    % Show the sum of mapped image1 (colormap1)
                                    % plus image2 (colormap2)
 
    image( mapped_falsecolor_image+ind2rgb(map_avefrm2,handles.ColorMap2) );axis('equal');axis(handles.limitsxy2)
    if get(handles.OverlapImageFigure,'Value') ==1
                                % Here if button is pushed requesting that
                                % a figure be made
                                % Load a new colormap combination
        load OverlapInfo.dat -mat                           % Loads the structure OverlapInfo
                 % OverlapInfo.ColorMap1 ==false color colormap for field1
                 % OverlapInfo.ColorMap2 ==false color colormap for field2
        handles.ColorMap1=OverlapInfo.ColorMap1;
        handles.ColorMap2=OverlapInfo.ColorMap2;
        guidata(gcbo,handles)
        figure(24);image(ind2rgb(map_avefrm1,handles.ColorMap1));axis('equal');axis(handles.limitsxy1)
        figure(25);image( mapped_falsecolor_image+ind2rgb(map_avefrm2,handles.ColorMap2) );axis('equal');axis(handles.limitsxy2)
    end

% *************************************************************************
end                               % end of switch for MappingChoice


                                       % Draw boxes around all the aois
[aoinumber parameters]=size(handles.MappingPoints);
for indx=1:aoinumber
     draw_box(handles.MappingPoints(indx,9:10),(handles.MappingPoints(indx,11)-1)/2,(handles.MappingPoints(indx,11)-1)/2,'b');
end
if length(parenthandles.Time2)>val2       % If we have loaded a timebase that extends as far as the current frame number
    set(handles.Time2Text,'String',num2str( (parenthandles.Time2(val2)-parenthandles.Time1(1))*1e-3));
end
handles.avefrm2=avefrm2;
handles.clowval2=clowval2;
handles.chival2=chival2;

handles.limitsxy2=limitsxy2;
guidata(gcbo,handles);



% --- Executes during object creation, after setting all properties.
function SliderFrame2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderFrame2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function FrameNumber1_Callback(hObject, eventdata, handles)
% hObject    handle to FrameNumber1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameNumber1 as text
%        str2double(get(hObject,'String')) returns contents of FrameNumber1 as a double

inval=get(handles.FrameNumber1,'String');
axes(handles.axes1);title(['input value=' inval]);
%if inval>get(handles.ImageNumber,'Max')
    set(handles.SliderFrame1,'Max',str2num(inval))    % User can set maximum frame number here
    %end
% --- Executes during object creation, after setting all properties.
function FrameNumber1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameNumber1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function FrameNumber2_Callback(hObject, eventdata, handles)
% hObject    handle to FrameNumber2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameNumber2 as text
%        str2double(get(hObject,'String')) returns contents of FrameNumber2 as a double
inval=get(handles.FrameNumber2,'String');
axes(handles.axes2);title(['input value=' inval]);
%if inval>get(handles.ImageNumber,'Max')
    set(handles.SliderFrame2,'Max',str2num(inval))    % User can set maximum frame number here
    %end

% --- Executes during object creation, after setting all properties.
function FrameNumber2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameNumber2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function AveNumber1_Callback(hObject, eventdata, handles)
% hObject    handle to AveNumber1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AveNumber1 as text
%        str2double(get(hObject,'String')) returns contents of AveNumber1 as a double


% --- Executes during object creation, after setting all properties.
function AveNumber1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AveNumber1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function AveNumber2_Callback(hObject, eventdata, handles)
% hObject    handle to AveNumber2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AveNumber2 as text
%        str2double(get(hObject,'String')) returns contents of AveNumber2 as a double


% --- Executes during object creation, after setting all properties.
function AveNumber2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AveNumber2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes on slider movement.
function SliderMinIntensity1_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to SliderMinIntensity1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%dum1=varargin{1};
%images1=varargin{2};                            % Get mages1=images from command mode
%folder1=varargin{3};
 mxx=get(handles.SliderMaxIntensity1,'Value');                               
if get(handles.SliderMinIntensity1,'Value') > mxx
    set(handles.SliderMinIntensity1,'Value',mxx-1);
end



                                % Get the value of slider, and print it in
                                % MinScale box

mxval=get(handles.SliderMinIntensity1,'Value');
set(handles.MinIntensity1,'String',num2str(round(mxval)));
                                % Now update the display
clowval1=round(get(handles.SliderMinIntensity1,'Value'));  % set minimum display intensity
chival1=round(get(handles.SliderMaxIntensity1,'Value'));   % set maximum display intensity
axes(handles.axes1);
handles.clowval1=clowval1;
handles.chival1=chival1;
guidata(gcbo,handles);
                                              % Now update the display
%SliderFrame1_Callback(handles.SliderFrame1, eventdata, handles,dum1,images1,folder1)
SliderFrame1_Callback(handles.SliderFrame1, eventdata, handles)
%caxis([clowval1 chival1]);                            % changes the current display to match
                                       % the new hi/lo intensity settings


% --- Executes during object creation, after setting all properties.
function SliderMinIntensity1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderMinIntensity1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes on slider movement.
function SliderMinIntensity2_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to SliderMinIntensity2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%dum2=varargin{1};
%images2=varargin{2};
%folder2=varargin{2};
mxx=get(handles.SliderMaxIntensity2,'Value');                               
if get(handles.SliderMinIntensity2,'Value') > mxx
    set(handles.SliderMinIntensity2,'Value',mxx-1);
end



                                % Get the value of slider, and print it in
                                % MinScale box

mxval=get(handles.SliderMinIntensity2,'Value');
set(handles.MinIntensity2,'String',num2str(round(mxval)));
                                % Now update the display
clowval2=round(get(handles.SliderMinIntensity2,'Value'));  % set minimum display intensity
chival2=round(get(handles.SliderMaxIntensity2,'Value'));   % set maximum display intensity
axes(handles.axes2);
handles.clowval2=clowval2;
handles.chival2=chival2;
guidata(gcbo,handles);
%SliderFrame2_Callback(handles.SliderFrame2, eventdata, handles,dum2,images2,folder2)
SliderFrame2_Callback(handles.SliderFrame2, eventdata, handles)
%caxis([clowval2 chival2]);                            % changes the current display to match
                                       % the new hi/lo intensity settings

% --- Executes during object creation, after setting all properties.
function SliderMinIntensity2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderMinIntensity2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in AutoScale1.
function AutoScale1_Callback(hObject, eventdata, handles)
% hObject    handle to AutoScale1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AutoScale1
if get(handles.AutoScale1,'Value')==0
    set(handles.AutoScale1,'String','Auto Scale')
     set(handles.SliderMinIntensity1,'Visible','off')
     set(handles.SliderMaxIntensity1,'Visible','off')
   
else
    set(handles.AutoScale1,'String','Manual Scale')
     set(handles.SliderMinIntensity1,'Visible','on')
     set(handles.SliderMaxIntensity1,'Visible','on')
end

% --- Executes on button press in AutoScale2.
function AutoScale2_Callback(hObject, eventdata, handles)
% hObject    handle to AutoScale2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AutoScale2
if get(handles.AutoScale2,'Value')==0
    set(handles.AutoScale2,'String','Auto Scale')
     set(handles.SliderMinIntensity2,'Visible','off')
     set(handles.SliderMaxIntensity2,'Visible','off')
   
else
    set(handles.AutoScale2,'String','Manual Scale')
     set(handles.SliderMinIntensity2,'Visible','on')
     set(handles.SliderMaxIntensity2,'Visible','on')
end



% --- Executes on button press in ImageSource1.
function ImageSource1_Callback(hObject, eventdata, handles)
% hObject    handle to ImageSource1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ImageSource1
%if get(handles.ImageSource1,'Value')==0
%    set(handles.ImageSource1,'String','Folder')
%else
%    set(handles.ImageSource1,'String','Images')
%end

% --- Executes on button press in ImageSource2.
function ImageSource2_Callback(hObject, eventdata, handles)
% hObject    handle to ImageSource2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ImageSource2

%if get(handles.ImageSource2,'Value')==0
%    set(handles.ImageSource2,'String','Folder')
%else
%    set(handles.ImageSource2,'String','Images')
%end


% --- Executes on slider movement.
function SliderMaxIntensity2_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to SliderMaxIntensity2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%dum2=varargin{1};
%images2=varargin{2};                            % Get mages1=images from command mode
%folder2=varargin{3};
mxval=get(handles.SliderMaxIntensity2,'Value');
set(handles.MaxIntensity2,'String',num2str(round(mxval)));  % Write the number in the display box
                                % Now update the display
clowval2=round(get(handles.SliderMinIntensity2,'Value'));  % set minimum display intensity
chival2=round(get(handles.SliderMaxIntensity2,'Value'));   % set maximum display intensity
axes(handles.axes2);
handles.clowval2=clowval2;
handles.chival2=chival2;
guidata(gcbo,handles);
%SliderFrame2_Callback(handles.SliderFrame2, eventdata, handles,dum2,images2,folder2)
SliderFrame2_Callback(handles.SliderFrame2, eventdata, handles)
%caxis([clowval2 chival2]);                            % changes the current display to match
                                       % the new hi/lo intensity settings

% --- Executes during object creation, after setting all properties.
function SliderMaxIntensity2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderMaxIntensity2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function SliderMaxIntensity1_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to SliderMaxIntensity1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%dum1=varargin{1};
%images1=varargin{2};                            % Get mages1=images from command mode
%folder1=varargin{3};
mxval=get(handles.SliderMaxIntensity1,'Value');
set(handles.MaxIntensity1,'String',num2str(round(mxval)));  % Write the number in the display box
                                % Now update the display
clowval1=round(get(handles.SliderMinIntensity1,'Value'));  % set minimum display intensity
chival1=round(get(handles.SliderMaxIntensity1,'Value'));   % set maximum display intensity
axes(handles.axes1);
handles.clowval1=clowval1;
handles.chival1=chival1;
guidata(gcbo,handles);
%SliderFrame1_Callback(handles.SliderFrame1, eventdata, handles,dum1,images1,folder1)
SliderFrame1_Callback(handles.SliderFrame1, eventdata, handles)
%caxis([clowval1 chival1]);                            % changes the current display to match
                                       % the new hi/lo intensity settings

% --- Executes during object creation, after setting all properties.
function SliderMaxIntensity1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderMaxIntensity1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function MaxIntensity1_Callback(hObject, eventdata, handles)
% hObject    handle to MaxIntensity1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxIntensity1 as text
%        str2double(get(hObject,'String')) returns contents of MaxIntensity1 as a double
 mxx=str2double(get(handles.MaxIntensity1,'String'));                                                           
%if get(handles.MaxIntensity,'Max') < mxx
                                    % Use the manual input in order to set
                                    % the slider switch maximum for both
                                    % the Min and Max slider swiches
    set(handles.SliderMaxIntensity1,'Max',mxx); 
    set(handles.SliderMinIntensity1,'Max',mxx);
    set(handles.SliderMaxIntensity1,'Value',mxx);
    set(handles.SliderMinIntensity1,'Value',1);

% --- Executes during object creation, after setting all properties.
function MaxIntensity1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxIntensity1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function MinIntensity1_Callback(hObject, eventdata, handles)
% hObject    handle to MinIntensity1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinIntensity1 as text
%        str2double(get(hObject,'String')) returns contents of MinIntensity1 as a double



% --- Executes during object creation, after setting all properties.
function MinIntensity1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinIntensity1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end





function MaxIntensity2_Callback(hObject, eventdata, handles)
% hObject    handle to MaxIntensity2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxIntensity2 as text
%        str2double(get(hObject,'String')) returns contents of MaxIntensity2 as a double
 mxx=str2double(get(handles.MaxIntensity2,'String'));                                                           
%if get(handles.MaxIntensity,'Max') < mxx
                                    % Use the manual input in order to set
                                    % the slider switch maximum for both
                                    % the Min and Max slider swiches
    set(handles.SliderMaxIntensity2,'Max',mxx); 
    set(handles.SliderMinIntensity2,'Max',mxx);
    set(handles.SliderMaxIntensity2,'Value',mxx);
    set(handles.SliderMinIntensity2,'Value',1);
%end

% --- Executes during object creation, after setting all properties.
function MaxIntensity2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxIntensity2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function MinIntensity2_Callback(hObject, eventdata, handles)
% hObject    handle to MinIntensity2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinIntensity2 as text
%        str2double(get(hObject,'String')) returns contents of MinIntensity2 as a double


% --- Executes during object creation, after setting all properties.
function MinIntensity2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinIntensity2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on button press in AddPoint.
function AddPoint_Callback(hObject, eventdata, handles)
% hObject    handle to AddPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% First get a point from the displayed images1
set(handles.FieldID,'String','Image1');
framenumber1=str2num(get(handles.FrameNumber1,'String'));
ave1=round(str2double(get(handles.AveNumber1,'String')));
pixnum1=str2double(get(handles.PixelNumber1,'String'));
cycleflag=0;            % Will be set to 1 if we wish to continue designating mapping points
shaddowflag=0;          % Will be set to 1 if we shaddow a point in the field 2
axes(handles.axes1)
[aoinumber parameters]=size(handles.MappingPoints);
[x1pt y1pt but1]=ginput(1);                                % Click on a point in field 1
   
    

 Field1Point=[framenumber1 ave1 x1pt y1pt pixnum1 aoinumber+1];
 if get(handles.FitSpot,'Value')==1
                % Here if we want to apply a gaussian fit to refine the
                % center of the spot we just clicked
               
     [xlow1 xhi1 ylow1 yhi1]=AOI_Limits([x1pt y1pt],Field1Point(5)/2);
     presentaoi1=handles.avefrm1(ylow1:yhi1,xlow1:xhi1);
     mx1=double(max(max(presentaoi1)));
     mn1=double(mean(mean(presentaoi1)));
     inputarg0=[mx1-mn1 Field1Point(5)/2 Field1Point(5)/2 Field1Point(5)/4 mn1];
     outarg1=gauss2dfit(double(presentaoi1),double(inputarg0));
                % Replace our clicked x y coordinates with those from the
                % gaussian fit
     Field1Point(3:4)=[outarg1(2)+xlow1  outarg1(3)+ylow1];
 end
 axes(handles.axes1);
 hold on
 
                              % try drawing boxes around just last aoi
 draw_box(Field1Point(3:4),(Field1Point(5)-1)/2,(Field1Point(5)-1)/2,'b');
 hold off
 [rosemp colmp]=size(handles.MappingPoints);
 parenthandles=guidata(handles.parenthandles_fig);
 if rosemp>=3  
                % Here if it is possible to fit mapping so that we can
                % shadow the field 1 spot just picked into field 2 to aid
                % in picking the field 2 spot
           
          fitparmvector=get(parenthandles.FitDisplay,'UserData');
         shadowxy2=proximity_mapping(handles.MappingPoints,Field1Point(3:4),rosemp,fitparmvector,2);
         axes(handles.axes2);
         draw_box(shadowxy2(1:2),(Field1Point(5)-1)/2,(Field1Point(5)-1)/2,'g');
         shaddowflag=1;         % Designates that we drew a shaddow point
 end
 
 % Now get point from the displayed images2
 set(handles.FieldID,'String','Image2');
framenumber2=str2num(get(handles.FrameNumber2,'String'));
ave2=round(str2double(get(handles.AveNumber2,'String')));
pixnum2=str2double(get(handles.PixelNumber2,'String'));

axes(handles.axes2)
                                    % Waiting here for user to click again
[x2pt y2pt but2]=ginput(1);                                % Click on a point in field 2
%if (shaddowflag==1) & (but2==3)
if (shaddowflag==1) & ( (but2==3) | (but2==32) )
              % There is a shaddow box and user hit either right button or the space bar
              % Space bar will reject position of the shaddow box
                    % User hit the right button AND there is a shaddow box:
                    % Here to accept or reject the position of the shaddow box and to
                    % keep designating mapping points
    x2pt=shadowxy2(1);  % Use the shaddow point rather than x2pt y2pt from the ginput above
    y2pt=shadowxy2(2);
    cycleflag=1;    % Indicates that we should just keep designating mapping points
end
    Field2Point=[framenumber2 ave2 x2pt y2pt pixnum2 aoinumber+1];

if get(handles.FitSpot,'Value')==1
                % Here if we want to apply a gaussian fit to refine the
                % center of the spot we just clicked
     [xlow2 xhi2 ylow2 yhi2]=AOI_Limits([x2pt y2pt],Field2Point(5)/2);
     presentaoi2=handles.avefrm2(ylow2:yhi2,xlow2:xhi2);
     mx2=double(max(max(presentaoi2)));
     mn2=double(mean(mean(presentaoi2)));
     inputarg0=[mx2-mn2 Field2Point(5)/2 Field2Point(5)/2 Field2Point(5)/4 mn2];
     outarg2=gauss2dfit(double(presentaoi2),double(inputarg0));
                % Replace our clicked x y coordinates with those from the
                % gaussian fit
     Field2Point(3:4)=[outarg2(2)+xlow2  outarg2(3)+ylow2];
 end
 axes(handles.axes2);
 hold on
 
                              % try drawing boxes around just last aoi
 draw_box(Field2Point(3:4),(Field2Point(5)-1)/2,(Field2Point(5)-1)/2,'b');
 hold off

 
            % [frm#1   ave1  x1  y1  pixnum1  aoinum1   frm#2  ave2 x2 y2 pixnum2 aoinum2]  
if but2~=32
            % Here if user did not reject the point i.e. did not hit the space bar 
    handles.MappingPoints=[handles.MappingPoints; Field1Point Field2Point];                            % Store the list in the handles structure
elseif but2==32
            % Here if the user DID reject the point.  Repaint the image, then continue on
    SliderFrame1_Callback(handles.SliderFrame1, eventdata, handles) 
   
    SliderFrame2_Callback(handles.SliderFrame2, eventdata, handles)
   
end
guidata(gcbo,handles);
 parenthandles=guidata(handles.parenthandles_fig);       % Get handle structure from top imscroll gui
 [aoinumber parameters]=size(handles.MappingPoints);                                                               

if aoinumber>=3               % Map the two fields if we have 3 or more points
                                %  x2= mx21*x1 + bx21
                                %  y2= my21*y1 + by21
                                % first polyfit(x1,x2)=[slope intercept] as
                                % first guess
    fitparmx21=polyfit(handles.MappingPoints(:,3),handles.MappingPoints(:,9),1);
                                % Form a cell array, first member is a matrix of the
                                % x1y1 pairs
    inarray{1}=[ handles.MappingPoints(:,3) handles.MappingPoints(:,4)];
                                % second member is a vector of the output
                                % x2 points
    inarray{2} = handles.MappingPoints(:,9);
                                % Input guess is [mxx21 mxy21 bx] with
                                % mxy21 = 0 at first
    fitparmx21more=mappingfit(inarray,[fitparmx21(1) 0 fitparmx21(2) ]);
    rangex=[min(handles.MappingPoints(:,3) ): max(handles.MappingPoints(:,3) )];
                                % Get the linear fit result
    valx=polyval(fitparmx21,rangex);
                                % Get the more complex fit result
    valxmore=mappingfunc(fitparmx21more,inarray{1});
                                % Plot the x data and fit
    figure(20);subplot(121);plot(handles.MappingPoints(:,3),handles.MappingPoints(:,9),'o',...
                          rangex,valx,'r-', handles.MappingPoints(:,3),valxmore,'x')
    xlabel('X1 Coordinate');ylabel('X2 Coordinate');title(['X Mapping:' num2str(fitparmx21more')])
                                % then polyfit(y1,y2)
    fitparmy21=polyfit(handles.MappingPoints(:,4),handles.MappingPoints(:,10),1);
                                % Form a cell array, first member is a
                                % matrix of the x1y1 pairs
      inarray{1}=[ handles.MappingPoints(:,3) handles.MappingPoints(:,4)];
                                % second member is a vector of the output
                                % y2 points
    inarray{2} = handles.MappingPoints(:,10);
                                % Input guess is [myx21 myy21 bx] with
                                % myx21 = 0 at first
       fitparmy21more=mappingfit(inarray,[0 fitparmx21(1) fitparmx21(2) ]);
     rangey=[min(handles.MappingPoints(:,4) ): max(handles.MappingPoints(:,4) )];
                                % Get the linear fit result
    valy=polyval(fitparmy21,rangey);
                                % Get the more complex fit result
    valymore=mappingfunc(fitparmy21more,inarray{1});
                                % Plot the y data and fit
    figure(20);subplot(122);plot(handles.MappingPoints(:,4),handles.MappingPoints(:,10),'o',...
                          rangey,valy,'-',handles.MappingPoints(:,4),valymore,'x')
        xlabel('Y1 Coordinate');ylabel('Y2 Coordinate');title(['Y Mapping:' num2str(fitparmy21more')])
  
        handles.FitParameters=[fitparmx21more;fitparmy21more];          % Store the fit parameters in the handles structure
        guidata(hObject,handles);                               % [mx21 bx21; my21 by21]
     
                                                                 % Place fitparm into 'Value' of FitDisplay 
                                                                 % as a two row matrix
                                                               
        fitparmvector=[fitparmx21more';fitparmy21more'];
        set(parenthandles.FitDisplay,'UserData',fitparmvector)  % Store the mapping  fit in
                                                              % the parenthandles structure
        set(parenthandles.FitDisplay,'String',[ num2str(fitparmx21more') '  ' num2str(fitparmy21more')]);
                                                                 % display as row [mxx21 mxy21 bx21 myx21 myy21 by21]' 
        mappingpoints=handles.MappingPoints;
        %save p:\matlab12\larry\fig-files\imscroll\mapping\fitparms.dat fitparmvector mappingpoints 
        eval(['save ' parenthandles.FileLocations.mapping 'fitparms.dat fitparmvector mappingpoints']);
else
                                     % If fewer than 3 aois, just save the
                                     % mappingpoints so we can recall them
                                     % from the main gui in the menu for 
                                     % 'Load AOIs mapping (x2y2)'
    mappingpoints=handles.MappingPoints;                                 
    %save p:\matlab12\larry\fig-files\imscroll\mapping\fitparms.dat mappingpoints
    eval(['save ' parenthandles.FileLocations.mapping 'fitparms.dat mappingpoints']);
    
end

if cycleflag==1
                % If user hit the right button while picking a point for
                % Field 2, then keep picking more mapping points 
                % This is the same as having the user again hit the
                % 'AddPoint' button in the gui
   AddPoint_Callback(handles.AddPoint, eventdata, handles)
end




function FieldID_Callback(hObject, eventdata, handles)
% hObject    handle to FieldID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FieldID as text
%        str2double(get(hObject,'String')) returns contents of FieldID as a double


% --- Executes during object creation, after setting all properties.
function FieldID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FieldID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in ClearPoints.
%function ClearPoints_Callback(hObject, eventdata, handles)
% hObject    handle to ClearPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%handles.MappingPoints=[];
%handles.FitParameters=[];
%guidata(hObject,handles);


function PixelNumber1_Callback(hObject, eventdata, handles)
% hObject    handle to PixelNumber1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PixelNumber1 as text
%        str2double(get(hObject,'String')) returns contents of PixelNumber1 as a double


% --- Executes during object creation, after setting all properties.
function PixelNumber1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PixelNumber1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function PixelNumber2_Callback(hObject, eventdata, handles)
% hObject    handle to PixelNumber2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PixelNumber2 as text
%        str2double(get(hObject,'String')) returns contents of PixelNumber2 as a double


% --- Executes during object creation, after setting all properties.
function PixelNumber2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PixelNumber2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on button press in MouseInput1.
function MouseInput1_Callback(hObject, eventdata, handles)
% hObject    handle to MouseInput1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1)
[xpts ypts]=ginput(2);                      % Get two points via mouse clicks.
                                            % These will define our region
                                            % for magnification
                                            % Now write the string into the
                                            % MagRange editable box
xpts=round(xpts);ypts=round(ypts);
xpts=sort(xpts);ypts=sort(ypts);            % Place in order of [low high] so the 
                                            % orientation of points entered does not
                                            % matter
val=[xpts(1) xpts(2) ypts(1) ypts(2)];      % Place in row vector so we can
                                            % store the points in 'Value'
set(handles.MouseInput1,'UserData',val);        % Store points in 'Value'
guidata(gcbo,handles);

% --- Executes on button press in MouseInput2.
function MouseInput2_Callback(hObject, eventdata, handles)
% hObject    handle to MouseInput2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes2)
[xpts ypts]=ginput(2);                      % Get two points via mouse clicks.
                                            % These will define our region
                                            % for magnification
                                            % Now write the string into the
                                            % MagRange editable box
xpts=round(xpts);ypts=round(ypts);
xpts=sort(xpts);ypts=sort(ypts);            % Place in order of [low high] so the 
                                            % orientation of points entered does not
                                            % matter
val=[xpts(1) xpts(2) ypts(1) ypts(2)];      % Place in row vector so we can
                                            % store the points in 'Value'
set(handles.MouseInput2,'UserData',val);        % Store points in 'Value'
guidata(gcbo,handles);
% --- Executes on button press in Magnify1.
function Magnify1_Callback(hObject, eventdata, handles)
% hObject    handle to Magnify1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Magnify1
if get(handles.Magnify1,'Value')==0
    set(handles.Magnify1,'String','Full Screen1')
else
    set(handles.Magnify1,'String','Magnified1')
end

% --- Executes on button press in Magnify2.
function Magnify2_Callback(hObject, eventdata, handles)
% hObject    handle to Magnify2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Magnify2
if get(handles.Magnify2,'Value')==0
    set(handles.Magnify2,'String','Full Screen2')
else
    set(handles.Magnify2,'String','Magnified2')
end



% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles,varargin)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called





function Time2Text_Callback(hObject, eventdata, handles)
% hObject    handle to Time2Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Time2Text as text
%        str2double(get(hObject,'String')) returns contents of Time2Text as a double


% --- Executes during object creation, after setting all properties.
function Time2Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Time2Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Time1Text_Callback(hObject, eventdata, handles)
% hObject    handle to Time1Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Time1Text as text
%        str2double(get(hObject,'String')) returns contents of Time1Text as a double


% --- Executes during object creation, after setting all properties.
function Time1Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Time1Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on button press in KeyboardButton.
function KeyboardButton_Callback(hObject, eventdata, handles)
% hObject    handle to KeyboardButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

keyboard


% --- Executes on selection change in MappingChoice.
function MappingChoice_Callback(hObject, eventdata, handles)
% hObject    handle to MappingChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns MappingChoice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MappingChoice


% --- Executes during object creation, after setting all properties.
function MappingChoice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MappingChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in OverlapImageFigure.
function OverlapImageFigure_Callback(hObject, eventdata, handles)
% hObject    handle to OverlapImageFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OverlapImageFigure

button_value=get(handles.OverlapImageFigure,'Value');
if button_value==0
    set(handles.OverlapImageFigure,'String','No Figure')
else
    set(handles.OverlapImageFigure,'String','Figure')
end


% --- Executes on button press in RemovePoint.
function RemovePoint_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to RemovePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%dum=varargin{1};
%images=varargin{2};                            % Get mages1=images from command mode
%folder=varargin{3};
%dum2=varargin{4};
%images2=varargin{5};                            % Get mages1=images from command mode
%folder2=varargin{6};
parenthandles=guidata(handles.parenthandles_fig);       % Get handle structure from top gui

flag=0;
axes(handles.axes1)
 
while flag==0
    [a b but]=ginput(1);
    if but==3
        flag=1;
    else
                                            % Get the aoi number for the
                                            % aoi closest to where user
                                            % clicked
        num_closest=MappingPointsCompare([a b],handles);
                                            % logical array, =1 when it
                                            % matches the aoi number

  % Get the aoi closest to that clicked, remove it from list, then call the
  % two slider callbacks in order to rewrite the fields.  
        logik=(handles.MappingPoints(:,6)==num_closest);
        handles.MappingPoints(logik,:)=[];          % remove information for that aoi

    end
                                                  % Update the existin list of aoi
                                                  % information so that no
                                                  % aoi numbers are skipped

handles.MappingPoints=update_MappingPoints_aoinum(handles.MappingPoints);

guidata(gcbo,handles) ;

end
                                                % Update the images
%SliderFrame1_Callback(handles.SliderFrame1, eventdata, handles, dum,images,folder)
%SliderFrame2_Callback(handles.SliderFrame1, eventdata, handles, dum2,images2,folder2)
SliderFrame1_Callback(handles.SliderFrame1, eventdata, handles)
SliderFrame2_Callback(handles.SliderFrame2, eventdata, handles)
 %****** Up to here:  presently modifiying MappingPointsCompare.m 2/14/09
 %If you like, then
  % recompute the fit parameters (optional at this point: user can just
  % chose another point to recompute, or remove a good point an put it back
  % in in order to recompute without the bad point.
[aoinumber parameter]=size(handles.MappingPoints);

if aoinumber>=3
                % When there are at least 3 points, use them to fit the
                % mapping function
    fitparmvector=Determine_FitParameters(handles,parenthandles);
    handles.FitParameters=fitparmvector;                % Store the fit parameters in the handles structure
    guidata(gcbo,handles);                        % [mx21 bx21; my21 by21]
    set(parenthandles.FitDisplay,'UserData',fitparmvector)
    set(parenthandles.FitDisplay,'String',[ num2str(fitparmvector(1,:)) '  ' num2str(fitparmvector(2,:))]);
                % Store the mapping points and fit parameters in the file 'fitparms.dat'
    mappingpoints=handles.MappingPoints;
    eval(['save ' parenthandles.FileLocations.mapping 'fitparms.dat fitparmvector mappingpoints']);

else
    mappingpoints=handles.MappingPoints;
                % store the mapping points only in 'fitparms.dat (no fit
                % since the # of points is too low)

    eval(['save ' parenthandles.FileLocations.mapping 'fitparms.dat mappingpoints']);
end


% --- Executes on button press in FitSpot.
function FitSpot_Callback(hObject, eventdata, handles)
% hObject    handle to FitSpot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FitSpot

if get(handles.FitSpot,'Value')==1
                % Here if we want to apply a gaussian fit to the spot 
                % that we click on (see AddPoint callback)
    set(handles.FitSpot,'String','Fitting')
else
    set(handles.FitSpot,'String','NoFit')
end


% --- Executes on button press in LoadFile.
function LoadFile_Callback(hObject, eventdata, handles)
% hObject    handle to LoadFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fn fp]=uigetfile;      % Prompt user for the mapping file
                        % that will be used to restart the mapping program
 eval(['load ' [fp fn] ' -mat'])    % Loads the file
 parenthandles=guidata(handles.parenthandles_fig); 
 handles.MappingPoints=mappingpoints;   % Assign the mappingpoints to the proper variable
 set(parenthandles.FitDisplay,'UserData',fitparmvector);    % Place the fitparmvector in the display
 guidata(gcbo,handles);                 % Store the handles 
 