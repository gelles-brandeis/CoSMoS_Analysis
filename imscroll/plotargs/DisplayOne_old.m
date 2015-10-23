function pc=DisplayOne(handles)
%
% This function will be called from the plotargout gui in order to display
% an expanded region around one aoi.  
%
% handles == handles structure from plotargout
% parenthandles == handles structure from imscroll (parent gui that opens plotargout gui) 

                % ***Copy some code region from the DisplayAOIs callback in plotargout
                
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
xy1=[ aoifits1.aoiinfo2(aoilogic,3:4) aoinumber1]; 

                                % Get the frame limits to display from the
                                % manual settings for the axis limits

MidAOINumber=round(str2num(get(handles.EditMidAOINumber,'String')));    % Defines the image number in the middle of the display gallery
frms1=[MidAOINumber:MidAOINumber];        % Display just the one frame

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
 AOInum=[1 1];          % One aoi image per row, and just one row         
                        % Now get the image of one (actually two) aois
                        % Note the ViewMagNum*pixnum to get a larger surrounding area 
 ViewMagNum=round(str2num(get(handles.ViewMag,'String'))); 
 pc=SubImages_v1(ImageSource1,xy1,frms1,ViewMagNum*pixnum1,ImageSource2,xy2,frms2,ViewMagNum*pixnum2,AOInum,handles,parenthandles);
 [pcrose pccol]=size(pc);
 pchalfrose=round(pcrose/2);        % We use only the bottom half of the image (original image has two aois) 
            % Next, just deal with image scaling
 
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

            % Now display the image
axes(handles.axes10);                            % active figure is now the top plot in the gui
imagesc(pc(pchalfrose-2:pcrose-3,1:pccol-1),[clowval chival] );axis('equal');axis auto;colormap(gray);axis 'off'
AOIBoxPixnumValue=round(str2num(get(handles.AOIBoxPixnum,'String')));
%keyboard
draw_box(handles.galleryxy1Centers,AOIBoxPixnumValue/2,AOIBoxPixnumValue/2,'y');
pc=1;       % will need to output pixel indices for purpose of drawing boxes
 
   