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
if ImageSource1==1                  % here to use Tiff folder
    if get(handles.DisplayOne12,'Value')==0
        % Here using AOIs and Tiff from bottom display
        fold.TiffFolder=handles.AOITiffFile2;
        fold.DumTiffFolder=handles.AOIDumTiffFile2;
    else
        fold.TiffFolder=handles.AOITiffFile1;
        fold.DumTiffFolder=handles.AOIDumTiffFile1;
    end

elseif ImageSource1==3                  % here for Glimpse folder useage.  Add additional
                                    % useage options later
    if get(handles.DisplayOne12,'Value')==0
        % Here using AOIs and Glimpse from bottom display
       fold.gfolder=handles.AOIgfolder2;
       fold.gheader=handles.AOIgheader2;
       fold.Dumgfolder=handles.AOIDumgfolder2;
    else
       fold.gfolder=handles.AOIgfolder1;
       fold.gheader=handles.AOIgheader1;
       fold.Dumgfolder=handles.AOIDumgfolder1;
    end
end
if get(handles.DisplayOne12,'Value')==0
    % here to display AOI from bottom display
    aoifits=parenthandles.aoifits2;           % aoifits currently displayed on bottom plot
                                    % Get the aoi number to be displayed
                                    % from the BottomAOIPlot input text
    aoinumber=str2num(get(handles.BottomAOIPlot,'String'));
                % aoifits:
                %[aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi]
                % Get the [x y (aoi#)] coordinates of the current aoi,
               % using the original x y coordinates when the aoi was marked
                % ( aoi# needed for later to correct for drift)
else
    aoifits=parenthandles.aoifits1;
    aoinumber=str2num(get(handles.MiddleAOIPlot,'String'));
end
    
               % Pick out line from aoiinfo2 corresponding to current aoifits and current aoi 
aoilogic=aoifits.aoiinfo2(:,6)==aoinumber;
                %xy2=[x y (aoi#)] coordinates of the current aoi,
xy2=[ aoifits.aoiinfo2(aoilogic,3:4) aoinumber]; 


MidAOINumber=round(str2num(get(handles.EditMidAOINumber,'String')));    % Defines the image number in the middle of the display gallery

                                % Get the AOI width for display from the
                                % current PixelNumber setting for AOIs in
                                % the imscroll gui
pixnum=str2num(get(parenthandles.PixelNumber,'String'));
                            

          % handles structure contains members:
          % handles. AOIgfolder1, AOIgheader1, AOIDumgfolder1
          %handles. AOIgfolder2, AOIgheader2, AOIDumgfolder2
          %handles. AOITiffFile1, AOIDumTiffFile1
          %handles. AOITiffFile2, AOIDumTiffFile2
          %handles. AOIRAM1, AOIDumRAM1
          %handles. AOIRAM2, AOIDumRAM2
                        % ViewMagNum to control size of surrounding area displayed  
 ViewMagNum=round(str2num(get(handles.ViewMag,'String'))); 
 frmave=str2double(get(parenthandles.FrameAve,'String'));   % Frame ave from imscroll parent gui
                        % Fetch the image
 Im1=get_image_frames(ImageSource1,frmave,MidAOINumber,fold,parenthandles);

            %   ***** Section for determining min/max for display
clowval=round(double(min(min(Im1))));chival=round(double(max(max(Im1))));     % Frame max and min values,
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
            % End of section that sets min/max for display

            % Now display the image
axes(handles.axes10);                            % active figure is now the top plot in the gui

                        % Fetch size of AOI box, specified in plotarg gui 
AOIBoxPixnumValue=round(str2num(get(handles.AOIBoxPixnum,'String')));

XYshift=[0 0];
    % Calculate the shift due to drift
if any(get(parenthandles.StartParameters,'Value')==[2 3 4])
            % Here if we use a driftlist with a moving aoi 
    XYshift=ShiftAOI(xy2(3),MidAOINumber,aoifits.aoiinfo2,parenthandles.DriftList);
end
xyshifted=xy2(1:2)+XYshift;
                        % Specify the size of the region to be displayed
limitsxy=[xyshifted(1)-round(ViewMagNum*pixnum/2) xyshifted(1)+round(ViewMagNum*pixnum/2) xyshifted(2)-round(ViewMagNum*pixnum/2) xyshifted(2)+round(ViewMagNum*pixnum/2)]; 
                        % Display the image
imagesc(Im1,[clowval chival] );axis('equal');axis 'off';colormap(gray(256));axis(limitsxy)
if get(handles.OneAOIBox,'Value')==1
                % here if toggle depressed to draw aoi box
                        % Draw the aoi box around the shifted location
     draw_box(xyshifted,AOIBoxPixnumValue/2,AOIBoxPixnumValue/2,'b');
end
pc=1;
 
   