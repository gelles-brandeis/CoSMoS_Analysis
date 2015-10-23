function varargout = imscroll(varargin)
% IMSCROLL Application M-file Gofor imscrollmou.fig
%    FIG = IMSCROLL launch imscroll GUI.
%    IMSCROLL('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 07-Oct-2015 10:05:31

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


if nargin <= 1  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
    if nargin==1
        
        foldstruc=varargin{1};              % structure containing image folder(s)
                                            % foldstruc.gfolder == glimse folder for image files
                                            % folstruc.folder == folder for the *.tiff stacked tiff image file
    end
        
        
    handles.FitData=[];                     % LF: adding a handle that will contain fit data array
                                            % [framenumber ave x y pixnum aoinumber];
    handles.aoifits1=[];                     % LF: adding a handle that will contain the aoifits structure
                                            %  (the same aoifits structure that we store as output)
    handles.aoifits2=[];
    handles.FitParameters=[];               % Adding handles that will store the fit for mapping fields from
                                            % images and images2
                                            %                    Fitparameters =[mx21 bx21
                                            %                                     my21 by21]
                                            %                          where     x2= mx21*x1 + bx21
                                            %                                    y2= my21*y1 + by21
    handles.FieldFrames=[];                 % Will contain a cell array (alphanumerics) that list the frames belonging to 
                              % to each field viewed in the sequence, e.g.
                              % handles.FieldFrames{1}= '5:5:200'
                              % handles.FieldFrames{2}= '6:5:200'  etc
                              % (notice the quotes ' ' )
    handles.CurrentFieldNumber=0;           % Initialize current field number viewed to zero
    handles.CurrentField=[1:100000];        % Initialize list of frames in current field to be every frame 
                                            % max frame number here is
                                            % 100000 (should be enough)

    if exist('foldstruc')                   % if foldstruc is defined, put its members into the handles structrue
        if isfield(foldstruc,'gfolder');
          
           handles.gfolder=foldstruc.gfolder;        % The path to the glimpse folder, (maybe) defined by user in command mode
           handles.gfolder1=foldstruc.gfolder;      % Storing gfolder as gfolder1 so we can switch between gfolders
           eval(['load ' foldstruc.gfolder 'header.mat'])     % loads the vid structure of the glimpse folder
           handles.gheader=vid;
           handles.gheader1=vid;
           handles.MaxFrames=vid.nframes;               % Get number of frames in the file from vid structure
           dum=uint32(glimpse_image(handles.gfolder,vid,1));
           handles.DumGfolder=dum-dum;             % zeroed array the same size as the images
           handles.DumGfolder1=dum-dum;
           handles.GlimpseMax=1;
           %handles.Dum=handles.DumGfolder;          % Will be used as replacement for 'dum' variable formerly 
                                            % picked up from command mode
           gname=handles.gfolder;
           lengthgname=length(gname);
           set(handles.GlimpseFolderName,'String',gname(lengthgname-14:lengthgname));
        
        end
        if isfield(foldstruc,'gfolder2');
           handles.gfolder2=foldstruc.gfolder2;        % The path to the second glimpse folder (for mapping, (maybe) defined by 
           eval(['load ' foldstruc.gfolder2 'header.mat'])  % user in command modeloads the vid structure of the glimpse folder
           handles.gheader2=vid;
           dum=uint32(glimpse_image(handles.gfolder2,vid,1));
           handles.DumGfolder2=dum-dum;             % zeroed array the same size as the images
           handles.GlimpseMax=2;
        
        end  
        if isfield(foldstruc,'gfolder3');
           handles.gfolder3=foldstruc.gfolder3;        % The path to the second glimpse folder (for mapping, (maybe) defined by 
           eval(['load ' foldstruc.gfolder3 'header.mat'])  % user in command modeloads the vid structure of the glimpse folder
           handles.gheader3=vid;
           dum=uint32(glimpse_image(handles.gfolder3,vid,1));
           handles.DumGfolder3=dum-dum;             % zeroed array the same size as the images
           handles.GlimpseMax=3;
        end
        if isfield(foldstruc,'gfolder4');
           handles.gfolder4=foldstruc.gfolder4;        % The path to the second glimpse folder (for mapping, (maybe) defined by 
           eval(['load ' foldstruc.gfolder4 'header.mat'])  % user in command modeloads the vid structure of the glimpse folder
           handles.gheader4=vid;
           dum=uint32(glimpse_image(handles.gfolder4,vid,1));
           handles.DumGfolder4=dum-dum;             % zeroed array the same size as the images
           handles.GlimpseMax=4;
        end
        if isfield(foldstruc,'gfolder5');
           handles.gfolder5=foldstruc.gfolder5;        % The path to the second glimpse folder (for mapping, (maybe) defined by 
           eval(['load ' foldstruc.gfolder5 'header.mat'])  % user in command modeloads the vid structure of the glimpse folder
           handles.gheader5=vid;
           dum=uint32(glimpse_image(handles.gfolder5,vid,1));
           handles.DumGfolder5=dum-dum;             % zeroed array the same size as the images
           handles.GlimpseMax=5;
        end

        
        if isfield(foldstruc,'folder')
           handles.TiffMax=1;
           handles.TiffFolder=foldstruc.folder;      % Will replace the 'folder' arguement formerly picked up from command mode
           handles.TiffFolder1=foldstruc.folder;   % The path to the tiff file, (maybe) defined by user in command mode
           dum=uint32(imread(handles.TiffFolder, 'tif', 1));
           handles.DumTiffFolder=dum-dum;             % zeroed array the same size as the images
        
           handles.DumTiffFolder1=dum-dum;
                
        else
            handles.TiffFolder=[];                  % We will have a handles.TiffFolder regardless of whether the user
                                 % inputs a foldstruc.folder arguement (formerly picked up from command mode)
        end
        if isfield(foldstruc,'folder2')
           handles.TiffMax=2;
           handles.TiffFolder2=foldstruc.folder2;   % The path to the tiff file #2 (for mapping), (maybe) defined by user in command mode    
           dum=uint32(imread(handles.TiffFolder2, 'tif', 1));
           handles.DumTiffFolder2=dum-dum;              % zeroed array the same size as the images
        
        else
            handles.TiffFolder2=[];                 % We will always have a handles.TiffFolder2 regardless of input, use as folder2 replacement
                                                    % formerly picked up from command mode
        end
        if isfield(foldstruc,'folder3')
           handles.TiffMax=3;
           handles.TiffFolder3=foldstruc.folder3;   % The path to the tiff file #2 (for mapping), (maybe) defined by user in command mode    
           dum=uint32(imread(handles.TiffFolder3, 'tif', 1));
           handles.DumTiffFolder3=dum-dum;              % zeroed array the same size as the images
        end
        if isfield(foldstruc,'folder4')
           handles.TiffMax=4;
           handles.TiffFolder4=foldstruc.folder4;   % The path to the tiff file #2 (for mapping), (maybe) defined by user in command mode    
           dum=uint32(imread(handles.TiffFolder4, 'tif', 1));
           handles.DumTiffFolder4=dum-dum;              % zeroed array the same size as the images
        end
        if isfield(foldstruc,'folder5')
           handles.TiffMax=5;
           handles.TiffFolder5=foldstruc.folder5;   % The path to the tiff file #2 (for mapping), (maybe) defined by user in command mode    
           dum=uint32(imread(handles.TiffFolder5, 'tif', 1));
           handles.DumTiffFolder5=dum-dum;              % zeroed array the same size as the images
        end
        if isfield(foldstruc,'images')
           handles.images=foldstruc.images;        % array of images already stored in RAM
           dum=uint32(handles.images(:,:,1));
           handles.DumImages=dum-dum;               % zeroed array the same size as the images
           handles.Dum=handles.DumImages;           % Will be used as replacement for 'dum' variable formerly picked up
                                            % from command mode
        else
            handles.images=[];                  % We will have a handles.images even if the user does NOT input a foldstruc.images arguement
            handles.Dum=[];                         % We also have a handles.Dum from above
          
        end
        if isfield(foldstruc,'images2')
           handles.images2=foldstruc.images2;        % array of images already stored in RAM
           dum2=uint32(handles.images2(:,:,1));
           handles.DumImages2=dum2-dum2;               % zeroed array the same size as the images2
           handles.Dum2=handles.DumImages2;           % Will be used as replacement for 'dum2' variable formerly picked up
                                            % from command mode
        else
            handles.images2=[];                  % We will have a handles.images2 even if the user does NOT input a foldstruc.images arguement
            handles.Dum2=[];                                     % We also always have a handles.Dum2 from above (from foldstruc.gfolder2 above) 
                                                
          
        end
        if isfield(foldstruc,'DriftList')
           handles.DriftList=foldstruc.DriftList;    % List of xy shifts to account for drift 
                                            % see ShiftAOI.m.  This
                                            % driftlist is activelly
                                            % accessed by the program in
                                            % compensating drift
                                                    
           handles.DriftListInput=foldstruc.DriftList;  %  This variable stores the driftlist input by the user
                                        % We will be transforming this
                                        % depending on whether the aoi
                                        % movement we compensate is in the
                                        % field where the driftlist was
                                        % made (long or short) or the
                                        % opposite field (short 
                                        % or long wavelength fields)
          handles.DriftListStored=foldstruc.DriftList;  % Need this extra storage when the user later inputs 
                                        % a cell array of driftlists that
                                        % can at times replace the one
                                        % input by foldstruc.DriftList
          handles.DriftListCell=[]; % Will hold cell array of driftlists
                                        % corresponding to cell arrays in
                                        % handles.FieldFrames
          handles.DriftFlagg=0;         % Driftflagg will =1 if user later inputs a 
                                        % cell array of driftlists
        else
           handles.DriftList=[];        % Actively used
           handles.DriftListCell=[];    % Cell array later input by user
           handles.DriftListInput=[];   % Needed to compensate drift in both fields 1 and 2 (see 'StartParameters')
           handles.DriftListStored=[];  % Extra storage of driftlist input through foldstruc.DriftList
           handles.DriftFlagg=0;        % Driftflagg will =1 if user later inputs a cell array of driftlists 
        end
        if isfield(foldstruc,'MaxFrames')
           handles.MaxFrames=foldstruc.MaxFrames;        % Number of frames in file (only need this if using a tiff file array
                        % If using glimpse, get MaxFrames from vid (above)
                                                        
        end
        if isfield(foldstruc,'Pixnums')   % [pixnum0 pixnum1 pixnum2]
                        % pixnum0== width of aoi used for spot integration
                        % pixnum1== larger aoi width that contains all the
                        %             spot intensity
                        % pixnum2== larger still aoi width used for background
                        %                subtraction
            handles.Pixnums=foldstruc.Pixnums;          % pixnum values that enter into background subtraction used
                                                        % by e.g. Danny in his FRET routines, or anyone else that
                                                        % needs just the spot intensity minus the background
        end
   
                                                    
    end
                    % 12/15/2009:  We have replaced dum, folder and images variables
                    % with handles.Dum, handles.TiffFolder and
                    % handles.images repsectively
                     % 3/20/2010:  We have replaced dum2, folder2 and images2 variables
                    % with handles.Dum2, handles.TiffFolder2 and
                    % handles.images2 repsectively
                   % Using handles.DumGFolder1,2,3,4,5, handles.DumTiffFolder1,2,3,4,5, and handles.Dum1,2
    load FileLocations.dat -mat;                % Load the FileLocations stucture whose members list
                                                % file locations to place
                                                % and retrieve files
                                            % FileLocations.data
                                            % FileLocations.avis 
                                            %FileLocations.mapping
                                            %FileLocations.imscroll
                                                %FileLocations = 
                                                %     data: 'p:\matlab12\larry\data'
                                                %     avis: 'p:\matlab12\larry\avis'
                                                %     mapping: 'p:\matlab12\larry\fig-files\imscroll\mapping'
                                                %     mapping:'p:\matlab12\larry\fig-files\imscroll'
    handles.FileLocations=FileLocations;
                                                % Load 'magxyCoord' variable: 12x4 for 12 [x1 x2 y1 y2] magnification coordinate settings  
    eval(['load ' handles.FileLocations.gui_files 'MagxyCoord.dat -mat'])
    set(handles.MagChoice,'UserData',MagxyCoord);
    set(handles.MagRangeYX,'String',['[' num2str(MagxyCoord(1,:)) ']' ]);
    handles.MappingPoints=[];                % Points used to map the two fields (gathered in 'mapping' gui)
                    % =[framenumber1 ave1 x1pt y1pt pixnum1 aoinumber framenumber2 ave2 x2pt y2pt pixnum2 aoinumber]
    handles.Time1=[];
    handles.Time2=[];
    handles.DriftCorrectxy=[];              % xy list collected in DriftInfo.dat routine
    handles.RollingBallRadius=15;           % Default values for R and H
    handles.RollingBallHeight=5;            % in the rolling_ball( ) ave function
    handles.NoiseDiameter=1.0;              % For spot picking, starting default value input to bpass() function
    handles.SpotDiameter=5;                 % For spot picking, starting default value, input to bpass(),pkfnd(), cntrd()
    handles.SpotBrightness=50;              % For spot picking, starting default value, input to pkfnd( )
    handles.AllSpots.AllSpotsCells=cell(3,3);  % Will be a cell array {N,4} N=# of frames computed, and
                                            % AllSpots{m,1}= [x y] list of spots, {m,2}= # of spots in list, {m,3}= frame#
                                            % {1,4}=vector of all frame numbers stored in this cell array
                                            % Holds the AllSpots with a high threshold for spot detection 
    handles.AllSpots.AllSpotsCellsDescription='{m,1}= [x y] list of spots in frm m, {m,2}= # of spots in list, {m,3}= frame#]';
    handles.AllSpots.FrameVector=[];         % Vector of frames whose spots are stored in AllSpotsCells
    handles.AllSpots.Parameters=[ 1 5 50];  % [NoiseDiameter  SpotDiameter  SpotBrightness] used for picking spots
    handles.AllSpots.ParametersDescripton='[NoiseDiameter  SpotDiameter  SpotBrightness] used for picking spots';
    handles.AllSpots.aoiinfo2=[];       
    handles.AllSpots.aoiinfo2Description='[frm#  ave  x  y  pixnum  aoi#]';
    handles.AllSpotsLow=handles.AllSpots;   % Will hold the AllSpots with a low threshold for spot detection
    handles.Field1=[];                      % Will hold aois for field1 for mapping
    handles.Field2=[];                      % Will hold aois for field2 for mapping
    handles.PreAddition=[];                 % Will hold the smaller aoi list (aoiinfo2) that was present just prior  
                                            % to adding another aoi list during the process of constructing a map 

    guidata(fig, handles);

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
%| callback type separated by '_', e.g. 'MaxIntensity_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.MaxIntensity. This
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
function varargout = slider1_Callback(h, eventdata, handles,varargin)
% SLIDER SWITCH: Controls the frame number being displayed
% Stub for Callback of the uicontrol handles.slider1.
%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};


%images=varargin{1};
% should pull out the images arguement
imagenum=get(handles.ImageNumber,'value');        % Retrieve the value of the slider
val= round(imagenum);

userdat=get(handles.ImageNumber,'UserData');      % userdata contains last value of slider
                      
                        % Ilast will be the element index of
                        % handles.CurrentField that corresponds to the last
                        % value of the slider,  Icurrent the index of the
                        % current frame value of the slider
    [Ylast Ilast]=min(abs(handles.CurrentField-userdat));
    [Ycurrent Icurrent]=min(abs(handles.CurrentField-val));

if imagenum>userdat                                      % userdata contains last value of slider
                      
    
    if Icurrent-Ilast <1
        Icurrent=Icurrent+1;                              % Must increment frame index by at least 1
                                        % Check for max limit
        Icurrent=min(Icurrent,length(handles.CurrentField));    
        val=handles.CurrentField(Icurrent);       
     end
elseif imagenum < userdat 
    
    if Ilast-Icurrent <1
        Icurrent=Icurrent-1;                              % Must decrement frame index by at least 1
        Icurrent=max(Icurrent,1);       % Check for min limit
        val=handles.CurrentField(Icurrent);
     end
end

%val=round(val);
[Y I]=min(abs(handles.CurrentField-val));       % Find the index I of the element of handles.CurrentField
                                                % that is closest to the frame number 
val=handles.CurrentField(I);            % Current slider value will now be an element of the restrictive
                                        % set of frames listed in
                                        % handles.CurrentField
set(handles.ImageNumber,'UserData',val) % Reset UserData to reflect newest value
set(handles.ImageNumber,'value',val)    % Force slider value to reflect current frame#


set(handles.ImageNumberValue,'String',num2str(val ) ); 
axes(handles.axes1);
%imagesc(images(:,:,val));colormap(gray)
%dum=imread([folder tiff_name(val)],'tiff');
%dum=imread([folder cook_name(val)],'tiff');

%avefrm=getframes(dum,images,folder,handles);

avefrm=getframes_v1(handles);
%*************************************
%{
if get(handles.BackgroundChoice,'Value')==2
                            % Here to display background
    avefrm=rolling_ball(avefrm,handles.RollingBallRadius,handles.RollingBallHeight);
elseif get(handles.BackgroundChoice,'Value')==3
                            % Here to display image-background
    avefrm=double(avefrm)-double(rolling_ball(avefrm,handles.RollingBallRadius,handles.RollingBallHeight));
elseif get(handles.BackgroundChoice,'Value')==4
                            % Here to display background with Danny's
                            % latest rolling ball ave,  default rollingballradius==spotsize=5, default rollingballheight==noise radius=2  
    
     avefrm=bkgd_image(avefrm,handles.RollingBallRadius,handles.RollingBallHeight);
     
elseif get(handles.BackgroundChoice,'Value')==5
     avefrm=double(avefrm)-double(bkgd_image(avefrm,handles.RollingBallRadius,handles.RollingBallHeight));
     
    
end
%}
%***************************
switch get(handles.BackgroundChoice,'Value')
    case 1
    case 2
                                    % Here to display background
        avefrm=rolling_ball(avefrm,handles.RollingBallRadius,handles.RollingBallHeight);
    case 3
                                 % Here to display image-background
        avefrm=double(avefrm)-double(rolling_ball(avefrm,handles.RollingBallRadius,handles.RollingBallHeight));
    case 4
         % Here to display background with Danny's
                            % latest rolling ball ave,  default rollingballradius==spotsize=5, default rollingballheight==noise radius=2  
    
         avefrm=bkgd_image(avefrm,handles.RollingBallRadius,handles.RollingBallHeight);
    case 5
        
         avefrm=double(avefrm)-double(bkgd_image(avefrm,handles.RollingBallRadius,handles.RollingBallHeight));
end
        

                    %dum=imread([folder],'tiff',val);                    %*** NEED TO CHANGE IMREAD
                    %[drow dcol]=size(dum);
                    %ave=str2double(get(handles.FrameAve,'String'));     % Fetch the number of frames to ave
                    %dum=zeros(drow,dcol);                              % for display purposes
                    %for aveindx=val:val+ave-1                          % Grab the frames
                    %dum=dum+double(imread([folder],'tiff',aveindx));    % ***NEED TO CHANGE IMREAD
%dum=dum+double( imread([folder tiff_name(aveindx)],'tiff') );
%dum=dum+double( imread([folder cook_name(aveindx)],'tiff') );
%end
                    %dum=dum/ave;                                        % Normalize the frames

clowval=round(double(min(min(avefrm))));chival=round(double(max(max(avefrm))));     % Frame max and min values,
                               % same as auto values for scaling image

                                    % Now test whether to manually scale images
if get(handles.ImageScale,'Value')==1          % =1 for manual scale
    clowval=round(get(handles.MinIntensity,'Value'));  % set minimum display intensity
    chival=round(get(handles.MaxIntensity,'Value'));   % set maximum display intensity
else
                                      % If auto scaling is on, label the
                                      % Maxscale and MinScale text
                                      % with the auto values
                                                
    set(handles.MaxScale,'String',num2str(chival));
    set(handles.MinScale,'String',num2str(clowval));
   
end

                    %[mrow ncol]=size(dum);
     % ******* lines to update quickly:
                    %h=get(handles.axes1,'children')
                    %set(h(end),'cdata',round(rand(200,330)*255))
if get(handles.PlotContent,'Value')==0      % check whether to plot image (1) or mesh (0)
    
    if get(handles.Magnify,'Value')==0      % check whether to plot full screen (0) or mag (1)
        if get(handles.ImageFigure,'Value')==1  % =1 if we should also make a separate figure
            figure(23);imagesc(avefrm,[clowval chival] );colormap(gray(256));axis('equal');axis('off');
        end
    axes(handles.axes1);                        % sets the active figure to bthe gui
    imagesc(avefrm,[clowval chival] );colormap(gray(256));axis('equal')
    else                                    % Here to magnify image
    %imagesc(avefrm,[clowval chival] );axis('equal');colormap(gray(256))
    %eval( ['rangeyx=' get(handles.MagRangeYX,'String') ])
    %ymin=rangeyx
    limitsxy=eval( get(handles.MagRangeYX,'String') );                 % Will be axis limits of magnified FOV
        if get(handles.ImageFigure,'Value')==1       % =1 if we should make an separate figure
            figure(23);imagesc(avefrm,[clowval chival] );axis('equal');axis('off');colormap(gray(256));axis(limitsxy)
        end
    axes(handles.axes1);                            % active figure is now the in the gui
    imagesc(avefrm,[clowval chival] );axis('equal');colormap(gray(256));axis(limitsxy)
%    eval(['imagesc(avefrm' get(handles.MagRangeYX,'String') ',[' num2str(clowval) ' ' num2str(chival) '])' ]);axis('equal');colormap(gray(256))
    end
   pixnum=str2double(get(handles.PixelNumber,'String'));

%draw_diamond(str2double(get(handles.Xspot,'String')),str2double(get(handles.Yspot,'String')),2,.5,[0 0 1]);   
 %draw_box([str2double(get(handles.Xspot,'String')) str2double(get(handles.Yspot,'String'))],(pixnum-1)/2,...
%                              (pixnum-1)/2,'b')
    aoiinfo=handles.FitData;
    [maoi naoi]=size(aoiinfo);          % handles.FitData contains the aoiinfo collected 
                                                % with the 'AOI' button
                                                % (tag = CollectAOI)
       
    for indx=1:maoi
        XYshift=[0 0];                  % initialize aoi shift due to drift
        if any(get(handles.StartParameters,'Value')==[2 3 4])
                                    % here to move the aois in order to follow drift
            XYshift=ShiftAOI(indx,val,aoiinfo,handles.DriftList);
        end
        if any(get(handles.FitChoice,'Value')==[5 6]) 
                    % == 5 or 6 if we are set to do linear interpolation with 
                    % repsect to integrating partial overlap of AOIs and
                    % pixels
                    % draw boxes around all the aois, adding the XYshift to
                    % account for possible drift
                    % Here to draw boxes that fractionally overlaps pixels
            draw_box(aoiinfo(indx,3:4)+XYshift,(pixnum)/2,...
                              (pixnum)/2,'b');
        else
                    % Here to draw aoi boxes only at pixel boundaries
            draw_box_v1(aoiinfo(indx,3:4)+XYshift,(pixnum)/2,...
                               (pixnum)/2,'b');
        end
    end
    if get(handles.MarkFolder2SpotsToggle,'Value')==1   % Test if toggle is depressed
    
        MarkFolder2Spots_v1(handles);          % Here to mark the spots that appeared in the
                                            % InputParms editable text
                                            % region
    end    

else                                        %Here to plot mesh
    pixnum=str2double(get(handles.PixelNumber,'String'));
    xypt(1)=str2double(get(handles.Xspot,'String'));
    xypt(2)=str2double(get(handles.Yspot,'String'));

    xlow=round(xypt(1)-pixnum/2);xhi=xlow+pixnum-1;
    ylow=round(xypt(2)-pixnum/2);yhi=ylow+pixnum-1;
    aoi=avefrm(ylow:yhi,xlow:xhi);
     if get(handles.ImageFigure,'Value')==1  % =1 if we should also make a separate figure
         figure(23);mesh(double(aoi));
     end
    axes(handles.axes1);                            % active figure is now the in the gui 
    mesh(double(aoi));
end


% --------------------------------------------------------------------
function varargout = ImageNumberValue_Callback(h, eventdata, handles, varargin)
% EDITABLE TEXT: Displays the current frame number being displayed
% Stub for Callback of the uicontrol handles.ImageNumberValue.
% Here when user inputs a value to the Frame Number editable text box
inval=get(handles.ImageNumberValue,'String');
axes(handles.axes1);title(['input value=' inval]);
%if inval>get(handles.ImageNumber,'Max')
    set(handles.ImageNumber,'Max',str2num(inval))    % User can set maximum frame number here
    %end


% --------------------------------------------------------------------
function varargout = figure1_ResizeFcn(h, eventdata, handles, varargin)
% Stub for ResizeFcn of the figure handles.figure1.
disp('figure1 ResizeFcn not implemented yet.')


% --------------------------------------------------------------------



% --------------------------------------------------------------------
function varargout = ginput_spot_Callback(h, eventdata, handles, varargin)
%PUSHBUTTON: Allows user to input one coordinate by mouse clicking.  Right
%click to end.
% Stub for Callback of the uicontrol handles.ginput_spot.
flag=0;
while flag==0
[a b but]=ginput(1);
axes(handles.axes1)
xlabel(['coordinates are x=' num2str(a) 'y=' num2str(b)])
if but ==3
    flag=1;
else
    set(handles.Xspot,'String',num2str(a));         % Store the last clicked point
    set(handles.Yspot,'String',num2str(b));
end
end





%


% --- Executes during object creation, after setting all properties.
function PixelNumber_CreateFcn(hObject, eventdata, handles)
% EDITABLE TEXT:  Sets the full width of the AOI that will be fit (or
% displayed when a mesh plot is asked for)
% hObject    handle to PixelNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function PixelNumber_Callback(hObject, eventdata, handles)
% EDITABLE TEXT:  Sets the full width of the AOI that will be fit (or
% displayed when a mesh plot is asked for)

% hObject    handle to PixelNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PixelNumber as text
%        str2double(get(hObject,'String')) returns contents of PixelNumber as a double


% --- Executes on button press in PlotContent.
function PlotContent_Callback(hObject, eventdata, handles)
% TOGGLE SWITCH: User presses to switch between image (grayscale) and mesh
% plot of the AOI
% hObject    handle to PlotContent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PlotContent
if get(handles.PlotContent,'Value')==0
    set(handles.PlotContent,'String','Image')
else
    set(handles.PlotContent,'String','AOI Mesh')
end


% --- Executes during object creation, after setting all properties.
function Xspot_CreateFcn(hObject, eventdata, handles)
%EDITABLE TEXT: Displays the x coordinate of the selected spot (center of
%the AOI that will be gaussian fit or displayed as a mesh plot)
% hObject    handle to Xspot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function Xspot_Callback(hObject, eventdata, handles)
%EDITABLE TEXT: Displays the x coordinate of the selected spot (center of
%the AOI that will be gaussian fit or displayed as a mesh plot)

% hObject    handle to Xspot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xspot as text
%        str2double(get(hObject,'String')) returns contents of Xspot as a double


% --- Executes during object creation, after setting all properties.
function Yspot_CreateFcn(hObject, eventdata, handles)
%EDITABLE TEXT: Displays the y coordinate of the selected spot (center of
%the AOI that will be gaussian fit or displayed as a mesh plot)

% hObject    handle to Yspot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Yspot_Callback(hObject, eventdata, handles)
%EDITABLE TEXT: Displays the y coordinate of the selected spot (center of
%the AOI that will be gaussian fit or displayed as a mesh plot)

% hObject    handle to Yspot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Yspot as text
%        str2double(get(hObject,'String')) returns contents of Yspot as a double


% --- Executes during object creation, after setting all properties.
function FrameRange_CreateFcn(hObject, eventdata, handles)
%EDITABLE TEXT: Displays the range of frames that will be fit with the
%gaussian function
% hObject    handle to FrameRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function FrameRange_Callback(hObject, eventdata, handles)
%EDITABLE TEXT: Displays the range of frames that will be fit with the
%gaussian function

% hObject    handle to FrameRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameRange as text
%        str2double(get(hObject,'String')) returns contents of FrameRange as a double


% --- Executes on button press in FitSpotxy.
function varargout=FitSpotxy_Callback(hObject, eventdata, handles, varargin)
%PUSHBUTTON: User pushes button in order to fit the selected spot over the designated
% frame range with a gaussian that has adjustable sigma width for both x and y

% hObject    handle to FitSpotxy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder=varargin{1}
pixnum=str2double(get(handles.PixelNumber,'String')); % Fetch the pixel number (aoi width)
frms=eval(get(handles.FrameRange,'String')); % Fetch the frame range to fit

xypt=zeros(1,2);                                    
xypt(1)=str2double(get(handles.Xspot,'String'));    % Fetch the center location for the AOI
xypt(2)=str2double(get(handles.Yspot,'String'));    % (set earlier through ginput)
argouts=gauss2dxy_seq(folder,frms,xypt,pixnum);        % Fit the spot
                                                    % Save the data
%save p:\matlab12\larry\data\argout.dat argouts
eval(['save ' handles.FileLocations.data 'argout.dat argouts']);
axes(handles.axes2);
plot(argouts(:,1),argouts(:,4),'r',argouts(:,1),argouts(:,6),'b')





% --- Executes on button press in Magnify.
function Magnify_Callback(hObject, eventdata, handles)
% TOGGLE SWITCH: User pushes in order to magnify the display according to
% the pixel range set in the editable text box labeled 'Magnify Range' on
% the display (has MagRangeXY handle)

% hObject    handle to Magnify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Magnify

if get(handles.Magnify,'Value')==0
    set(handles.Magnify,'String','Full Screen')
else
    set(handles.Magnify,'String','Magnified')
end
slider1_Callback(handles.ImageNumber, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function MagRangeYX_CreateFcn(hObject, eventdata, handles)
%EDITABLE TEXT: User specifies the pixel range that will be displayed
%whenever the (full screen)/Magnify toggle switch is pressed
% hObject    handle to MagRangeYX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function MagRangeYX_Callback(hObject, eventdata, handles)
%EDITABLE TEXT: User specifies the pixel range that will be displayed
%whenever the (full screen)/Magnify toggle switch is pressed
% hObject    handle to MagRangeYX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MagRangeYX as text
%        str2double(get(hObject,'String')) returns contents of MagRangeYX as a double
MagRangeString=get(handles.MagRangeYX,'String');
MagRangeNum=str2num(MagRangeString);
xpts=MagRangeNum(1:2); ypts=MagRangeNum(3:4);
            % Following copied from MagRange to insure that a manual input
            % of the range will be placed in the correct locations
xpts=round(xpts);ypts=round(ypts);
xpts=sort(xpts);ypts=sort(ypts);            % Place in order of [low high] so the 
                                            % orientation of points entered does not
                                            % matter
xpts(1)=max(xpts(1),1);     % Error check on values
% xpts(2)=min(xpts(2),1024); % Remove error check so we can view Alex's gallery images 
ypts(1)=max(ypts(1),1);
%ypts(2)=min(ypts(2),1024);   % Remove error check so we can view Alex's gallery images
val=[xpts(1) xpts(2) ypts(1) ypts(2)];      % Place in row vector so we can
                                            % store the points in 'Value'
set(handles.MouseRange,'Value',val);        % Store points in 'Value'
                                            % Now write the string into the
                                            % MagRange editable box
magrange_string=['[' num2str(xpts(1)) ' ' num2str(xpts(2)) ' ' num2str(ypts(1)) ' ' num2str(ypts(2)) ']'];
set(handles.MagRangeYX,'String',magrange_string);
MagxyCoord=get(handles.MagChoice,'UserData');   % Fetch current MagxyCoord matrix of [x1 x2 y1 y2] values
MagValue=get(handles.MagChoice,'Value');        % Fetch current value of popup menu (1-12)
MagxyCoord(MagValue,:)=[xpts(1) xpts(2) ypts(1) ypts(2)];   % Replace numerical value for this value of MagxyCoord
set(handles.MagChoice,'UserData',MagxyCoord);               % Update the MagxyCoord matrix
                               % Save the updated matrix 
eval(['save ' handles.FileLocations.gui_files 'MagxyCoord.dat MagxyCoord'])
           % Make the display reflect the new magnification setting
slider1_Callback(handles.ImageNumber, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function FrameAve_CreateFcn(hObject, eventdata, handles)
%EDITABLE TEXT: User specifies the number of frames that will be averaged
%for the purpose of the display
% hObject    handle to FrameAve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function FrameAve_Callback(hObject, eventdata, handles)
%EDITABLE TEXT: User specifies the number of frames that will be averaged
%for the purpose of the display

% hObject    handle to FrameAve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameAve as text
%        str2double(get(hObject,'String')) returns contents of FrameAve as a double


% --- Executes on button press in ImageScale.
function ImageScale_Callback(hObject, eventdata, handles)
%TOGGLE BUTTON: press to manually scale the image intensity
% hObject    handle to ImageScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ImageScale
if get(handles.ImageScale,'Value')==0
    set(handles.ImageScale,'String','Auto Scale')
     set(handles.MinIntensity,'Visible','off')
     set(handles.MaxIntensity,'Visible','off')
   
else
    set(handles.ImageScale,'String','Manual Scale')
     set(handles.MinIntensity,'Visible','on')
     set(handles.MaxIntensity,'Visible','on')
end

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over ImageScale.
function ImageScale_ButtonDownFcn(hObject, eventdata, handles)
%TOGGLE BUTTON: press to manually scale the image intensity
% hObject    handle to ImageScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.ImageScale,'Value')==0
    set(handles.ImageScale,'String','Auto Scale')
    set(handles.MinIntensity,'Visible','off')
else
    set(handles.ImageScale,'String','Manual Scale')
    set(handles.MinIntensity,'Visible','on')
end



% --- Executes during object creation, after setting all properties.
function MaxIntensity_CreateFcn(hObject, eventdata, handles)
%SLIDER SWITCH: controls value of the highest intensity in display

% hObject    handle to MaxIntensity (see GCBO)
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
function MaxIntensity_Callback(hObject, eventdata, handles)
%SLIDER SWITCH: controls value of the highest intensity in display
% hObject    handle to MaxIntensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

                                % Get the value of slider, and print it in
                                % MaxScale box
mxval=get(handles.MaxIntensity,'Value');
set(handles.MaxScale,'String',num2str(round(mxval)));
                                % Now update the display
clowval=round(get(handles.MinIntensity,'Value'));  % set minimum display intensity
chival=round(get(handles.MaxIntensity,'Value'));   % set maximum display intensity
axes(handles.axes1);
caxis([clowval chival]);                            % changes the current display to match
                                       % the new hi/lo intensity settings
                                                    
% --- Executes during object creation, after setting all properties.
function MaxScale_CreateFcn(hObject, eventdata, handles)
%EDITABLE TEXT;  Value of the highest intensity displayed
% hObject    handle to MaxScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function MaxScale_Callback(hObject, eventdata, handles)
%EDITABLE TEXT;  Value of the highest intensity displayed
% hObject    handle to MaxScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxScale as text
%        str2double(get(hObject,'String')) returns contents of MaxScale as a double
                                    %Check to see if entered value exceeds
                                    % current maximum.  If so, change value
                                    % of allowed maximum.
 mxx=str2double(get(handles.MaxScale,'String'));                                                           
%if get(handles.MaxIntensity,'Max') < mxx
                                    % Use the manual input in order to set
                                    % the slider switch maximum for both
                                    % the Min and Max slider swiches
    set(handles.MaxIntensity,'Max',mxx); 
    set(handles.MinIntensity,'Max',mxx);
%end

    
% --- Executes during object creation, after setting all properties.
function MinScale_CreateFcn(hObject, eventdata, handles)
%EDITABLE TEXT;  Value of the lowest intensity displayed
% hObject    handle to MinScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function MinScale_Callback(hObject, eventdata, handles)
%EDITABLE TEXT;  Value of the lowest intensity displayed
% hObject    handle to MinScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinScale as text
%        str2double(get(hObject,'String')) returns contents of MinScale as a double


% --- Executes during object creation, after setting all properties.
function MinIntensity_CreateFcn(hObject, eventdata, handles)
%SLIDER SWITCH: Sets minimum intensity value in display

% hObject    handle to MinIntensity (see GCBO)
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
function MinIntensity_Callback(hObject, eventdata, handles)
%SLIDER SWITCH: Sets minimum intensity value in display
% hObject    handle to MinIntensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


                                % Check that value is below that of the
                                % MaxInitensity slider switch
 mxx=get(handles.MaxIntensity,'Value');                               
if get(handles.MinIntensity,'Value') > mxx
    set(handles.MinIntensity,'Value',mxx-1);
end



                                % Get the value of slider, and print it in
                                % MinScale box

mxval=get(handles.MinIntensity,'Value');
set(handles.MinScale,'String',num2str(round(mxval)));
                                % Now update the display
clowval=round(get(handles.MinIntensity,'Value'));  % set minimum display intensity
chival=round(get(handles.MaxIntensity,'Value'));   % set maximum display intensity
axes(handles.axes1);
caxis([clowval chival]);                            % changes the current display to match
                                       % the new hi/lo intensity settings


% --- Executes on button press in MouseRange.
function MouseRange_Callback(hObject, eventdata, handles)
%PUSHBOTTON: indicates the user will define a region using mouse clicks
% hObject    handle to MouseRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[xpts ypts]=ginput(2);                      % Get two points via mouse clicks.
                                            % These will define our region
                                            % for magnification

xpts=round(xpts);ypts=round(ypts);
xpts=sort(xpts);ypts=sort(ypts);            % Place in order of [low high] so the 
                                            % orientation of points entered does not
                                            % matter
xpts(1)=max(xpts(1),1);     % Error check on values
%xpts(2)=min(xpts(2),1024); % Remove upper error check so we can see Alex's
                            % gallery images
ypts(1)=max(ypts(1),1);
%ypts(2)=min(ypts(2),1024); % Remove upper error check so we can see Alex's
                            % gallery images
val=[xpts(1) xpts(2) ypts(1) ypts(2)];      % Place in row vector so we can
                                            % store the points in 'Value'
set(handles.MouseRange,'Value',val);        % Store points in 'Value'
                                            % Now write the string into the
                                            % MagRange editable box
magrange_string=['[' num2str(xpts(1)) ' ' num2str(xpts(2)) ' ' num2str(ypts(1)) ' ' num2str(ypts(2)) ']'];
set(handles.MagRangeYX,'String',magrange_string);
MagxyCoord=get(handles.MagChoice,'UserData');   % Fetch current MagxyCoord matrix of [x1 x2 y1 y2] values
MagValue=get(handles.MagChoice,'Value');        % Fetch current value of popup menu (1-12)
MagxyCoord(MagValue,:)=[xpts(1) xpts(2) ypts(1) ypts(2)];   % Replace numerical value for this value of MagxyCoord
set(handles.MagChoice,'UserData',MagxyCoord);               % Update the MagxyCoord matrix
                               % Save the updated matrix 
eval(['save ' handles.FileLocations.gui_files 'MagxyCoord.dat MagxyCoord'])
           % Make the display reflect the new magnification setting
slider1_Callback(handles.ImageNumber, eventdata, handles)

 
 






% --- Executes on button press in PixVal.
function PixVal_Callback(hObject, eventdata, handles)
%TOGGLE SWITCH: User pushes to turn on the cursor/xy/value function
% hObject    handle to PixVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PixVal

axes(handles.axes1)
if get(handles.PixVal,'Value')==1
    pixval('on')
else
    pixval('off')
end


% --- Executes on button press in ImageSource.
function ImageSource_Callback(hObject, eventdata, handles)
% hObject    handle to ImageSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ImageSource

if get(handles.ImageSource,'Value')==0
    %set(handles.ImageSource,'String','Folder')
else
    %set(handles.ImageSource,'String','Images')
end




% --- Executes during object creation, after setting all properties.
function FitChoice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FitChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in FitChoice.
function FitChoice_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to FitChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns FitChoice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FitChoice


% --- Executes on button press in CollectAOI.

%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};

%slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
if get(handles.FitChoice,'Value')==7
    set(handles.SigmaValueString,'Visible','on')
    set(handles.SigmaLabel,'Visible','on')
else
    set(handles.SigmaValueString,'Visible','off')
    set(handles.SigmaLabel,'Visible','off')
end
slider1_Callback(handles.ImageNumber, eventdata, handles)


function CollectAOI_Callback(hObject, eventdata, handles)
% hObject    handle to CollectAOI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


aoiinfo=[];
framenumber=str2num(get(handles.ImageNumberValue,'String'));
ave=round(str2double(get(handles.FrameAve,'String')));
pixnum=str2double(get(handles.PixelNumber,'String'));
flag=0;
axes(handles.axes1)
aoinumber=1;
while flag==0
    [a b but]=ginput(1);
    if but==3
        flag=1;
    else
        aoiinfo=[aoiinfo; framenumber ave a b pixnum aoinumber];
        aoinumber=aoinumber+1;                      %Give each aoi a number
        axes(handles.axes1);
        hold on
        [maoi naoi]=size(aoiinfo);
        for indx=maoi:maoi                        
            if get(handles.FitChoice,'Value')==5
                    % == 5 if we are set to do linear interpolation with 
                    % repsect to integrating partial overlap of AOIs and
                    % pixels
                    % draw boxes around all the aois, adding the XYshift to
                    % account for possible drift
                    % Here to draw boxes that fractionally overlaps pixels
            draw_box(aoiinfo(indx,3:4),(pixnum)/2,...
                              (pixnum)/2,'b');
        else
                    % Here to draw aoi boxes only at pixel boundaries
            draw_box_v1(aoiinfo(indx,3:4),(pixnum)/2,...
                               (pixnum)/2,'b');
        end
                    % draw boxes around all the aois
            %draw_box_v1(aoiinfo(indx,3:4),(pixnum)/2,...
             %                 (pixnum)/2,'b');
        end
        hold off
    end
end
handles.FitData=aoiinfo;                            % Store the list in the handles structure
guidata(gcbo,handles) ;


% --- Executes on button press in FitAOIs.
function FitAOIs_Callback(hObject, eventdata, handles, varargin)
% hObject    handle to FitAOIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%global argouts imageset folderpass %parenthandles




%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};

folder=handles.TiffFolder;
    % next four lines because 'folder' cannot be empty, or we get an error
    % message when referencing folder(1,:) in build_mapstruc.m
[aa bb]=size(folder);
if (aa==0)&(bb==0);
    folder='folder not specified';
end

%folderpass=folder;
pixnum=str2double(get(handles.PixelNumber,'String')); % Fetch the pixel number (aoi width)
%frms=eval(get(handles.FrameRange,'String'));        % Fetch the frame range to fit

eval([get(handles.FrameRange,'String') ';']);
frms=ans;
                %xypt=zeros(1,2);                                    
                %xypt(1)=str2double(get(handles.Xspot,'String'));    % Fetch the center location for the AOI
                %xypt(2)=str2double(get(handles.Yspot,'String'));    % (set earlier through ginput)

                                                    % Fit the spot.  The
                                                    % fits will use the
                                                    % frame ave as
                                                    % specified in the gui
                              %  ***************************                        

[mfrms nfrms]=size(frms);
if mfrms ==1
    frms=frms';                                 % frms now a column vector
end
[mfrms nfrms]=size(frms); 
ave=round(str2double(get(handles.FrameAve,'String')));
% aoiinf=[frms  ave*ones(mfrms,1) xypt(1)*ones(mfrms,1) xypt(2)*ones(mfrms,1) pixnum*ones(mfrms,1)];
aoiinf=handles.FitData;                         % AOIs selected earlier (AOI button, tag=CollectAOI)
                                                %[framenumber ave x y pixnum aoinumber];
[maoi naoi]=size(aoiinf);
                                                % Now successively fit each AOI over the
 
                                            % specified frame range
argoutsImageData=[];
argoutsBackgroundData=[];

                                            % Define most of the output structure
aoifits.dataDescription='[aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi (integrated pixnum) (original aoi#)]';
aoifits.parameter=[ave pixnum];
aoifits.parameterDescription='[ave pixnum]';
aoifits.tifFile=folder;
aoifits.centers=aoiinf(:,3:4);
aoifits.centersDescription='[aoi_xcenters aoi_ycenters]';
aoifits.aoiinfo2Description='[(framenumber when marked) ave x y pixnum aoinumber]';
aoifits.aoiinfo2=handles.FitData;
aoifits.AllSpotsDescription='aoifits.AllSpots{m,1}=[x y] spots in frm m;  {m,2}=# of spots,frame m; {m,3}=frame #; {1,4}=[firstframe:lastframe]; {2,4}=NoiseDiameter  SpotDiameter  SpotBrightness]'  ;
                                        '{2,4}=NoiseDiameter  SpotDiameter  SpotBrightness]'  ;
aoifits.AllSpots=FreeAllSpotsMemory(handles.AllSpots);      
outputName=get(handles.OutputFilename,'String');



% *** filler_for_imscroll_fit_aois_callback  placed here   ****



mapstruc2d=build_2d_mapstruc_aois_frms(handles);        % Build a 2D mapstruc to direct data processing  

%DataOutput2d=gauss2d_mapstruc2d_v1(mapstruc2d,handles); % Process the data (integrate, fit etc)

DataOutput2d=gauss2d_mapstruc2d_v2(mapstruc2d,handles); % Process the data (integrate, fit etc)
                                                   % V.2 is parallel processing  

argoutsImageData=DataOutput2d.ImageData;
argoutsBackgroundData=DataOutput2d.BackgroundData;


                                                     % Start a gui for display of the fit results
      % argouts=[ aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi]
       % Save the data after each aoi is processed  
                % First assign the ImageData

%eval(['save p:\matlab12\larry\data\' outputName ' aoifits' ])
aoifits.data=argoutsImageData;
aoifits.BackgroundData=argoutsBackgroundData;
eval(['save ' handles.FileLocations.data outputName ' aoifits']);
handles.aoifits1=aoifits;                        % store our structure in the handles structure
handles.aoifits2=aoifits;
guidata(gcbo,handles);
%parenthandles=handles;
                                                % Pass the handle to the
                                                % main gui figure as input
                                                % to the subgui plotargout

plotargout(handles.figure1)  


% --- Executes during object creation, after setting all properties.
function OutputFilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OutputFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function OutputFilename_Callback(hObject, eventdata, handles)
% hObject    handle to OutputFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OutputFilename as text
%        str2double(get(hObject,'String')) returns contents of OutputFilename as a double


% --- Executes during object creation, after setting all properties.
function StartParameters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in StartParameters.
function StartParameters_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to StartParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns StartParameters contents as cell array
%        contents{get(hObject,'Value')} returns selected item from StartParameters
%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};
argnum=get(handles.StartParameters,'Value');
switch argnum
    case 1
                % Here if we are not using drift correction
        %slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
        slider1_Callback(handles.ImageNumber, eventdata, handles)
    case 2
                % Here if we measured the drift in field # 1 or # 2 and we
                % are now wanting to track aois  in the same field where
                % the drift was measured
        handles.DriftList=handles.DriftListInput;
        guidata(gcbo,handles);
       % slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
        slider1_Callback(handles.ImageNumber, eventdata, handles)
    case 3
                % Here if we measured the drift in field # 1 but we are now
                % wanting to track aois moving in field #2.  See notes in
                % file and B22p148,149
                % Get the mapping parameters [f11 f12 f13;  f21 f22 f23]
                % where x2=f11*x1 + f12*y1  +f13
                %       y2=f21*x1  +f22*y1  +f23
        fitparmvector=get(handles.FitDisplay,'UserData');
        f11=fitparmvector(1,1);  f12=fitparmvector(1,2) ;  f13=fitparmvector(1,3);
        f21=fitparmvector(2,1);  f22=fitparmvector(2,2) ;  f23=fitparmvector(2,3);
                % Now fetch the input driftlist that was measured in
                % field #1
        dx1=handles.DriftListInput(:,2);
        dy1=handles.DriftListInput(:,3);
        dx2=f11*dx1 + f12*dy1;      % Transform driftlist to field #2
        dy2=f21*dx1 + f22*dy1;
        handles.DriftList=[handles.DriftListInput(:,1) dx2 dy2];
        guidata(gcbo,handles);
%        slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
        slider1_Callback(handles.ImageNumber, eventdata, handles)
     case 4
                % Here if we measured the drift in field # 2 but we are now
                % wanting to track aois moving in field #1.  See notes in
                % file and B22p148,149
                % Get the mapping parameters [f11 f12 f13;  f21 f22 f23]
                % where x2=f11*x1 + f12*y1  +f13
                %       y2=f21*x1  +f22*y1  +f23
                % and inverse with denom=1/(f11*f22-f12*f21)
              %x1=denom*f22*x2 + denom*(-f12)*y2+ (f12*f23-f13*f22)*denom
              %y1=denom*(-f21)*x2 + denom*f11*y2+ (f21*f13-f23*f11)*denom

        fitparmvector=get(handles.FitDisplay,'UserData');
        f11=fitparmvector(1,1);  f12=fitparmvector(1,2) ;  f13=fitparmvector(1,3);
        f21=fitparmvector(2,1);  f22=fitparmvector(2,2) ;  f23=fitparmvector(2,3);
        denom=(1/(f11*f22-f12*f21));
                % Now fetch the input driftlist that was measured in
                % field #2
        dx2=handles.DriftListInput(:,2);
        dy2=handles.DriftListInput(:,3);
        dx1=denom*f22*dx2 + denom*(-f12)*dy2;      % Transform driftlist to field #1
        dy1=denom*(-f21)*dx2 + denom*f11*dy2;
        handles.DriftList=[handles.DriftListInput(:,1) dx1 dy1];
        guidata(gcbo,handles);
        %slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
        slider1_Callback(handles.ImageNumber, eventdata, handles)
end
    
             


% --- Executes on button press in ImageFigure.
function ImageFigure_Callback(hObject, eventdata, handles)
% hObject    handle to ImageFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ImageFigure

if get(handles.ImageFigure,'Value')==0
    set(handles.ImageFigure,'String','No Figure')
else
    set(handles.ImageFigure,'String','Figure23')
end


% --- Executes on button press in MakeAVI.
function MakeAVI_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to MakeAVI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Will create an avi in 'p:\matlab12\larry\avis\guiavi.avi'
% according to all the settings on the gui panel (frame limit,
% magnification, frame average, intensity scale)
set(handles.MakeAVI,'String','In Process')
images=varargin{1};
Max_Display_String=get(handles.MaxScale,'String');
Min_Display_String=get(handles.MinScale,'String');
dispscale=[ round(str2num(Min_Display_String)) round(str2num(Max_Display_String)) ];
%avifolder='p:\matlab12\larry\avis\guiavi.avi';
%avifolder=[handles.FileLocations.avis '\guiavi.avi'];
avifolder=[handles.FileLocations.avis 'guiavi.avi'];
frms=eval(get(handles.FrameRange,'String'));        % Range of frames for which aois are
                                                    % fit.  Here we use them to define
                                                    % the avi frame limits

loindx=min(frms);
hiindx=max(frms);
frmave=str2double(get(handles.FrameAve,'String'));     % Number of frames in running ave to use in 
                                                    %display, here we use as running ave in avi
guimacavi(images,loindx,hiindx,dispscale,avifolder,frmave,handles);
set(handles.MakeAVI,'String','avi')


% --- Executes on button press in Mapping.
function Mapping_Callback(hObject, eventdata, handles, varargin)
% hObject    handle to Mapping (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Mapping_fig=mapping(handles.figure1);            % Output should be figure from Mapping gui
guidata(hObject,handles);                                % Place Mapping Figure into handles structure
                                                         %  Retrieve the Mapping handle structure using 
                                                          %  MappingHandles=guidata(handles.Mapping_fig)
                                                         %  

% --- Executes on button press in GoButton.
function GoButton_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to GoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
argnum=get(handles.ButtonChoice,'Value');
%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};
if argnum ==1                                           % load the Fit Parameters for mapping

    filestring=get(handles.InputParms,'String');

    eval(['load ' handles.FileLocations.mapping filestring ' -mat'])                        % loads 'fitparmvector', 2x3
                                                              % [mxx21 mxy21 bx21; myx21 myy21 by21]'
       % and mappingpoints = 
       % [frm#1   ave1  x1  y1  pixnum1  aoinum1   frm#2  ave2 x2 y2 pixnum2 aoinum2] 
    set(handles.FitDisplay,'UserData',fitparmvector)    %
    set(handles.FitDisplay,'String',[ num2str(fitparmvector(1,:)) '  ' num2str(fitparmvector(2,:))]); 
    handles.MappingPoints=mappingpoints;
     guidata(gcbo,handles)
elseif argnum==2                                        % load an AOI set
    filestring=get(handles.OutputFilename,'String');
     eval(['load ' handles.FileLocations.data filestring ' -mat'])    % loads 'aoifits' structure from a prior
                                                        % fit to aois
    
                                                     % Reset filename where we store or retrieve the 'aoifits' structure 

     set(handles.OutputFilename,'String','default.dat');
     
     [aoirows aoicol]=size(aoifits.centers);
     onecol=ones(aoirows,1);                            % column of ones (length= # of aois)
                                                        % Now substitute the AOIs into the present field 
                           %[frm#       ave                 x     y             pixnum                aoinum   ]  
     handles.FitData=[onecol aoifits.parameter(1)*onecol aoifits.centers aoifits.parameter(2)*onecol [1:aoirows]'];
     
     if isfield(aoifits,'aoiinfo2')
         handles.FitData=aoifits.aoiinfo2;
     end
  
     set(handles.PixelNumber,'String',num2str(aoifits.parameter(2)));
     guidata(gcbo,handles)
     
elseif argnum==3                                        % map the present AOI set to 
                                                        % field #2 e.g. x1
                                                        % -> x2
                                                        % (output is x2y2  coordinates)
                        % Save the current AOI locations before mapping
     aoiinfo2=handles.FitData;
     eval(['save ' handles.FileLocations.data 'premapAOIs.dat' ' aoiinfo2']);
     fitparmvector=get(handles.FitDisplay,'UserData');     % Fetch the mapping parameters
                                                           % Stored as [mxx21 mxy21 bx; 
                                                           %            myx21 myy21 by]
                % handles.Fitdata=[ frm# ave AOIx  AOIy pixnum aoinum]

     nowpts=[handles.FitData(:,3) handles.FitData(:,4)];
                % Now map to the x2 
       
     handles.FitData(:,3)=mappingfunc(fitparmvector(1,:),nowpts);
 %handles.FitData(:,3)=handles.FitData(:,3)*fitparmvector(1) + fitparmvector(2);
                % Now map to the y2 
     handles.FitData(:,4)=mappingfunc(fitparmvector(2,:),nowpts);
 %handles.FitData(:,4)=handles.FitData(:,4)*fitparmvector(3) + fitparmvector(4);
         if get(handles.ProximityMappingToggle,'Value')==1
                    % Here to instead use proximity mapping method
             [rosenow colnow]=size(nowpts);
             mappednow=zeros(rosenow,2);
             for indx=1:rosenow
                            % Use 15 nearest points for mapping to field2
             mappednow(indx,:)=proximity_mapping_v1(handles.MappingPoints,nowpts(indx,:),15,fitparmvector,2);
             end
             handles.FitData(:,3:4)=mappednow;
         end
     

                                % only keep points with pixel indices >=1
      log=(handles.FitData(:,3)>=1 ) & (handles.FitData(:,4) >=1) & (handles.FitData(:,3) <=1024) & (handles.FitData(:,4) <=1024);
      handles.FitData=handles.FitData(log,:);
      handles.FitData=update_FitData_aoinum(handles.FitData);
     guidata(gcbo,handles)
                             % Save the current AOI locations after mapping
     aoiinfo2=handles.FitData;
     eval(['save ' handles.FileLocations.data 'postmapAOIs.dat aoiinfo2']);
     set(handles.ButtonChoice,'Value',7);           % Make ButtonChoice menu ready to reload mapped AOIs
     set(handles.InputParms,'String','postmapAOIs.dat')     % Put name of postmap AOI file into editable text field (ready to re-load)
   
    
elseif argnum==4                                        % Invert the map: go from e.g. x2 -> x1
                                                        % output is x1y1 coordinates
                                                        % B9p148
                                                        %
                        % Save the current AOI locations before mapping
     aoiinfo2=handles.FitData;
     eval(['save ' handles.FileLocations.data 'premapAOIs.dat' ' aoiinfo2']);
     fitparmvector=get(handles.FitDisplay,'UserData');     % Fetch the mapping parameters
                                                           % Stored as [mxx21 mxy21 bx; 
                                                           %            myx21 myy21 by]
     za=fitparmvector(1,1);zb=fitparmvector(1,2);zc=fitparmvector(1,3);
     zd=fitparmvector(2,1);ze=fitparmvector(2,2);zf=fitparmvector(2,3);
     denom=1/(za*ze-zb*zd);
     invmapmat=denom*[ze -zb (zb*zf-zc*ze) ; -zd za (zd*zc-zf*za)]; % b9p148 inverse matrix

                % handles.Fitdata=[ frm# ave AOIx  AOIy pixnum aoinum]
     nowpts=[handles.FitData(:,3) handles.FitData(:,4)]; 
                % Now map to the x1
     handles.FitData(:,3)=mappingfunc(invmapmat(1,:),nowpts);
                % Now map to the y1
     handles.FitData(:,4)=mappingfunc(invmapmat(2,:),nowpts);

     if get(handles.ProximityMappingToggle,'Value')==1
                    % Here to instead use proximity mapping method
             [rosenow colnow]=size(nowpts);
             mappednow=zeros(rosenow,2);
             for indx=1:rosenow
                            % Use 15 nearest points for mapping to field1
             mappednow(indx,:)=proximity_mapping_v1(handles.MappingPoints,nowpts(indx,:),15,fitparmvector,1);
             end
             handles.FitData(:,3:4)=mappednow;
         end
      

                                % only keep points with pixel indices >=1
      log=(handles.FitData(:,3)>=1 ) & (handles.FitData(:,4) >=1) & (handles.FitData(:,3) <=1024) & (handles.FitData(:,4) <=1024);
      handles.FitData=handles.FitData(log,:);
      handles.FitData=update_FitData_aoinum(handles.FitData);
     guidata(gcbo,handles)
                             % Save the current AOI locations after mapping
     aoiinfo2=handles.FitData;
     eval(['save ' handles.FileLocations.data 'postmapAOIs.dat aoiinfo2']);
     set(handles.ButtonChoice,'Value',7);           % Make ButtonChoice menu ready to reload mapped AOIs
     set(handles.InputParms,'String','postmapAOIs.dat')     % Put name of postmap AOI file into editable text fi  

elseif argnum==5
    filestring='Fitparms.dat';
    eval(['load ' filestring ' -mat'])          % Loads 'mappingpoints' mx12 stored by 'mapping' routine
    %[aoirows aoicol]=size(mappingpoints);       % aoirows gives number of aois 
    %onecol=ones(aoirows,1);                     % column of ones (length = # aois)
                                                 % Now substitute the AOIs
                                                 % into the present field
    handles.FitData=mappingpoints(:,7:12);      % Place the AOIs (from field 2 of the mapping routine)
                                                % into the present Fitdata variable
    set(handles.PixelNumber,'String',num2str(mappingpoints(1,11)));
    guidata(gcbo,handles)
elseif argnum==6
    aoiinfo2=handles.FitData                     % Saving the aoiinfo array so that user may see
                                                % the framenumber where each aoi
                                                % was clicked (e.g for oligo binding and such
     filestring=get(handles.OutputFilename,'String');
     %eval(['save p:\matlab12\larry\data\' filestring ' aoiinfo2' ])
     %eval(['save ' handles.FileLocations.data '\' filestring ' aoiinfo2']);
     eval(['save ' handles.FileLocations.data filestring ' aoiinfo2']);
     set(handles.OutputFilename,'String','default.dat');
elseif argnum==7
        filestring=get(handles.InputParms,'String');    % Get filename from editable text region

        eval(['load ' handles.FileLocations.data filestring ' -mat'])        % Load the aoiinfo2 variable from a prior instance
                                                  % where the user marked the frm #
                                                  % at which spots appeared.  This allows a user to
                                                  % continue marking spots in a sequence that was
                                                  % being processed previously
        handles.FitData=aoiinfo2;                 % Put the aoi information into present handles.FitData
        guidata(gcbo,handles);
elseif argnum==8    
                                                 % Here for Drift
                                                 % correction DriftInfo.dat
   %eval(['load ' handles.FileLocations.imscroll '\DriftInfo.dat -mat']);
   %eval(['load ' handles.FileLocations.imscroll 'DriftInfo.dat -mat']);
   eval(['load ' handles.FileLocations.gui_files 'DriftInfo.dat -mat']);
                                          % Load file in 'imscroll' directory containing parameters
                                   %DriftInfo.MaxFrames         == largest frame number in the image sequence
                                   %DriftInfo.SpotNumber2Track == number of spots we will track for drifting
                                   %DriftInfo.InputFrames     ==  vector listing frame numbers we will use for tracking
                                   %DriftInfo.PolyOrderx     ==  Order of the polynomial we will use for
                                   %                            fitting x drift (=1 or 2 typically)
                                   %DriftInfo.PolyOrdery     ==  Order of the polynomial we will use for
                                   %                            fitting  y drift (=1 or 2 typically)

                                   % see b18p11 for reference
    
    %dum=varargin{1};                             % Need dum, images, folder  to
    %images=varargin{2};                          % pass to the slider1 routine
    %folder=varargin{3};
    inputfrms=DriftInfo.InputFrames;
    spotnumber=DriftInfo.SpotNumber2Track;
    maxfrm=DriftInfo.MaxFrames;
    datt=[];                                    % Will contain the list of drifting tracked coordinates
    for frmindxx=1:length(inputfrms)            %Loop to track spots as they drift
                                                %Set the frame number to a
                                                %frame number in the list
        set(handles.ImageNumber,'Value',inputfrms(frmindxx));
                                          % Change the gui image displayed
        %slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
        slider1_Callback(handles.ImageNumber, eventdata, handles)
                                          % Click on a number of reference spots
        [xcoord ycoord]=ginput(spotnumber);
                                          % Accumulate the xy coordinate of the average
                                          % of all the reference spots
        datt=[datt; inputfrms(frmindxx) sum(xcoord)/spotnumber sum(ycoord)/spotnumber];
    end
                                    % Now fit the drifting coordinates to a
                                    % quadratic polynomial
    fitx=polyfit(datt(:,1),datt(:,2),DriftInfo.PolyOrderX);
    fity=polyfit(datt(:,1),datt(:,3),DriftInfo.PolyOrderY);
                                    % Generate points for each frame that
                                    % fit the average reference spot
                                    % location
    handles.DriftCorrectxy=datt;    % Place the collected xy points into handles
    valuex=polyval(fitx,1:maxfrm);
    valuey=polyval(fity,1:maxfrm);
                                    % Take slope of this curve to get
                                    % changes in the spot locations for
                                    % each frame
    diffx=diff(valuex);
    diffy=diff(valuey);
    figure(24);hold off;plot(datt(:,1),datt(:,2),'o',1:maxfrm,valuex,'r');shg
    figure(25);hold off;plot(datt(:,1),datt(:,3),'o',1:maxfrm,valuey,'r');shg
                                    % Generate driftlist that will correct
                                    % drifts for all spot in the images
 
    driftlist=[1 0 0
        [2:maxfrm]' diffx' diffy'];
    handles.DriftList=driftlist;
    handles.DriftListInput=driftlist;
    handles.DriftListStored=driftlist;
     
    guidata(gcbo,handles);           % Place our new driftlist into handles
                                    % Save our driftlist into a file
   % eval(['save ' handles.FileLocations.imscroll '\DriftList.dat driftlist']);
   % eval(['save ' handles.FileLocations.imscroll '\DriftListIntermediates.dat datt']);
     % eval(['save ' handles.FileLocations.imscroll 'DriftList.dat driftlist']);
     %eval(['save ' handles.FileLocations.imscroll 'DriftListIntermediates.dat datt']);
     eval(['save ' handles.FileLocations.gui_files 'DriftList.dat driftlist']);
     eval(['save ' handles.FileLocations.gui_files 'DriftListIntermediates.dat datt']);

elseif argnum==9
                % Here to change the jump value of the jumpVary button
                % We will take the new value of jumpVary from the editable
                % text written in the FrameAve editable text region
     new_jumpVary_string=get(handles.FrameAve,'String');
                % Change the string written on the jumpVary button
     set(handles.jumpVary,'String',new_jumpVary_string);
                % Change the value of jumpVary so the jump will now match
                % the value written on the button
     new_jumpVary_value=round(str2num(new_jumpVary_string));
     set(handles.jumpVary,'Value',new_jumpVary_value);
     set(handles.jumpVary,'UserData',new_jumpVary_value);
     guidata(gcbo,handles);
elseif argnum==10
                % Generate the background AOIs
                % Get the image on which to base the AOI placement
    %avefrm=getframes(dum,images,folder,handles);
    avefrm=getframes_v1(handles);
                % handles.FitData=[framenumber ave x y pixnum aoinumber];
    [aoinumber argnumber]=size(handles.FitData);
                % Generate large aoi for each existing AOI
        pixnum1=handles.Pixnums(2); % Width of intermediate AOI
        pixnum2=handles.Pixnums(3); % Width of large AOI
                                    % Add column 7 to FitData (aoiinfo2) to
                                    % identify which of the three aois we
                                    % are dealing with
        handles.FitData=[handles.FitData(:,1:6) zeros(aoinumber,1)];
        
                                    % Create a matrix to temporarily hold 
                                    % new aois of
                                    % size pixnum1 and pixnum2
        aoiinfo2extra=[];
        for indxaoi=1:aoinumber
            aoix=handles.FitData(indxaoi,3);    % aoi x and y coord
            aoiy=handles.FitData(indxaoi,4);
                     % Vary center of large AOI, compute its integral
            intlist=integration_list(aoix,aoiy,pixnum1,pixnum2,avefrm);
                     % Pick the location with minimum integral
           logik=intlist(:,3)==min(intlist(:,3));
                     % Pick median in the list
                   
            %intlistlength=length(intlist(:,3));
            %[Y I]=sort(intlist(:,3));
            %logik=intlist(:,3)==intlist(I(round(intlistlength/2)),3);
    
                     % Move the AOI to new location x y
            %**handles.FitData(indxaoi,3:4)=intlist(logik,1:2);
                     % Set size of AOI to match Pixnum2 value for large aoi
            %**handles.FitData(indxaoi,5)=pixnum2;
            %
                                % Make entry for aoi of size pixnum2
            pixnum2Entry=handles.FitData(indxaoi,:);
                                % Column 7 will contain the original aoi#
            pixnum2Entry(1,7)=pixnum2Entry(1,6);
                                % AOI size will equal pixnum2=Pixnums(3)
            pixnum2Entry(1,5)=pixnum2;
                                % Place the aoi according to th above
                                % minimization protocol (median, or min)
            pixnum2Entry(3:4)=intlist(logik,1:2);
                
                                % Make entry for aoi of size pixnum1
            pixnum1Entry=handles.FitData(indxaoi,:);
                                % column 7 will contain the original aoi #
            pixnum1Entry(1,7)=pixnum1Entry(1,6);
                                % AOI size will equal pixnum1=Pixnums(2);
            pixnum1Entry(1,5)=pixnum1;
            
                                % Make entry for original aoi
            pixnumOrigEntry=handles.FitData(indxaoi,:);
                                % Column 7 will contain the original aoi #
            pixnumOrigEntry(1,7)=pixnumOrigEntry(1,6);
                                % AOI size will equal Pixnums(1)
            pixnumOrigEntry(1,5)=handles.Pixnums(1);
                                % Now add the extra AOIs to our list
            aoiinfo2extra=[aoiinfo2extra
                           pixnumOrigEntry
                           pixnum1Entry
                           pixnum2Entry];
                   
            
        end
                            % update the list of AOIs to include all three
                            % sizes
        handles.FitData=aoiinfo2extra;
                            % update the aoi numbers in the list (column 6) 
        handles.FitData=update_FitData_aoinum(handles.FitData);
        
         % Write AOI width in pixnum field of gui
        set(handles.PixelNumber,'String',num2str(pixnum2));
                    % Once all aois are generated, rewrite field of aois
         guidata(gcbo,handles);
        %slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
        slider1_Callback(handles.ImageNumber, eventdata, handles)
elseif argnum==11                                        % load an AOI set
                                  % and recenter the aois with the gaussian
                                  % fit centers from a single frame fit
    filestring=get(handles.OutputFilename,'String');
                                 % Load aoifits from same directory where
                                 % we store it
    eval(['load ' handles.FileLocations.data filestring ' -mat']);
     %eval(['load ' filestring ' -mat'])              % loads 'aoifits' structure from a prior
                                                        % fit to aois
                                                     % Reset filename where we store or retrieve the 'aoifits' structure 
%keyboard
     set(handles.OutputFilename,'String','default.dat');
     
     %[aoirows aoicol]=size(aoifits.centers);
     %onecol=ones(aoirows,1);                            % column of ones (length= # of aois)
                                                        % Now substitute the AOIs into the present field 
                           %[frm#       ave                 x     y             pixnum                aoinum   ]  
     %handles.FitData=[onecol aoifits.parameter(1)*onecol aoifits.centers aoifits.parameter(2)*onecol [1:aoirows]'];
     handles.FitData=aoifits.aoiinfo2;                  % Replace the current aoiinfo2
                                          % data set with that from aoifits
                                          % (they are likely the same)
    
     %handles.FitData(:,3:4)=aoifits.data(:,4:5)+1;   % Replace the center positions
                                          % with the gaussian fit centers
     handles.FitData(:,3:4)=aoifits.data(:,4:5);    % Drop the +1 after our change in
                                % gauss2d_mapstruc_v2.m line 64 for the
                                % pc.ImageData= definition
     set(handles.PixelNumber,'String',num2str(aoifits.parameter(2)));
     guidata(gcbo,handles)
      %slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder
      slider1_Callback(handles.ImageNumber, eventdata, handles)
elseif argnum==12
            % Here to shadow map the aois from field 1 to field 2
            % This will place just a visual copy (not added to aoi list)of
            % the aoi set (from field 1) into field 2
    fitparmvector=get(handles.FitDisplay,'UserData');     % Fetch the mapping parameters
                                                           % Stored as [mxx21 mxy21 bx; 
                                                           %            myx
                                                           %            21 myy21 by]
    aoiinfo=handles.FitData;                  % [framenumber ave a b pixnum aoinumber]
    [maoi naoi]=size(aoiinfo);                % maoi=number of aois
    imagenum=round(get(handles.ImageNumber,'value'));        % Retrieve the value of the slider
    for indxx=1:maoi
       XYshift=[0 0];                  % initialize aoi shift due to drift
        if get(handles.StartParameters,'Value')==2
                                    % here to move the aois in order to follow drift
            XYshift=ShiftAOI(indxx,imagenum,aoiinfo,handles.DriftList);
        end
        aoiinfo(indxx,3)=aoiinfo(indxx,3)+XYshift(1);
        aoiinfo(indxx,4)=aoiinfo(indxx,4)+XYshift(2);
    end
                %The xy coordinates in aoiinfo now reflect the actual (i.e.
                %shifted due to drift, if appropriate) positions of the
                %aois
        
        
                   % handles.Fitdata=[ frm# ave AOIx  AOIy pixnum aoinum]
    nowpts=[aoiinfo(:,3) aoiinfo(:,4)];
       % Now map to the x2
    shadowx_vec=mappingfunc(fitparmvector(1,:),nowpts);
                   % Now map to the y2 
    shadowy_vec=mappingfunc(fitparmvector(2,:),nowpts);
                  % Remove points that map to indices less than 1
    logik=(shadowx_vec>=1 ) & (shadowy_vec >=1);
    shadowx_vec=shadowx_vec(logik,1);
    shadowy_vec=shadowy_vec(logik,1);
            %Now we are ready to write the aoi boxes in field 2
    pixnum=str2double(get(handles.PixelNumber,'String'));
    shadownum=length(shadowy_vec);        % Number of aoi boxes to write
      
 
    for indx=1:shadownum
        
        if get(handles.FitChoice,'Value')==5
                    % == 5 if we are set to do linear interpolation with 
                    % repsect to integrating partial overlap of AOIs and
                    % pixels
                    % draw boxes around all the aois, adding the XYshift to
                    % account for possible drift
                    % Here to draw boxes that fractionally overlaps pixels
            draw_box([shadowx_vec(indx) shadowy_vec(indx)],(pixnum)/2,...
                              (pixnum)/2,'y');
        else
                    % Here to draw aoi boxes only at pixel boundaries
            draw_box_v1([shadowx_vec(indx) shadowy_vec(indx)],(pixnum)/2,...
                               (pixnum)/2,'y');
        end
    end  
elseif argnum==13
                % Here to shadow map from field 2 to field 1
                % This will place just a visual copy (not added to aoi list)of
            % the aoi set (from field 2) into field 1
                                           % Invert the map: go from e.g. x2 -> x1
                                                        % output is x1y1 coordinates
                                                        % B9p148
    fitparmvector=get(handles.FitDisplay,'UserData');     % Fetch the mapping parameters
                                                           % Stored as [mxx21 mxy21 bx; 
                                                           %            myx21 myy21 by]
    za=fitparmvector(1,1);zb=fitparmvector(1,2);zc=fitparmvector(1,3);
    zd=fitparmvector(2,1);ze=fitparmvector(2,2);zf=fitparmvector(2,3);
    denom=1/(za*ze-zb*zd);
    invmapmat=denom*[ze -zb (zb*zf-zc*ze) ; -zd za (zd*zc-zf*za)]; % b9p148 inverse matrix

    aoiinfo=handles.FitData;                  % [framenumber ave a b pixnum aoinumber]
    [maoi naoi]=size(aoiinfo);                % maoi=number of aois
    imagenum=round(get(handles.ImageNumber,'value'));        % Retrieve the value of the slider
    for indxx=1:maoi
       XYshift=[0 0];                  % initialize aoi shift due to drift
        if get(handles.StartParameters,'Value')==2
                                    % here to move the aois in order to follow drift
            XYshift=ShiftAOI(indxx,imagenum,aoiinfo,handles.DriftList);
        end
        aoiinfo(indxx,3)=aoiinfo(indxx,3)+XYshift(1);
        aoiinfo(indxx,4)=aoiinfo(indxx,4)+XYshift(2);
    end
                %The xy coordinates in aoiinfo now reflect the actual (i.e.
                %shifted due to drift, if appropriate) positions of the
                %aois
        
        
                   % handles.Fitdata=[ frm# ave AOIx  AOIy pixnum aoinum]
    nowpts=[aoiinfo(:,3) aoiinfo(:,4)];
       % Now map to the x1
    shadowx_vec=mappingfunc(invmapmat(1,:),nowpts);
                   % Now map to the y1 
    shadowy_vec=mappingfunc(invmapmat(2,:),nowpts);
                % Remove points that map to indices less than 1
    logik=(shadowx_vec>=1 ) & (shadowy_vec >=1);
    shadowx_vec=shadowx_vec(logik,1);
    shadowy_vec=shadowy_vec(logik,1);
            %Now we are ready to write the aoi boxes in field 1
    pixnum=str2double(get(handles.PixelNumber,'String'));
    shadownum=length(shadowy_vec);        % Number of aoi boxes to write
      
 
    for indx=1:shadownum
        
        if get(handles.FitChoice,'Value')==5
                    % == 5 if we are set to do linear interpolation with 
                    % repsect to integrating partial overlap of AOIs and
                    % pixels
                    % draw boxes around all the aois, adding the XYshift to
                    % account for possible drift
                    % Here to draw boxes that fractionally overlaps pixels
            draw_box([shadowx_vec(indx) shadowy_vec(indx)],(pixnum)/2,...
                              (pixnum)/2,'y');
        else
                    % Here to draw aoi boxes only at pixel boundaries
            draw_box_v1([shadowx_vec(indx) shadowy_vec(indx)],(pixnum)/2,...
                               (pixnum)/2,'y');
        end
    end
    elseif argnum==14
        

end



function FitDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to FitDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FitDisplay as text
%        str2double(get(hObject,'String')) returns contents of FitDisplay as a double

            % Take the input string and place it also in the 'Value' field
           
%display_fitparms=eval( ['[ ' get(handles.FitDisplay,'String') ' ]' ]);
display_fitparms=( ['[ ' get(handles.FitDisplay,'String') ' ]' ]);

set(handles.FitDisplay,'UserData',str2num(display_fitparms)');
% --- Executes during object creation, after setting all properties.
function FitDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FitDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function InputParms_Callback(hObject, eventdata, handles)
% hObject    handle to InputParms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InputParms as text
%        str2double(get(hObject,'String')) returns contents of InputParms as a double


% --- Executes during object creation, after setting all properties.
function InputParms_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InputParms (see GCBO)
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


% --- Executes on button press in AddAois.
function AddAois_Callback(hObject, eventdata, handles)
% hObject    handle to AddAois (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

aoiinfo=[];
framenumber=str2num(get(handles.ImageNumberValue,'String'));
ave=round(str2double(get(handles.FrameAve,'String')));
pixnum=str2double(get(handles.PixelNumber,'String'));
flag=0;
axes(handles.axes1)
                                             % Get the last aoi number,
                                             % add one to assign next aoi number 
aoinumber=1+max(handles.FitData(:,6));
while flag==0
    [a b but]=ginput(1);
    if but==3
        flag=1;
    else
        aoiinfo=[aoiinfo; framenumber ave a b pixnum aoinumber];
        aoinumber=aoinumber+1;                      %Give each aoi a number
        axes(handles.axes1);
        hold on
        [maoi naoi]=size(aoiinfo);
        for indx=maoi:maoi 
            if get(handles.FitChoice,'Value')==5
                    % == 5 if we are set to do linear interpolation with 
                    % repsect to integrating partial overlap of AOIs and
                    % pixels
                    % draw boxes around all the aois, adding the XYshift to
                    % account for possible drift
                    % Here to draw boxes that fractionally overlaps pixels
            draw_box(aoiinfo(indx,3:4),(pixnum)/2,...
                              (pixnum)/2,'b');
            else
                    % Here to draw aoi boxes only at pixel boundaries
            draw_box_v1(aoiinfo(indx,3:4),(pixnum)/2,...
                               (pixnum)/2,'b');
            end
                    % draw boxes around all the aois
            %draw_box_v1(aoiinfo(indx,3:4),(pixnum)/2,...
                            %  (pixnum)/2,'b');
        end
        hold off
    end
end
handles.FitData=[handles.FitData; aoiinfo];        % Add the new list onto the enc of the existing
                                                   %in the handles structure
guidata(gcbo,handles) ;


% --- Executes on button press in MarkFolder2SpotsToggle.
function MarkFolder2SpotsToggle_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to MarkFolder2SpotsToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MarkFolder2SpotsToggle
%dum=varargin{3};
%images=varargin{4};
%folder1=varargin{1};
%folder2=varargin{2};

folder1=handles.TiffFolder;
folder2=handles.TiffFolder2;
folder=folder1;


if get(handles.MarkFolder2SpotsToggle,'Value')==1
    set(handles.MarkFolder2SpotsToggle,'String','Mark Spots')
    handles.AOIsize=str2num(get(handles.PixelNumber,'String'));
    handles.Folder1=folder1;
    handles.Folder2=folder2;
    handles.Flag=0;                 % Flag used to mark that timing and aoiinfo spots
                                % from the folder2 have already been loaded
                                % (they will be loaded on next call to
                                % 'MarkFolder2Spots()' function )
                                %
                                % Make place for timebase of Folder1,
                                % Folder2 and the aoiinfo file from the
                                % Folder2 sequence
    handles.Time1=[];
    handles.Time2=[];
    handles.Folder2aoiinfo=[];
    guidata(gcbo,handles);
    MarkFolder2Spots_v1(handles);
else
    set(handles.MarkFolder2SpotsToggle,'String','No Spots')
end
                    % Next two lines are needed to prevent the frame number
                    % from jumping in the display (I do not know why this
                    % occurs)
userdat=get(handles.ImageNumber,'UserData');
set(handles.ImageNumber,'value',userdat);

%slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
slider1_Callback(handles.ImageNumber, eventdata, handles)

% --- Executes on button press in RemoveAois.
function RemoveAois_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to RemoveAois (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};
aoiinfo=[];
framenumber=str2num(get(handles.ImageNumberValue,'String'));
ave=round(str2double(get(handles.FrameAve,'String')));
pixnum=str2double(get(handles.PixelNumber,'String'));
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
       
        num_closest=aoicompare([a b],handles);
       
       
                                            % logical array, =1 when it
                                            % matches the aoi number
       
        logik=(handles.FitData(:,6)==num_closest);
       
        handles.FitData(logik,:)=[];          % remove information for that aoi
                                            % Refresh display
      
        handles.FitData=update_FitData_aoinum(handles.FitData);
        guidata(gcbo,handles) ;
        %slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
        slider1_Callback(handles.ImageNumber, eventdata, handles)
        
    end
handles.FitData=[handles.FitData; aoiinfo];        % Update the existin list of aoi
                                                  % information so that no
                                                  % aoi numbers are skipped

handles.FitData=update_FitData_aoinum(handles.FitData);

guidata(gcbo,handles) ;

end


% --- Executes on button press in MagChoice.
function MagChoice_Callback(hObject, eventdata, handles)
% hObject    handle to MagChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Push Button that switches between two limit sets for magnifying
% two different regions of the FOV.
MagxyCoord=get(handles.MagChoice,'UserData');          % Retrieve the UserData matrix containing the sets of xy limits
                                                    % userdat = [xpts(1) xpts(2) ypts(1) ypts(2)]
MagValue=get(handles.MagChoice,'Value');            % Retrieve the value of the popup menu                                                    
       % Make the editable text MagRangeYX region reflect the proper magnification setting 
set(handles.MagRangeYX,'String',['[' num2str(MagxyCoord(MagValue,:)) ']' ]);
           % Make the display reflect the new magnification setting
slider1_Callback(handles.ImageNumber, eventdata, handles)





% --- Executes on button press in IncreaseFrameAve.
function IncreaseFrameAve_Callback(hObject, eventdata, handles)
% hObject    handle to IncreaseFrameAve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
frmave=str2double(get(handles.FrameAve,'String'));
frmave=frmave+1;
set(handles.FrameAve,'String',num2str(frmave));

% --- Executes on button press in DecreaseFrameAve.
function DecreaseFrameAve_Callback(hObject, eventdata, handles)
% hObject    handle to DecreaseFrameAve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
frmave=str2double(get(handles.FrameAve,'String'));
if frmave>=2
frmave=frmave-1;
set(handles.FrameAve,'String',num2str(frmave));
end


% --- Executes on button press in OneFrameAve.
function OneFrameAve_Callback(hObject, eventdata, handles)
% hObject    handle to OneFrameAve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.FrameAve,'String',1);


% --- Executes on button press in jump1000.
function jump1000_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to jump1000 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};
valnow=get(handles.ImageNumber,'Value');
if get(handles.PlusMinus,'Value')==0
   set(handles.ImageNumber,'Value',valnow+1000);
elseif get(handles.PlusMinus,'Value')==1
    set(handles.ImageNumber,'Value',valnow-1000);
end

   %slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
   slider1_Callback(handles.ImageNumber, eventdata, handles)


% --- Executes on button press in PlusMinus.
function PlusMinus_Callback(hObject, eventdata, handles)
% hObject    handle to PlusMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PlusMinus
if get(handles.PlusMinus,'Value')==0
    set(handles.PlusMinus,'String','+')
elseif get(handles.PlusMinus,'Value')==1
    set(handles.PlusMinus,'String','-')
end


% --- Executes on button press in jump100.
function jump100_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to jump100 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};
valnow=get(handles.ImageNumber,'Value');
if get(handles.PlusMinus,'Value')==0
   set(handles.ImageNumber,'Value',valnow+100);
elseif get(handles.PlusMinus,'Value')==1
    set(handles.ImageNumber,'Value',valnow-100);
end

%   slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
    slider1_Callback(handles.ImageNumber, eventdata, handles)
   


% --- Executes on button press in jump10.
function jump10_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to jump10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};
valnow=get(handles.ImageNumber,'Value');
if get(handles.PlusMinus,'Value')==0
   set(handles.ImageNumber,'Value',valnow+10);
elseif get(handles.PlusMinus,'Value')==1
    set(handles.ImageNumber,'Value',valnow-10);
end

   %slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
   slider1_Callback(handles.ImageNumber, eventdata, handles)


% --- Executes on button press in jump1.
function jump1_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to jump1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};
valnow=get(handles.ImageNumber,'Value');
if get(handles.PlusMinus,'Value')==0
   set(handles.ImageNumber,'Value',valnow+1);
elseif get(handles.PlusMinus,'Value')==1
    set(handles.ImageNumber,'Value',valnow-1);
end

  %slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
  slider1_Callback(handles.ImageNumber, eventdata, handles)


% --- Executes on button press in jumpVary.
function jumpVary_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to jumpVary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};

valnow=get(handles.ImageNumber,'Value');    % Present value of the frame index
jumpVary_value=get(handles.jumpVary,'UserData');
                                            % Change the value of the frame
                                            % index by jumpVary_value
if get(handles.PlusMinus,'Value')==0
   set(handles.ImageNumber,'Value',valnow+jumpVary_value);
elseif get(handles.PlusMinus,'Value')==1
    set(handles.ImageNumber,'Value',valnow-jumpVary_value);
end
          % Call the slider subroutine that will alter the frame index
  %slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
  slider1_Callback(handles.ImageNumber, eventdata, handles)



function GlimpseNumber_Callback(hObject, eventdata, handles)
% hObject    handle to GlimpseNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GlimpseNumber as text
%        str2double(get(hObject,'String')) returns contents of GlimpseNumber as a double
                % First check the range limits of glimpse folder number to
                % insure that a folder exists for the number entered
sourcenum=get(handles.ImageSource,'Value');
if sourcenum==3
                        % here for glimpse files
    presentnum=str2num(get(handles.GlimpseNumber,'String'));
    if presentnum>handles.GlimpseMax
        presentnum=handles.GlimpseMax;
    elseif presentnum<1
        presentnum=1;
    end
    set(handles.GlimpseNumber,'String',num2str(presentnum));
    switch str2num(get(handles.GlimpseNumber,'String'))
        case 1
            handles.gfolder=handles.gfolder1;
            handles.gheader=handles.gheader1;
            handles.DumGfolder=handles.DumGfolder1;
            %handles.Dum=handles.DumGfolder1;
        case 2
            handles.gfolder=handles.gfolder2;
            handles.gheader=handles.gheader2;
            handles.DumGfolder=handles.DumGfolder2;
            %handles.Dum=handles.DumGfolder2;
        case 3
            handles.gfolder=handles.gfolder3;
            handles.gheader=handles.gheader3;
            handles.DumGfolder=handles.DumGfolder3;
            %handles.Dum=handles.DumGfolder3;
        case 4
            handles.gfolder=handles.gfolder4;
            handles.gheader=handles.gheader4;
            handles.DumGfolder=handles.DumGfolder4;
            %handles.Dum=handles.DumGfolder4;
        case 5
            handles.gfolder=handles.gfolder5;
            handles.gheader=handles.gheader5;
            handles.DumGfolder=handles.DumGfolder5;
            %handles.Dum=handles.DumGfolder5;
    end
    gname=handles.gfolder;
    lengthgname=length(gname);
    set(handles.GlimpseFolderName,'String',gname(lengthgname-14:lengthgname));
    guidata(gcbo,handles);
end
if sourcenum==1
                        % here for using tiff files
    presentnum=str2num(get(handles.GlimpseNumber,'String'));
    if presentnum>handles.TiffMax
        presentnum=handles.TiffMax;
    elseif presentnum<1
        presentnum=1;
    end
    set(handles.GlimpseNumber,'String',num2str(presentnum));
    switch str2num(get(handles.GlimpseNumber,'String'))
        case 1
            handles.TiffFolder=handles.TiffFolder1;
            handles.DumTiffFolder=handles.DumTiffFolder1;
            %handles.Dum=handles.DumTiffFolder1;
        case 2
            handles.TiffFolder=handles.TiffFolder2;
            handles.DumTiffFolder=handles.DumTiffFolder2;
            %handles.Dum=handles.DumTiffFolder2;
        case 3
            handles.TiffFolder=handles.TiffFolder3;
            handles.DumTiffFolder=handles.DumTiffFolder3;
            %handles.Dum=handles.DumTiffFolder3;
        case 4
            handles.TiffFolder=handles.TiffFolder4;
            handles.DumTiffFolder=handles.DumTiffFolder4;
            %handles.Dum=handles.DumTiffFolder4;
        case 5
            handles.TiffFolder=handles.TiffFolder5;
            handles.DumTiffFolder=handles.DumTiffFolder5;
            %handles.Dum=handles.DumTiffFolder5;
    end
    tiffname=handles.TiffFolder;
    lengthtiffname=length(tiffname);
    set(handles.GlimpseFolderName,'String',tiffname(lengthtiffname-14:lengthtiffname));
    guidata(gcbo,handles);
end




% --- Executes during object creation, after setting all properties.
function GlimpseNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GlimpseNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in IncreaseGlimpseNumber.
function IncreaseGlimpseNumber_Callback(hObject, eventdata, handles)
% hObject    handle to IncreaseGlimpseNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
                            % Get the current glimpse folder number
sourcenum=get(handles.ImageSource,'Value');
if sourcenum==3
    % here for using glimpse file
    presentnum=str2num(get(handles.GlimpseNumber,'String'));
    if presentnum < handles.GlimpseMax
                            % If we are not at the max glimpse folder
                            % number, then increase it
        presentnum=presentnum+1;
                            % Update the text showing glimpse folder #
        set(handles.GlimpseNumber,'String',num2str(presentnum));
    end
                        % Invoke callback to update the glimpse folder 
                        % number used in displaying the images
    GlimpseNumber_Callback(handles.GlimpseNumber, eventdata, handles)
end
if sourcenum==1
    % here for using tiff file
    presentnum=str2num(get(handles.GlimpseNumber,'String'));
    if presentnum < handles.TiffMax
                            % If we are not at the max glimpse folder
                            % number, then increase it
        presentnum=presentnum+1;
                            % Update the text showing glimpse folder #
        set(handles.GlimpseNumber,'String',num2str(presentnum));
    end
                        % Invoke callback to update the glimpse folder 
                        % number used in displaying the images
    GlimpseNumber_Callback(handles.GlimpseNumber, eventdata, handles)
end

% --- Executes on button press in DecreaseGlimpseNumber.
function DecreaseGlimpseNumber_Callback(hObject, eventdata, handles)
% hObject    handle to DecreaseGlimpseNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    presentnum=str2num(get(handles.GlimpseNumber,'String'));
    if presentnum > 1
                            % If we are not at the max glimpse folder
                            % number, then increase it
        presentnum=presentnum-1;
                            % Update the text showing glimpse folder #
        set(handles.GlimpseNumber,'String',num2str(presentnum));
    end
                        % Invoke callback to update the glimpse folder 
                        % number used in displaying the images
    GlimpseNumber_Callback(handles.GlimpseNumber, eventdata, handles)



function GlimpseFolderName_Callback(hObject, eventdata, handles)
% hObject    handle to GlimpseFolderName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GlimpseFolderName as text
%        str2double(get(hObject,'String')) returns contents of GlimpseFolderName as a double


% --- Executes during object creation, after setting all properties.
function GlimpseFolderName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GlimpseFolderName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MoveAoi.
function MoveAoi_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to MoveAoi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};
[rosed col_danny]=size(handles.FitData);
aoiinfo=[];
framenumber=str2num(get(handles.ImageNumberValue,'String'));
ave=round(str2double(get(handles.FrameAve,'String')));
pixnum=str2double(get(handles.PixelNumber,'String'));
flag=0;
axes(handles.axes1)
 

    [a1 b1]=ginput(1);
    
                                            % Get the aoi number for the
                                            % aoi closest to where user
                                            % clicked
        if col_danny==7
                        % Here is we have generated extra aois using 
                        % handles.Pixnums (foldstruc.Pixnums)
                        % Only accept an aoi with size matching Pixnums(3)
                        % because we only want to move the largest aoi
            num_closest=aoicompare_v1([a1 b1],handles,handles.Pixnums(3));
        else
            num_closest=aoicompare_v1([a1 b1],handles);
        end
                                            % logical array, =1 when it
                                            % matches the aoi number
                                            % FitData=[framenumber ave x y pixnum aoinumber];
     
        logik=(handles.FitData(:,6)==num_closest);
    [a2 b2]=ginput(1);
        handles.FitData(logik,3:4)=[a2 b2];          % replace information for that aoi

                                            % Update the handles structure 

guidata(gcbo,handles);
%slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
slider1_Callback(handles.ImageNumber, eventdata, handles)


% --- Executes on button press in Keyboard.
function Keyboard_Callback(hObject, eventdata, handles)
% hObject    handle to Keyboard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard



function AOINumberDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to AOINumberDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AOINumberDisplay as text
%        str2double(get(hObject,'String')) returns contents of AOINumberDisplay as a double


% --- Executes during object creation, after setting all properties.
XYshift=[0 0];                  % Shift related to drifting
aoiinfo=(handles.FitData);       % [framenumber ave x y pixnum aoinumber]
imagenum=round(get(handles.ImageNumber,'value'));        % Retrieve the value of the slider
    
aoinumber=str2num(get(handles.AOINumberDisplay,'String'));

maxaoinum=max(aoiinfo(:,6));
minaoinum=min(aoiinfo(:,6));
if aoinumber<minaoinum
    set(handles.AOINumberDisplay,'String',num2str(minaoinum-1))
end
if aoinumber>maxaoinum
    set(handles.AOINumberDisplay,'String',num2str(maxaoinum+1))
end
if (aoinumber>maxaoinum) | (aoinumber<minaoinum)
                                % Here if aoinumber input is greater than
                                % the number of aois or less than 1 
                                % => print all the #s
   
   for indx=1:maxaoinum
       if get(handles.StartParameters,'Value')==2
                    % Here if moving AOI  => compensate for drift
        XYshift=ShiftAOI(indx,imagenum,aoiinfo,handles.DriftList);
       end
       
       text(aoiinfo(indx,3)+XYshift(1),aoiinfo(indx,4)+XYshift(2),num2str(aoiinfo(indx,6)),'Color','y')
   end
else
    if get(handles.StartParameters,'Value')==2
                    % Here if moving AOI  => there should be a driftlist
        XYshift=ShiftAOI(aoinumber,imagenum,aoiinfo,handles.DriftList);
       end
   text(aoiinfo(aoinumber,3)+XYshift(1),aoiinfo(aoinumber,4)+XYshift(2),num2str(aoinumber),'Color','y')
end
function AOINumberDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AOINumberDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in IncreaseAOINumberDisplay.
function IncreaseAOINumberDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to IncreaseAOINumberDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

aoinumber=str2num(get(handles.AOINumberDisplay,'String'));
set(handles.AOINumberDisplay,'String',num2str(aoinumber+1))
AOINumberDisplay_Callback(handles.AOINumberDisplay, eventdata, handles)

% --- Executes on button press in DecreaseAOINumberDisplay.
function DecreaseAOINumberDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to DecreaseAOINumberDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
aoinumber=str2num(get(handles.AOINumberDisplay,'String'));
set(handles.AOINumberDisplay,'String',num2str(aoinumber-1))
AOINumberDisplay_Callback(handles.AOINumberDisplay, eventdata, handles)


% --- Executes on button press in LoadFieldFrames.
function LoadFieldFrames_Callback(hObject, eventdata, handles)
% hObject    handle to LoadFieldFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


 [fn fp]=uigetfile('*.*','Load Field Frames Cell Array'); 
    eval( ['load ' [fp fn] ' -mat' ] );                    % Load the FieldFrames{ }
                                     % cell array containing lists of
                                     % frames pertinent for each field
                                     % The file should contain a cell array
                                     % called 'FieldFrames'
 
    handles.FieldFrames=FieldFrames;
    if exist('DriftList','var')
                                % DriftList is a cell array of driftlists
                                % Here if we have loaded separate driftlist
                                % tables for each of the cells in
                                % FieldFrames
        handles.DriftFlagg=1;   % Set flag to indicate user input the cell array of driftlists
        handles.DriftListCell=DriftList;
        
    end
    
                            
    guidata(gcbo,handles);                  % Update the handles structure 

function FieldFrameText_Callback(hObject, eventdata, handles)
% hObject    handle to FieldFrameText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FieldFrameText as text
%        str2double(get(hObject,'String')) returns contents of FieldFrameText as a double


% --- Executes during object creation, after setting all properties.
function FieldFrameText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FieldFrameText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FieldNumber_Callback(hObject, eventdata, handles)
% hObject    handle to FieldNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FieldNumber as text
%        str2double(get(hObject,'String')) returns contents of FieldNumber as a double
presentnum=str2num(get(handles.FieldNumber,'String'));
[a b]=size(handles.FieldFrames);      % dimensions of cell array
maxnumber=max([a b]);

                                % Test limits of field number
if (presentnum<=maxnumber) & (presentnum>=0)  
    handles.CurrentFieldNumber=presentnum;
else
    handles.CurrentFieldNumber=0;
end
                               % Write current field number in text region
set(handles.FieldNumber,'String',num2str(handles.CurrentFieldNumber));
                % Update the current field (list of frames to be shown)
if handles.CurrentFieldNumber>0
    handles.CurrentField=eval( handles.FieldFrames{handles.CurrentFieldNumber});
    set(handles.FieldFrameText,'String',handles.FieldFrames{handles.CurrentFieldNumber})
    if handles.DriftFlagg==1;
                          %Here if user input a cell array of driftlists along
                          %with the FieldFrames cell array
        handles.DriftList=handles.DriftListCell{ handles.CurrentFieldNumber};
        handles.DriftListInput=handles.DriftListCell{ handles.CurrentFieldNumber};
    end
else
    handles.CurrentField=[1:100000];
    set(handles.FieldFrameText,'String','all frames')
    if handles.DriftFlagg==1
                          %Here if user input a cell array of driftlists along
                          %with the FieldFrames cell array
        if max(size(handles.DriftListStored))==0
                          % No driftlist input via foldstruc.DriftList
                          % Just construct a driftlist with all zeros
            handles.DriftList=[handles.DriftListCell{1}(:,1) zeros(size(handles.DriftListCell{1}(:,2:3) ))];
            handles.DriftListInput=[handles.DriftListCell{1}(:,1) zeros(size(handles.DriftListCell{1}(:,2:3) ))];
            handles.DriftListStored=[handles.DriftListCell{1}(:,1) zeros(size(handles.DriftListCell{1}(:,2:3) ))];
        else
        handles.DriftList=handles.DriftListStored;   % See callback for LoadFieldFrames
                                           % This driftlist will be 
                                           % the driftlist put in using
                                           % foldstrucDriftList, or the one
                                           % made above with all zeros
        handles.DriftListInput=handles.DriftListStored;
        end
    end
end
guidata(gcbo,handles);    

% --- Executes during object creation, after setting all properties.
function FieldNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FieldNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in IncreaseFieldFrames.
function IncreaseFieldFrames_Callback(hObject, eventdata, handles)
% hObject    handle to IncreaseFieldFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  [a b]=size(handles.FieldFrames);      % dimensions of cell array
  maxnumber=max([a b]);
  presentnum=str2num(get(handles.FieldNumber,'String'));
    if presentnum < maxnumber
                            % If we are not at the highes field 
                            % number, then increase it
        presentnum=presentnum+1;
                            % Update the text showing glimpse folder #
        set(handles.FieldNumber,'String',num2str(presentnum));


    end
guidata(gcbo,handles);    
 
                        % Invoke callback to update the field folder
                        % number used in displaying the images
FieldNumber_Callback(handles.FieldNumber, eventdata, handles)

% --- Executes on button press in DecreaseFieldFrames.
function DecreaseFieldFrames_Callback(hObject, eventdata, handles)
% hObject    handle to DecreaseFieldFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 
  presentnum=str2num(get(handles.FieldNumber,'String'));
    if presentnum >0
                            % If we are not at the lowest field 
                            % number, then decrease it
        presentnum=presentnum-1;
                            % Update the text showing glimpse folder #
        set(handles.FieldNumber,'String',num2str(presentnum));

    end
guidata(gcbo,handles);    
 
                        % Invoke callback to update the field folder
                        % number used in displaying the images
FieldNumber_Callback(handles.FieldNumber, eventdata, handles)


% --- Executes on button press in BackgroundChoice.
function BackgroundChoice_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to BackgroundChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BackgroundChoice
%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};
                    % Make + and - controls visible for Radius if we
                    % are looking at background
if any(get(handles.BackgroundChoice,'Value')==[2 3])
    set(handles.EditRollingBallRadius,'Visible','on')
    set(handles.IncrementRollingBallRadius,'Visible','on')
    set(handles.DecrementRollingBallRadius,'Visible','on')
     set(handles.EditRollingBallHeight,'Visible','on')
    set(handles.IncrementRollingBallHeight,'Visible','on')
    set(handles.DecrementRollingBallHeight,'Visible','on')
     set(handles.EditRollingBallRadius,'String',15);
     handles.RollingBallRadius=5;
     set(handles.EditRollingBallHeight,'String',5);
     handles.RollingBallHeight=2;

elseif any(get(handles.BackgroundChoice,'Value')==[4 5])
    set(handles.EditRollingBallRadius,'Visible','on')
    set(handles.IncrementRollingBallRadius,'Visible','on')
    set(handles.DecrementRollingBallRadius,'Visible','on')
     set(handles.EditRollingBallHeight,'Visible','on')
    set(handles.IncrementRollingBallHeight,'Visible','on')
    set(handles.DecrementRollingBallHeight,'Visible','on')
    
     set(handles.EditRollingBallRadius,'String',5);
     handles.RollingBallRadius=5;
     set(handles.EditRollingBallHeight,'String',2);
     handles.RollingBallHeight=2;
     guidata(gcbo,handles) ;
else
    set(handles.EditRollingBallRadius,'String',5);
     handles.RollingBallRadius=5; 
     set(handles.EditRollingBallHeight,'String',2);
     handles.RollingBallHeight=2;
    set(handles.EditRollingBallRadius,'Visible','off')
    set(handles.IncrementRollingBallRadius,'Visible','off')
    set(handles.DecrementRollingBallRadius,'Visible','off')
    set(handles.EditRollingBallHeight,'Visible','off')
    set(handles.IncrementRollingBallHeight,'Visible','off')
    set(handles.DecrementRollingBallHeight,'Visible','off')
     guidata(gcbo,handles) ;
end
guidata(gcbo,handles);

%slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
slider1_Callback(handles.ImageNumber, eventdata, handles)



function EditRollingBallRadius_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to EditRollingBallRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditRollingBallRadius as text
%        str2double(get(hObject,'String')) returns contents of EditRollingBallRadius as a double

%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};
handles.RollingBallRadius=str2num(get(handles.EditRollingBallRadius,'String'));
guidata(gcbo,handles);

%slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
slider1_Callback(handles.ImageNumber, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function EditRollingBallRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditRollingBallRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in IncrementRollingBallRadius.
function IncrementRollingBallRadius_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to IncrementRollingBallRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};
handles.RollingBallRadius=round(handles.RollingBallRadius+1);
set(handles.EditRollingBallRadius,'String',num2str(handles.RollingBallRadius))
guidata(gcbo,handles);  

%slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
slider1_Callback(handles.ImageNumber, eventdata, handles)
% --- Executes on button press in DecrementRollingBallRadius.
function DecrementRollingBallRadius_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to DecrementRollingBallRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};
handles.RollingBallRadius=round(handles.RollingBallRadius-1);
if handles.RollingBallRadius<1
    handles.RollingBallRadius=1;
end
set(handles.EditRollingBallRadius,'String',num2str(handles.RollingBallRadius))
guidata(gcbo,handles);  
%slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
slider1_Callback(handles.ImageNumber, eventdata, handles)



function EditRollingBallHeight_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to EditRollingBallHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditRollingBallHeight as text
%        str2double(get(hObject,'String')) returns contents of EditRollingBallHeight as a double
%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};
handles.RollingBallHeight=str2num(get(handles.EditRollingBallHeight,'String'));
guidata(gcbo,handles);


%slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
slider1_Callback(handles.ImageNumber, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function EditRollingBallHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditRollingBallHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in IncrementRollingBallHeight.
function IncrementRollingBallHeight_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to IncrementRollingBallHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};
handles.RollingBallHeight=round(handles.RollingBallHeight+1);
set(handles.EditRollingBallHeight,'String',num2str(handles.RollingBallHeight))
guidata(gcbo,handles); 
%slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
slider1_Callback(handles.ImageNumber, eventdata, handles)

% --- Executes on button press in DecrementRollingBallHeight.
function DecrementRollingBallHeight_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to DecrementRollingBallHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%dum=varargin{1};
%images=varargin{2};
%folder=varargin{3};
handles.RollingBallHeight=round(handles.RollingBallHeight-1);
if handles.RollingBallHeight<1
    handles.RollingBallHeight=1;
end
set(handles.EditRollingBallHeight,'String',num2str(handles.RollingBallHeight))
guidata(gcbo,handles);  
%slider1_Callback(handles.ImageNumber, eventdata, handles, dum,images,folder)
slider1_Callback(handles.ImageNumber, eventdata, handles)


% --- Executes on button press in PickSpotsButton.
function PickSpotsButton_Callback(hObject, eventdata, handles)
% hObject    handle to PickSpotsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
                                    % Check ranges of NoiseDiameter,
                                    % SpotDiameter and SpotBrightness

if handles.NoiseDiameter<=0
    handles.NoiseDiameter=1;
    set(handles.EditNoiseDiameter,'String',num2str(handles.NoiseDiameter))
end
if handles.SpotDiameter<=0
    handles.SpotDiameter=1;
    set(handles.EditSpotDiameter,'String',num2str(handles.SpotDiameter))
end
if handles.SpotBrightness<=0
    handles.SpotBrightness=1;
    set(handles.EditSpotBrightness,'String',num2str(handles.SpotBrightness))
end
FitDataHold=handles.FitData;
handles.FitData=[];                 % Clear the screen of AOIs by setting handles.Fitdata=[]
guidata(gcbo,handles)               % and showing the image
slider1_Callback(handles.ImageNumber, eventdata, handles)
handles.FitData=FitDataHold;        % Replace the handles.FitData and show the image with
                                    % the proper AOIs
guidata(gcbo,handles)

ave=round(str2double(get(handles.FrameAve,'String')));  % Averaging number
pixnum=str2double(get(handles.PixelNumber,'String'));   % Pixel number
imagenum=round(get(handles.ImageNumber,'value'));        % Retrieve the value of the slider
avefrm=getframes_v1(handles);                       % Fetch the current frame(s) displayes
if get(handles.SpotsPopup,'Value')==8
    % Here if the spots are to be picked from images that have been background
    % subtracted according to handles.BackgroundChoice
    if any(get(handles.BackgroundChoice,'Value')==[2 3])
                        % Here to use rolling ball background (subtract off background) 
           
        avefrm=avefrm-rolling_ball(avefrm,handles.RollingBallRadius,handles.RollingBallHeight);
    elseif any(get(handles.BackgroundChoice,'Value')==[4 5])
                        % Here to use Danny's newer background subtraction(subtract off background) 
            
        avefrm=avefrm-bkgd_image(avefrm,handles.RollingBallRadius,handles.RollingBallHeight);
    end
end
[frmrose frmcol]=size(avefrm);                  % [ysize xsize]
xlow=1;xhigh=frmcol;ylow=1;yhigh=frmrose;         % Initialize frame limits
if get(handles.Magnify,'Value')==1                  % Check whether the image magnified (restrct range for finding spots)  
    limitsxy=eval( get(handles.MagRangeYX,'String') );  % Get the limits of the magnified region
                                                   % [xlow xhi ylow yhi]
    xlow=limitsxy(1);xhigh=limitsxy(2);            % Define frame limits as those of 
    ylow=limitsxy(3);yhigh=limitsxy(4);            % the magnified region

end
                                    % Find the spots

dat=bpass(double(avefrm(ylow:yhigh,xlow:xhigh)),handles.NoiseDiameter,handles.SpotDiameter);
pk=pkfnd(dat,handles.SpotBrightness,handles.SpotDiameter);
pk=cntrd(dat,pk,handles.SpotDiameter+2);

[aoirose aoicol]=size(pk);
                    % Put the aois into our handles structure handles.FitData = [frm#  ave  x   y  pixnum  aoinum]
if aoirose~=0       % If there are spots, put them into handles.FitData and draw them
    pk(:,1)=pk(:,1)+xlow-1;             % Correct coordinates for case where we used a magnified region
    pk(:,2)=pk(:,2)+ylow-1;
    handles.FitData=[imagenum*ones(aoirose,1) ave*ones(aoirose,1) pk(:,1) pk(:,2) pixnum*ones(aoirose,1) [1:aoirose]'];
                    % Draw the aois
    for indx=1:aoirose
        draw_box_v1(handles.FitData(indx,3:4),(pixnum)/2,(pixnum)/2,'b');
    end
end
                        %draw_aois(handles.FitData,imagenum,pixnum,handles.DriftList);
guidata(gcbo,handles)



function EditNoiseDiameter_Callback(hObject, eventdata, handles)
% hObject    handle to EditNoiseDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditNoiseDiameter as text
%        str2double(get(hObject,'String')) returns contents of EditNoiseDiameter as a double
handles.NoiseDiameter=str2num(get(handles.EditNoiseDiameter,'String'));
handles.NoiseDiameter=round(handles.NoiseDiameter*10)/10;       % express in 0.1 increments
set(handles.EditNoiseDiameter,'String',num2str(handles.NoiseDiameter) );

guidata(gcbo,handles)
PickSpotsButton_Callback(handles.PickSpotsButton, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function EditNoiseDiameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditNoiseDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditSpotDiameter_Callback(hObject, eventdata, handles)
% hObject    handle to EditSpotDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSpotDiameter as text
%        str2double(get(hObject,'String')) returns contents of EditSpotDiameter as a double
handles.SpotDiameter=round(str2num(get(handles.EditSpotDiameter,'String')));
if handles.SpotDiameter/2==round(handles.SpotDiameter/2)      % True if even, but SpotDiameter must be odd
    handles.SpotDiameter=handles.SpotDiameter+1;
end
set(handles.EditSpotDiameter,'String',num2str(handles.SpotDiameter));


guidata(gcbo,handles)
PickSpotsButton_Callback(handles.PickSpotsButton, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function EditSpotDiameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSpotDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditSpotBrightness_Callback(hObject, eventdata, handles)
% hObject    handle to EditSpotBrightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSpotBrightness as text
%        str2double(get(hObject,'String')) returns contents of EditSpotBrightness as a double
handles.SpotBrightness=str2num(get(handles.EditSpotBrightness,'String'));
handles.SpotBrightness=round(handles.SpotBrightness*10)/10;       % express in 0.1 increments
set(handles.EditSpotBrightness,'String',num2str(handles.SpotBrightness) );


guidata(gcbo,handles)

PickSpotsButton_Callback(handles.PickSpotsButton, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function EditSpotBrightness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSpotBrightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in IncrementNoiseDiameter.
function IncrementNoiseDiameter_Callback(hObject, eventdata, handles)
% hObject    handle to IncrementNoiseDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.NoiseDiameter=handles.NoiseDiameter+.1;
handles.NoiseDiameter=round(handles.NoiseDiameter*10)/10;       % express in 0.1 increments
set(handles.EditNoiseDiameter,'String',num2str(handles.NoiseDiameter) );

guidata(gcbo,handles)
PickSpotsButton_Callback(handles.PickSpotsButton, eventdata, handles)


% --- Executes on button press in DecrementNoiseDiameter.
function DecrementNoiseDiameter_Callback(hObject, eventdata, handles)
% hObject    handle to DecrementNoiseDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.NoiseDiameter=handles.NoiseDiameter-.1;
handles.NoiseDiameter=round(handles.NoiseDiameter*10)/10;       % express in 0.1 increments
set(handles.EditNoiseDiameter,'String',num2str(handles.NoiseDiameter) );

guidata(gcbo,handles)
PickSpotsButton_Callback(handles.PickSpotsButton, eventdata, handles)


% --- Executes on button press in IncrementSpotDiameter.
function IncrementSpotDiameter_Callback(hObject, eventdata, handles)
% hObject    handle to IncrementSpotDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.SpotDiameter=handles.SpotDiameter+2;
handles.SpotDiameter=round(handles.SpotDiameter);       % express in integer increments
if handles.SpotDiameter/2==round(handles.SpotDiameter/2)      % True if even, but SpotDiameter must be odd
    handles.SpotDiameter=handles.SpotDiameter+1;            % Make it odd
end

set(handles.EditSpotDiameter,'String',num2str(handles.SpotDiameter) );

guidata(gcbo,handles)
PickSpotsButton_Callback(handles.PickSpotsButton, eventdata, handles)

% --- Executes on button press in DecrementSpotDiameter.
function DecrementSpotDiameter_Callback(hObject, eventdata, handles)
% hObject    handle to DecrementSpotDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.SpotDiameter=handles.SpotDiameter-2;
handles.SpotDiameter=round(handles.SpotDiameter);       % express in integer increments
if handles.SpotDiameter/2==round(handles.SpotDiameter/2)      % True if even, but SpotDiameter must be odd
    handles.SpotDiameter=handles.SpotDiameter+1;            % Make it odd
end
set(handles.EditSpotDiameter,'String',num2str(handles.SpotDiameter) );

guidata(gcbo,handles)
PickSpotsButton_Callback(handles.PickSpotsButton, eventdata, handles)

% --- Executes on button press in IncrementSpotBrightness.
function IncrementSpotBrightness_Callback(hObject, eventdata, handles)
% hObject    handle to IncrementSpotBrightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.SpotBrightness=handles.SpotBrightness+1;
handles.SpotBrightness=round(handles.SpotBrightness*10)/10;       % express in 0.1 increments
set(handles.EditSpotBrightness,'String',num2str(handles.SpotBrightness) );

guidata(gcbo,handles)
PickSpotsButton_Callback(handles.PickSpotsButton, eventdata, handles)

% --- Executes on button press in DecrementSpotBrightness.
function DecrementSpotBrightness_Callback(hObject, eventdata, handles)
% hObject    handle to DecrementSpotBrightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.SpotBrightness=handles.SpotBrightness-1;
handles.SpotBrightness=round(handles.SpotBrightness*10)/10;       % express in 0.1 increments
set(handles.EditSpotBrightness,'String',num2str(handles.SpotBrightness) );

guidata(gcbo,handles)
PickSpotsButton_Callback(handles.PickSpotsButton, eventdata, handles)


% --- Executes on button press in FramesPickSpots.
function FramesPickSpots_Callback(hObject, eventdata, handles)
% hObject    handle to FramesPickSpots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
                    % Run program to find spots in all frames specified by
                    % the FrameRange input
set(handles.FramesPickSpots,'String','...')
pause(0.1)
handles.AllSpots=FindAllSpots(handles,3500);     % 500=max # of spots to retain for each frame
                % AllSpots.AllSpotsCells{m,1}=[x y] list of spots, AllSpots{m,2}= # of spots in this frame
                % AllSpots.AllSpotsCells{m,3}= frame #
%keyboard
set(handles.FramesPickSpots,'String','Frames')
set(handles.MapSpots,'Visible','on')
guidata(gcbo,handles)


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%slider1_Callback(hObject, eventdata, handles)
                % Get current value of ImageNumber slider
present_value=round(get(handles.ImageNumber,'value'));
            % Compare current slider value to previous value
if present_value~=get(handles.ImageNumber,'UserData');
            % Update image only if slider position has changed
    slider1_Callback(handles.ImageNumber, eventdata, handles)
end

    


% --- Executes on scroll wheel click while the figure is in focus.
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ProximityMappingToggle.
function ProximityMappingToggle_Callback(hObject, eventdata, handles)
% hObject    handle to ProximityMappingToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ProximityMappingToggle


% --- Executes on button press in MapSpots.
function MapSpots_Callback(hObject, eventdata, handles)
% hObject    handle to MapSpots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
frms=handles.AllSpots.FrameVector;      % List of frames over which we found spots
hold on
[rose col]=size(frms);

for indx=1:max(rose,col)                           % Cycle through frame range
    
    spotnum=handles.AllSpots.AllSpotsCells{indx,2}; % number of spots found in the current frame
     xy=handles.AllSpots.AllSpotsCells{indx,1}(1:spotnum,:);    % xy pairs of spots in current frame
     plot(xy(:,1),xy(:,2),'y.');                % Plot the spots for current frame
end
hold off


     


% --- Executes on button press in SpotsButton.
function SpotsButton_Callback(hObject, eventdata, handles)
% hObject    handle to SpotsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%SpotsButtonA   mark so we can easily search for this line 

SpotsButtonChoice=get(handles.SpotsPopup,'Value');
switch SpotsButtonChoice
    case 1
                % Here to pick spots in just the current frame
                 % We use the unprocessed frame (without any background
                % subtraction regardless of the BackgroundChoice setting
       if handles.NoiseDiameter<=0
           handles.NoiseDiameter=1;
           set(handles.EditNoiseDiameter,'String',num2str(handles.NoiseDiameter))
       end
       if handles.SpotDiameter<=0
           handles.SpotDiameter=1;
           set(handles.EditSpotDiameter,'String',num2str(handles.SpotDiameter))
       end
       if handles.SpotBrightness<=0
           handles.SpotBrightness=1;
           set(handles.EditSpotBrightness,'String',num2str(handles.SpotBrightness))
       end
       FitDataHold=handles.FitData;
       handles.FitData=[];                 % Clear the screen of AOIs by setting handles.Fitdata=[]
       guidata(gcbo,handles)               % and showing the image
       slider1_Callback(handles.ImageNumber, eventdata, handles)
       handles.FitData=FitDataHold;        % Replace the handles.FitData and show the image with
                                    % the proper AOIs
       guidata(gcbo,handles)

       ave=round(str2double(get(handles.FrameAve,'String')));  % Averaging number
       pixnum=str2double(get(handles.PixelNumber,'String'));   % Pixel number
       imagenum=round(get(handles.ImageNumber,'value'));        % Retrieve the value of the slider
       avefrm=getframes_v1(handles);                       % Fetch the current frame(s) displayes
      
 % keyboard   
       [frmrose frmcol]=size(avefrm);                  % [ysize xsize]
       xlow=1;xhigh=frmcol;ylow=1;yhigh=frmrose;         % Initialize frame limits
       if get(handles.Magnify,'Value')==1                  % Check whether the image magnified (restrct range for finding spots)  
           limitsxy=eval( get(handles.MagRangeYX,'String') );  % Get the limits of the magnified region
                                                   % [xlow xhi ylow yhi]
           xlow=limitsxy(1);xhigh=limitsxy(2);            % Define frame limits as those of 
           ylow=limitsxy(3);yhigh=limitsxy(4);            % the magnified region

       end
                                    % Find the spots

       dat=bpass(double(avefrm(ylow:yhigh,xlow:xhigh)),handles.NoiseDiameter,handles.SpotDiameter);
       pk=pkfnd(dat,handles.SpotBrightness,handles.SpotDiameter);
       pk=cntrd(dat,pk,handles.SpotDiameter+2);

       [aoirose aoicol]=size(pk);
                    % Put the aois into our handles structure handles.FitData = [frm#  ave  x   y  pixnum  aoinum]
       if aoirose~=0       % If there are spots, put them into handles.FitData and draw them
           pk(:,1)=pk(:,1)+xlow-1;             % Correct coordinates for case where we used a magnified region
           pk(:,2)=pk(:,2)+ylow-1;
           handles.FitData=[imagenum*ones(aoirose,1) ave*ones(aoirose,1) pk(:,1) pk(:,2) pixnum*ones(aoirose,1) [1:aoirose]'];
                    % Draw the aois
           for indx=1:aoirose
               draw_box_v1(handles.FitData(indx,3:4),(pixnum)/2,(pixnum)/2,'b');
           end
       end
                        %draw_aois(handles.FitData,imagenum,pixnum,handles.DriftList);
       guidata(gcbo,handles)
%*******************************************************************************************
    case 2
                % Here to find spots over the specified frame range
      set(handles.FramesPickSpots,'String','...')
      set(handles.SpotsButton,'String','...')
      pause(0.1)
      AllSpots=FindAllSpots(handles,3500);     % 3500=max # of spots to retain for each frame
                % AllSpots.AllSpotsCells{m,1}=[x y] list of spots, AllSpots{m,2}= # of spots in this frame
                % AllSpots.AllSpotsCells{m,3}= frame #
      if get(handles.HighLowAllSpots,'Value')==0
                % Here if toggle button is not depressed
                % => get AllSpots for with high threshold for detection
          handles.AllSpots=AllSpots;
      else
                % Here if toggle button is depressed
                % => get AllSpots for with low threshold for detection
          handles.AllSpotsLow=AllSpots;
      end
      set(handles.FramesPickSpots,'String','Frames')
      set(handles.SpotsButton,'String','Frames')
      set(handles.MapSpots,'Visible','on')  
      guidata(gcbo,handles)
%******************************************************************************************
    case 3
                % Here to draw Map all the spots picked into the current field of view
        frms=handles.AllSpots.FrameVector;      % List of frames over which we found spots
        hold on
        [rose col]=size(frms);
        
        imval=round(str2num(get(handles.ImageNumberValue,'String')));   % Current frame number
        for indx=1:max(rose,col)                           % Cycle through frame range
            XYshift=[0 0];                  % initialize aoi shift due to drift
                    if any(get(handles.StartParameters,'Value')==[2 3 4])
                                    % here to move the detected spots:  reference all spots to the current frame number to follow drift
                                    % aoiinfo =[(framenumber when marked) ave x y pixnum aoinumber]
                                    % Fake aoiinfo structure (one entry) specification frame being the indx (i.e. frame for spot detection)  
                    aoiinfo=[indx 1 0 0 5 1];
                                    % Get the xy shift that moves each spot detected in frame=indx to the current frame=imval   
                    XYshift=ShiftAOI(1,imval,aoiinfo,handles.DriftList);
                    end
            
            spotnum=handles.AllSpots.AllSpotsCells{indx,2}; % number of spots found in the current frame
            xy=handles.AllSpots.AllSpotsCells{indx,1}(1:spotnum,:);     % xy pairs of spots in current frame
       
            xy(:,1)=xy(:,1)+XYshift(1);     % Offset all the x coordinates for the detected spots
            xy(:,2)=xy(:,2)+XYshift(2);     % Offset all the y coordinates for the detected spots
            plot(xy(:,1),xy(:,2),'ro','MarkerSize',3.0);                % Plot the spots for current frame
        end
        hold off
%*****************************************************************************************
    case 4
                 % Here to save a file containing the AllSpots structure
       filestring=get(handles.OutputFilename,'String');
     %eval(['save p:\matlab12\larry\data\' filestring ' aoiinfo2' ])
     %eval(['save ' handles.FileLocations.data '\' filestring ' aoiinfo2']);
       AllSpots=FreeAllSpotsMemory(handles.AllSpots);   % Get rid of zero entries in the spot list
                                                        % prior to saving the AllSpots structure 
       eval(['save ' handles.FileLocations.data filestring ' AllSpots']);
       set(handles.OutputFilename,'String','default.dat');
    case 5
                % Here to load a file containing the AllSpots structure
       filestring=get(handles.InputParms,'String');
       eval(['load ' handles.FileLocations.data filestring ' -mat'])
       handles.AllSpots=AllSpots;
       guidata(gcbo,handles);
%******************************************************************************************* 
%*****************************************************************************************
    case 6
                 % Here to save a file containing the AllSpotsLow structure
       filestring=get(handles.OutputFilename,'String');
     %eval(['save p:\matlab12\larry\data\' filestring ' aoiinfo2' ])
     %eval(['save ' handles.FileLocations.data '\' filestring ' aoiinfo2']);
       AllSpotsLow=FreeAllSpotsMemory(handles.AllSpotsLow);   % Get rid of zero entries in the spot list
                                                        % prior to saving the AllSpots structure 
       eval(['save ' handles.FileLocations.data filestring ' AllSpotsLow']);
       set(handles.OutputFilename,'String','default.dat');
    case 7
                % Here to load a file containing the AllSpotsLow structure
       filestring=get(handles.InputParms,'String');
       eval(['load ' handles.FileLocations.data filestring ' -mat'])
       handles.AllSpotsLow=AllSpotsLow;
       guidata(gcbo,handles);
%**************************************************************************
   case 8
                % Here to pick spots in just the current frame
                % We use the background subtracted image if the user
                % is seeing a background subtracted image (i.e. if
                % handles.BackgroundChoice does not equal 1
               
       if handles.NoiseDiameter<=0
           handles.NoiseDiameter=1;
           set(handles.EditNoiseDiameter,'String',num2str(handles.NoiseDiameter))
       end
       if handles.SpotDiameter<=0
           handles.SpotDiameter=1;
           set(handles.EditSpotDiameter,'String',num2str(handles.SpotDiameter))
       end
       if handles.SpotBrightness<=0
           handles.SpotBrightness=1;
           set(handles.EditSpotBrightness,'String',num2str(handles.SpotBrightness))
       end
       FitDataHold=handles.FitData;
       handles.FitData=[];                 % Clear the screen of AOIs by setting handles.Fitdata=[]
       guidata(gcbo,handles)               % and showing the image
       slider1_Callback(handles.ImageNumber, eventdata, handles)
       handles.FitData=FitDataHold;        % Replace the handles.FitData and show the image with
                                    % the proper AOIs
       guidata(gcbo,handles)

       ave=round(str2double(get(handles.FrameAve,'String')));  % Averaging number
       pixnum=str2double(get(handles.PixelNumber,'String'));   % Pixel number
       imagenum=round(get(handles.ImageNumber,'value'));        % Retrieve the value of the slider
       avefrm=getframes_v1(handles);                       % Fetch the current frame(s) displayes
       if any(get(handles.BackgroundChoice,'Value')==[2 3])
                        % Here to use rolling ball background (subtract off background) 
           
             avefrm=avefrm-rolling_ball(avefrm,handles.RollingBallRadius,handles.RollingBallHeight);
       elseif any(get(handles.BackgroundChoice,'Value')==[4 5])
                        % Here to use Danny's newer background subtraction(subtract off background) 
            
             avefrm=avefrm-bkgd_image(avefrm,handles.RollingBallRadius,handles.RollingBallHeight);
       end
       [frmrose frmcol]=size(avefrm);                  % [ysize xsize]
       xlow=1;xhigh=frmcol;ylow=1;yhigh=frmrose;         % Initialize frame limits
       if get(handles.Magnify,'Value')==1                  % Check whether the image magnified (restrct range for finding spots)  
           limitsxy=eval( get(handles.MagRangeYX,'String') );  % Get the limits of the magnified region
                                                   % [xlow xhi ylow yhi]
           xlow=limitsxy(1);xhigh=limitsxy(2);            % Define frame limits as those of 
           ylow=limitsxy(3);yhigh=limitsxy(4);            % the magnified region

       end
                                    % Find the spots

       dat=bpass(double(avefrm(ylow:yhigh,xlow:xhigh)),handles.NoiseDiameter,handles.SpotDiameter);
       pk=pkfnd(dat,handles.SpotBrightness,handles.SpotDiameter);
       pk=cntrd(dat,pk,handles.SpotDiameter+2);

       [aoirose aoicol]=size(pk);
                    % Put the aois into our handles structure handles.FitData = [frm#  ave  x   y  pixnum  aoinum]
       if aoirose~=0       % If there are spots, put them into handles.FitData and draw them
           pk(:,1)=pk(:,1)+xlow-1;             % Correct coordinates for case where we used a magnified region
           pk(:,2)=pk(:,2)+ylow-1;
           handles.FitData=[imagenum*ones(aoirose,1) ave*ones(aoirose,1) pk(:,1) pk(:,2) pixnum*ones(aoirose,1) [1:aoirose]'];
                    % Draw the aois
           for indx=1:aoirose
               draw_box_v1(handles.FitData(indx,3:4),(pixnum)/2,(pixnum)/2,'b');
           end
       end
                        %draw_aois(handles.FitData,imagenum,pixnum,handles.DriftList);
       guidata(gcbo,handles)
%*******************************************************************************************

end


% --- Executes on selection change in SpotsPopup.
function SpotsPopup_Callback(hObject, eventdata, handles)
% hObject    handle to SpotsPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SpotsPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SpotsPopup
if get(handles.SpotsPopup,'Value')==1
    set(handles.SpotsButton,'String','Pick Frm')
elseif get(handles.SpotsPopup,'Value')==2
    set(handles.SpotsButton,'String','Frames')
elseif get(handles.SpotsPopup,'Value')==3
    set(handles.SpotsButton,'String','Map')
elseif get(handles.SpotsPopup,'Value')==4
    set(handles.SpotsButton,'String','Save')
elseif get(handles.SpotsPopup,'Value')==5
    set(handles.SpotsButton,'String','Load')
elseif get(handles.SpotsPopup,'Value')==6
    set(handles.SpotsButton,'String','Save')
elseif get(handles.SpotsPopup,'Value')==7
    set(handles.SpotsButton,'String','Load')
elseif get(handles.SpotsPopup,'Value')==8
    set(handles.SpotsButton,'String','Bkgnd Frm')
end


% --- Executes on button press in IncreasePixelNumber.
function IncreasePixelNumber_Callback(hObject, eventdata, handles)
% hObject    handle to IncreasePixelNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pixnum=str2double(get(handles.PixelNumber,'String'));   % Fetch current number
pixnum=round(pixnum+1);                     % Increment by 1
set(handles.PixelNumber,'String',num2str(pixnum))   % Write new number

% --- Executes on button press in DecreasePixelNumber.
function DecreasePixelNumber_Callback(hObject, eventdata, handles)
% hObject    handle to DecreasePixelNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pixnum=str2double(get(handles.PixelNumber,'String'));   % Fetch current number
if round(pixnum)>1
    pixnum=round(pixnum-1);                     % decrease by 1 only if pixnum >=2
end
set(handles.PixelNumber,'String',num2str(pixnum))   % Write new number


% --- Executes on button press in TrackAOIs.
function TrackAOIs_Callback(hObject, eventdata, handles)
% hObject    handle to TrackAOIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TrackAOIs



function SigmaValueString_Callback(hObject, eventdata, handles)
% hObject    handle to SigmaValueString (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SigmaValueString as text
%        str2double(get(hObject,'String')) returns contents of SigmaValueString as a double


% --- Executes during object creation, after setting all properties.
function SigmaValueString_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigmaValueString (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in HighLowAllSpots.
function HighLowAllSpots_Callback(hObject, eventdata, handles)
% hObject    handle to HighLowAllSpots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of HighLowAllSpots

if get(handles.HighLowAllSpots,'Value')==0
    set(handles.HighLowAllSpots,'String','High')
else
    set(handles.HighLowAllSpots,'String','Low')
end


% --- Executes on button press in IncrementSpotBrightness10.
function IncrementSpotBrightness10_Callback(hObject, eventdata, handles)
% hObject    handle to IncrementSpotBrightness10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.SpotBrightness=handles.SpotBrightness+10;
handles.SpotBrightness=round(handles.SpotBrightness*10)/10;       % express in 0.1 increments
set(handles.EditSpotBrightness,'String',num2str(handles.SpotBrightness) );

guidata(gcbo,handles)
PickSpotsButton_Callback(handles.PickSpotsButton, eventdata, handles)

% --- Executes on button press in DecrementSpotBrightness10.
function DecrementSpotBrightness10_Callback(hObject, eventdata, handles)
% hObject    handle to DecrementSpotBrightness10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.SpotBrightness=handles.SpotBrightness-10;
handles.SpotBrightness=round(handles.SpotBrightness*10)/10;       % express in 0.1 increments
set(handles.EditSpotBrightness,'String',num2str(handles.SpotBrightness) );

guidata(gcbo,handles)
PickSpotsButton_Callback(handles.PickSpotsButton, eventdata, handles)


% --- Executes on button press in MoveAOIs.
function MoveAOIs_Callback(hObject, eventdata, handles)
% hObject    handle to MoveAOIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MoveAOIs
if get(handles.MoveAOIs,'Value')==1
    set(handles.MoveAOIsUp,'Visible','on')      % Here if MoveAOIs toggle is depressed
    set(handles.MoveAOIsDown,'Visible','on')
    set(handles.MoveAOIsRight,'Visible','on')
    set(handles.MoveAOIsLeft,'Visible','on')
    set(handles.AOINumberDisplay,'String','1')
else
    set(handles.MoveAOIsUp,'Visible','off')      % Here if MoveAOIs toggle is not depressed
    set(handles.MoveAOIsDown,'Visible','off')
    set(handles.MoveAOIsRight,'Visible','off')
    set(handles.MoveAOIsLeft,'Visible','off')    
end


% --- Executes on button press in MoveAOIsUp.
function MoveAOIsUp_Callback(hObject, eventdata, handles)
% hObject    handle to MoveAOIsUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
step=round(str2num(get(handles.AOINumberDisplay,'String')));
handles.FitData(:,4)=handles.FitData(:,4)-step;    % Move all aois up 1 pixel
guidata(gcbo,handles);
slider1_Callback(handles.ImageNumber, eventdata, handles)
% --- Executes on button press in MoveAOIsDown.
function MoveAOIsDown_Callback(hObject, eventdata, handles)
% hObject    handle to MoveAOIsDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
step=round(str2num(get(handles.AOINumberDisplay,'String')));
handles.FitData(:,4)=handles.FitData(:,4)+step;    % Move all aois up 1 pixel
guidata(gcbo,handles);
slider1_Callback(handles.ImageNumber, eventdata, handles)

% --- Executes on button press in MoveAOIsRight.
function MoveAOIsRight_Callback(hObject, eventdata, handles)
% hObject    handle to MoveAOIsRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
step=round(str2num(get(handles.AOINumberDisplay,'String')));
handles.FitData(:,3)=handles.FitData(:,3)+step;    % Move all aois up 1 pixel
guidata(gcbo,handles);
slider1_Callback(handles.ImageNumber, eventdata, handles)

% --- Executes on button press in MoveAOIsLeft.
function MoveAOIsLeft_Callback(hObject, eventdata, handles)
% hObject    handle to MoveAOIsLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
step=round(str2num(get(handles.AOINumberDisplay,'String')));
handles.FitData(:,3)=handles.FitData(:,3)-step;    % Move all aois up 1 pixel
guidata(gcbo,handles);
slider1_Callback(handles.ImageNumber, eventdata, handles)


% --- Executes on selection change in MappingMenu.
function MappingMenu_Callback(hObject, eventdata, handles)
% hObject    handle to MappingMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MappingMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MappingMenu

MenuValue=get(handles.MappingMenu,'Value');
switch MenuValue
    case 1
        set(handles.MapButton,'String','AddAOI File')
        set(handles.EditUniqueRadius,'Visible','off')
        set(handles.IncrementUniqueRadius,'Visible','off')
        set(handles.DecrementUniqueRadius,'Visible','off')
    case 2
        set(handles.MapButton,'String','Define Field1')
        set(handles.EditUniqueRadius,'Visible','off')
        set(handles.IncrementUniqueRadius,'Visible','off')
        set(handles.DecrementUniqueRadius,'Visible','off')
    case 3
        set(handles.MapButton,'String','Define Field2')
        set(handles.EditUniqueRadius,'Visible','off')
        set(handles.IncrementUniqueRadius,'Visible','off')
        set(handles.DecrementUniqueRadius,'Visible','off')
    case 4
        set(handles.MapButton,'String','Make Map')
        set(handles.EditUniqueRadius,'Visible','off')
        set(handles.IncrementUniqueRadius,'Visible','off')
        set(handles.DecrementUniqueRadius,'Visible','off')
    case 5
        set(handles.MapButton,'String','Restore PreAddition')
        set(handles.EditUniqueRadius,'Visible','off')
        set(handles.IncrementUniqueRadius,'Visible','off')
        set(handles.DecrementUniqueRadius,'Visible','off')
    case 6
        set(handles.MapButton,'String','Import Map')
        set(handles.EditUniqueRadius,'Visible','off')
        set(handles.IncrementUniqueRadius,'Visible','off')
        set(handles.DecrementUniqueRadius,'Visible','off')
    case 7
        set(handles.MapButton,'String','Add to Field1')
        set(handles.EditUniqueRadius,'Visible','off')
        set(handles.IncrementUniqueRadius,'Visible','off')
        set(handles.DecrementUniqueRadius,'Visible','off')
    case 8
        set(handles.MapButton,'String','Add to Field2')
        set(handles.EditUniqueRadius,'Visible','off')
        set(handles.IncrementUniqueRadius,'Visible','off')
        set(handles.DecrementUniqueRadius,'Visible','off')
    case 9 
        set(handles.MapButton,'String','Remove Close AOIs')
        set(handles.EditUniqueRadius,'Visible','on')
        set(handles.IncrementUniqueRadius,'Visible','on')
        set(handles.DecrementUniqueRadius,'Visible','on')
    case 10
        set(handles.MapButton,'String','Remove X2 AOI')
        set(handles.EditUniqueRadius,'Visible','off')
        set(handles.IncrementUniqueRadius,'Visible','off')
        set(handles.DecrementUniqueRadius,'Visible','off')
    case 11
        set(handles.MapButton,'String','Remove Y2 AOI')
        set(handles.EditUniqueRadius,'Visible','off')
        set(handles.IncrementUniqueRadius,'Visible','off')
        set(handles.DecrementUniqueRadius,'Visible','off')
    case 12
        set(handles.MapButton,'String','Remove MT AOIs')
        set(handles.EditUniqueRadius,'Visible','on')
        set(handles.IncrementUniqueRadius,'Visible','on')
        set(handles.DecrementUniqueRadius,'Visible','on')
    case 13
        set(handles.MapButton,'String','Remove Spot AOIs')
        set(handles.EditUniqueRadius,'Visible','on')
        set(handles.IncrementUniqueRadius,'Visible','on')
        set(handles.DecrementUniqueRadius,'Visible','on')
        
end
        
% --- Executes during object creation, after setting all properties.
function MappingMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MappingMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MapButton.
function MapButton_Callback(hObject, eventdata, handles)
% hObject    handle to MapButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MenuValue=get(handles.MappingMenu,'Value');
switch MenuValue
    case 1      
                        % Here to add an AOI file containing aoiinfo2 matrix to present handles.FitData matrix
        handles.PreAddition=handles.FitData;                % Store the present aoi set before adding with another set 
        [fn fp]=uigetfile('*.*','Load aoiinfo2 list');      % Promt user for filename 
        eval( ['load ' [fp fn]  ' -mat'] );                         % Load the aoiinfo2 
        handles.FitData=[handles.FitData;aoiinfo2];         % Add aoiinfo2 list to current FitData list
        [rose col]=size(handles.FitData);                   % 
        handles.FitData(:,6)=[1:rose]';                     % Renumber the AOIs to match current length of list
        guidata(gcbo,handles);                              % Update the handles
        slider1_Callback(handles.ImageNumber, eventdata, handles)   % Update the image
    case 2
                        % Here to define the current set of AOIs as the Field1 AOIs for the purpose of mapping 
        handles.Field1=handles.FitData;
        guidata(gcbo,handles);
        aoiinfo2=handles.Field1;        % Save the new field1 list of aois
        eval(['save ' handles.FileLocations.mapping 'field1.dat aoiinfo2'])
    case 3
                        % Here to define the current set of AOIs as the Field2 AOIs for the purpose of mapping 
        handles.Field2=handles.FitData;
        guidata(gcbo,handles);
        aoiinfo2=handles.Field2;            % Save the new field2 list of aois
        eval(['save ' handles.FileLocations.mapping 'field2.dat aoiinfo2'])
    case 4
                        % Here to create a mapping file using the current
                        % Field1 and Field2 aoi lists
        filename=[handles.FileLocations.mapping 'fitparms.dat'];
        mp=MakeMappingFile(handles.Field1, handles.Field2, filename);
                        % Save the two aoi lists in field1 and field2
        aoiinfo2=handles.Field1;        %[frm  ave  x  y  pixnum  aoi#]
        
        eval(['save ' handles.FileLocations.mapping 'field1.dat aoiinfo2'])
        aoiinfo2=handles.Field2;
        eval(['save ' handles.FileLocations.mapping 'field2.dat aoiinfo2'])
                        % Load the new mapping file into imscroll
        set(handles.ButtonChoice,'Value',1)     % Set ButtonChoice to 'Load Fitparms
        set(handles.InputParms,'String','FitParms.dat');    % Input filename set to newly made mapping file
        guidata(gcbo,handles);
        GoButton_Callback(handles.GoButton, eventdata, handles) % Invoke the GoButton so that
                                           % the new mapping file is loaded  
  
                                           
           % Now make plots that enable user to tell if any points in mapping list are bad  
           % Map 1-->2 and compare the proxmapped locations in 2 to the original x2y2 list
        fitparmvector=get(handles.FitDisplay,'UserData');
        aoiinfo2_1=handles.Field1;      % Mapping point list
        aoiinfo2_2=handles.Field2;
        mappingpointlist=[handles.Field1 handles.Field2];
        %size(mappingpointlist)
        [rosenow colnow]=size(aoiinfo2_1);
        
        mapped2=zeros(rosenow,2);
        for indx=1:rosenow
                % Prox map each aoiinfo2_1 point to field 2
            %mapped2(indx,:)=proximity_mapping_v1(handles.MappingPoints,aoiinfo2_1(indx,3:4),15,fitparmvector,2);
            mapped2(indx,:)=proximity_mapping_v1(mappingpointlist,aoiinfo2_1(indx,3:4),15,fitparmvector,2);
        end
        %keyboard
        [rose coll]=size(aoiinfo2_2);
        figure(21);plot(aoiinfo2_2(:,3),aoiinfo2_2(:,3)-mapped2(:,1),'o');shg
        xlabel('gaussian fit x2 coordinate');ylabel('gaussian-proxmapped x2 coordinate');title(['std = ' num2str(std(aoiinfo2_2(:,3)-mapped2(:,1))) 'mean = ' num2str(mean(aoiinfo2_2(:,3)-mapped2(:,1))) ' length=' num2str(rose)]);
        figure(22);plot(aoiinfo2_2(:,4),aoiinfo2_2(:,4)-mapped2(:,2),'o');shg
        xlabel('gaussian fit y2 coordinate');ylabel('gaussian-proxmapped y2 coordinate');title(['std = ' num2str(std(aoiinfo2_2(:,4)-mapped2(:,2))) 'mean = ' num2str(mean(aoiinfo2_2(:,4)-mapped2(:,2))) ' length=' num2str(rose)]);
        figure(23);plot(aoiinfo2_2(:,3),aoiinfo2_2(:,4),'o');shg
        xlabel('gaussian x2 coordinate');ylabel('gaussian y2 coordinate');
        

      


   
        
        

    
    
    case 5
                        % Here to restore the AOI set that was present just before adding another AOI set to it
        handles.FitData=handles.PreAddition;
        guidata(gcbo,handles);
        slider1_Callback(handles.ImageNumber, eventdata, handles)   % Update the image
    case 6
                        % Here to import a map: Use the field1 and field2
                        % aois in the map to define field1 and field2
        [fn fp]=uigetfile('*.*','Import a mapping file');      % Promt user for filename 
        eval( ['load ' [fp fn]  ' -mat'] );                         % Load the fitparmvector and mappingpoints
        handles.Field1=mappingpoints(:,1:6);                        % Assign field 1 of the mapping points
        handles.Field2=mappingpoints(:,7:12);                       % Assign field 2 of the mapping points
        handles.Field1=update_FitData_aoinum(handles.Field1);       % Update the numbering of the AOIs in the map
        handles.Field2=update_FitData_aoinum(handles.Field2);
        guidata(gcbo,handles);
    case 7
                        % Here to add the current aois to Field1
        handles.PreAddition=handles.FitData;                % Store the present aoi set before adding with another set 
        handles.Field1=[handles.FitData;handles.Field1];
        [rose1 col1]=size(handles.Field1);
        handles.Field1(:,6)=[1:rose1]';
        handles.FitData=handles.Field1;                     % Place the summed aoi sets also into current FitData
        guidata(gcbo,handles);                              % Update the handle varialbes
        slider1_Callback(handles.ImageNumber, eventdata, handles)   % And show the user the updated summed aoiset
    case 8
                               % Here to add the current aois to Field2
        handles.PreAddition=handles.FitData;                % Store the present aoi set before adding with another set 
        handles.Field2=[handles.FitData;handles.Field2];
        [rose2 col2]=size(handles.Field2);
        handles.Field2(:,6)=[1:rose2]';
        handles.FitData=handles.Field2;                     % Place the summed aoi sets also into current FitData
        guidata(gcbo,handles);                              % Update the handle varialbes
        slider1_Callback(handles.ImageNumber, eventdata, handles)   % And show the user the updated summed aoiset
    case 9
                               % Here to remove Close AOIs
                               % Grab radius off of editable text region
        Unique_Landing_Radius=str2num(get(handles.EditUniqueRadius,'String'));
                               % Alter list of AOIs
        handles.FitData=Remove_Close_AOIs_v1(handles.FitData,Unique_Landing_Radius);
        guidata(gcbo,handles);      % Update the handles structure
        slider1_Callback(handles.ImageNumber, eventdata, handles)   % And show the user the updated aoiset
        

    case 10
                               % Here to remove an AOI by clicking on the figure(21) X2 plot 
           % First make plots that enable user to tell if any points in mapping list are bad  
           % Map 1-->2 and compare the proxmapped locations in 2 to the original x2y2 list
        fitparmvector=get(handles.FitDisplay,'UserData');
        aoiinfo2_1=handles.Field1;      % Mapping point list
        aoiinfo2_2=handles.Field2;
        mappingpointlist=[handles.Field1 handles.Field2];
        [rosenow colnow]=size(aoiinfo2_1);
        mapped2=zeros(rosenow,2);
        for indx=1:rosenow
                % Prox map each aoiinfo2_1 point to field 2
            %mapped2(indx,:)=proximity_mapping_v1(handles.MappingPoints,aoiinfo2_1(indx,3:4),15,fitparmvector,2);
            mapped2(indx,:)=proximity_mapping_v1(mappingpointlist,aoiinfo2_1(indx,3:4),15,fitparmvector,2);
        end
        %keyboard
        [rose coll]=size(aoiinfo2_2);
        figure(21);plot(aoiinfo2_2(:,3),aoiinfo2_2(:,3)-mapped2(:,1),'o');shg
        h21=gca;                        % Axis of figure(21)
        xticks=get(h21,'XTick');        % vector of XTicks
        scalex=max(xticks)-min(xticks); % max - min of x axis
        yticks=get(h21,'YTick');
        scaley=max(yticks)-min(yticks);
        xlabel('gaussian fit x2 coordinate');ylabel('gaussian-proxmapped x2 coordinate');title(['std = ' num2str(std(aoiinfo2_2(:,3)-mapped2(:,1))) 'mean = ' num2str(mean(aoiinfo2_2(:,3)-mapped2(:,1))) ' length=' num2str(rose)]);
        figure(22);plot(aoiinfo2_2(:,4),aoiinfo2_2(:,4)-mapped2(:,2),'o');shg
        xlabel('gaussian fit y2 coordinate');ylabel('gaussian-proxmapped y2 coordinate');title(['std = ' num2str(std(aoiinfo2_2(:,4)-mapped2(:,2))) 'mean = ' num2str(mean(aoiinfo2_2(:,4)-mapped2(:,2))) ' length=' num2str(rose)]);
        figure(23);plot(aoiinfo2_2(:,3),aoiinfo2_2(:,4),'o');shg
        xlabel('gaussian x2 coordinate');ylabel('gaussian y2 coordinate');
        

                    % Let the user click on a bad spot in Figure(21) (y coordinate plot) 
        fig21ylist=[aoiinfo2_2(:,3) aoiinfo2_2(:,3)-mapped2(:,1)];
        figure(21);
        flag=0;     % flag=0 means we do continue to find bad points
        while flag==0
            [xpt ypt but]=ginput(1);        % Chose a bad point or right click to end
            if but==3
                       flag=1;     % flag=1 means we did not select a bad point
        
            else       % If the user did NOT right click, then record a pt [xpt ypt]
                        % Here if we ARE removing a bad point
         
        % The scale of the x and y axis is different by about 500/.5, so if we are clicking
        % near points we must adjust the scales to what the user actually sees when we measure distance 
                %scalex=max(fig21ylist(:,1))-min(fig21ylist(:,1));
                %scaley=max(fig21ylist(:,2))-min(fig21ylist(:,2));
                        % Find the pt in Fig 22 closest to where the user clicked
                distancelist=[(fig21ylist(:,1)-xpt).^2/scalex^2+(fig21ylist(:,2)-ypt).^2/scaley^2 [1:rosenow]'];      
    
                                            % Get the aoi number for the
                                            % aoi closest to where user
                                            % clicked
       
                [sortdistance I]=sort(distancelist(:,1));
                num_closest=distancelist(I(1),2);   % Index in the aoilist used to remove a point
   
                handles.Field1(num_closest,:)=[];
                handles.Field2(num_closest,:)=[];
                mapped2(num_closest,:)=[];
                handles.Field1=update_FitData_aoinum(handles.Field1);       % Update the numbering of the AOIs in the map
                handles.Field2=update_FitData_aoinum(handles.Field2);
                guidata(gcbo,handles) ;
           
                    % Now update the figure (21) plot in anticipation of picking the next point
                aoiinfo2_1=handles.Field1;      % Mapping point list
                aoiinfo2_2=handles.Field2; 
                figure(21);plot(aoiinfo2_2(:,3),aoiinfo2_2(:,3)-mapped2(:,1),'o');shg
                h21=gca;                        % Axis of figure(22)
                xticks=get(h21,'XTick');        % vector of XTicks
                scalex=max(xticks)-min(xticks); % max - min of x axis
                yticks=get(h21,'YTick');
                scaley=max(yticks)-min(yticks);
                xlabel('gaussian fit y2 coordinate');ylabel('gaussian-proxmapped y2 coordinate');title(['std = ' num2str(std(aoiinfo2_2(:,4)-mapped2(:,2))) 'mean = ' num2str(mean(aoiinfo2_2(:,4)-mapped2(:,2)))  ' length=' num2str(rose)]);
                fig21ylist=[aoiinfo2_2(:,3) aoiinfo2_2(:,3)-mapped2(:,1)];
                [rosenow colnow]=size(aoiinfo2_1);      % update the number of rows in the spot list (needed for distancelist
                figure(21);
      
        
            end         % end of if but==3
        end             % end of while flag=0, here when user right clicks
        if flag~=0
                % Here is we removed selected and removed a bad point above,
                % in which case we make a map again
            set(handles.MappingMenu,'Value',4); % Set menu to 'Make Map' again
            MapButton_Callback(handles.MapButton, eventdata, handles) % Invoke the MapButton so that
        end                            % we make a mapping again, this time with the bad point deleted 

    
    case 11
                               % Here to remove an AOI by clicking on the figure(22) Y2 plot
    
              % Now make plots that enable user to tell if any points in mapping list are bad  
           % Map 1-->2 and compare the proxmapped locations in 2 to the original x2y2 list
        fitparmvector=get(handles.FitDisplay,'UserData');
        aoiinfo2_1=handles.Field1;      % Mapping point list
        aoiinfo2_2=handles.Field2;
        mappingpointlist=[handles.Field1 handles.Field2];
        [rosenow colnow]=size(aoiinfo2_1);
        mapped2=zeros(rosenow,2);
        for indx=1:rosenow
                % Prox map each aoiinfo2_1 point to field 2
            %mapped2(indx,:)=proximity_mapping_v1(handles.MappingPoints,aoiinfo2_1(indx,3:4),15,fitparmvector,2);
            mapped2(indx,:)=proximity_mapping_v1(mappingpointlist,aoiinfo2_1(indx,3:4),15,fitparmvector,2);
        end
        %keyboard
        [rose coll]=size(aoiinfo2_2);
        figure(21);plot(aoiinfo2_2(:,3),aoiinfo2_2(:,3)-mapped2(:,1),'o');shg
        xlabel('gaussian fit x2 coordinate');ylabel('gaussian-proxmapped x2 coordinate');title(['std = ' num2str(std(aoiinfo2_2(:,3)-mapped2(:,1))) 'mean = ' num2str(mean(aoiinfo2_2(:,3)-mapped2(:,1))) ' length=' num2str(rose)]);
        figure(22);plot(aoiinfo2_2(:,4),aoiinfo2_2(:,4)-mapped2(:,2),'o');shg
        h22=gca;                        % Axis of figure(21)
        xticks=get(h22,'XTick');        % vector of XTicks
        scalex=max(xticks)-min(xticks); % max - min of x axis
        yticks=get(h22,'YTick');
        scaley=max(yticks)-min(yticks);
        xlabel('gaussian fit y2 coordinate');ylabel('gaussian-proxmapped y2 coordinate');title(['std = ' num2str(std(aoiinfo2_2(:,4)-mapped2(:,2))) 'mean = ' num2str(mean(aoiinfo2_2(:,4)-mapped2(:,2)))  ' length=' num2str(rose)]);
        figure(23);plot(aoiinfo2_2(:,3),aoiinfo2_2(:,4),'o');shg
        xlabel('gaussian x2 coordinate');ylabel('gaussian y2 coordinate');
        

                    % Let the user click on a bad spot in Figure(22) (y coordinate plot) 
        fig22ylist=[aoiinfo2_2(:,4) aoiinfo2_2(:,4)-mapped2(:,2)];
        figure(22);
        flag=0;     % flag=0 means we do continue to find bad points
        while flag==0
            [xpt ypt but]=ginput(1);    % chose a bad point, or right click
        
            if but==3       % User right clicks:  stop chosing points
                        % 
                flag=1;     % flag=1 means we did not select a bad point
        % The scale of the x and y axis is different by about 500/.5, so if we are clicking
        % near points we must adjust the scales to what the user actually sees when we measure distance
            else
                        % Here if user did not right click=> chose a bad point 
                %scalex=max(fig22ylist(:,1))-min(fig22ylist(:,1));
                %scaley=max(fig22ylist(:,2))-min(fig22ylist(:,2));
                        % Find the pt in Fig 22 closest to where the user clicked 
                distancelist=[(fig22ylist(:,1)-xpt).^2/scalex^2+(fig22ylist(:,2)-ypt).^2/scaley^2 [1:rosenow]'];      
    
                                            % Get the aoi number for the
                                            % aoi closest to where user
                                            % clicked
       
                [sortdistance I]=sort(distancelist(:,1));
                num_closest=distancelist(I(1),2);   % Index in the aoilist used to remove a point
                %keyboard
                handles.Field1(num_closest,:)=[];
                handles.Field2(num_closest,:)=[];
                mapped2(num_closest,:)=[];
                handles.Field1=update_FitData_aoinum(handles.Field1);       % Update the numbering of the AOIs in the map
                handles.Field2=update_FitData_aoinum(handles.Field2);
       
                guidata(gcbo,handles) ;
                        % Now update the figure (22) plot in anticipation of picking the next point
                aoiinfo2_1=handles.Field1;      % Mapping point list
                aoiinfo2_2=handles.Field2; 
                figure(22);plot(aoiinfo2_2(:,4),aoiinfo2_2(:,4)-mapped2(:,2),'o');shg
                h22=gca;                        % Axis of figure(22)
                xticks=get(h22,'XTick');        % vector of XTicks
                scalex=max(xticks)-min(xticks); % max - min of x axis
                yticks=get(h22,'YTick');
                scaley=max(yticks)-min(yticks);
                xlabel('gaussian fit y2 coordinate');ylabel('gaussian-proxmapped y2 coordinate');title(['std = ' num2str(std(aoiinfo2_2(:,4)-mapped2(:,2))) 'mean = ' num2str(mean(aoiinfo2_2(:,4)-mapped2(:,2)))  ' length=' num2str(rose)]);
                fig22ylist=[aoiinfo2_2(:,4) aoiinfo2_2(:,4)-mapped2(:,2)];
                [rosenow colnow]=size(aoiinfo2_1);      % update the number of rows in the spot list (needed for distancelist
                figure(22);
        
            end                 % end of if but==3
        end                     % end of while flag==0
            if flag~=0
                % Here is we removed selected and removed a bad point above,
                % in which case we make a map again
                set(handles.MappingMenu,'Value',4); % Set menu to 'Make Map' again
                MapButton_Callback(handles.MapButton, eventdata, handles) % Invoke the MapButton so that
            end                            % we make a mapping again, this time with the bad point deleted 
    case 12
                               % Here to remove AOIs that do not contain a
                               % spot  case12A
                               
        handles.PreAddition=handles.FitData;                % Store the present aoi set before removing some of them
                                              % Pick Spots according to paramters set within
                                              % the 'Auto Spot Picking' box
        imagenum=get(handles.ImageNumber,'value');        % Retrieve the value of the slider
        CurrentFrameRange=get(handles.FrameRange,'String');  % Fetch current frame range
                                       % Set the frame range to current single value of image number from the slider 
        set(handles.FrameRange,'String',['[' num2str(imagenum) ']'])
        CurrentSpotsPopup=get(handles.SpotsPopup,'Value');  % Fetch current value of SpotsPopup dropdown menu
        CurrentSpotsButtonString=get(handles.SpotsButton,'String');
        set(handles.SpotsPopup,'Value',2)          % Set to 'FrameRange'
                                        % Now execute a detection of AllSpots  
        handles=FrameRange(handles);    % Invokes the Frame Range choice of finding AllSpots
                                        % in just the current frame
        set(handles.FrameRange,'String',CurrentFrameRange)  % Returns the editable text handles.FrameRange to prior string
        set(handles.SpotsPopup,'Value',CurrentSpotsPopup);
        set(handles.SpotsButton,'String',CurrentSpotsButtonString);
        %SpotsButton_Callback(handles.SpotsButton, eventdata, handles)
        %FramesPickSpots_Callback(handles.FramesPickSpots, eventdata, handles)
         
        % Remove AOIs that do not contain a detected spot 
                        % Now the AllSpots structure
                        % contains a list of all spots in the current
                        % frame.  We next want to remove all the current
                        % AOIs that do not contain one of these spots
      %  AOISpotLanding(AOInum,radius,handles,aoiinfo2,radius_hys)
        radius=str2num(get(handles.EditUniqueRadius,'String'));     % Use as max pixel distance to a spot.
                                                        % A spot must be this close to an AOI center
                                                        % for that AOI to  be retained 
        radius_hys = 1;     % A multiplicative constant not used here
        aoiinfo2=handles.FitData;       % Contains list of current AOIs
                                    % [framenumber ave x y pixnum aoinumber];
        [rose col]=size(aoiinfo2);  % rose = number of AOIs currently
        AOIspots=zeros(rose,2);     % We will denote the AOI spot number N 
                                    % as containing a spot by marking 
                                    % AOIspots(N,2) = 1
        
        for indx=1:rose

                                    % Cycle through all the aois
            AOIspots(indx,:)=AOISpotLanding(aoiinfo2(indx,6),radius,handles,aoiinfo2,radius_hys);
           
        end
                    % We have now found all the AOIs w/ and w/o spots and need
                    % to remove those AOIs without spots
                                % Keep only those rows i for which AOIspots(i,2) = 1
        handles.FitData=handles.FitData(logical(AOIspots(:,2)),:);     
         
       
      
        handles.FitData=update_FitData_aoinum(handles.FitData);           
                    
        %handles.Field2=[handles.FitData;handles.Field2];
        %[rose2 col2]=size(handles.Field2);
        %handles.Field2(:,6)=[1:rose2]';
        %handles.FitData=handles.Field2;                     % Place the summed aoi sets also into current FitData
        guidata(gcbo,handles);                              % Update the handle varialbes
        slider1_Callback(handles.ImageNumber, eventdata, handles)   % And show the user the updated summed aoiset    
        case 13
                               % Here to remove AOIs that contain a
                               % spot  case13
                               
        handles.PreAddition=handles.FitData;                % Store the present aoi set before removing some of them
                                              % Pick Spots according to paramters set within
                                              % the 'Auto Spot Picking' box
        imagenum=get(handles.ImageNumber,'value');        % Retrieve the value of the slider
        CurrentFrameRange=get(handles.FrameRange,'String');  % Fetch current frame range
                                       % Set the frame range to current single value of image number from the slider 
        set(handles.FrameRange,'String',['[' num2str(imagenum) ']'])
        CurrentSpotsPopup=get(handles.SpotsPopup,'Value');  % Fetch current value of SpotsPopup dropdown menu
        CurrentSpotsButtonString=get(handles.SpotsButton,'String');
        set(handles.SpotsPopup,'Value',2)          % Set to 'FrameRange'
                                        % Now execute a detection of AllSpots  
        handles=FrameRange(handles);    % Invokes the Frame Range choice of finding AllSpots
                                        % in just the current frame
        set(handles.FrameRange,'String',CurrentFrameRange)  % Returns the editable text handles.FrameRange to prior string
        set(handles.SpotsPopup,'Value',CurrentSpotsPopup);
        set(handles.SpotsButton,'String',CurrentSpotsButtonString);
        %SpotsButton_Callback(handles.SpotsButton, eventdata, handles)
        %FramesPickSpots_Callback(handles.FramesPickSpots, eventdata, handles)
         
        % Remove AOIs that do not contain a detected spot 
                        % Now the AllSpots structure
                        % contains a list of all spots in the current
                        % frame.  We next want to remove all the current
                        % AOIs that do not contain one of these spots
      %  AOISpotLanding(AOInum,radius,handles,aoiinfo2,radius_hys)
        radius=str2num(get(handles.EditUniqueRadius,'String'));     % Use as max pixel distance to a spot.
                                                        % A spot must be this close to an AOI center
                                                        % for that AOI to  be retained 
        radius_hys = 1;     % A multiplicative constant not used here
        aoiinfo2=handles.FitData;       % Contains list of current AOIs
                                    % [framenumber ave x y pixnum aoinumber];
        [rose col]=size(aoiinfo2);  % rose = number of AOIs currently
        AOIspots=zeros(rose,2);     % We will denote the AOI spot number N 
                                    % as containing a spot by marking 
                                    % AOIspots(N,2) = 1
        
        for indx=1:rose

                                    % Cycle through all the aois
            AOIspots(indx,:)=AOISpotLanding(aoiinfo2(indx,6),radius,handles,aoiinfo2,radius_hys);
           
        end
                    % We have now found all the AOIs w/ and w/o spots and need
                    % to remove those AOIs without spots
                                % Keep only those rows i for which
                                % AOIspots(i,2) = 0
        handles.FitData=handles.FitData(~logical(AOIspots(:,2)),:);     
         
       
      
        handles.FitData=update_FitData_aoinum(handles.FitData);           
                    
        %handles.Field2=[handles.FitData;handles.Field2];
        %[rose2 col2]=size(handles.Field2);
        %handles.Field2(:,6)=[1:rose2]';
        %handles.FitData=handles.Field2;                     % Place the summed aoi sets also into current FitData
        guidata(gcbo,handles);                              % Update the handle varialbes
        slider1_Callback(handles.ImageNumber, eventdata, handles)   % And show the user the updated summed aoiset    
end                                         % End of switch
        
  



function EditUniqueRadius_Callback(hObject, eventdata, handles)
% hObject    handle to EditUniqueRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditUniqueRadius as text
%        str2double(get(hObject,'String')) returns contents of EditUniqueRadius as a double


% --- Executes during object creation, after setting all properties.
function EditUniqueRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditUniqueRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in IncrementUniqueRadius.
function IncrementUniqueRadius_Callback(hObject, eventdata, handles)
% hObject    handle to IncrementUniqueRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

UniqueRadius=str2num(get(handles.EditUniqueRadius,'String'));
UniqueRadius=UniqueRadius+.2;
set(handles.EditUniqueRadius,'String',num2str(UniqueRadius));
guidata(gcbo,handles);
%MapButton_Callback(handles.MapButton, eventdata, handles)   % Invoke the Remove Close AOIs function

% --- Executes on button press in DecrementUniqueRadius.
function DecrementUniqueRadius_Callback(hObject, eventdata, handles)
% hObject    handle to DecrementUniqueRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UniqueRadius=str2num(get(handles.EditUniqueRadius,'String'));
UniqueRadius=UniqueRadius-.2;
set(handles.EditUniqueRadius,'String',num2str(UniqueRadius));
guidata(gcbo,handles);
%MapButton_Callback(handles.MapButton, eventdata, handles)   % Invoke the Remove Close AOIs function


% --- Executes on button press in IncrementMagChoice.
function IncrementMagChoice_Callback(hObject, eventdata, handles)
% hObject    handle to IncrementMagChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.MagChoice,'Value');
if val<12           % Check range
    val=val+1;
    set(handles.MagChoice,'Value',val)

end
MagChoice_Callback(handles.MagChoice, eventdata,handles)    % Invoke the MapChoice popup menu



% --- Executes on button press in DecrementMagChoice.
function DecrementMagChoice_Callback(hObject, eventdata, handles)
% hObject    handle to DecrementMagChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.MagChoice,'Value');
if val>1           % Check range
    val=val-1;
    set(handles.MagChoice,'Value',val)

end
MagChoice_Callback(handles.MagChoice, eventdata,handles)    % Invoke the MapChoice popup menu


% --- Executes on button press in AOIgrid.
function AOIgrid_Callback(hObject, eventdata, handles)
% hObject    handle to AOIgrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes1);
roi=roipoly;
pixnum=str2num(get(handles.PixelNumber,'String'));
aoiinfo2=control_aois(roi,pixnum);
imagenum=get(handles.ImageNumber,'value');        % Retrieve the value of the slider
val= round(imagenum);
aoiinfo2(:,1)=val;                          % Set the frame number to match the current frame
handles.FitData=aoiinfo2;
guidata(gcbo,handles);


