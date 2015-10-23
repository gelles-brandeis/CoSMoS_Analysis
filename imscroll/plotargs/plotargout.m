function varargout = plotargout(varargin)
% PLOTARGOUT Application M-file for plotargout.fig
%    FIG = PLOTARGOUT launch plotargout GUI.
%    PLOTARGOUT('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 07-Oct-2015 11:17:49

% 3/28/10  LJF Now using remove_event_v1 rather than remove_event.  Also
% added AOI# to column 7 of the CumulativeIntervalArray and PTCA{1,10}

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


%if nargin == 0  % LAUNCH GUI
if ishandle(varargin{1})  % Launch GUI
	fig = openfig(mfilename,'reuse');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
    handles.aoiFrame=[];                        % Will contain the aoi image data and its fit
                                                % as constructed from
                                                % compare_aoi_fit() in the
                                                % call to the
                                                % FitFrameNumberSlider
                                                % callback
    handles.AOIgfolder1=[];        % Glimplse folder for display of AOIs
    handles.AOIgheader1=[];         % vid structure stored in header.mat in
                                    % in the Glimpse folder
    handles.AOIDumgfolder1=[];     % zeroed image of size and type of aoi
    handles.AOIgfolder2=[];
    handles.AOIgheader2=[];
    handles.AOIDumgfolder2=[];
    handles.AOITiffFile1=[];        % Tiff file for display of AOis
    handles.AOIDumTiffFile1=[]; % zeroed image of size and data type of aoi 
    handles.AOITiffFile2=[];
    handles.AOIDumTiffFile2=[];
    handles.AOIRAM1=[];         % stacked images for display of AOIs
    handles.AOIDumRAM1=[];      % zeroed image of size and data type of aoi
    handles.AOIRAM2=[];
    handles.AOIDumRAM2=[];
    handles.galleryxy1Centers=[];
    handles.galleryxy2Centers=[];
    
    %  Next add the members necessary for the interval detection:  We make
    %  a structure with one member being a cell array containing aoifits file info,
    %  data processing info and the high/low event intervals for that
    %  aoifits file.
   
    CellArrayDescription=['(1:AOIfits Filename) (2:AOI Number) (3:Upward Threshold, sigma units) (4:Down Threshold, sigma units)'...
         '(5:DetrendedMean (6:Std) (7:MeanStdFrameRange Nx2) (8:DataFrameRange Nx2) (9:TimeBase 1xM) [10:Interval array Nx7]'...
         ' 11:InputTrace 2xP  12:DetrendedTrace 2xP 13:BinaryInputTrace Lx3  '...
         '14:BinaryInputTraceDescription 15:DetrendFrameRange Lx2 16:UncorrectedTraceMean'];
     % Both InputTrace and DetrendedTrace are [(frame #)   (integrated intensity)]
     % Description of the cell array element containing the interval array information                                     
    IntervalArrayDescription=['(low or high =-2,0,2 or -3,1,3) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#'];
                % InputTrace is the current integrated intensity trace being detected for high/low events,
           % and the InputTrace(:,2) InputTrace(:,3) refered to in next entry
           % runs over just the frame range selected for interval detection
    BinaryInputTraceDescription=['(low or high =0 or 1) InputTrace(:,1) InputTrace(:,2)'];
                    % the IntervalDataStructure structure 
    handles.IntervalDataStructure.PresentTraceCellArray=cell(1,16);  % Holds trace presently being processed
    handles.IntervalDataStructure.PresentTraceCellArray{1,14}=BinaryInputTraceDescription;
    %handles.IntervalDataStructure.PresentTraceCellArray{1,4}=str2num( get(handles.DownThreshold,'String') );
    %handles.IntervalDataStructure.PresentTraceCellArray{1,3}=str2num( get(handles.UPThreshold,'String') );
    handles.IntervalDataStructure.OneTraceCellDescription=CellArrayDescription;   % describes contents of cell array
    handles.IntervalDataStructure.AllTracesCellArray=cell(1,16);     % Cumulative data from all traces
    handles.IntervalDataStructure.CumulativeIntervalArray=[];        % Just the interval list from all traces
    handles.IntervalDataStructure.IntervalArrayDescription=IntervalArrayDescription;  % Describes the interval list contents
    handles.IntervalDataStructure.AllSpots=[];                      %Will hold the AllSpots structure from imscroll (spot picker option)
    guidata(fig, handles);
    handles.parenthandles_fig = varargin{1};            % Get the handle for the parent gui figure  
    % save the handles structure
    handles.SpotProximityRadius=1.0;                    % Max Distance between detected spot and AOI center to count spot as a landing 
    handles.DefaultXLimitsBottom=[0 1000];              % Default limits of X axis for bottom plot
    handles.RowXLimitsMatrixBottom=1;                   % Row # in use (wrt XLimitsMatrixBottom) for determining X limits
                                                        % when plotting Bottom plot
                   % Next: starting matrix for x limits on bottom row
    handles.XLimitsMatrixBottom=[0 1000;1000 2000;2000 3000;3000 4000;4000 5000];
    handles.AllTracesDiplayNumber=1;                    % This will be the row index of the AllTracesCellArray 
                                                        % being displayed 
	guidata(fig, handles);
    
    % get the handles structure for parent gui    
    parenthandles = guidata(handles.parenthandles_fig); 
                                                % Reset name where we store
                                                % the 'aoifits' structure
    set(parenthandles.OutputFilename,'String','default.dat');
                                        % Get the AllSpots structure (may be empty) 
    handles.IntervalDataStructure.AllSpots=FreeAllSpotsMemory(parenthandles.AllSpots);
    handles.IntervalDataStructure2=handles.IntervalDataStructure;   % Duplicates the structure of 
                   % the IntervalDataStructure so we can import two of them for plotting purposes  
    if get(parenthandles.ImageSource,'Value') ==3     % When using glimpse folders, pre-assign
        handles.AOIgfolder1=parenthandles.gfolder;  % For viewing AOIs
        handles.AOIgfolder2=parenthandles.gfolder;
        handles.AOIgheader1=parenthandles.gheader;  % vid structure with time info
        handles.AOIgheader2=parenthandles.gheader;
        dum=glimpse_image(handles.AOIgfolder1,handles.AOIgheader1,1);
        handles.AOIDumgfolder1=uint32(dum-dum);     % Zero frame and store dummy
        handles.AOIDumgfolder2=uint32(dum-dum);     % Zero frame and store dummy
    end
    guidata(fig,handles);
        
	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
	catch
		disp(lasterr);
	end

end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'SliceIndexSlider_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.SliceIndexSlider. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.



% --------------------------------------------------------------------
function varargout = MiddlePlotY_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.middleplot.
%disp('middleplot Callback not implemented yet.')
%tst=handles.IntervalDataStructure;
%keyboard
%if get(handles.MiddlePlotY,'Value')==1
%    set(handles.ButtonChoice,'Value',1)
%elseif get(handles.MiddlePlotY,'Value')==2
%    set(handles.ButtonChoice,'Value',2)
%end
if get(handles.MiddlePlotY,'Value')==8
    set(handles.ProximityRadiusPanel,'Visible','on')
else
    set(handles.ProximityRadiusPanel,'Visible','off')
end

% --------------------------------------------------------------------

% PUSHBUTTON TO DISPLAY THE MIDDLE PLOT
function varargout = DisplayMiddle_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.DisplayMiddle.
%global argouts
%argouts=varargin{1};                            % argouts=[aoi# frame# amp x0 y0 sigma offset]
%parenthandles=guidata(gcbo);
%args=parenthandles.fitdata;

parenthandles = guidata(handles.parenthandles_fig);         % Get the handle structure of the parent gui
                                                            % Look at the
                                                            % if ishandle()
                                                            % section at
                                                            % top of this
                                                            % function.
aoifits=parenthandles.aoifits1;
argouts=aoifits.data;
argnumber=get(handles.MiddlePlotY,'Value');
flagg=0;
if argnumber==8
    flagg=1;        % Plot the Binary Spot Trace.  Very awkward
    argnumber=1;    % Plot the amplitude, then we'll overwrite
end
if argnumber==7
                        % Here to plot background
    argouts=aoifits.BackgroundData;
    argnumber=6;
end
axes(handles.axes2);
maxaois=max(argouts(:,1));                       % Number of AOIs in data set
set(handles.MaxAOIs,'String',num2str(maxaois))
                                                % Get the AOI number to plot
aoinumber=str2num(get(handles.MiddleAOIPlot,'String'));
if aoinumber<=maxaois
                                                % Logical array that picks
                                                % out matching argouts entries
    logik=( argouts(:,1)==aoinumber );
    oneargouts=argouts(logik,:);                      % Sub matrix for just one AOI
else
                                                % Use entire data set if
                                                % chosen AOI number exceeds
                                                % the max in the set
    oneargouts=argouts;
end
figure(24);plot(oneargouts(:,2),oneargouts(:,argnumber+2),'r',oneargouts(:,2),oneargouts(:,argnumber+2),'b-');shg
axes(handles.axes2);
plot(oneargouts(:,2),oneargouts(:,argnumber+2),'r',oneargouts(:,2),oneargouts(:,argnumber+2),'b-');

if flagg==1                 % True if initial argnumber ==8 (Binary Spot Trace)
    radius=handles.SpotProximityRadius;           % Proximity of spot to AOI center
    radius_hys=str2num(get(handles.UpThreshold,'String'));
    Bin01Trace=AOISpotLanding(aoinumber,radius,parenthandles,aoifits.aoiinfo2,radius_hys);          % 1/0 binary trace of spot landings
                                                                   % w/in radius of the AOI center
    figure(24);plot(Bin01Trace(:,1),Bin01Trace(:,2),'b');           % Plot the binary trace
    
    axes(handles.axes2);
    plot(Bin01Trace(:,1),Bin01Trace(:,2),'b')
    
end

                                            % Now check for manual or
                                            % automatic axis scaling
if (get(handles.AxisScale,'Value')) ==0
    figure(24);axis auto
    axes(handles.axes2);axis auto
    if flagg==1         % True is plotting 1/0 Binary Spot Trace
        figure(24);h=gca;set(h,'Ylim',[-1 2]);
        axes(handles.axes2);h=gca;set(h,'Ylim',[-1 2]);
    end
else
    figure(24);axis(eval(get(handles.AxisLimits,'String')))
    axes(handles.axes2);axis(eval(get(handles.AxisLimits,'String')))
end
if get(handles.PlotRangeToggle,'Value')
    plotfrms=round(eval( get(handles.PlotRange,'String')));
    plotfrmmin=min(plotfrms);
    plotfrmmax=max(plotfrms);
    axes(handles.axes2)
    ax=axis;
    axis([plotfrmmin plotfrmmax ax(3) ax(4)]);
end


% --------------------------------------------------------------------
function varargout = close_plotting_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.close_plotting.
closereq


% --- Executes during object creation, after setting all properties.
function BottomPlotY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BottomPlotY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in BottomPlotY.

function BottomPlotY_Callback(hObject, eventdata, handles)
% hObject    handle to BottomPlotY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns BottomPlotY contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BottomPlotY



% --- Executes on button press in DisplayBottom.  This displays the bottom
% plot.
% PUSHBUTTON TO DISPLAY THE BOTTOM PLOT
function DisplayBottom_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to DisplayBottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA
%global argouts %parenthandles
%argouts=varargin{1};                            % argouts=[aoi# frame# amp x0 y0 sigma offset (int. AOI)]
%images=varargin{1};
%dum=varargin{2};
%folder=varargin{3};
parenthandles = guidata(handles.parenthandles_fig);         % Get the handle structure of the parent gui
                                                            % Look at the
                                                            % if ishandle()
                                                            % section at
                                                            % top of this
                                                            % function.
                                                            %
                           % Next pertains to the detection of dye-protein
                           % landing intervals (see top)
                                                 % Get the AOI number to plot
aoinumber=str2num(get(handles.BottomAOIPlot,'String'));
PTCA=handles.IntervalDataStructure.PresentTraceCellArray;   
aoifits=parenthandles.aoifits2;                             % Present aoifits2 structure
argouts=aoifits.data;                                       % Just the data member of aoifits
 
log1= (aoifits.data(:,1)==aoinumber);              % Get sub aoifits for this 
onedat=aoifits.data(log1,:);                    % one aoi = onedat
 % [aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi]


 
PTCA{1,11}=[onedat(:,2) onedat(:,8)];           % This is the InputTrace in which we
                        % want to detect events
PTCA{1,12}=PTCA{1,11};                          % DetrendedInputTrace = InputTrace for now
      % We will later choose to remove the slow baseline drifts from PTCA{1,12}  

   %[aoifitsFile AOINum UpThreshold DownThreshold  mean  std  MeanStdFrms DataFrms  TimeBase IntervalArray ...
                 % InputTrace DetrendedInputTrace BinaryInputTrace BinaryInputtraceDescription DetrendFrameRange]
PTCA{1,2}=aoinumber;
handles.IntervalDataStructure.PresentTraceCellArray=PTCA;   % Update the handles structure

guidata(gcbo,handles);

 
argnumber=get(handles.BottomPlotY,'Value');
axes(handles.axes3);

maxaois=max(argouts(:,1));                       % Number of AOIs in data set
set(handles.MaxAOIs,'String',num2str(maxaois))
                       % update aoi number in the Interval data cell array


                                                

if aoinumber<=maxaois
                                               % Display the aoi coordinates
                                                % that we are displaying
    aoiinf=parenthandles.FitData;                     %[framenumber ave x y pixnum aoinumber];

    %logp=aoiinf(:,6)==aoinumber;
 
    %oneaoiinf=aoiinf(logp,:);                        % Get the sub-aoiinf pertaining to present aoi
     
    %xycoor=oneaoiinf(1,3:4);                        % [x y] for this aoi
    %log1=aoifits.data(:,1)==aoinumber;              % get sub aoifits for this one aoi
    %onedat=aoifits.data(log1,:);
    xycoor=onedat(1,4:5);                           % [x y] for this aoi
    set(handles.AOICenter,'String',['[ ' num2str( round(xycoor(2)) ) '   ' num2str( round(xycoor(1)) ) ' ]' ])

                                                % Now get the fit data for
                                                % this aoi
                                                % Logical array that picks
                                                % out matching argouts entries
    log=( argouts(:,1)==aoinumber );
    oneargouts=argouts(log,:);                      % Sub matrix for just one AOI
else                                                % argouts=[ aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi]
                                                % Use entire data set if
                                                % chosen AOI number exceeds
                                                % the max in the set
    oneargouts=argouts;
end
                                                % Now plot the appropriate
                                                % parameters on the gui and
                                                % in Fig 25

PlotBottom_v1(handles,parenthandles,oneargouts,argnumber); 

%figure(25);plot(oneargouts(:,2),oneargouts(:,argnumber+2),'b',oneargouts(:,2),oneargouts(:,argnumber+2),'r');
%axes(handles.axes3)
%plot(oneargouts(:,2),oneargouts(:,argnumber+2),'b',oneargouts(:,2),oneargouts(:,argnumber+2),'r');
                                                % Now check for manual or
                                                % auto axis scale
%if (get(handles.AxisScale,'Value')) ==0
%    figure(25);axis auto
%    axes(handles.axes3);axis auto
%else
%    figure(25);axis(eval(get(handles.AxisLimits,'String')))
%    axes(handles.axes3);axis(eval(get(handles.AxisLimits,'String')))
%end
                                                % Now perform the averaging
                                                % if it is requested
                                                %if ( get(handles.PlotRangeToggle,'Value')==1 )       % ==1 if ave requested
                                                % Fetch the range over
                                                % which to ave.
frmrange=eval( get(handles.IntervalDataFrameRange,'String') );
                                                % Compute the ave over said
                                                % range
frmrange=[frmrange(1):frmrange(2)];
mxfrm=max(argouts(:,2));mnfrm=min(argouts(:,2));
                                                % Compare listed frame#
                                               % limits to data
%keyboard
if (min(frmrange)>=mnfrm)&(max(frmrange)<=mxfrm)
    yvalues=[];                                 % Frame limit are ok
                                                % Pick out entries to
                                                % averave
                                                % argouts=[ aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi]
    for indxx=1:length(frmrange)
        logg=(oneargouts(:,2)==frmrange(indxx) );
        yvalues=[yvalues;oneargouts(logg,min([argnumber+2 8]))];
                                                % min() above to keep
                                                % within oneargouts range
    end
                                                % Apply outlier limits, if
                                                % toggle is set
    if (get(handles.OutlierToggle,'Value')) ==0
                                                % Here if no outlier limits
        mny=mean( yvalues );
        sdny=std(yvalues);
    else                                        % Here to apply outlier limits
        outlie=eval(get(handles.OutlierRange,'String'));
                                                % Logical array to flag
                                                % outliers
        log=(yvalues>=outlie(2)) | (yvalues<=outlie(1));
        yvalues(log)=[];                        % Eliminate all outliers
        mny=mean(yvalues);
        sdny=std(yvalues);
    end                                         % End of outlier application
                                                % Display the resulting ave
 
    %end
else
                                              % Here to ave over all frames
                                            % for this aoi
                                             % Apply outlier limits, if
                                             % toggle is set
    if (get(handles.OutlierToggle,'Value')) ==0
                                          % Here if not outlier limits set
        mny=mean(oneargouts(:,min([argnumber+2 6])));
        sdny=std(oneargouts(:,min([argnumber+2 6])));
    else
                                            % Here to apply outlier limits
     
        ybalues=oneargouts(:,min([argnumber+2 6]));
        outlie=eval(get(handles.OutlierRange,'String'));
                                                % Logical array to flag
                                                % outliers
        log=(yvalues>=outlie(2)) | (yvalues<=outlie(1));
        yvalues(log)=[];                        % Eliminate all outliers
        mny=mean(yvalues);
        sdny=std(yvalues);
    end                                     % End of outlier application                   
                                            % Replace frame limits with
                                            % max and min
    set(handles.IntervalDataFrameRange,'String',[ '[ ' num2str(mnfrm) '  ' num2str(mxfrm) ' ]' ] );
end                                         % End of ave over all or partial frame range
                                            % Display the frame ave result
 set(handles.AveValue,'String',num2str(mny));
 set(handles.StdDev,'String',num2str(sdny));
% --- Executes during object creation, after setting all properties.
function FitFrameNumberSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FitFrameNumberSlider (see GCBO)
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
%  SLIDER SWITCH SETTING THE FRAMENUMBER THAT WILL BE DISPLAYED
function FitFrameNumberSlider_Callback(hObject, eventdata, handles)
% hObject    handle to FitFrameNumberSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global argouts imageset folderpass%parenthandles
if get(handles.DisplayScales,'Value')==1
    % here if slider controls the maximum value for the gallery display
    mxval=get(handles.FitFrameNumberSlider,'Value');
    set(handles.FitFrameNumber,'String',num2str(round(mxval)));
                                % Now update the display
    clowval=round(get(handles.SliceIndexSlider,'Value'));  % set minimum display intensity
    chival=round(get(handles.FitFrameNumberSlider,'Value'));   % set maximum display intensity
    axes(handles.axes1);
    caxis([clowval chival]);                            % changes the current display to match
                                       % the new hi/lo intensity settings
    axes(handles.axes10);                               % Also change display for single aoi 
    caxis([clowval chival]);
else

    parenthandles = guidata(handles.parenthandles_fig); 
                                                        % imageset is the data set of
                                                        % images
                                                        % parenthandles is the 'handles' set
                                                        % from the root gui
                                                        
                                                        % Set parameters of
                                                        % slider switch:
                                                        %
                                                        % Get frame number from slider
    framenumber=round(get(handles.FitFrameNumberSlider,'Value'))
    set(handles.FitFrameNumber,'String',num2str(framenumber));
    dum=getframes_v1(parenthandles);
    imageset=dum;
    %dum=imageset(:,:,1);
    dum=dum-dum;
    %dum=imsubtract(dum,dum); 
    frmnum=str2num(get(handles.FitFrameNumber,'String'));
    aoinum=str2num(get(handles.MiddleAOIPlot,'String'));
%ave=round(str2double(get(parenthandles.FrameAve,'String')));

    aoifits=parenthandles.aoifits1;
    argouts=aoifits.data;                                %  Fit data portion of the aoifits array that we store
    pixnum=aoifits.parameter(2);
    ave=aoifits.parameter(1);
    width=get(handles.XWidth,'Value');                      % AOI width setting from the popup menu
    log=( argouts(:,1)==aoinum)&( argouts(:,2)==frmnum );
    oneargout=argouts(log,:);                      % Pick argouts line containing the
                                               % data for this aoi and
                                               % framenumber
                                                %
                                                % Now get the image AOI and
                                                % the fit to it

    cf=compare_aoi_fit(oneargout,imageset,pixnum*width,ave,folderpass,parenthandles);

    handles.aoiFrame=cf;                            % cf(:,:,1) is the data
                                                % cf(:,:,2) is the fit
    guidata(gcbo,handles);
    slicenumber=round(get(handles.SliceIndexSlider,'Value'));
    axes(handles.axes1);

    [mcf ncf]=size(cf(:,:,1));


    plottype=get(handles.TopPlotChoice,'Value');    % Popup menu for choice of plot type
    if (plottype==1)
        plot([1:ncf],cf(slicenumber,:,1),'r',[1:ncf],cf(slicenumber,:,2),'b')
    elseif (plottype==2)
                                                % Here for contour plots of
                                                % image and fit
                                                % Get the mean and max of
                                                % the data image AOI
        mncf=mean(mean(cf(:,:,1)));
        mxcf=max(max(cf(:,:,1)));
        hold off
        imagesc(cf(:,:,2));colormap(gray);axis('equal');shg
        hold on
                                                % Retrieve the contour values
                                                % from the gui
        cval=str2num(get(handles.ContourLevels,'String'))
        [c h]=contour(cf(:,:,1),mncf+(mxcf-mncf)*cval,'y');
        hold off
        %ndx=length(h)
        %colours=['r' 'r' 'y' 'w']
        %for indx=1:ndx
        %set(h(indx),'EdgeColor',colours( rem(indx,3)+1))
        %end
    end
end






% --- Executes during object creation, after setting all properties.
function FitFrameNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FitFrameNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function FitFrameNumber_Callback(hObject, eventdata, handles)
% hObject    handle to FitFrameNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FitFrameNumber as text
%        str2double(get(hObject,'String')) returns contents of FitFrameNumber as a double


% --- Executes on button press in Initialize.
% This is used to set the max and min of the slider according to
% the set of frame numbers in the data set
                    % Radio button pushed:  treat sliders as display scales
if get(handles.DisplayScales,'Value')==1
                            % Get number off text field
    FitFrameNumberVal=str2num(get(handles.FitFrameNumber,'String'));
                            % Redefine max value for sliders
    set(handles.FitFrameNumberSlider,'Max',FitFrameNumberVal)
    set(handles.SliceIndexSlider,'Max',FitFrameNumberVal)
    FitFrameNumberSliderVal=round(get(handles.FitFrameNumberSlider,'Value'));
                            % rewrite text field to reflect current slider
                            % value
    set(handles.FitFrameNumber,'String',num2str(FitFrameNumberSliderVal))
end
    
function Initialize_Callback(hObject, eventdata, handles)
% hObject    handle to Initialize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%global parenthandles
parenthandles = guidata(handles.parenthandles_fig); 
aoifits=parenthandles.aoifits1;
argout=aoifits.data;                                    % Fit data portion of the oaifits array that we store
mn=min( argout(:,2) );                                      % Minimum frame number fit
mx=max( argout(:,2) );                                      % Maximum frame number fit
                                                            % Set the pertinent slider parameters
%frms=eval(get(parenthandles.FrameRange,'String'));          % Range of frames that were fit
set(handles.FitFrameNumberSlider,'Value',mn);
set(handles.FitFrameNumberSlider,'Min',mn);
set(handles.FitFrameNumberSlider,'Max',mx);
set(handles.FitFrameNumber,'String',num2str( mn ));
set(handles.FitFrameNumberSlider,'SliderStep',[1/(mx-mn) .1])

                                                        % Now initialize
                                                        % the SliceIndexSlider
pixnum=aoifits.parameter(2);
width=get(handles.XWidth,'Value');
set(handles.SliceIndexNumber,'String','1');                                                     
set(handles.SliceIndexSlider,'Value',1);
set(handles.SliceIndexSlider,'Min',1);
set(handles.SliceIndexSlider,'Max',pixnum*width);
set(handles.SliceIndexSlider,'SliderStep',[1/(pixnum*width) .1])

% --- Executes on button press in HistogramMiddle.
function HistogramMiddle_Callback(hObject, eventdata, handles)
% hObject    handle to HistogramMiddle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%global argouts
parenthandles = guidata(handles.parenthandles_fig);         % Get the handle structure of the parent gui
                                                            % Look at the
                                                            % if ishandle()
                                                            % section at
                                                            % top of this
                                                            % function.
aoifits=parenthandles.aoifits1;
argouts=aoifits.data;
argnumber=get(handles.MiddlePlotY,'Value');
axes(handles.axes2)
maxaois=max(argouts(:,1))                       % Number of AOIs in data set
set(handles.MaxAOIs,'String',num2str(maxaois))
                                                % Get the AOI number to plot
aoinumber=str2num(get(handles.MiddleAOIPlot,'String'));
if aoinumber<=maxaois
                                                % Logical array that picks
                                                % out matching argouts entries
    log=( argouts(:,1)==aoinumber );
    oneargouts=argouts(log,:);                      % Sub matrix for just one AOI
else
                                                % Use entire data set if
                                                % chosen AOI number exceeds
                                                % the max in the set
    oneargouts=argouts;
end
[margs nargs]=size(oneargouts);
hist(oneargouts(:,argnumber+2),round(margs/10))

% --- Executes on button press in HistogramBottom.
function HistogramBottom_Callback(hObject, eventdata, handles)
% hObject    handle to Histogram bottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%global argouts

parenthandles = guidata(handles.parenthandles_fig);         % Get the handle structure of the parent gui
                                                            % Look at the
                                                            % if ishandle()
                                                            % section at
                                                            % top of this
                                                            % function.
aoifits=parenthandles.aoifits2;
argouts=aoifits.data;

argnumber=get(handles.BottomPlotY,'Value');
axes(handles.axes3);
maxaois=max(argouts(:,1))                       % Number of AOIs in data set
set(handles.MaxAOIs,'String',num2str(maxaois))  % Write number of AOIs to gui
                                                % Get the AOI number to plot
aoinumber=str2num(get(handles.BottomAOIPlot,'String'));
if aoinumber<=maxaois
                                                % Logical array that picks
                                                % out matching argouts entries
    log=( argouts(:,1)==aoinumber );
    oneargouts=argouts(log,:);                      % Sub matrix for just one AOI
else
                                                % Use entire data set if
                                                % chosen AOI number exceeds
                                                % the max in the set
    oneargouts=argouts;
end
                                    % Call routine for plotting histogram
HistogramBottom_Subroutine(handles,parenthandles,oneargouts,argnumber);
%[margs nargs]=size(oneargouts);
%bnst=get(handles.BinNumber,'String');
%bn=round(str2num(bnst));

%figure(25);hist(oneargouts(:,argnumber+2),bn)
%axes(handles.axes3);hist(oneargouts(:,argnumber+2),bn)

% --- Executes during object creation, after setting all properties.
function MiddleAOIPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MiddleAOIPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function MiddleAOIPlot_Callback(hObject, eventdata, handles)
% hObject    handle to MiddleAOIPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MiddleAOIPlot as text
%        str2double(get(hObject,'String')) returns contents of MiddleAOIPlot as a double


% --- Executes during object creation, after setting all properties.
function BottomAOIPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BottomAOIPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function BottomAOIPlot_Callback(hObject, eventdata, handles)
% hObject    handle to BottomAOIPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BottomAOIPlot as text
%        str2double(get(hObject,'String')) returns contents of BottomAOIPlot as a double


% --- Executes during object creation, after setting all properties.
function MaxAOIs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxAOIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function MaxAOIs_Callback(hObject, eventdata, handles)
% hObject    handle to MaxAOIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxAOIs as text
%        str2double(get(hObject,'String')) returns contents of MaxAOIs as a double


% --- Executes on button press in TopPlotx.
function TopPlotx_Callback(hObject, eventdata, handles)
% hObject    handle to TopPlotx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in TopPlotX.
function TopPlotX_Callback(hObject, eventdata, handles)
% hObject    handle to TopPlotX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%global argouts imageset parenthandles mapstrucpass folderpass
global imageset  mapstrucpass folderpass %parenthandles
parenthandles = guidata(handles.parenthandles_fig); 
dum=imageset(:,:,1);
dum=dum-dum;
%dum=imsubtract(dum,dum); 
frmnum=str2num(get(handles.FitFrameNumber,'String'));
aoinum=str2num(get(handles.MiddleAOIPlot,'String'));
ave=round(str2double(get(parenthandles.FrameAve,'String')));
%presentframe= sum(imageset(:,:,frmnum:frmnum+ave-1),3);
%presentframe=imdivide(presentframe,ave);
                                                % Fetch the present frame ave 

presentframe=getframes(dum,imageset,folderpass,parenthandles);
argouts=parenthandles.aoifits1.data;             %Pick off the data portion of our aoifits structure

log=( argouts(:,1)==aoinum)&( argouts(:,2)==frmnum );
oneargout=argouts(log,:);                      % Pick argouts line containing the
                                               % data for this aoi and
                                               % framenumber
                                               %
                                               % Now produce the fitted
                                               % frame of data
fitfrm=gauss2dfit_eval(double(imageset(:,:,frmnum)),oneargout(1,3:7));
                                               % Fetch the width of the aoi
                                               % we wish to display
pixnum=str2double(get(parenthandles.PixelNumber,'String'));
axes(handles.axes1)
ycenter=round(oneargout(5));
xcenter=round(oneargout(4));
width=get(handles.XWidth,'Value');
xargs=( xcenter-width*round((pixnum-1)/2)):(xcenter+width*round((pixnum-1)/2) );
                                                % Plot along x dimension
                                                % (within a row) a length 
                                                % that is 2*(aoisize)
plot(xargs,presentframe(ycenter,xargs),'r',xargs,fitfrm(ycenter,xargs),'b')


% --- Executes during object creation, after setting all properties.
function XWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in XWidth.
function XWidth_Callback(hObject, eventdata, handles)
% hObject    handle to XWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns XWidth contents as cell array
%        contents{get(hObject,'Value')} returns selected item from XWidth
                                            % Need to alter the
                                            % SliceIndexSlider parameters
                                            % when the display width of the
                                            % AOI is altered
%global parenthandles
parenthandles = guidata(handles.parenthandles_fig); 
aoifits=parenthandles.aoifits1;
pixnum=aoifits.parameter(2);
width=get(handles.XWidth,'Value');
set(handles.SliceIndexNumber,'String','1');                                                     
set(handles.SliceIndexSlider,'Value',1);
set(handles.SliceIndexSlider,'Min',1);
set(handles.SliceIndexSlider,'Max',pixnum*width);
set(handles.SliceIndexSlider,'SliderStep',[1/(pixnum*width) .1])





% --- Executes during object creation, after setting all properties.
% creation of SliceIndexSlider
function SliceIndexSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliceIndexSlider (see GCBO)
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


% --- Executes on SliceIndexSlider slider movement.
function SliceIndexSlider_Callback(hObject, eventdata, handles)
% hObject    handle to SliceIndexSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if get(handles.DisplayScales,'Value')==1
    % here if slider controls the maximum value for the gallery display
    mnval=get(handles.SliceIndexSlider,'Value');
    set(handles.SliceIndexNumber,'String',num2str(round(mnval)));
                                % Now update the display
    clowval=round(get(handles.SliceIndexSlider,'Value'));  % set minimum display intensity
    chival=round(get(handles.FitFrameNumberSlider,'Value'));   % set maximum display intensity
    axes(handles.axes1);
    caxis([clowval chival]);                            % changes the current display to match
                                       % the new hi/lo intensity settings
    axes(handles.axes10);              % Also change display scale for single aoi 
    caxis([clowval chival]);
else


    axes(handles.axes1)
    slicenumber=round(get(handles.SliceIndexSlider,'Value'));
    set(handles.SliceIndexNumber,'String',num2str(slicenumber));
    cf=handles.aoiFrame;                                            % Fetch the current AOI data/fit
    [mcf ncf]=size(cf(:,:,1));
    plot([1:ncf],cf(slicenumber,:,1),'r',[1:ncf],cf(slicenumber,:,2),'b')
end

% --- Executes during object creation, after setting all properties.
function SliceIndexNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliceIndexNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function SliceIndexNumber_Callback(hObject, eventdata, handles)
% hObject    handle to SliceIndexNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SliceIndexNumber as text
%        str2double(get(hObject,'String')) returns contents of SliceIndexNumber as a double


% --- Executes during object creation, after setting all properties.
function TopPlotChoice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TopPlotChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in TopPlotChoice.
function TopPlotChoice_Callback(hObject, eventdata, handles)
% hObject    handle to TopPlotChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns TopPlotChoice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TopPlotChoice


% --- Executes during object creation, after setting all properties.
function ContourLevels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ContourLevels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function ContourLevels_Callback(hObject, eventdata, handles)
% hObject    handle to ContourLevels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ContourLevels as text
%        str2double(get(hObject,'String')) returns contents of ContourLevels as a double


% --- Executes on button press in AxisScale.
% Toggle determines whether the axis scales on auto or manual
function AxisScale_Callback(hObject, eventdata, handles)
% hObject    handle to AxisScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AxisScale
if get(handles.AxisScale,'Value')==0
    set(handles.AxisScale,'String','Auto Scale')
else
    set(handles.AxisScale,'String','Manual Limits')
end

% --- Executes during object creation, after setting all properties.
function AxisLimits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AxisLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function AxisLimits_Callback(hObject, eventdata, handles)
% hObject    handle to AxisLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AxisLimits as text
%        str2double(get(hObject,'String')) returns contents of AxisLimits as a double


% --- Executes during object creation, after setting all properties.
function AOICenter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AOICenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function AOICenter_Callback(hObject, eventdata, handles)
% hObject    handle to AOICenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AOICenter as text
%        str2double(get(hObject,'String')) returns contents of AOICenter as a double


% --- Executes on button press in PlotRangeToggle.
function PlotRangeToggle_Callback(hObject, eventdata, handles)
% hObject    handle to PlotRangeToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PlotRangeToggle


% --- Executes during object creation, after setting all properties.
function AveRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AveRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function AveRange_Callback(hObject, eventdata, handles)
% hObject    handle to AveRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AveRange as text
%        str2double(get(hObject,'String')) returns contents of AveRange as a double


% --- Executes during object creation, after setting all properties.
function StdDev_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StdDev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function StdDev_Callback(hObject, eventdata, handles)
% hObject    handle to StdDev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StdDev as text
%        str2double(get(hObject,'String')) returns contents of StdDev as a double


% --- Executes during object creation, after setting all properties.
function AveValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AveValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function AveValue_Callback(hObject, eventdata, handles)
% hObject    handle to AveValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AveValue as text
%        str2double(get(hObject,'String')) returns contents of AveValue as a double



function BinNumber_Callback(hObject, eventdata, handles)
% hObject    handle to BinNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BinNumber as text
%        str2double(get(hObject,'String')) returns contents of BinNumber as a double


% --- Executes during object creation, after setting all properties.
function BinNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BinNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in OutlierToggle.
function OutlierToggle_Callback(hObject, eventdata, handles)
% hObject    handle to OutlierToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OutlierToggle



function OutlierRange_Callback(hObject, eventdata, handles)
% hObject    handle to OutlierRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OutlierRange as text
%        str2double(get(hObject,'String')) returns contents of OutlierRange as a double


% --- Executes during object creation, after setting all properties.
function OutlierRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OutlierRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function PlotRange_Callback(hObject, eventdata, handles)
% hObject    handle to PlotRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PlotRange as text
%        str2double(get(hObject,'String')) returns contents of PlotRange as a double


% --- Executes during object creation, after setting all properties.
function PlotRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in ButtonChoice.
function ButtonChoice_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ButtonChoice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ButtonChoice


% --- Executes during object creation, after setting all properties.
function ButtonChoice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ButtonChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in DataOperation.
function DataOperation_Callback(hObject, eventdata, handles)
% hObject    handle to DataOperation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DataOperation
parenthandles = guidata(handles.parenthandles_fig);        
aoifits=parenthandles.aoifits2;                 % Now have the current aoifits2 structure
             % Get the aoinumber (saved when plotting in DisplayBottom)
aoinumber=handles.IntervalDataStructure.PresentTraceCellArray{1,2};
log1=aoifits.data(:,1)==aoinumber;              % Get sub aoifits for this 
onedat=aoifits.data(log1,:);                    % one aoi = onedat
 % [aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi]
%PTCA{1,11}=[onedat(:,2) onedat(:,8)];           % This is the InputTrace in which we
                        % want to detect events (and is plotted on axes3)

   %[aoifitsFile AOINum UpThreshold DownThreshold  mean  std  MeanStdFrms DataFrms  TimeBase IntervalArray...
                    % InputTrace DetrendedInputTrace BinaryInputTrace BinaryInputtraceDescription DetrendFrameRange]

PTCA=handles.IntervalDataStructure.PresentTraceCellArray;
ButtonChoiceValue=get(handles.ButtonChoice,'Value');
                    % Follow different routines depending on value of the
                    % popup menue ButtonChoice
switch ButtonChoiceValue
    case 2         % Load the vid.ttb time base array
    set(handles.DataOperation,'Value',0)        % reset the toggle to 0
                                                % Open a dialog box for user
    [fn fp]=uigetfile('*.*','Loading Time Base'); 
    eval( ['load ' [fp fn] ' -mat' ] );                    % Load the vid structure
    tb=vid.ttb;                                  % Get the time base information
    tb=tb*1e-3;                                 % Convert time base to seconds
                                                % Save the time base into the IntervalDataStructure
    handles.IntervalDataStructure.FrameTimeBase=tb';
                            % Place TimeperFrame into the PresentTraceCellArray
    handles.IntervalDataStructure.PresentTraceCellArray{1,9}=tb';
    guidata(gcbo,handles);


%*************************************************************************
    case 3         % Load the AllTracesCellArray that
                   % that contains the cumulative list of traces that
                   % comprise our CumulativeIntervalArray
    set(handles.DataOperation,'Value',0)        % reset the toggle to 0
                                                % Open a dialog box for user
    [fn fp]=uigetfile('*.*','Loading AllTracesCellArray'); 
    eval( ['load ' [fp fn] ' -mat' ] );                    % Load the Intervals structure
                                     % (saved under ButtonChoice==4 or 5)
 
    handles.IntervalDataStructure.AllTracesCellArray=Intervals.AllTracesCellArray;

    handles.IntervalDataStructure.CumulativeIntervalArray=Intervals.CumulativeIntervalArray;
    if isfield(Intervals,'AllSpots');
        parenthandles.AllSpots=Intervals.AllSpots;
    end
                            
    guidata(gcbo,handles);                  % Update the handles structure 
    guidata(handles.parenthandles_fig,parenthandles);


%**************************************************************************
    case 4         % Save the cumulative Interval structure information
                       % in same place as used previously through the 
                       % UI save command
    set(handles.DataOperation,'Value',0)        % reset the toggle to 0
              % get the filepath as written in the editable text field
    filepath=get(handles.AOIList,'String');
                % Set up the structure that will be saved
    Intervals.AllTracesCellArrayDescription=handles.IntervalDataStructure.OneTraceCellDescription;
    Intervals.AllTracesCellArray=handles.IntervalDataStructure.AllTracesCellArray;
    Intervals.CumulativeIntervalArrayDescription=handles.IntervalDataStructure.IntervalArrayDescription;
    Intervals.CumulativeIntervalArray=handles.IntervalDataStructure.CumulativeIntervalArray;
                % Now save the structure
                
    eval(['save ' filepath ' Intervals'])
    

%*************************************************************************
    case 5         % User Interface Save the cumulative Interval structure information
    set(handles.DataOperation,'Value',0)        % reset the toggle to 0
    Intervals.AllTracesCellArrayDescription=handles.IntervalDataStructure.OneTraceCellDescription;
    Intervals.AllTracesCellArray=handles.IntervalDataStructure.AllTracesCellArray;
    Intervals.CumulativeIntervalArrayDescription=handles.IntervalDataStructure.IntervalArrayDescription;
    Intervals.CumulativeIntervalArray=handles.IntervalDataStructure.CumulativeIntervalArray;
    handles.IntervalDataStructure.AllSpots=FreeAllSpotsMemory(parenthandles.AllSpots);
    Intervals.AllSpots=handles.IntervalDataStructure.AllSpots;
                                                % Open a dialog box for user
    [fn fp]=uiputfile('*.*','Save the CumulativeIntervalArray and AllTracesCellArray');
    eval( ['save ' [fp fn] ' Intervals' ] );                    % Save the Intervals structure
    set(handles.AOIList,'String',[fp fn])
    guidata(gcbo,handles)

 %*****************************************************************8   
    case 6         % get the frame range for Detrending InputTrace
    set(handles.DataOperation,'Value',0)        % change the toggle to 0
    PTCA{1,15}=[];                       % discard past frame range

    axes(handles.axes3);
    flag=0; 

    while flag==0
        [a b but]=ginput(2);                % user defines frame range by mouse clicking
        if (but(1) ==3) | (but(2)==3)                  % get x1 x2 pairs until right button hit 
            flag=1;
        else
            PTCA{1,15}=[PTCA{1,15};sort(round([a(1) a(2)]))];        % append xlow xhigh to DetrendFrameRange
            [m n]=size(PTCA{1,15});
            set(handles.AveRange,'String',num2str( reshape(PTCA{1,15}',1,m*n) ));
        end
    end
    handles.IntervalDataStructure.PresentTraceCellArray=PTCA;    %update the IntervalDataStructure
    guidata(gcbo,handles); 
    set(handles.ButtonChoice,'Value',7);                         % Advance to next task

%*************************************************************************
    case 7         % Detrend the Input Trace
    set(handles.DataOperation,'Value',0)        % change the toggle to 0
    InputTrace=PTCA{1,11};
    DetrendFrameRange=PTCA{1,15};
    %sprintf('before')
    dat=RemoveBaseDrift(InputTrace,DetrendFrameRange);
    %sprintf('after')
    PTCA{1,12}=dat.DetrendedInputTrace;
    DetrendedInputTrace=PTCA{1,12};
    figure(25);plot(DetrendedInputTrace(:,1),DetrendedInputTrace(:,2),'r');
    axes(handles.axes3)
    plot(DetrendedInputTrace(:,1),DetrendedInputTrace(:,2),'r');
    
    
    handles.IntervalDataStructure.PresentTraceCellArray=PTCA;    %update the IntervalDataStructure
    guidata(gcbo,handles); 
    set(handles.ButtonChoice,'Value',8);
        % Check for manual limits on the bottom axis
    if (get(handles.AxisScale,'Value')) ==0
    figure(25);axis auto
    axes(handles.axes3);axis auto
    else
    figure(25);axis(eval(get(handles.BottomAxisLimits,'String')))
    axes(handles.axes3);axis(eval(get(handles.BottomAxisLimits,'String')))
    end


%************************************************************************
    
    case 8         % get the frame range for mean/std
    set(handles.DataOperation,'Value',0)        % change the toggle to 0
    PTCA{1,7}=[];                       % discard past frame range

    axes(handles.axes3);
    flag=0; 

    while flag==0
    [a b but]=ginput(2);                % user defines frame range by mouse clicking
    if (but(1) ==3) | (but(2)==3)                  % get x1 x2 pairs until right button hit 
        flag=1;
    else
        PTCA{1,7}=[PTCA{1,7};sort(round([a(1) a(2)]))];        % append xlow xhigh to MeanStdFrameRange
        [m n]=size(PTCA{1,7});
       set(handles.AveRange,'String',num2str( reshape(PTCA{1,7}',1,m*n) ));
    end
    end
    
   
        % get a [frames (int intensity] list of just those frames specified, 
        % using the detrended trace PTCA{1,12} rather than the unmodified
        % InputTrace = PTCA{1,11};
    sublist_onedat=DataExtract(PTCA,PTCA{1,7},12);
        % Do the same, this time using the uncorrected input trace
    sublist_rawdat=DataExtract(PTCA,PTCA{1,7},11); 
    PTCA{1,5}=[mean(sublist_onedat(:,2))];       % [ (mean of low part of detrended trace)]
    PTCA{1,16}=[mean(sublist_rawdat(:,2))];  % [(mean of low part of raw trace)]
   
    PTCA{1,6}=std(sublist_onedat(:,2));
    set(handles.AveValue,'String',num2str([PTCA{1,5} PTCA{1,16}]));  % Print both detrended and uncorrected trace means
    set(handles.StdDev,'String',num2str(PTCA{1,6}));
    handles.IntervalDataStructure.PresentTraceCellArray=PTCA;    %update the IntervalDataStructure
    guidata(gcbo,handles); 
    set(handles.ButtonChoice,'Value',10);

% *********************************************
    case 9         % get the frame range for Interval detection
    set(handles.DataOperation,'Value',0)        % change the toggle to 0
    PTCA{1,8}=[];                       % discard past frame range
  % Grab the current Up and Down thresholds from their editable text fields
    PTCA{1,3}=str2num( get(handles.UpThreshold,'String') );
    PTCA{1,4}=str2num( get(handles.DownThreshold,'String') );
    axes(handles.axes3);
    flag=0; 

    while flag==0
    [a b but]=ginput(2);                % user defines frame range by mouse clicking
    if (but(1) ==3)|but(2)==3                        % get x1 x2 pairs until right button hit 
        flag=1;
    else
        PTCA{1,8}=[PTCA{1,8};sort(round([a(1) a(2)]))];        % append xlow xhigh to MeanStdFrameRange
        [m n]=size(PTCA{1,8});
       set(handles.IntervalDataFrameRange,'String',['[' num2str( reshape(PTCA{1,8}',1,m*n) ) ' ]']);
       flag=1;                          % Limits user to one frame interval range;  Just remove
                        % this flag=1 statement to allow user to select
                        % multiple intervals in which events will be
                        % detected
    end
    end

    %Now use the defined frame ranges to detect the high/low intervals

    InputTrace=PTCA{1,12};    % DetrendedInputTrace used here
    MultipleFrameIntervals=PTCA{1,8};
    UpThreshold=PTCA{1,5}+PTCA{1,6}*PTCA{1,3}; DownThreshold=PTCA{1,5}+PTCA{1,6}*PTCA{1,4};
    MinUpFrames=1;MinDownFrames=1;
 
    dat=Find_Landings_MultipleFrameIntervals(InputTrace,MultipleFrameIntervals,UpThreshold,DownThreshold,MinUpFrames,MinDownFrames);
       tb=PTCA{1,9};                         %Time base array
      % BinaryInputTrace= [(low/high=0 or 1) InputTrace(:,1) InputTrace(:,2)]
      % where InputTrace here includes only sections searched for events
    PTCA{1,13}=dat.BinaryInputTrace;

    if isempty(tb)
        sprintf('User must input time base file prior to building IntervalData array')
    else
            % add the deltaTime value to the 5th column to the IntervalData array
%IntervalArrayDescription=['(low or high =0 or 1) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#'];
  
        %PTCA{1,10}=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3)+1)-tb(dat.IntervalData(:,2)) dat.IntervalData(:,5)-PTCA{1,5}];

        % Next get the average intensity of the detrended
                        % trace for each event
      
        [IDrose IDcol]=size(dat.IntervalData);
        %InputTrace=PTCA{1,12};          % Detrended trace used here (same definition from above)
        RawInputTrace=PTCA{1,11};          % Uncorrected input trace used here 
        aveint=[];
     
        for IDindx=1:IDrose
          
            startframe=dat.IntervalData(IDindx,2);
            rawstartframe=find(RawInputTrace(:,1)==startframe);
            
            endframe=dat.IntervalData(IDindx,3);
            rawendframe=find(RawInputTrace(:,1)==endframe);
            
            aveint=[aveint;sum(RawInputTrace(rawstartframe:rawendframe,2))/(rawendframe-rawstartframe+1)-PTCA{1,16}];   % subtract mean off uncorrected trace to get pulse height
        end
                             %   ************  Correct problem with one frame events right at gap in the aquisition sequence (between Glimpse boxes) 
        
        %PTCA_1_10_dum=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3)+1)-tb(dat.IntervalData(:,2)) aveint  PTCA{1,2}*ones(IDrose,1)];
            % Next expression takes care of incidents where events occur at edge or across boundaries where Glimpse
            % goes off to take other images (multiple Glimpse boxes)% Altered at lines 1515 1616 1881 3141 and in EditBinaryTrace.m
        medianOneFrame=median(diff(tb));    % median value of one frame duration
        PTCA{1,10}=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3))-tb(dat.IntervalData(:,2))+medianOneFrame aveint  PTCA{1,2}*ones(IDrose,1)];     
        %logikal=dat.IntervalData(:,3)==dat.IntervalData(:,2);       % Single frame duration: need this in case one frame events begins
                                                            % just before Glimpse sequence goes off to take other image (can
                                                          % artificially lengthen the event length
        %PTCA_1_10_dum(logikal,5)=medianOneFrame;
        %PTCA{1,10}=PTCA_1_10_dum;                       %  Same form as cia array
                               %   ****************    
       % PTCA{1,10}=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3)+1)-tb(dat.IntervalData(:,2)) aveint PTCA{1,2}*ones(IDrose,1)];
               % Altered at lines 1515 1616 1881 3141
        
        handles.IntervalDataStructure.PresentTraceCellArray=PTCA;   %update the IntervalDataStructure
        guidata(gcbo,handles);
     
                % at this point we have the entire trace plotted:  Replot
                % using just the BinaryInputTrace so that only the relevant
                % trace region is being plotted
        axes(handles.axes3)
        hold off
        plot(dat.BinaryInputTrace(:,2),dat.BinaryInputTrace(:,3),'r');hold on
        figure(25);hold off;plot(dat.BinaryInputTrace(:,2),dat.BinaryInputTrace(:,3),'r');hold on
                % Overlay the binary information showing interval detection
                % onto the axes3 plot and figure(25)
        OverlayBinaryPlot(PTCA,handles.axes3,25);
                % Display the current trace interval histogram for high=1 states
        BinNumber=str2num(get(handles.BinNumber,'String'));
      
        HistogramIntervalData(handles.IntervalDataStructure.PresentTraceCellArray{1,10},handles.axes2,1,BinNumber);
                % Display the cumulative interval histogram for high=1 states
             
        if isempty(handles.IntervalDataStructure.CumulativeIntervalArray)
            sprintf('Cumulative Interval Array is empty')
        else
        
            HistogramIntervalData(handles.IntervalDataStructure.CumulativeIntervalArray,handles.axes1,1,BinNumber);
        end
    end
            % Check for manual limits on the bottom axis
   if (get(handles.AxisScale,'Value')) ==0
    figure(25);axis auto
    axes(handles.axes3);axis auto
   else
    figure(25);axis(eval(get(handles.BottomAxisLimits,'String')))
    axes(handles.axes3);axis(eval(get(handles.BottomAxisLimits,'String')))
   end

%***********************************************************************
    case 10         % Find intervals again WITHOUT redefining frame range (see #7)
    set(handles.DataOperation,'Value',0)        % change the toggle to 0
    
  % Grab the current Up and Down thresholds from their editable text fields
    PTCA{1,3}=str2num( get(handles.UpThreshold,'String') );
    PTCA{1,4}=str2num( get(handles.DownThreshold,'String') );
    axes(handles.axes3);
    %Now use the defined frame ranges to detect the high/low intervals

    InputTrace=PTCA{1,12};    % DetrendedInputTrace used here
    MultipleFrameIntervals=PTCA{1,8};
    UpThreshold=PTCA{1,5}+PTCA{1,6}*PTCA{1,3}; DownThreshold=PTCA{1,5}+PTCA{1,6}*PTCA{1,4};
    MinUpFrames=1;MinDownFrames=1;
 
    dat=Find_Landings_MultipleFrameIntervals(InputTrace,MultipleFrameIntervals,UpThreshold,DownThreshold,MinUpFrames,MinDownFrames);
       tb=PTCA{1,9};                         %Time base array
        % BinaryInputTrace= [(low/high=0 or 1) InputTrace(:,1) InputTrace(:,2)]
        % where InputTrace here includes only sections searched for events
        %Also mark the first interval 0s or 1s with -2 or -3 respectively,
        %and the ending interval 0s or 1s with +2 or +3 respectivley
    PTCA{1,13}=dat.BinaryInputTrace;

    if isempty(tb)
        sprintf('User must input time base file prior to building IntervalData array')
    else
            % add the deltaTime value to the 5th column to the IntervalData
            % array, and subtract mean from event height
%IntervalArrayDescription=['(low or high =0 or 1) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#'];
  
        %PTCA{1,10}=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3)+1)-tb(dat.IntervalData(:,2)) dat.IntervalData(:,5)-PTCA{1,5}];
                        
                        % Next get the average intensity of the detrended
                        % trace for each event (for column 6 of IntervalData)
                        % And AOI number (for column 7)
        
        [IDrose IDcol]=size(dat.IntervalData);
        %InputTrace=PTCA{1,12};          % Detrended trace used here (same definition from above)
        RawInputTrace=PTCA{1,11};          % Uncorrected input trace used here 
        aveint=[];
        for IDindx=1:IDrose
           
            
             startframe=dat.IntervalData(IDindx,2);
            rawstartframe=find(RawInputTrace(:,1)==startframe);
            
            endframe=dat.IntervalData(IDindx,3);
            rawendframe=find(RawInputTrace(:,1)==endframe);
                                % Use ave of raw input trace w/ mean
                                % subtracted off
          
            aveint=[aveint;sum(RawInputTrace(rawstartframe:rawendframe,2))/(rawendframe-rawstartframe+1)-PTCA{1,16}];   % Subtract mean off the uncorrected trace to get pulse height
            
        end
                            %   ************  Correct problem with one frame events right at gap in the aquisition sequence (between Glimpse boxes) 
        %medianOneFrame=median(diff(tb));    % median value of one frame duration
        %PTCA_1_10_dum=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3)+1)-tb(dat.IntervalData(:,2)) aveint  PTCA{1,2}*ones(IDrose,1)];
      
        %logikal=dat.IntervalData(:,3)==dat.IntervalData(:,2);       % Single frame duration: need this in case one frame events begins
                                                            % just before Glimpse sequence goes off to take other image (can
                                                          % artificially lengthen the event length
        %PTCA_1_10_dum(logikal,5)=medianOneFrame;
        %PTCA{1,10}=PTCA_1_10_dum;                       %  Same form as cia array
 
        % Next expression takes care of incidents where events occur at edge or across boundaries where Glimpse
            % goes off to take other images (multiple Glimpse boxes)% Altered at lines 1515 1616 1881 3141 and in EditBinaryTrace.m
        medianOneFrame=median(diff(tb));    % median value of one frame duration
        PTCA{1,10}=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3))-tb(dat.IntervalData(:,2))+medianOneFrame aveint  PTCA{1,2}*ones(IDrose,1)];  
                               %   ****************      
        %PTCA{1,10}=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3)+1)-tb(dat.IntervalData(:,2)) aveint  PTCA{1,2}*ones(IDrose,1)];       
           % Altered at lines 1515 1616 1881 3141    
        handles.IntervalDataStructure.PresentTraceCellArray=PTCA;   %update the IntervalDataStructure
        guidata(gcbo,handles);
        axes(handles.axes3)
        hold off
        plot(dat.BinaryInputTrace(:,2),dat.BinaryInputTrace(:,3),'r');hold on
        figure(25);hold off;plot(dat.BinaryInputTrace(:,2),dat.BinaryInputTrace(:,3),'r');hold on
                % Overlay the binary information showing interval detection
                % onto the axes3 plot and figure(25)
        OverlayBinaryPlot(PTCA,handles.axes3,25);
                % Display the current trace interval histogram for high=1 states
        BinNumber=str2num(get(handles.BinNumber,'String'));
      
        HistogramIntervalData(handles.IntervalDataStructure.PresentTraceCellArray{1,10},handles.axes2,1,BinNumber);
                % Display the cumulative interval histogram for high=1 states
   
        if isempty(handles.IntervalDataStructure.CumulativeIntervalArray)
            sprintf('Cumulative Interval Array is empty')
        else
        
            HistogramIntervalData(handles.IntervalDataStructure.CumulativeIntervalArray,handles.axes1,1,BinNumber);
        end
    end
               % Check for manual limits on the bottom axis
   if (get(handles.AxisScale,'Value')) ==0
    figure(25);axis auto
    axes(handles.axes3);axis auto
   else
    figure(25);axis(eval(get(handles.BottomAxisLimits,'String')))
    axes(handles.axes3);axis(eval(get(handles.BottomAxisLimits,'String')))
   end
   
                       % Change X limits if toggle is depressed
