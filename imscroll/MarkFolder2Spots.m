function pc=MarkFolder2Spots(handles);
%
% Call from imscroll to mark the aoi spots that were already found in the
% Folder2 file.  For example, in a tricolor experiment the image sequence
% in 'folder2' will first be marked according to the time appearance of the
% dye spots.  Bleedthrough into the 'folder' sequence is confusing when
% marking the folder sequence dye spots, so it is best to be able to mark the location of the folder2
% sequence spots while reviewing the folder sequence.  This occured in the
% tricolor oligo experiment where the Cy3 spots were cross excited by the
% 488 laser (alexa488 dye excitation).  While reviewing the Alexa488 file
% we needed to mark the already known locations for the Cy3 spots.
% This routine gets its timebase data from the *.mat files (from Glimpse)
% stored in the same directory as the folder1 and folder2 *.tif files.  The
% file for aoinfo2 data for the (already marked) spots that appear in folder2 sequence is
% the file from the larry\data\ directory and named in the InputParms
% editable text field.   
% e.g. folder = 'd:\temp\b10p41a.tif'   (the Alexa 488 binding sequence + time base)
% folder2 = 'd:\temp\b10p42b.tif'   (the Cy3 binding sequence + time base)
% 'b12p37a.dat'  (in the InputParms editable text field, found in p:\matlab12\larry\data\ directory)
% OPTIONAL:  user may place the timebase file for the aoiinfo2 in the
% FitParms text field (in case the aoiinfo2 timebase is not the same as
% that for folder2--e.g. Cy3 binding split into multiple files as in b10p42b,c,d
%
% Normal instance will have the aoiinfo2 file e.g b14p75b.dat (aois saved via the 'Go
% Button') in the 'Input Filename' field below the 'Go Button') and a
% '[  ]' (two spaces between [ and ] ) appearing in the 'mx21 bx21 my21 by21' text field
% If using a Glimpse image sequence:  place a dummy tiff file in the
% Glimpse directory (e.g. B10p15.tif) and a copy of the glimpse header file
% under the same name in the Glimpse directory as well (e.g. B10p10.mat,
% which is a copy of the header.mat file).  Then assign foldstruc.folder
% and foldstruc.folder2 to the full path...\b10p15.tif  file (that is in
% the Glimpse directory).

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


if handles.Flag == 0                        % ==0 if the files have not already been loaded
   
    handles.Flag=1;                         
    folder1=handles.Folder1;                    % Folder for the sequence being viewed presently
    folder2=handles.Folder2;                    % Folder for the sequence in which the spot appearances
                                            % have already been marked
    f1length=length(folder1);
    folder1time=[folder1(1:f1length-4) '.mat '];
     
    eval(['load ' folder1time ' -mat']);                            % Load the vid structure from the timebase file *.mat
 
    handles.Time1=vid.ttb;
    time1=handles.Time1;
    f2length=length(folder2); 
    folder2time=[folder2(1:f2length-4) '.mat '];
 
   
    eval(['load ' folder2time ' -mat']);
 
    handles.Time2=vid.ttb;
    time2=handles.Time2;
                                                             % See if any filename is in the FitDisplay text
                                                             % for fetching aoiinfo2 timebase
    FitDisplay_String= (get(handles.FitDisplay,'String'));
    if strcmp(FitDisplay_String,'[  ]')                     % true, when FitDisplay_String='[]' 
       
        aoiinfo2time=time2;                 % Just use the folder2 name (for aoiinfo2 timebase) if nothing appears in 
                                            %the FitDisplay text field
        handles.AoiInfo2Time=aoiinfo2time;
    else
        %  Uncomment the next four lines in order to use the
        %  FitDisplay_String as the time base.  Otherwise we'll just use
        %  the folder2 name to retrieve the *.mat file with a time base 
        %aoiinfo2timefile=FitDisplay_String;           % Use the file listed in the FitDisplay text field if one exists
                                                      % The full pathname must be listed there
  
        %eval(['load ' aoiinfo2timefile ' -mat']);

        %handles.AoiInfo2Time=vid.ttb;
        %aoiinfo2time=handles.AoiInfo2Time;
        aoiinfo2time=time2;                 % Just use the folder2 name (for aoiinfo2 timebase) if nothing appears in 
                                            %the FitDisplay text field
        handles.AoiInfo2Time=aoiinfo2time;

    end
   
   
                                                        % Fetch the input filename for the aoiinfo
                                                        % file. 
    folderaoiinfo=get(handles.InputParms,'String');
                      % Load variable 'aoiinfo2' containing the frm# for spots
                      % in the folder2 sequence file.

%    eval(['load p:\matlab12\larry\data\' folderaoiinfo ' -mat']);

    eval(['load ' handles.FileLocations.data '\' folderaoiinfo ' -mat']);

    handles.Folder2aoiinfo=aoiinfo2;
    guidata(gcbo,handles);
else
    time1=handles.Time1;
    time2=handles.Time2;
    aoiinfo2=handles.Folder2aoiinfo;
    aoiinfo2time=handles.AoiInfo2Time;
end

                                                    % At this point we have
                                                    % definded all the timebase
                                                    % and aoiinfo2 files
% Need to now place markers on the display
folder1frm=round(get(handles.ImageNumber,'Value'));    % Retrieve the current frame number displayed
timenow=time1(folder1frm);                          % Get the real time for the current folder1 frame
logic=aoiinfo2time(aoiinfo2(:,1))<=timenow;                   % Look for aois in folder2 sequence with a frame time
                                                    % less than the current time

aoiinfolength=length(aoiinfo2(:,1));
axes(handles.axes1);
hold on
                                % place red 'o' at location of each folder1
                                % spot that occurred up to the present time
for indx=1:aoiinfolength
    if logic(indx)==1
        XYshift=[0 0];                  % initialize aoi shift due to drift
        if get(handles.StartParameters,'Value')==2
                                    % here to move the aois in order to follow drift
            XYshift=ShiftAOI(indx,folder1frm,aoiinfo2,handles.DriftList);
        end
        plot(aoiinfo2(indx,3)+XYshift(1),aoiinfo2(indx,4)+XYshift(2),'ro','MarkerSize',6)
    else
                                    % Place green 'o' at location of each
                                    % folder1 spot that has not occurred up
                                    % to the present time
        XYshift=[0 0];                  % initialize aoi shift due to drift
        if get(handles.StartParameters,'Value')==2
                                    % here to move the aois in order to follow drift
            XYshift=ShiftAOI(indx,folder1frm,aoiinfo2,handles.DriftList);
        end
        plot(aoiinfo2(indx,3)+XYshift(1),aoiinfo2(indx,4)+XYshift(2),'go','MarkerSize',6)
    end
end
hold off

