function pc=MarkFolder2Spots_v1(handles)
%
% Call from imscroll in order to mark the aois that are specified in the
% file that is listed in the handles.InputParms editable text region (just
% beneath the GoButton).
% 

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


   
   
                                                        % Fetch the input filename for the aoiinfo
                                                        % file. 
    folderaoiinfo=get(handles.InputParms,'String');
                      % Load variable 'aoiinfo2' containing the frm# for spots
                      % in the folder2 sequence file.

%    eval(['load p:\matlab12\larry\data\' folderaoiinfo ' -mat']);
    eval(['load ' handles.FileLocations.data '\' folderaoiinfo ' -mat']);

    handles.Folder2aoiinfo=aoiinfo2;
    guidata(gcbo,handles);


                                                    % At this point we have
                                                    % definded all the timebase
                                                    % and aoiinfo2 files
% Need to now place markers on the display
folder1frm=round(get(handles.ImageNumber,'Value'));    % Retrieve the current frame number displayed
folder1frm=round(get(handles.ImageNumber,'Value'));    % Current frame number on slider
axes(handles.axes1);
aoisize=handles.AOIsize;                % Set when MarkFolder2Spots button first depressed in imscroll
if get(handles.StartParameters,'Value')==2
    framenumber=folder1frm;
    draw_aois(aoiinfo2,framenumber,aoisize,handles.DriftList);
else
    fakedrift=[1 0 0];
    framenumber=1;
    draw_aois(aoiinfo2,framenumber,aoisize,fakedrift);
end