if get(handles.CustomXLimitsBottomToggle,'Value')==1
                    % Toggle depressed: use x limits from matrix
    set(handles.axes3,'Xlim',[handles.XLimitsMatrixBottom(handles.RowXLimitsMatrixBottom,:)]);
else
      % auto scaling used above: store the auto scaled x axis limits
    handles.DefaultXLimitsBottom=get(handles.axes3,'Xlim');
end
guidata(gcbo,handles);  
    
set(handles.ButtonChoice,'Value',11);
    
%***********************************************************************
    case 11         % Display AOIs around a mouse click
    set(handles.DataOperation,'Value',0)
    axes(handles.axes3)
                                        % user clicks on trace near event
                                        % in question
    flag=0; 
    
    while flag==0
    [a b but]=ginput(1);                % user defines frame range by mouse clicking
    if (but ==3)                        % get x=frame until right button hit 
        flag=1;
    else
                                        % Here if user has selected frame
                                        % to display
        CenterFrame=round(a);   
                 % Grab the current values defining the limits of the AOI
                 % frames to display
                                        % Display center frame number selected  
        set(handles.EditMidAOINumber,'String',num2str(CenterFrame));
        
        AxisLimitsVector= eval(get(handles.AxisLimits,'String'));
        [roses cols]=size(AxisLimitsVector);
       
        FrameColumns=AxisLimitsVector(cols-1);
        FrameRows=AxisLimitsVector(cols);
        
        %FrameColumns=AxisLimitsVector(3);
        %FrameRows=AxisLimitsVector(4);
                % Center the AOI display frames about the location of the
                % mouse click
        FrameLow=CenterFrame-round( FrameColumns*FrameRows/2)+1;
        if FrameLow<1
            FrameLow=1;
        end
        
        FrameHigh=CenterFrame+round( FrameColumns*FrameRows/2)-1;
                                % Check upper limit if glimpse file
        if get(handles.ImageSourceFileType,'Value')==3
            MaximumFrames=handles.AOIgheader2.nframes;       % vid.nframes
            if FrameHigh>MaximumFrames                  % Check upper limit
                FrameHigh=MaximumFrames;
            end
        end
        
        AxisLimitsVector=[FrameLow FrameHigh AxisLimitsVector(cols-1:cols)];
                  % Replace the limits of the AOI frames to display
        set(handles.AxisLimits,'String',[ '[ ' num2str(AxisLimitsVector) ']'])
        guidata(gcbo,handles);
                % Then invoke the DisplayAOIs callback
               
        DisplayAOIs_Callback(handles.DisplayAOIs, eventdata, handles)
            
    end
    end
    

% **********************************************************************
    case 12         % Remove a high event from the BinaryInputTrace and IntervalArray

    set(handles.DataOperation,'Value',0)        % reset the toggle to 0
    flag=0;
    while flag==0
    [a b but]=ginput(1);                % User clicks on plot near to undesired event
    BinaryInputTrace=PTCA{1,13};
    IntervalArray=PTCA{1,10};
        if (but(1) ==3)                        % Will keep going until right button hit
            flag=1;
        else
            
                                        % Now alter the IntervalArray and
                                        % BinaryInputTrace by removing a
                                        % high event
            dat=Remove_Event_v1(IntervalArray,BinaryInputTrace,a,handles);
            PTCA{1,13}=dat.BinaryInputTrace;
            PTCA{1,10}=dat.IntervalArray;
            flag=1;                     % Remove this if you want to implement feature
                                        % where the user will keep removing
                                        % high events until right clicking
                                        % on the mouse.

        end
        
            % And replot the present trace
        axes(handles.axes3)
        hold off
        plot(BinaryInputTrace(:,2),BinaryInputTrace(:,3),'r');hold on
        figure(25);hold off;plot(BinaryInputTrace(:,2),BinaryInputTrace(:,3),'r');hold on
                 % And overlay the binary information
        OverlayBinaryPlot(PTCA,handles.axes3,25);
                % Display the current trace interval histogram for high=1 states
        BinNumber=str2num(get(handles.BinNumber,'String'));
      
        HistogramIntervalData(PTCA{1,10},handles.axes2,[1],BinNumber);
                % Display the cumulative interval histogram for high=1 states
   
        if isempty(handles.IntervalDataStructure.CumulativeIntervalArray)
            sprintf('Cumulative Interval Array is empty')
        else
        
            HistogramIntervalData(handles.IntervalDataStructure.CumulativeIntervalArray,handles.axes1,1,BinNumber);
        end
        
    end
    
    handles.IntervalDataStructure.PresentTraceCellArray=PTCA;   %update the IntervalDataStructure
    guidata(gcbo,handles);
           % Check for manual limits on the bottom axis
   if (get(handles.AxisScale,'Value')) ==0
    figure(25);axis auto
    axes(handles.axes3);axis auto
   else
    figure(25);axis(eval(get(handles.BottomAxisLimits,'String')))
    axes(handles.axes3);axis(eval(get(handles.BottomAxisLimits,'String')))
   end
   
                       % Change X limits if toggle is depressed
if get(handles.CustomXLimitsBottomToggle,'Value')==1
                    % Toggle depressed: use x limits from matrix
    set(handles.axes3,'Xlim',[handles.XLimitsMatrixBottom(handles.RowXLimitsMatrixBottom,:)]);
else
      % auto scaling used above: store the auto scaled x axis limits
    handles.DefaultXLimitsBottom=get(handles.axes3,'Xlim');
end
guidata(gcbo,handles);  
%***********************************************************************
    case 13        % Add the present trace array to the cumulative arrays
    set(handles.DataOperation,'Value',0)        % reset the toggle to 0
    ATCA=handles.IntervalDataStructure.AllTracesCellArray;
            % append the present trace cell array to the AllTraceCellArray
    [rose col]=size(ATCA); 
            if (rose==1) & isempty(ATCA{1,10})
                        % Here if this is the first nonempty entry to ATCA
                ATCA=PTCA;
            else
                ATCA=[ATCA;PTCA];
            end
            % Now put all the interval data together into one Nx5 array
    cumul=[];
    [rose col]=size(ATCA);
    for indx=1:rose
        cumul=[cumul;ATCA{indx,10}];
    end
      % Update the handles structure
    handles.IntervalDataStructure.AllTracesCellArray=ATCA;
    handles.IntervalDataStructure.CumulativeIntervalArray=cumul;
        % Now turn off the expand X axis  toggle
        set(handles.CustomXLimitsBottomToggle,'Value',0);
        CustomXLimitsBottomToggle_Callback(handles.CustomXLimitsBottomToggle, eventdata, handles)
    guidata(gcbo,handles);
    set(handles.ButtonChoice,'Value',6);
% **********************************************************************
    case 14         % Subtract off the Background
        set(handles.DataOperation,'Value',0)
        parenthandles.aoifits2.data(:,8)=parenthandles.aoifits2.data(:,8)-parenthandles.aoifits2.BackgroundData(:,8);
        guidata(handles.parenthandles_fig,parenthandles);
         set(handles.ButtonChoice,'Value',1); 
%  *********************************************************************
    case 15         % Use handles.AllSpots.AllSpotsCells picked spots to define landing intervals 
         radius=handles.SpotProximityRadius;           % Proximity of spot to AOI center
         radius_hys=str2num(get(handles.UpThreshold,'String'));
    Bin01Trace=AOISpotLanding(aoinumber,radius,parenthandles,aoifits.aoiinfo2,radius_hys);          % 1/0 binary trace of spot landings
                                                                   % w/in radius of the AOI center
    MultipleFrameIntervals=PTCA{1,8};
  
    dat=Find_Landings_MultipleFrameIntervals(Bin01Trace,MultipleFrameIntervals,0.5,0.5,1,1);
    
   % figure(24);plot(Bin01Trace(:,1),Bin01Trace(:,2),'b');           % Plot the binary trace
    
    %axes(handles.axes2);
    %plot(Bin01Trace(:,1),Bin01Trace(:,2),'b')
    
                        % Next section just from 'Find Intervals case 10 above
    tb=PTCA{1,9};                         %Time base array
        % BinaryInputTrace= [(low/high=0 or 1) InputTrace(:,1) InputTrace(:,2)]
        % where InputTrace here includes only sections searched for events
        %Also mark the first interval 0s or 1s with -2 or -3 respectively,
        %and the ending interval 0s or 1s with +2 or +3 respectivley
     PTCA{1,13}=dat.BinaryInputTrace;
     
    if isempty(tb)
        sprintf('User must input time base file prior to building IntervalData array')
    else
            % add the deltaTime value to the 5th column to the IntervalData
            % array, and subtract mean from event height
%IntervalArrayDescription=['(low or high =0 or 1) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#'];
  
        %PTCA{1,10}=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3)+1)-tb(dat.IntervalData(:,2)) dat.IntervalData(:,5)-PTCA{1,5}];
                        
                        % Next get the average intensity of the detrended
                        % trace for each event (for column 6 of IntervalData)
                        % And AOI number (for column 7)
        
        [IDrose IDcol]=size(dat.IntervalData);
        %InputTrace=PTCA{1,12};          % Detrended trace used here (same definition from above)
        RawInputTrace=PTCA{1,11};          % Uncorrected input trace used here 
        aveint=[];
        for IDindx=1:IDrose
           
            
             startframe=dat.IntervalData(IDindx,2);
            rawstartframe=find(RawInputTrace(:,1)==startframe);
            
            endframe=dat.IntervalData(IDindx,3);
            rawendframe=find(RawInputTrace(:,1)==endframe);
                                % Use ave of raw input trace w/ mean
                                % subtracted off
          
            aveint=[aveint;sum(RawInputTrace(rawstartframe:rawendframe,2))/(rawendframe-rawstartframe+1)-PTCA{1,16}];   % Subtract mean off the uncorrected trace to get pulse height
            
        end
                             %   ************  Correct problem with one frame events right at gap in the aquisition sequence (between Glimpse boxes) 
        %medianOneFrame=median(diff(tb));    % median value of one frame duration
        %PTCA_1_10_dum=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3)+1)-tb(dat.IntervalData(:,2)) aveint  PTCA{1,2}*ones(IDrose,1)];
      
        %logikal=dat.IntervalData(:,3)==dat.IntervalData(:,2);       % Single frame duration: need this in case one frame events begins
                                                            % just before Glimpse sequence goes off to take other image (can
                                                          % artificially lengthen the event length
        %PTCA_1_10_dum(logikal,5)=medianOneFrame;
        %PTCA{1,10}=PTCA_1_10_dum;                       %  Same form as cia array
        
        % Next expression takes care of incidents where events occur at edge or across boundaries where Glimpse
            % goes off to take other images (multiple Glimpse boxes)% Altered at lines 1515 1616 1881 3141 and in EditBinaryTrace.m
        medianOneFrame=median(diff(tb));    % median value of one frame duration
        PTCA{1,10}=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3))-tb(dat.IntervalData(:,2))+medianOneFrame aveint  PTCA{1,2}*ones(IDrose,1)];  
        
                               %   ****************     
        %PTCA{1,10}=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3)+1)-tb(dat.IntervalData(:,2)) aveint  PTCA{1,2}*ones(IDrose,1)];  
        % Altered at lines 1515 1616 1881 3141
       
        handles.IntervalDataStructure.PresentTraceCellArray=PTCA;   %update the IntervalDataStructure
        guidata(gcbo,handles);
        axes(handles.axes3)
        hold off
      
        plot(dat.BinaryInputTrace(:,2),dat.BinaryInputTrace(:,3),'r');hold on
        figure(25);hold off;plot(dat.BinaryInputTrace(:,2),dat.BinaryInputTrace(:,3),'r');hold on
                % Overlay the binary information showing interval detection
                % onto the axes3 plot and figure(25)
        OverlayBinaryPlot(PTCA,handles.axes3,25);
                % Display the current trace interval histogram for high=1 states
        BinNumber=str2num(get(handles.BinNumber,'String'));
      
        HistogramIntervalData(handles.IntervalDataStructure.PresentTraceCellArray{1,10},handles.axes2,1,BinNumber);
                % Display the cumulative interval histogram for high=1 states
   
        if isempty(handles.IntervalDataStructure.CumulativeIntervalArray)
            sprintf('Cumulative Interval Array is empty')
        else
        
            HistogramIntervalData(handles.IntervalDataStructure.CumulativeIntervalArray,handles.axes1,1,BinNumber);
        end
    end
               % Check for manual limits on the bottom axis
   if (get(handles.AxisScale,'Value')) ==0
    figure(25);axis auto
    axes(handles.axes3);axis auto
   else
    figure(25);axis(eval(get(handles.BottomAxisLimits,'String')))
    axes(handles.axes3);axis(eval(get(handles.BottomAxisLimits,'String')))
   end
   
                       % Change X limits if toggle is depressed
if get(handles.CustomXLimitsBottomToggle,'Value')==1
                    % Toggle depressed: use x limits from matrix
    set(handles.axes3,'Xlim',[handles.XLimitsMatrixBottom(handles.RowXLimitsMatrixBottom,:)]);
else
      % auto scaling used above: store the auto scaled x axis limits
    handles.DefaultXLimitsBottom=get(handles.axes3,'Xlim');
end
guidata(gcbo,handles);  
    
set(handles.ButtonChoice,'Value',11);

            % End of section copied from Find Intervals case 10
%  *********************************************************************
    case 16         % Load the IntervalsDataStructure2.  Will be used for displaying 
                    % binary traces from two Intervals files
                    % Just follow case 3 and import to a second Intervals
                    % structure (same as IntervalsDataStructure
                    
                    % First duplicate all the entries in the existing
                    % IntervalDataStructure, then replace the Intervals
                    % data by importing an Intervals file for the present
                    % number 2 structure we are creating
    handles.IntervalDataStructure2=handles.IntervalDataStructure;
    
    set(handles.DataOperation,'Value',0)        % reset the toggle to 0
                                                % Open a dialog box for user
    [fn fp]=uigetfile('*.*','Loading AllTracesCellArray number 2'); 
    eval( ['load ' [fp fn] ' -mat' ] );                    % Load the Intervals structure
                                     % (saved under ButtonChoice==4 or 5)
 
    handles.IntervalDataStructure2.AllTracesCellArray=Intervals.AllTracesCellArray;

    handles.IntervalDataStructure2.CumulativeIntervalArray=Intervals.CumulativeIntervalArray;
    if isfield(Intervals,'AllSpots');
        parenthandles.AllSpots=Intervals.AllSpots;
    end
                           
    guidata(gcbo,handles);                  % Update the handles structure 
    guidata(handles.parenthandles_fig,parenthandles);

%  **********************************************************************

end                         % End of the 'switch' options


function AOIList_Callback(hObject, eventdata, handles)
% hObject    handle to AOIList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AOIList as text
%        str2double(get(hObject,'String')) returns contents of AOIList as a double


% --- Executes during object creation, after setting all properties.
function AOIList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AOIList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function TextInputAoifits2_Callback(hObject, eventdata, handles)
% hObject    handle to TextInputAoifits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TextInputAoifits as text
%        str2double(get(hObject,'String')) returns contents of TextInputAoifits as a double


% --- Executes during object creation, after setting all properties.
function TextInputAoifits2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TextInputAoifits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in LoadAoifits2.
function LoadAoifits2_Callback(hObject, eventdata, handles)
% hObject    handle to LoadAoifits2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
                                      % Get the filename to load

 filestring=get(handles.TextInputAoifits2,'String');
                                      % load the file containing aoifits 

    %eval(['load p:\matlab12\larry\data\' filestring ' -mat'])
   

parenthandles = guidata(handles.parenthandles_fig);         % Get the handle structure of the parent gui
                                                            % Look at the
                                                            % if ishandle()
                                                            % section at
                                                            % top of this
                                                            % function.
                                        % load the file containing aoifigs
    eval(['load ' parenthandles.FileLocations.data '\' filestring ' -mat'])
                                      % get the aoifits variable
parenthandles.aoifits2=aoifits;
               % now update the variable 'parenthandles' of the top level
               % figure (the figure handle) handles.parenthandles_fig.  This
               % replaces the handles structure of the orginal figure with
               % our parenthandles structure in which we have altered the
               % aoifits variable.  See help  on guidata() function
    if isfield(aoifits,'AllSpots')
                            % if the aoifits structure contains the
                            % AllSpots information, place it also into the
                            % parenthandles structure (used for
                            % constructing binary trace in AOISpotLanding.m
        parenthandles.AllSpots=aoifits.AllSpots;
    end
                                    
guidata(handles.parenthandles_fig,parenthandles);
                % and updata the current handles structure of the
                % plotargout figure (gui)..
                % Update the aoifits filename in the Interval data cell array
%handles.IntervalDataStructure.PresentTraceCellArray{1,1}=['p:\matlab12\larry\data\' filestring ];
handles.IntervalDataStructure.PresentTraceCellArray{1,1}=[parenthandles.FileLocations.data '\' filestring ];

guidata(gcbo,handles);


% --- Executes on button press in LoadAoifits1.
function LoadAoifits1_Callback(hObject, eventdata, handles)
% hObject    handle to LoadAoifits1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 filestring=get(handles.TextInputAoifits1,'String');
                                      % load the file containing aoifits 

    %eval(['load p:\matlab12\larry\data\' filestring ' -mat'])
    

parenthandles = guidata(handles.parenthandles_fig);         % Get the handle structure of the parent gui
                                                            % Look at the
                                                            % if ishandle()
                                                            % section at
                                                            % top of this
                                                            % function.
                                        % load the file containing aoifits
     eval(['load ' parenthandles.FileLocations.data '\' filestring ' -mat'])
                                      % get the aoifits variable
parenthandles.aoifits1=aoifits;
               % now update the variable 'parenthandles' of the top level
               % figure (the figure handle) handles.parenthandles_fig.  This
               % replaces the handles structure of the orginal figure with
               % our parenthandles structure in which we have altered the
               % aoifits variable.  See help  on guidata() function
                                    
guidata(handles.parenthandles_fig,parenthandles);
                % and updata the current handles structure of the
                % plotargout figure (gui)..
guidata(gcbo,handles);


function TextInputAoifits1_Callback(hObject, eventdata, handles)
% hObject    handle to TextInputAoifits1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TextInputAoifits1 as text
%        str2double(get(hObject,'String')) returns contents of TextInputAoifits1 as a double


% --- Executes during object creation, after setting all properties.
function TextInputAoifits1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TextInputAoifits1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in LoadImageFile1.
function LoadImageFile1_Callback(hObject, eventdata, handles)
% hObject    handle to LoadImageFile1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.ImageSourceFileType,'Value')==1
    [fn fp]=uigetfile;                  % User selects *.tif file
    handles.AOITiffFile1=[fp fn];
    dum=uint32(imread(handles.AOITiffFile1, 'tif', 1));
    handles.AOIDumTiffFile1=dum-dum;             % zeroed array the same size as the images
    
elseif get(handles.ImageSourceFileType,'Value')==2
    sprintf('not yet implemented to use RAM images')
elseif get(handles.ImageSourceFileType,'Value')==3
    [fn fp]=uigetfile;                  % User selects header.mat file
                                        % in the Glimpse foler
    handles.AOIgfolder1=[fp];           % Glimpse folder
    eval(['load ' fp fn])               % header.mat fle in Glimpse folder
    handles.AOIgheader1=vid;            % structure with time information
                % grab one frame from the glimpse file
    dum=glimpse_image(handles.AOIgfolder1,vid,1);
    handles.AOIDumgfolder1=uint32(dum-dum); % zero the frame and store
end
                                        
guidata(gcbo,handles);


% --- Executes on button press in LoadImageFile2.
function LoadImageFile2_Callback(hObject, eventdata, handles)
% hObject    handle to LoadImageFile2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.ImageSourceFileType,'Value')==1
    [fn fp]=uigetfile;                  % User selects *.tif file
    handles.AOITiffFile2=[fp fn];
    dum=uint32(imread(handles.AOITiffFile2, 'tif', 1));
    handles.AOIDumTiffFile2=dum-dum;             % zeroed array the same size as the images
    
elseif get(handles.ImageSourceFileType,'Value')==2
    sprintf('not yet implemented to use RAM images')
elseif get(handles.ImageSourceFileType,'Value')==3
    [fn fp]=uigetfile;                  % User selects header.mat file
                                        % in the Glimpse foler
    handles.AOIgfolder2=[fp];           % Glimpse folder
    eval(['load ' fp fn])               % header.mat fle in Glimpse folder
    handles.AOIgheader2=vid;            % structure with time information
                % grab one frame from the glimpse file
    dum=glimpse_image(handles.AOIgfolder2,vid,1);
    handles.AOIDumgfolder2=uint32(dum-dum); % zero the frame and store
end
                                        
guidata(gcbo,handles);

% --- Executes on selection change in ImageSourceFileType.
function ImageSourceFileType_Callback(hObject, eventdata, handles)
% hObject    handle to ImageSourceFileType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ImageSourceFileType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImageSourceFileType


% --- Executes during object creation, after setting all properties.
function ImageSourceFileType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageSourceFileType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in DisplayAOIs.
function DisplayAOIs_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayAOIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


parenthandles = guidata(handles.parenthandles_fig);  % handle for imscroll gui
ImageSource1=get(handles.ImageSourceFileType,'Value'); % specifies the file/folder used for AOI images
aoifits1=parenthandles.aoifits1;           % aoifits currently displayed on middle plot
                                    % get the aoi number to be displayed
                                    % from the MiddleAOIPlot input text
aoinumber1=str2num(get(handles.MiddleAOIPlot,'String'));
logic=( aoifits1.data(:,1)==aoinumber1 );    % logical array picking out data from just the current aoi
onedata1=aoifits1.data(logic,:);      % Sub matrix with just the data from the current aoi
              %[aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi]
                % Get the [x y (aoi#)] coordinates of the current aoi,
               % using the original x y coordinates when the aoi was marked
                % ( aoi# needed for later to correct for drift)
%xy1=[round(onedata1(1,4:5)) onedata1(1,1)];
               % Pick out line from aoiinfo2 corresponding to current aoifits and current aoi 
aoilogic=aoifits1.aoiinfo2(:,6)==aoinumber1;
                %xy1=[x y (aoi#)] coordinates of the current aoi,
               % keyboard
xy1=[ aoifits1.aoiinfo2(aoilogic,3:4) aoinumber1]; 

                                % Get the frame limits to display from the
                                % manual settings for the axis limits
AxisLimitsVector= eval(get(handles.AxisLimits,'String'));
[roses cols]=size(AxisLimitsVector);

jumpVary_value=get(parenthandles.jumpVary,'UserData');
imagenum=get(parenthandles.ImageNumber,'value');       % Retrieve the value of the ImageNumber
                                                 % slider in the parent gui
imagenum= round(imagenum);
                               % When we have multiple FOVs (jumpVary ~=1)
                               % make sure we are displaying the aois from
                               % the FOV that the parent gui is presently
                               % viewing

                                               
startaoi=AxisLimitsVector(1)-rem(AxisLimitsVector(1)-imagenum,jumpVary_value);
if cols>4
    frms1=AxisLimitsVector(1:jumpVary_value:cols-2);
    AOInum=[AxisLimitsVector(cols-1) AxisLimitsVector(cols)];
else
    %frms1=AxisLimitsVector(1):jumpVary_value:AxisLimitsVector(2);
    frms1=startaoi:jumpVary_value:AxisLimitsVector(2);
    AOInum=[AxisLimitsVector(3) AxisLimitsVector(4)];                  % Temporary (input later)
end
                        % If the frame range is large, prompt the user to
                        % be certain you will not crash the program                        
if length(frms1)>300
    ques=input('This is a large frame range.  Are you sure (''y'' or ''n'')?','s');
    if ques ~='y'
        return
    end
end
                                % Get the AOI width for display from the
                                % current PixelNumber setting for AOIs in
                                % the imscroll gui
pixnum1=str2num(get(parenthandles.PixelNumber,'String'));

% Now do the same for the second set of AOIs
ImageSource2=ImageSource1;      % Both AOI sets will be from the same type source (for now)
aoifits2=parenthandles.aoifits2;
aoinumber2=str2num(get(handles.BottomAOIPlot,'String'));
logic=( aoifits2.data(:,1)==aoinumber2 );    % logical array picking out data from just the current aoi
onedata2=aoifits2.data(logic,:);      % Sub matrix with just the data from the current aoi
    % Get the [x y (aoi#)] coordinates of the current aoi
%xy2=[round(onedata2(1,4:5)) onedata2(1,1)];
               % Pick out line from aoiinfo2 corresponding to current aoifits and current aoi 
aoilogic=aoifits2.aoiinfo2(:,6)==aoinumber2;
                %xy1=[x y (aoi#)] coordinates of the current aoi,
xy2=[ aoifits2.aoiinfo2(aoilogic,3:4) aoinumber2]; 

                                % Get the frame limits to display from the
                                % manual settings for the axis limits
frms2=frms1;                    % Same frame range as 1 (for now)
pixnum2=pixnum1;

          % handles structure contains members:
          % handles. AOIgfolder1, AOIgheader1, AOIDumgfolder1
          %handles. AOIgfolder2, AOIgheader2, AOIDumgfolder2
          %handles. AOITiffFile1, AOIDumTiffFile1
          %handles. AOITiffFile2, AOIDumTiffFile2
          %handles. AOIRAM1, AOIDumRAM1
          %handles. AOIRAM2, AOIDumRAM2
   
  
   pc=SubImages_v1(ImageSource1,xy1,frms1,pixnum1,ImageSource2,xy2,frms2,pixnum2,AOInum,handles,parenthandles);

        % Get the display scale information from the manual scale setting 
        % in the imscroll gui
clowval=round(double(min(min(pc))));chival=round(double(max(max(pc))));     % Frame max and min values,
                               % same as auto values for scaling image
                                    % Now test whether to manually scale images
if get(parenthandles.ImageScale,'Value')==1          % =1 for manual scale
    clowval=round(get(parenthandles.MinIntensity,'Value'));  % set minimum display intensity
    chival=round(get(parenthandles.MaxIntensity,'Value'));   % set maximum display intensity
else
                                      % If auto scaling is on, label the
                                      % Maxscale and MinScale text
                                      % with the auto values
                                                
    set(parenthandles.MaxScale,'String',num2str(chival));
    set(parenthandles.MinScale,'String',num2str(clowval));
   
end
                                    % If radio button DisplayScales is
                                    % depressed, use sliders  in
                                    % plottargout to set display scales
if get(handles.DisplayScales,'Value')==1
    clowval=round(get(handles.SliceIndexSlider,'Value'));  % set minimum display intensity
    chival=round(get(handles.FitFrameNumberSlider,'Value'));   % set maximum display intensity
end
    
figure(26);subplot('position',[0 0 1 1]);imagesc(pc,[clowval chival]);axis('image');colormap(gray);axis('off');
axes(handles.axes1);                            % active figure is now the top plot in the gui
imagesc(pc,[clowval chival] );axis('equal');axis auto;colormap(gray);axis 'off';
[rose col]=size(handles.galleryxy1Centers);

        % Next, show the single large AOI
DisplayOneOut=DisplayOne(handles);
                                            % Draw the aoi boxes in the
                                            % gallery images

if get(handles.AOIboxes,'Value')==1
    FigureFlag=get(handles.FigureAOIBoxes,'Value');
    AOIBoxPixnumValue=str2num(get(handles.AOIBoxPixnum,'String'));
    for indxx=1:rose
        axes(handles.axes1);
        draw_box_v1(handles.galleryxy1Centers(indxx,:),AOIBoxPixnumValue/2,AOIBoxPixnumValue/2,'b')
        draw_box_v1(handles.galleryxy2Centers(indxx,:),AOIBoxPixnumValue/2,AOIBoxPixnumValue/2,'b')
        if FigureFlag==1                    % Possibly draw AOI boxes in the figure
            figure(26);hold on
            draw_box_v1(handles.galleryxy1Centers(indxx,:),AOIBoxPixnumValue/2,AOIBoxPixnumValue/2,'b')
            draw_box_v1(handles.galleryxy2Centers(indxx,:),AOIBoxPixnumValue/2,AOIBoxPixnumValue/2,'b')
            hold off
        end
    end
end



function IntervalDataFrameRange_Callback(hObject, eventdata, handles)
% hObject    handle to IntervalDataFrameRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IntervalDataFrameRange as text
%        str2double(get(hObject,'String')) returns contents of IntervalDataFrameRange as a double

PTCA=handles.IntervalDataStructure.PresentTraceCellArray;
PTCA{1,8}=eval( get(handles.IntervalDataFrameRange,'String') );
handles.IntervalDataStructure.PresentTraceCellArray=PTCA;
guidata(gcbo,handles)
% --- Executes during object creation, after setting all properties.
function IntervalDataFrameRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IntervalDataFrameRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function UpThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to UpThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of UpThreshold as text
%        str2double(get(hObject,'String')) returns contents of UpThreshold as a double
handles.IntervalDataStructure.PresentTraceCellArray{1,3}=str2num( get(handles.UpThreshold,'String') );
guidata(gcbo,handles);

% --- Executes during object creation, after setting all properties.
function UpThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UpThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function DownThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to DownThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DownThreshold as text
%        str2double(get(hObject,'String')) returns contents of DownThreshold as a double
handles.IntervalDataStructure.PresentTraceCellArray{1,4}=str2num( get(handles.DownThreshold,'String') );
guidata(gcbo,handles);

% --- Executes during object creation, after setting all properties.
function DownThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DownThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in CumulativeIntervalPopup.
function CumulativeIntervalPopup_Callback(hObject, eventdata, handles)
% hObject    handle to CumulativeIntervalPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns CumulativeIntervalPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        CumulativeIntervalPopup
PopupValue=get(handles.CumulativeIntervalPopup,'Value');
switch PopupValue
    case 1
                % Here to plot trace
        set(handles.DecreaseEditFrame,'Visible','off')      % Hide the Edit controls
        set(handles.IncreaseEditFrame,'Visible','off')
        set(handles.EditFrame,'Visible','off')
        set(handles.BinarySource,'Visible','off')
    case 2
                % Here to delete trace
        set(handles.CumulativeOperation,'Value',0)      % Turn off toggle (that allows user to run through traces)
        set(handles.CumulativeOperation,'BackgroundColor',[.938 .938 .938]);
        set(handles.DecreaseEditFrame,'Visible','off')      % Hide the Edit controls
        set(handles.IncreaseEditFrame,'Visible','off')
        set(handles.EditFrame,'Visible','off')
        set(handles.BinarySource,'Visible','off')
    case 3
                % Here for Edit mode, single point
        set(handles.CumulativeOperation,'Value',0)      % Turn off toggle (that allows user to run through traces)
        set(handles.CumulativeOperation,'BackgroundColor',[.938 .938 .938]);
        set(handles.DecreaseEditFrame,'Visible','on')   % Make the Edit controls visible
        set(handles.IncreaseEditFrame,'Visible','on')
        set(handles.EditFrame,'Visible','on')
        set(handles.BinarySource,'Visible','off')
    case 4
                    % Here for Edit mode, intervals
        set(handles.CumulativeOperation,'Value',0)      % Turn off toggle (that allows user to run through traces)
        set(handles.CumulativeOperation,'BackgroundColor',[.938 .938 .938]);
        set(handles.DecreaseEditFrame,'Visible','on')   % Make the Edit controls visible
        set(handles.IncreaseEditFrame,'Visible','on')
        set(handles.EditFrame,'Visible','on')
        set(handles.BinarySource,'Visible','off')
    case 5 
        set(handles.DecreaseEditFrame,'Visible','off')      % Hide the Edit controls
        set(handles.IncreaseEditFrame,'Visible','off')
        set(handles.EditFrame,'Visible','off')
        set(handles.BinarySource,'Visible','on')
end


% --- Executes during object creation, after setting all properties.
function CumulativeIntervalPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CumulativeIntervalPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in CumulativeOperation.
function CumulativeOperation_Callback(hObject, eventdata, handles)
% hObject    handle to CumulativeOperation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CumulativeOperation
if get(handles.CumulativeOperation,'Value')==1
    set(handles.CumulativeOperation,'BackgroundColor',[.746 .746 0]);
else
    set(handles.CumulativeOperation,'BackgroundColor',[.938 .938 .938]);
end
if get(handles.CumulativeOperation,'Value')==1
    
                % Plot the interval traces only if the toggle is depressed,
                % not when it is released
    parenthandles = guidata(handles.parenthandles_fig); 
                            % Get the cumulative cell array, ATCA
    ATCA=handles.IntervalDataStructure.AllTracesCellArray;
    [ATCArose ATCAcol]=size(ATCA);
                            % Alter display to reflect the number of traces
                            % stored in the ATCA
    set(handles.MaxAOIs,'String',ATCArose) ;
    TraceNumber=str2num(get(handles.MiddleAOIPlot,'String') );
    
    % Check that the number of the trace to display is between proper
    % limits
    if (1>TraceNumber) | (TraceNumber>ATCArose)
        TraceNumber=ATCArose;
    end
    handles.AllTracesDisplayNumber=TraceNumber;     % Keeps track of which trace is displayed (for editing purposes)
    guidata(gcbo,handles); 
    % Get the specified cell array from the ATCA cell array list
    ChosenCellArray=ATCA(TraceNumber,:);

   %[aoifitsFile AOINum UpThreshold DownThreshold  mean  std  MeanStdFrms DataFrms  TimeBase IntervalArray...
                    % InputTrace DetrendedInputTrace BinaryInputTrace BinaryInputtraceDescription DetrendFrameRange]



    if any( get(handles.CumulativeIntervalPopup,'Value')==[1 5] )        
                               % Plot a detrended trace from the AllTracesCellAray
                               % when popup is set to 'Plot' or to 
                               % 'Plot Cumul InputTrace 1/2'

                                                                  
        %set(handles.CumulativeOperation,'Value',0)        % reset the toggle to 0
                    % Plot the InputTrace and overlay the BinaryInputTrace
        DetrendedTrace=ChosenCellArray{1,12};
                    % Plot the Detrended Trace form the chosen cell array
        figure(24);hold off;plot(DetrendedTrace(:,1),DetrendedTrace(:,2),'r');
        axes(handles.axes2)
        hold off;plot(DetrendedTrace(:,1),DetrendedTrace(:,2),'r');
                    % and overlay the binary high/low data
        OverlayBinaryPlot(ChosenCellArray,handles.axes2,24);
    
                    % List the filename and aoi of the displayed trace
        mess=[ChosenCellArray{1,1} '  AOI:  ' num2str(ChosenCellArray{1,2})];
        lmess=length(mess);
        btm=max(1,lmess-33);        % Display the final 33 characters of 'mess'
        set(handles.AOIList,'String',mess(btm:lmess));
    
    
        handles.IntervalDataStructure.AllTracesCellArray=ATCA;    %update the IntervalDataStructure
        guidata(gcbo,handles);  
    end


%**************************************************************************
    if get(handles.CumulativeIntervalPopup,'Value')==2         % Delete the current cell array from AllTracesCellArray 
         set(handles.CumulativeOperation,'Value',0)        % reset the toggle to 0 and backgroun color to grey
         set(handles.CumulativeOperation,'BackgroundColor',[.938 .938 .938]);
            % Delete the current cell array from AllTracesCellArray
         ATCA(TraceNumber,:)=[];
            % Now update the CumulativeIntervalArray
         cumul=[];
         [rose col]=size(ATCA);
         for indx=1:rose
             cumul=[cumul;ATCA{indx,10}];
         end
      % Update the handles structure
         handles.IntervalDataStructure.AllTracesCellArray=ATCA;
         handles.IntervalDataStructure.CumulativeIntervalArray=cumul;
         handles.IntervalDataStructure.AllTracesCellArray=ATCA;    %update the IntervalDataStructure
         set(handles.CumulativeIntervalPopup,'Value',1);        % Reset the cumulative menu popup
         set(handles.CumulativeOperation,'Value',0);            % Release the toggle
          set(handles.CumulativeOperation,'BackgroundColor',[.938 .938 .938]);
         guidata(gcbo,handles);
    end
% *************************************************************************
   if get(handles.CumulativeIntervalPopup,'Value')==3
       set(handles.CumulativeOperation,'Value',0)        % reset the toggle to 0 and backgroun color to grey
       set(handles.CumulativeOperation,'BackgroundColor',[.938 .938 .938]);
       axes(handles.axes2)
       [frmnum xvalue]=ginput(1);               % User must mouse click on plot to specify a frame number
       frmnum=round(frmnum);
       set(handles.EditFrame,'String',num2str(frmnum)); % Alter the editable text region to reflect specified frame
   end
% *************************************************************************
   if get(handles.CumulativeIntervalPopup,'Value')==5
                            % Here to plot a second binary trace derived
                            % from the IntervalDataStructure2
                  % Plot the interval traces only if the toggle is depressed,
                % not when it is released
    parenthandles = guidata(handles.parenthandles_fig); 
                            % Get the cumulative cell array, ATCA
    ATCA2=handles.IntervalDataStructure2.AllTracesCellArray;
    [ATCArose2 ATCAcol2]=size(ATCA2);
                            % Alter display to reflect the number of traces
                            % stored in the ATCA
    set(handles.MaxAOIs,'String',ATCArose2) ;
                %********** Next line to take AOI number for second binary trace from the middle plot 
                % => both binary traces from same AOI number, but from different IntervalDataStructure 
    if get(handles.BinarySource,'Value')==0
        TraceNumber=str2num(get(handles.MiddleAOIPlot,'String') );

    else
               %**********  Next line to take AOI number for second binary trace from bottom plot
               % trace 1 gets AOI number from middle plot, trace 2 gets AOI number from bottom plot 
        TraceNumber=str2num(get(handles.BottomAOIPlot,'String') );
    end
                %******************
    
    % Check that the number of the trace to display is between proper
    % limits
    if (1>TraceNumber) | (TraceNumber>ATCArose2)
        TraceNumber=ATCArose2;
    end
    handles.AllTracesDisplayNumber=TraceNumber;     % Keeps track of which trace is displayed (for editing purposes)
    guidata(gcbo,handles); 
    % Get the specified cell array from the ATCA cell array list
    ChosenCellArray2=ATCA2(TraceNumber,:);

   %[aoifitsFile AOINum UpThreshold DownThreshold  mean  std  MeanStdFrms DataFrms  TimeBase IntervalArray...
                    % InputTrace DetrendedInputTrace BinaryInputTrace BinaryInputtraceDescription DetrendFrameRange]



    if any( get(handles.CumulativeIntervalPopup,'Value')==[5] )        % Plot a SECOND detrended trace from the AllTracesCellAray
                                                                  % when popup set to Plot Cumul InputTrace 1/2
        %set(handles.CumulativeOperation,'Value',0)        % reset the toggle to 0
                    % Plot the InputTrace and overlay the BinaryInputTrace
        DetrendedTrace2=ChosenCellArray2{1,12};
                    % Do Not re-Plot the Detrended Trace form the chosen
                    % cell array:  comment out next line
        %** figure(24);hold off;plot(DetrendedTrace(:,1),DetrendedTrace(:,2),'r');
        axes(handles.axes2)
                % Do not re-plot detrended trace: comment out next line
        %** hold off;plot(DetrendedTrace(:,1),DetrendedTrace(:,2),'r');
                    % and overlay the binary high/low data
                    
        OverlayBinaryPlot(ChosenCellArray2,handles.axes2,24,'r');
    
                    % List the filename and aoi of the displayed trace
        %**mess=[ChosenCellArray{1,1} '  AOI:  ' num2str(ChosenCellArray{1,2})];
        %**lmess=length(mess);
        %**btm=max(1,lmess-33);        % Display the final 33 characters of 'mess'
        %**set(handles.AOIList,'String',mess(btm:lmess));
    
    
        handles.IntervalDataStructure2.AllTracesCellArray=ATCA2;    %update the IntervalDataStructure
        guidata(gcbo,handles);  
    end
   
   end
end


% --- Executes on button press in IncreaseMiddleAOIPlot.
function IncreaseMiddleAOIPlot_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to IncreaseMiddleAOIPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%images=varargin{1};dum=varargin{2};folder=varargin{3};
aoinumber=str2num(get(handles.MiddleAOIPlot,'String'));
aoinumber=aoinumber+1;
set(handles.MiddleAOIPlot,'String',num2str(aoinumber));
if get(handles.CumulativeOperation,'Value')==1
                % If the CumulativeOperation toggle is depressed, then we
                % will jump to that callback and plot the binary plots 
                % from the Interval structure
    CumulativeOperation_Callback(handles.CumulativeOperation, eventdata, handles)
else
                % else,  we are just plotting the integrated traces
    if get(handles.MiddleAOIPlotToggle,'Value')==1
    %DisplayMiddle_Callback(handles.DisplayBottom, eventdata, handles, images,dum,folder)
        DisplayMiddle_Callback(handles.DisplayBottom, eventdata, handles)
    end
end


% --- Executes on button press in DecreaseMiddleAOIPlot.
function DecreaseMiddleAOIPlot_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to DecreaseMiddleAOIPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%images=varargin{1};dum=varargin{2};folder=varargin{3};
aoinumber=str2num(get(handles.MiddleAOIPlot,'String'));
aoinumber=aoinumber-1;
if aoinumber<1
    aoinumber=1;
end
set(handles.MiddleAOIPlot,'String',num2str(aoinumber));
if get(handles.CumulativeOperation,'Value')==1
                % If the CumulativeOperation toggle is depressed, then we
                % will jump to that callback and plot the binary plots 
                % from the Interval structure
    CumulativeOperation_Callback(handles.CumulativeOperation, eventdata, handles)
else
    if get(handles.MiddleAOIPlotToggle,'Value')==1
    %DisplayMiddle_Callback(handles.DisplayBottom, eventdata, handles, images,dum,folder)
        DisplayMiddle_Callback(handles.DisplayBottom, eventdata, handles)
    end
end


% --- Executes on button press in MiddleAOIPlotToggle.
function MiddleAOIPlotToggle_Callback(hObject, eventdata, handles)
% hObject    handle to MiddleAOIPlotToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MiddleAOIPlotToggle


% --- Executes on button press in IncreaseBottomAOIPlot.
function IncreaseBottomAOIPlot_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to IncreaseBottomAOIPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%images=varargin{1};dum=varargin{2};folder=varargin{3};
aoinumber=str2num(get(handles.BottomAOIPlot,'String'));
aoinumber=aoinumber+1;
set(handles.BottomAOIPlot,'String',num2str(aoinumber));
if get(handles.BottomAOIPlotToggle,'Value')==1
    %DisplayBottom_Callback(handles.DisplayBottom, eventdata, handles, images,dum,folder)
    DisplayBottom_Callback(handles.DisplayBottom, eventdata, handles)
end


% --- Executes on button press in DecreaseBottomAOIPlot.
function DecreaseBottomAOIPlot_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to DecreaseBottomAOIPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%images=varargin{1};dum=varargin{2};folder=varargin{3};
aoinumber=str2num(get(handles.BottomAOIPlot,'String'));
aoinumber=aoinumber-1;
if aoinumber<1
    aoinumber=1;
end
set(handles.BottomAOIPlot,'String',num2str(aoinumber));
if get(handles.BottomAOIPlotToggle,'Value')==1
    %DisplayBottom_Callback(handles.DisplayBottom, eventdata, handles, images,dum,folder)
    DisplayBottom_Callback(handles.DisplayBottom, eventdata, handles)
end


% --- Executes on button press in BottomAOIPlotToggle.
function BottomAOIPlotToggle_Callback(hObject, eventdata, handles)
% hObject    handle to BottomAOIPlotToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BottomAOIPlotToggle


% --- Executes on button press in AOIboxes.
function AOIboxes_Callback(hObject, eventdata, handles)
% hObject    handle to AOIboxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AOIboxes

DisplayAOIs_Callback(handles.DisplayAOIs, eventdata, handles)



function AOIBoxPixnum_Callback(hObject, eventdata, handles)
% hObject    handle to AOIBoxPixnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AOIBoxPixnum as text
%        str2double(get(hObject,'String')) returns contents of AOIBoxPixnum as a double


% --- Executes during object creation, after setting all properties.
function AOIBoxPixnum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AOIBoxPixnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in FigureAOIBoxes.
function FigureAOIBoxes_Callback(hObject, eventdata, handles)
% hObject    handle to FigureAOIBoxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FigureAOIBoxes


% --- Executes on button press in DisplayScales.
function DisplayScales_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayScales (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DisplayScales
if get(handles.DisplayScales,'Value')==1
                % Activate sliders as display scales
    if get(handles.FitFrameNumberSlider,'Max')<1000
                        % Here if the max and min have not previously been
                        % set
        set(handles.FitFrameNumberSlider,'Max',1000)
        set(handles.FitFrameNumberSlider,'Min',1)
        set(handles.FitFrameNumberSlider,'Value',1000)
        set(handles.FitFrameNumber,'String','1000')
        set(handles.SliceIndexSlider,'Max',1000)
        set(handles.SliceIndexSlider,'Min',1)
        set(handles.SliceIndexSlider,'Value',1)
        set(handles.SliceIndexNumber,'String','1')
    end
end
        
        



function BottomAxisLimits_Callback(hObject, eventdata, handles)
% hObject    handle to BottomAxisLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BottomAxisLimits as text
%        str2double(get(hObject,'String')) returns contents of BottomAxisLimits as a double


% --- Executes during object creation, after setting all properties.
function BottomAxisLimits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BottomAxisLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KeyboardButton.
function KeyboardButton_Callback(hObject, eventdata, handles)
% hObject    handle to KeyboardButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parenthandles = guidata(handles.parenthandles_fig);
keyboard



function EditSpotProximityRadius_Callback(hObject, eventdata, handles)
% hObject    handle to EditSpotProximityRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSpotProximityRadius as text
%        str2double(get(hObject,'String')) returns contents of EditSpotProximityRadius as a double
handles.SpotProximityRadius=str2num(get(handles.EditSpotProximityRadius,'String'));
handles.SpotProximityRadius=round(handles.SpotProximityRadius*10)/10;   % Only express in 0.1 increments
set(handles.EditSpotProximityRadius,'String',num2str(handles.SpotProximityRadius));
DisplayMiddle_Callback(handles.DisplayMiddle, eventdata, handles)
guidata(gcbo,handles)



% --- Executes during object creation, after setting all properties.
function EditSpotProximityRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSpotProximityRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in IncrementSpotProximityRadius.
function IncrementSpotProximityRadius_Callback(hObject, eventdata, handles)
% hObject    handle to IncrementSpotProximityRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.SpotProximityRadius=handles.SpotProximityRadius+0.1;            % Increment by 0.1 pixels
handles.SpotProximityRadius=round(handles.SpotProximityRadius*10)/10;   % Only express in 0.1 increments
set(handles.EditSpotProximityRadius,'String',num2str(handles.SpotProximityRadius))
DisplayMiddle_Callback(handles.DisplayMiddle, eventdata, handles)       % Plot the Binary Spot Trace
guidata(gcbo,handles)


% --- Executes on button press in DecrementSpotProximityRadius.
function DecrementSpotProximityRadius_Callback(hObject, eventdata, handles)
% hObject    handle to DecrementSpotProximityRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.SpotProximityRadius=handles.SpotProximityRadius-0.1;            % Increment by 0.1 pixels
handles.SpotProximityRadius=round(handles.SpotProximityRadius*10)/10;   % Only express in 0.1 increments
set(handles.EditSpotProximityRadius,'String',num2str(handles.SpotProximityRadius))
DisplayMiddle_Callback(handles.DisplayMiddle, eventdata, handles)       % Plot the Binary Spot Trace
guidata(gcbo,handles)


% --- Executes on scroll wheel click while the figure is in focus.
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
                % Change the pull down menu in respose to the scroll
ButtonChoiceValue=get(handles.ButtonChoice,'Value')+1;
if ButtonChoiceValue>14     % Wrap the value of the ButtonChoiceValue
    ButtonChoiceValue=1;
elseif ButtonChoiceValue<1
    ButtonChoiceValue=14;
end
%keyboard

set(handles.ButtonChoice,'Value',ButtonChoiceValue);
guidata(gcbo,handles)


% --- Executes on button press in ClickandDisplay.
function ClickandDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to ClickandDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.ButtonChoice,'Value',11)    % Set ButtonChoice to 
                                        % 'Click and Display AOIs'
guidata(gcbo,handles);
DataOperation_Callback(handles.DataOperation, eventdata, handles)



function TextXLimitsMatrixBottom_Callback(hObject, eventdata, handles)
% hObject    handle to TextXLimitsMatrixBottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TextXLimitsMatrixBottom as text
%        str2double(get(hObject,'String')) returns contents of TextXLimitsMatrixBottom as a double


% --- Executes during object creation, after setting all properties.
function TextXLimitsMatrixBottom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TextXLimitsMatrixBottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DecrementRowXLimitsMatrixBottom.
function DecrementRowXLimitsMatrixBottom_Callback(hObject, eventdata, handles)
% hObject    handle to DecrementRowXLimitsMatrixBottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
            % Grab current matrix of x limits
handles.XLimitsMatrixBottom=eval(get(handles.TextXLimitsMatrixBottom,'String'));
[rose col]=size(handles.XLimitsMatrixBottom);
            % If toggle depressed, check for limits; if limits ok then rescale x axis 
if (handles.RowXLimitsMatrixBottom>1)& (get(handles.CustomXLimitsBottomToggle,'Value')==1)
    handles.RowXLimitsMatrixBottom=handles.RowXLimitsMatrixBottom-1;
    set(handles.axes3,'Xlim',[handles.XLimitsMatrixBottom(handles.RowXLimitsMatrixBottom,:)]);
    set(handles.axes2,'Xlim',[handles.XLimitsMatrixBottom(handles.RowXLimitsMatrixBottom,:)]);
end
guidata(gcbo,handles)
% --- Executes on button press in IncrementRowXLimitsMatrixBottom.
function IncrementRowXLimitsMatrixBottom_Callback(hObject, eventdata, handles)
% hObject    handle to IncrementRowXLimitsMatrixBottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.XLimitsMatrixBottom=eval(get(handles.TextXLimitsMatrixBottom,'String'));
[rose col]=size(handles.XLimitsMatrixBottom);
            
%if (handles.RowXLimitsMatrixBottom<rose)& (get(handles.CustomXLimitsBottomToggle,'Value')==1)
                % If toggle depressedthen rescale x axis 
if (get(handles.CustomXLimitsBottomToggle,'Value')==1)
    handles.RowXLimitsMatrixBottom=handles.RowXLimitsMatrixBottom+1;
    if (handles.RowXLimitsMatrixBottom>rose)
                % If beyond end of limit list, wrap back to first entry
        handles.RowXLimitsMatrixBottom=1;
    end
    set(handles.axes3,'Xlim',[handles.XLimitsMatrixBottom(handles.RowXLimitsMatrixBottom,:)]);
    set(handles.axes2,'Xlim',[handles.XLimitsMatrixBottom(handles.RowXLimitsMatrixBottom,:)]);
end
guidata(gcbo,handles)

% --- Executes on button press in CustomXLimitsBottomToggle.
function CustomXLimitsBottomToggle_Callback(hObject, eventdata, handles)
% hObject    handle to CustomXLimitsBottomToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CustomXLimitsBottomToggle

if get(handles.CustomXLimitsBottomToggle,'Value')==1
    handles.DefaultXLimitsBottom=get(handles.axes3,'Xlim');     % Store present x limits of axis
   
    handles.RowXLimitsMatrixBottom=1;          % Begin by looking at left of plot
    set(handles.CustomXLimitsBottomToggle,'String','on')
                                 % Rescale X axis 
    set(handles.axes3,'Xlim',[handles.XLimitsMatrixBottom(handles.RowXLimitsMatrixBottom,:)]);
    set(handles.axes2,'Xlim',[handles.XLimitsMatrixBottom(handles.RowXLimitsMatrixBottom,:)]);
else
            % Toggled to off position
    set(handles.CustomXLimitsBottomToggle,'String','off')
            % Reset axis to prior value
    set(handles.axes3,'Xlim',[handles.DefaultXLimitsBottom]);
    set(handles.axes2,'Xlim',[handles.DefaultXLimitsBottom]);
end
guidata(gcbo,handles);


% --- Executes on button press in SpotIntervals.
function SpotIntervals_Callback(hObject, eventdata, handles)
% hObject    handle to SpotIntervals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % Copy top of the 'DataOperation' callback to set some variables
    
    % Use the aoifits1 to define the list of AOIs that we will process (find all landings near them)
    % Use the aoifits2 to provide a single example of the frame range and time base for processing
    % User should then load the full set of AOIS into aoifits1, and a single integrated trace into aoifits2 
parenthandles = guidata(handles.parenthandles_fig);        
aoifits=parenthandles.aoifits2;                 % Now have the current aoifits2 structure
             % Get the aoinumber (saved when plotting in DisplayBottom)
%****aoinumber=handles.IntervalDataStructure.PresentTraceCellArray{1,2};
%****log1=aoifits.data(:,1)==aoinumber;              % Get sub aoifits for this 
%****onedat=aoifits.data(log1,:);                    % one aoi = onedat
 % [aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi]
%PTCA{1,11}=[onedat(:,2) onedat(:,8)];           % This is the InputTrace in which we
                        % want to detect events (and is plotted on axes3)

   %[aoifitsFile AOINum UpThreshold DownThreshold  mean  std  MeanStdFrms DataFrms  TimeBase IntervalArray...
                    % InputTrace DetrendedInputTrace BinaryInputTrace BinaryInputtraceDescription DetrendFrameRange]

PTCA=handles.IntervalDataStructure.PresentTraceCellArray;

%aoiinfo2=aoifits.aoiinfo2;      % Will be whatever is currently loaded into plotargout
aoiinfo2=parenthandles.aoifits1.aoiinfo2;      % Will be whatever is currently loaded into plotargout aoifits1
                    %  '[(framenumber when marked) ave x y pixnum aoinumber]'
aoivector=aoiinfo2(:,6);    % Vector of aoi numbers
[aoirose aoicol]=size(aoivector);       
                                % First clear the exiting IntervalDataStructure
                                % (retain the .PresentTraceCellArray so we
                                % can keep the mean and std of one trace)

handles.IntervalDataStructure.AllTracesCellArray=cell(1,16);     % Cumulative data from all traces
handles.IntervalDataStructure.CumulativeIntervalArray=[];        % Just the interval list from all traces
                    % Cycle through all the aois listed in aoifits1

for aoiindx=1:max(aoirose,aoicol)
 

    aoinumber=aoivector(aoiindx);   % Current AOI  
    %log1=aoifits.data(:,1)==aoinumber;
    %onedat=aoifits.data(log1,:);
    % [aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi] 
   
    %PTCA{1,11}=[onedat(:,2) onedat(:,8)];   % Place current Input Trace into PTCA
    %PTCA{1,12}=[PTCA{1,11}(:,1) PTCA{1,11}(:,2)-min( PTCA{1,11}(:,2) )];     % Place Input Trace also into DetrendedTrace entry of PTCA
                                                      % Note that we subract off and bring baseline close to zero   
  
    %*****copy from Data Operation case 15 above to process one aoi
         radius=handles.SpotProximityRadius;           % Proximity of spot to AOI center 
         radius_hys=str2num(get(handles.UpThreshold,'String'));
         
    Bin01Trace=AOISpotLanding(aoinumber,radius,parenthandles,parenthandles.aoifits1.aoiinfo2,radius_hys);          % 1/0 binary trace of spot landings
   
                                      % w/in radius of the AOI center.  Uses the FrameRange from AllSpots.FrameRange itself   
                                                                     
    MultipleFrameIntervals=PTCA{1,8};   % Use the DataFrameRange [N x 2] from the PTCA 
               % Take binary trace and find all the intervals in it
                                                      %0.5=upThresh  0.5=downThresh  1=minUP  1=minDown
    dat=Find_Landings_MultipleFrameIntervals(Bin01Trace,MultipleFrameIntervals,0.5,0.5,1,1);
  
   % figure(24);plot(Bin01Trace(:,1),Bin01Trace(:,2),'b');           % Plot the binary trace
    
    %axes(handles.axes2);
    %plot(Bin01Trace(:,1),Bin01Trace(:,2),'b')
    
                        % Next section just from 'Find Intervals case 10 above
    tb=PTCA{1,9};                         %Time base array
        % BinaryInputTrace= [(low/high=0 or 1) InputTrace(:,1) InputTrace(:,2)]
        % where InputTrace here includes only sections searched for events
        %Also mark the first interval 0s or 1s with -2 or -3 respectively,
        %and the ending interval 0s or 1s with +2 or +3 respectivley
     PTCA{1,2}=aoinumber;               % Place aoinumber into proper cell array entry
     PTCA{1,13}=dat.BinaryInputTrace;   % [(-2,-3,0,1,2,3)  frm#  0,1]
                        % Place binary trace into input trace, b/c a raw integrated input trace MAY not by present 
     PTCA{1,11}=[PTCA{1,13}(:,2) PTCA{1,13}(:,3)]; 
     PTCA{1,12}=[PTCA{1,11}(:,1) PTCA{1,11}(:,2)-min( PTCA{1,11}(:,2) )];     % Place Input Trace also into DetrendedTrace entry of PTCA
                                       % Note that we subtract off and bring baseline close to zero 
 
    if isempty(tb)
        sprintf('User must input time base file prior to building IntervalData array')
    else
            % add the deltaTime value to the 5th column to the IntervalData
            % array, and subtract mean from event height
%IntervalArrayDescription=['(low or high =0 or 1) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#'];
  
        %PTCA{1,10}=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3)+1)-tb(dat.IntervalData(:,2)) dat.IntervalData(:,5)-PTCA{1,5}];
                        
                        % Next get the average intensity of the detrended
                        % trace for each event (for column 6 of IntervalData)
                        % And AOI number (for column 7)
        
        [IDrose IDcol]=size(dat.IntervalData);
        %InputTrace=PTCA{1,12};          % Detrended trace used here (same definition from above)
       
        RawInputTrace=PTCA{1,11};          % Uncorrected input trace used here 
        aveint=[];
       
       
        for IDindx=1:IDrose
          
        
             startframe=dat.IntervalData(IDindx,2);
            rawstartframe=find(RawInputTrace(:,1)==startframe);
            
            endframe=dat.IntervalData(IDindx,3);
            rawendframe=find(RawInputTrace(:,1)==endframe);
                                % Use ave of raw input trace w/ mean
                                % subtracted off
          
            aveint=[aveint;sum(RawInputTrace(rawstartframe:rawendframe,2))/(rawendframe-rawstartframe+1)-PTCA{1,16}];   % Subtract mean off the uncorrected trace to get pulse height
            
        end
                               %   ************  Correct problem with one frame events right at gap in the aquisition sequence (between Glimpse boxes) 
        %medianOneFrame=median(diff(tb));    % median value of one frame duration
        %PTCA_1_10_dum=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3)+1)-tb(dat.IntervalData(:,2)) aveint  PTCA{1,2}*ones(IDrose,1)];
      
        %logikal=dat.IntervalData(:,3)==dat.IntervalData(:,2);       % Single frame duration: need this in case one frame events begins
                                                            % just before Glimpse sequence goes off to take other image (can
                                                          % artificially lengthen the event length
        %PTCA_1_10_dum(logikal,5)=medianOneFrame;
        %PTCA{1,10}=PTCA_1_10_dum;                       %  Same form as cia array
        
        % Next expression takes care of incidents where events occur at edge or across boundaries where Glimpse
            % goes off to take other images (multiple Glimpse boxes)% Altered at lines 1515 1616 1881 3141 and in EditBinaryTrace.m  
        medianOneFrame=median(diff(tb));    % median value of one frame duration
        PTCA{1,10}=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3))-tb(dat.IntervalData(:,2))+medianOneFrame aveint  PTCA{1,2}*ones(IDrose,1)];  
                               %   ****************
        % PTCA{1,10}=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3)+1)-tb(dat.IntervalData(:,2)) aveint  PTCA{1,2}*ones(IDrose,1)];  
                % Altered at lines 1515 1616 1881 3141
        handles.IntervalDataStructure.PresentTraceCellArray=PTCA;   %update the IntervalDataStructure
        guidata(gcbo,handles);
        axes(handles.axes3)
        hold off
     
        plot(dat.BinaryInputTrace(:,2),dat.BinaryInputTrace(:,3),'r');hold on
        figure(25);hold off;plot(dat.BinaryInputTrace(:,2),dat.BinaryInputTrace(:,3),'r');hold on
                % Overlay the binary information showing interval detection
                % onto the axes3 plot and figure(25)
        OverlayBinaryPlot(PTCA,handles.axes3,25);
                % Display the current trace interval histogram for high=1 states
        BinNumber=str2num(get(handles.BinNumber,'String'));
      
        HistogramIntervalData(handles.IntervalDataStructure.PresentTraceCellArray{1,10},handles.axes2,1,BinNumber);
                % Display the cumulative interval histogram for high=1 states
   
        if isempty(handles.IntervalDataStructure.CumulativeIntervalArray)
            sprintf('Cumulative Interval Array is empty')
        else
        
            HistogramIntervalData(handles.IntervalDataStructure.CumulativeIntervalArray,handles.axes1,1,BinNumber);
        end
    end
               % Check for manual limits on the bottom axis
   if (get(handles.AxisScale,'Value')) ==0
    figure(25);axis auto
    axes(handles.axes3);axis auto
   else
    figure(25);axis(eval(get(handles.BottomAxisLimits,'String')))
    axes(handles.axes3);axis(eval(get(handles.BottomAxisLimits,'String')))
   end
  
                       % Change X limits if toggle is depressed
    if get(handles.CustomXLimitsBottomToggle,'Value')==1
                    % Toggle depressed: use x limits from matrix
        set(handles.axes3,'Xlim',[handles.XLimitsMatrixBottom(handles.RowXLimitsMatrixBottom,:)]);
   else
      % auto scaling used above: store the auto scaled x axis limits
        handles.DefaultXLimitsBottom=get(handles.axes3,'Xlim');
   end
   guidata(gcbo,handles);  
    
   %****set(handles.ButtonChoice,'Value',11);
            % ***End of copy from DataOperation case 15 (find intervals for one AOI)  
 
            % ***Now copy from Data Operation case 13 (add trace to Interval Data Structure)  
     set(handles.DataOperation,'Value',0)        % reset the toggle to 0
    ATCA=handles.IntervalDataStructure.AllTracesCellArray;
            % append the present trace cell array to the AllTraceCellArray
    [rose col]=size(ATCA); 
            if (rose==1) & isempty(ATCA{1,10})
                        % Here if this is the first nonempty entry to ATCA
                ATCA=PTCA;
            else
                ATCA=[ATCA;PTCA];
            end
    
            % Now put all the interval data together into one Nx5 array
    cumul=[];
    [rose col]=size(ATCA);
  
    for indx=1:rose
        cumul=[cumul;ATCA{indx,10}];
    end
    
      % Update the handles structure
    handles.IntervalDataStructure.AllTracesCellArray=ATCA;
    handles.IntervalDataStructure.CumulativeIntervalArray=cumul;
        % Now turn off the expand X axis  toggle
        set(handles.CustomXLimitsBottomToggle,'Value',0);
        CustomXLimitsBottomToggle_Callback(handles.CustomXLimitsBottomToggle, eventdata, handles)
    guidata(gcbo,handles);
    set(handles.ButtonChoice,'Value',6);
   
    aoiindx
        % *****End of copy from Data Operation case 13 (Add trace to Interval Data Structure)

end             % End of cycling through the AOIs
                % Add the AllSpots structure (for saving) used for finding intervals 
                % AllSpots structure defined in imscroll gui
handles.IntervalDataStructure.AllSpots=FreeAllSpotsMemory(parenthandles.AllSpots);
                % Add the proximity radius used in computing the intervals to the
                % AllSpots structure (so it will be there when saved)
handles.IntervalDataStructure.AllSpots.ProximityRadius=handles.SpotProximityRadius;
  
guidata(gcbo,handles);


% --- Executes on button press in IncreaseEditFrame.
function IncreaseEditFrame_Callback(hObject, eventdata, handles)
% hObject    handle to IncreaseEditFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

                    % Change the binary trace frame number specified by the EditFrame
                    % text to 1, increment the frame number displayed in
                    % EditFrame, recompute the intervals based on the new
                    % high (->1) event and update the AllTracesCellArray
handles.IntervalDataStructure.AllTracesCellArray=EditBinaryTrace(+1,handles);
ATCA=handles.IntervalDataStructure.AllTracesCellArray;
TraceNum=handles.AllTracesDisplayNumber;     % row index of the ATCA being edited

                    % At this point the ATCA has been altered and updated
                    % to reflect the editing 
                    % Next, update the CIA==CumulativeIntervalArray
cumul=[];
[rose col]=size(ATCA);
for indx=1:rose
    cumul=[cumul;ATCA{indx,10}];
end
      % Update the handles structure
handles.IntervalDataStructure.AllTracesCellArray=ATCA;
handles.IntervalDataStructure.CumulativeIntervalArray=cumul;
guidata(gcbo,handles);
                    % Next plot the edited trace+binary trace
axes(handles.axes2)
hold off
                    % re-plot the traces
plot(ATCA{TraceNum,12}(:,1),ATCA{TraceNum,12}(:,2),'r');
        % Add 4/9/2013 to retain expanded axis
if get(handles.CustomXLimitsBottomToggle,'Value')==1
                    % Toggle depressed: use x limits from matrix
    set(handles.axes2,'Xlim',[handles.XLimitsMatrixBottom(handles.RowXLimitsMatrixBottom,:)]);
end

hold on
figure(24);
hold off
plot(ATCA{TraceNum,12}(:,1),ATCA{TraceNum,12}(:,2),'r');
hold on
%keyboard
OverlayBinaryPlot(ATCA(TraceNum,:),handles.axes2,24);
        % Add 4/9/2013 to retain expanded axis
if get(handles.CustomXLimitsBottomToggle,'Value')==1
                    % Toggle depressed: use x limits from matrix
    set(handles.axes2,'Xlim',[handles.XLimitsMatrixBottom(handles.RowXLimitsMatrixBottom,:)]);
end

            
% --- Executes on button press in DecreaseEditFrame.
function DecreaseEditFrame_Callback(hObject, eventdata, handles)
% hObject    handle to DecreaseEditFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
                   % Change the binary trace frame number specified by the EditFrame
                    % text to 0, increment the frame number displayed in
                    % EditFrame, recompute the intervals based on the new
                    % low (->0) event and update the AllTracesCellArray
handles.IntervalDataStructure.AllTracesCellArray=EditBinaryTrace(-1,handles);
ATCA=handles.IntervalDataStructure.AllTracesCellArray;
TraceNum=handles.AllTracesDisplayNumber;     % row index of the ATCA being edited

                    % At this point the ATCA has been altered and updated
                    % to reflect the editing 
                    % Next, update the CIA==CumulativeIntervalArray
cumul=[];
[rose col]=size(ATCA);
for indx=1:rose
    cumul=[cumul;ATCA{indx,10}];
end
      % Update the handles structure
handles.IntervalDataStructure.AllTracesCellArray=ATCA;
handles.IntervalDataStructure.CumulativeIntervalArray=cumul;
guidata(gcbo,handles);
                    % Next plot the edited trace+binary trace
axes(handles.axes2)
hold off
                    % re-plot the traces
plot(ATCA{TraceNum,12}(:,1),ATCA{TraceNum,12}(:,2),'r');
        % Add 4/9/2013 to retain expanded axis
if get(handles.CustomXLimitsBottomToggle,'Value')==1
                    % Toggle depressed: use x limits from matrix
    set(handles.axes2,'Xlim',[handles.XLimitsMatrixBottom(handles.RowXLimitsMatrixBottom,:)]);
end
hold on
figure(24);
hold off
plot(ATCA{TraceNum,12}(:,1),ATCA{TraceNum,12}(:,2),'r');
hold on
%keyboard
OverlayBinaryPlot(ATCA(TraceNum,:),handles.axes2,24);





function EditFrame_Callback(hObject, eventdata, handles)
% hObject    handle to EditFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditFrame as text
%        str2double(get(hObject,'String')) returns contents of EditFrame as a double


% --- Executes during object creation, after setting all properties.
function EditFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditMidAOINumber_Callback(hObject, eventdata, handles)
% hObject    handle to EditMidAOINumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditMidAOINumber as text
%        str2double(get(hObject,'String')) returns contents of EditMidAOINumber as a double


% --- Executes during object creation, after setting all properties.
function EditMidAOINumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditMidAOINumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in IncreaseMidAOINumber.
function IncreaseMidAOINumber_Callback(hObject, eventdata, handles)
% hObject    handle to IncreaseMidAOINumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
                        % Fetch present MidAOINumber
MidAOINumber=round(str2num(get(handles.EditMidAOINumber,'String')));
                    
MidAOINumber=round(MidAOINumber+1);     % Increment and redisplay
set(handles.EditMidAOINumber,'String',num2str(MidAOINumber));
                        % Now display the new AOI image

DisplayOne(handles);


% --- Executes on button press in DecreaseMidAOINumber.
function DecreaseMidAOINumber_Callback(hObject, eventdata, handles)
% hObject    handle to DecreaseMidAOINumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
                        % Fetch present MidAOINumber
MidAOINumber=round(str2num(get(handles.EditMidAOINumber,'String')));
if MidAOINumber>1                    
MidAOINumber=round(MidAOINumber-1);     % Derease if >1
end
set(handles.EditMidAOINumber,'String',num2str(MidAOINumber));
                        % Now display the new AOI image

DisplayOne(handles);



function ViewMag_Callback(hObject, eventdata, handles)
% hObject    handle to ViewMag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ViewMag as text
%        str2double(get(hObject,'String')) returns contents of ViewMag as a double


% --- Executes during object creation, after setting all properties.
function ViewMag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ViewMag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in IncreaseViewMag.
function IncreaseViewMag_Callback(hObject, eventdata, handles)
% hObject    handle to IncreaseViewMag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        % Changes the magnification of the display for a single AOI
ViewMagNum=round(str2num(get(handles.ViewMag,'String')));
ViewMagNum=round(min(ViewMagNum+1,30));            % Maximum expansion is 30 times
set(handles.ViewMag,'String',num2str(ViewMagNum));
DisplayOne(handles);                % re-Display the aoi region
% --- Executes on button press in DecreaseViewMag.
function DecreaseViewMag_Callback(hObject, eventdata, handles)
% hObject    handle to DecreaseViewMag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Changes the magnification of the display for a single AOI
ViewMagNum=round(str2num(get(handles.ViewMag,'String')));
ViewMagNum=round(max(ViewMagNum-1,1));            % Maximum expansion is 30 times
set(handles.ViewMag,'String',num2str(ViewMagNum));
DisplayOne(handles);            % re-display the aoi region


% --- Executes on button press in OneAOIBox.
function OneAOIBox_Callback(hObject, eventdata, handles)
% hObject    handle to OneAOIBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OneAOIBox
if get(handles.OneAOIBox,'Value')==1
                        % Here if toggle on to draw aoi box
    set(handles.OneAOIBox,'BackgroundColor',[0 0 1])    % set color
    set(handles.OneAOIBox,'ForegroundColor',[.99 .99 0])    % lettering yellow
else
    set(handles.OneAOIBox,'BackgroundColor',[0.941 0.941 0.941]);
    set(handles.OneAOIBox,'ForegroundColor',[0 0 0])    % lettering black
end
DisplayOne(handles);    % Redisplay the AOI


% --- Executes on button press in DisplayOne12.
function DisplayOne12_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayOne12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DisplayOne12
            % Toggle button indicating which AOI (middle plot or bottom
            % plot) is displayed in the small single aoi image
if get(handles.DisplayOne12,'Value')==0
    set(handles.DisplayOne12,'String','2')
else
    set(handles.DisplayOne12,'String','1')
end
DisplayOne(handles)    % Redisplay the AOI


% --- Executes on button press in GaussianIntervals.
function GaussianIntervals_Callback(hObject, eventdata, handles)
% hObject    handle to GaussianIntervals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   
parenthandles = guidata(handles.parenthandles_fig);        



PTCA=handles.IntervalDataStructure.PresentTraceCellArray;


aoiinfo2=parenthandles.aoifits2.aoiinfo2;      % Will be whatever is currently loaded into plotargout aoifits2
                    %  '[(framenumber when marked) ave x y pixnum aoinumber]'
aoivector=aoiinfo2(:,6);    % Vector of aoi numbers
[aoirose aoicol]=size(aoivector);       
                                % First clear the exiting IntervalDataStructure
                                % (retain the .PresentTraceCellArray so we
                                % can keep the mean and std of one trace)

handles.IntervalDataStructure.AllTracesCellArray=cell(1,16);     % Cumulative data from all traces
handles.IntervalDataStructure.CumulativeIntervalArray=[];        % Just the interval list from all traces
                    % Cycle through all the aois listed in aoifits1
                                      % Get the Gaussian threshold amplitude from 
                                      % the editable text on the popup region  
GaussAmp=str2num(get(handles.GaussianAmplitude,'String'));
                                  % Get a radius hysterisis factor from the UpThreshold:   
radius_hys=str2num(get(handles.UpThreshold,'String'));
                                % Get an amplitude hysterisis factor from the Down Threshold 
amp_hys=str2num(get(handles.DownThreshold,'String'));                  
                            % See Bin01TraceGaussian( ) function
for aoiindx=1:max(aoirose,aoicol)
 

    aoinumber=aoivector(aoiindx);   % Current AOI  
    
    radius=handles.SpotProximityRadius;           % Proximity of spot to AOI center
    logik=parenthandles.aoifits2.data(:,1)==aoinumber;
    current_data=parenthandles.aoifits2.data(logik,:);      % Pulls out just the data for the curren AOI being processed
                                                           % It is in the form of aoifits.data 
    Bin01Trace=Bin01TraceGaussian(parenthandles, current_data, radius, GaussAmp, parenthandles.aoifits2.aoiinfo2, aoinumber, radius_hys, amp_hys);
             % =[frames    1/0]  1/0 binary trace of spot landings
             % w/in radius of the AOI center.  Uses the FrameRange from AllSpots.FrameRange itself   
                                                                 
    MultipleFrameIntervals=PTCA{1,8};   % Use the DataFrameRange [N x 2] from the PTCA 
               % Take binary trace and find all the intervals in it
                                                      %0.5=upThresh  0.5=downThresh  1=minUP  1=minDown
    dat=Find_Landings_MultipleFrameIntervals(Bin01Trace,MultipleFrameIntervals,0.5,0.5,1,1);
  
   
    
                        % Next section just from 'Find Intervals case 10 above
    tb=PTCA{1,9};                         %Time base array
        % BinaryInputTrace= [(low/high=0 or 1) InputTrace(:,1) InputTrace(:,2)]
        % where InputTrace here includes only sections searched for events
        %Also mark the first interval 0s or 1s with -2 or -3 respectively,
        %and the ending interval 0s or 1s with +2 or +3 respectivley
     PTCA{1,2}=aoinumber;               % Put proper aoi number into structure
     PTCA{1,13}=dat.BinaryInputTrace;   % [(-2,-3,0,1,2,3)  frm#  0,1]
                        % Place gaussian amplitude into the input trace,
                        % and the detrended trace
%     PTCA{1,11}=[PTCA{1,13}(:,2) PTCA{1,13}(:,3)]; 

     PTCA{1,11}= [current_data(:,2) current_data(:,3)];
     PTCA{1,12}=PTCA{1,11};
%     PTCA{1,12}=[PTCA{1,11}(:,1) PTCA{1,11}(:,2)-min( PTCA{1,11}(:,2) )];     
 
    if isempty(tb)
        sprintf('User must input time base file prior to building IntervalData array')
    else

%IntervalArrayDescription=['(low or high =0 or 1) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#'];
  
                        
                        % Next get the average intensity of the detrended
                        % trace for each event (for column 6 of IntervalData)
                        % And AOI number (for column 7)
        
        [IDrose IDcol]=size(dat.IntervalData);
        RawInputTrace=PTCA{1,11};          % Uncorrected input trace used here
                                           % (same as detrended trace in this instance) 
        aveint=[];
      
        
        for IDindx=1:IDrose
          
        
             startframe=dat.IntervalData(IDindx,2);
            rawstartframe=find(RawInputTrace(:,1)==startframe);
            
            endframe=dat.IntervalData(IDindx,3);
            rawendframe=find(RawInputTrace(:,1)==endframe);
                                % Use ave of raw input trace w/ mean
                                % subtracted off
          
            aveint=[aveint;sum(RawInputTrace(rawstartframe:rawendframe,2))/(rawendframe-rawstartframe+1)-PTCA{1,16}];   % Subtract mean off the uncorrected trace to get pulse height
            
        end
    
        PTCA{1,10}=[dat.IntervalData(:,1:4) tb(dat.IntervalData(:,3)+1)-tb(dat.IntervalData(:,2)) aveint  PTCA{1,2}*ones(IDrose,1)];       
       
        handles.IntervalDataStructure.PresentTraceCellArray=PTCA;   %update the IntervalDataStructure
        guidata(gcbo,handles);
        axes(handles.axes3)
        hold off
     
        plot(dat.BinaryInputTrace(:,2),dat.BinaryInputTrace(:,3),'r');hold on
        figure(25);hold off;plot(dat.BinaryInputTrace(:,2),dat.BinaryInputTrace(:,3),'r');hold on
                % Overlay the binary information showing interval detection
                % onto the axes3 plot and figure(25)
                  
                    
        OverlayBinaryPlot(PTCA,handles.axes3,25);
    
                % Display the current trace interval histogram for high=1 states
        BinNumber=str2num(get(handles.BinNumber,'String'));
     
        HistogramIntervalData(handles.IntervalDataStructure.PresentTraceCellArray{1,10},handles.axes2,1,BinNumber);
                % Display the cumulative interval histogram for high=1 states
   
        if isempty(handles.IntervalDataStructure.CumulativeIntervalArray)
            sprintf('Cumulative Interval Array is empty')
        else
        
            HistogramIntervalData(handles.IntervalDataStructure.CumulativeIntervalArray,handles.axes1,1,BinNumber);
        end
    end
   
               % Check for manual limits on the bottom axis
   if (get(handles.AxisScale,'Value')) ==0
    figure(25);axis auto
    axes(handles.axes3);axis auto
   else
    figure(25);axis(eval(get(handles.BottomAxisLimits,'String')))
    axes(handles.axes3);axis(eval(get(handles.BottomAxisLimits,'String')))
   end
  
                       % Change X limits if toggle is depressed
    if get(handles.CustomXLimitsBottomToggle,'Value')==1
                    % Toggle depressed: use x limits from matrix
        set(handles.axes3,'Xlim',[handles.XLimitsMatrixBottom(handles.RowXLimitsMatrixBottom,:)]);
   else
      % auto scaling used above: store the auto scaled x axis limits
        handles.DefaultXLimitsBottom=get(handles.axes3,'Xlim');
   end
   guidata(gcbo,handles);  
    
   %****set(handles.ButtonChoice,'Value',11);
            % ***End of copy from DataOperation case 15 (find intervals for one AOI)  
 
            % ***Now copy from Data Operation case 13 (add trace to Interval Data Structure)  
     set(handles.DataOperation,'Value',0)        % reset the toggle to 0
    ATCA=handles.IntervalDataStructure.AllTracesCellArray;
            % append the present trace cell array to the AllTraceCellArray
    [rose col]=size(ATCA); 
            if (rose==1) & isempty(ATCA{1,10})
                        % Here if this is the first nonempty entry to ATCA
                ATCA=PTCA;
            else
                ATCA=[ATCA;PTCA];
            end
    
            % Now put all the interval data together into one Nx5 array
    cumul=[];
    [rose col]=size(ATCA);
  
    for indx=1:rose
        cumul=[cumul;ATCA{indx,10}];
    end
    
      % Update the handles structure
    handles.IntervalDataStructure.AllTracesCellArray=ATCA;
    handles.IntervalDataStructure.CumulativeIntervalArray=cumul;
        % Now turn off the expand X axis  toggle
        set(handles.CustomXLimitsBottomToggle,'Value',0);
        CustomXLimitsBottomToggle_Callback(handles.CustomXLimitsBottomToggle, eventdata, handles)
    guidata(gcbo,handles);
    set(handles.ButtonChoice,'Value',6);
   
    aoiindx
        % *****End of copy from Data Operation case 13 (Add trace to Interval Data Structure)

end             % End of cycling through the AOIs
                % Add the AllSpots structure (for saving) used for finding intervals 
                % AllSpots structure defined in imscroll gui
handles.IntervalDataStructure.AllSpots=FreeAllSpotsMemory(parenthandles.AllSpots);
                % Add the proximity radius used in computing the intervals to the
                % AllSpots structure (so it will be there when saved)
handles.IntervalDataStructure.AllSpots.ProximityRadius=handles.SpotProximityRadius;

guidata(gcbo,handles);



function GaussianAmplitude_Callback(hObject, eventdata, handles)
% hObject    handle to GaussianAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GaussianAmplitude as text
%        str2double(get(hObject,'String')) returns contents of GaussianAmplitude as a double


% --- Executes during object creation, after setting all properties.
function GaussianAmplitude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GaussianAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BinarySource.
function BinarySource_Callback(hObject, eventdata, handles)
% hObject    handle to BinarySource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BinarySource
if get(handles.BinarySource,'Value')==0
        % Both binary traces from IntervalDataSource
    set(handles.BinarySource,'String','1/1')
else
        % Binary trace 1 from handles.IntervalDataSource
        % Binary trace 2 from handles.IntervalDataSource2
    set(handles.BinarySource,'String','1/2')
end


