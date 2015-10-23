function pc=FrameRange(handles)
%
% function FrameRange(handles);
%
% This function should have the same effect at hitting the 'spotsbutton' in
% the imscroll gui, but here we will return the updated handles structure
% so the calling function can update its copy of the handles.  We were
% having problems with getting the handles to update AllSpots when the 'spotsbutton'
% was invoked to find all the spots (when removing AOIs that lack any spot
% within them).

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


            % Here to find spots over the specified frame range
      set(handles.FramesPickSpots,'String','...')
      set(handles.SpotsButton,'String','...')
      pause(0.1)
      AllSpots=FindAllSpots(handles,3500);     % 500=max # of spots to retain for each frame
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
      
      handles.AllSpotsLow=AllSpots;     % We later invoke AOISpotLanding() function, and it
                                % requires that we also have AllSpotsLow defined 
      pc=handles;
     % guidata(gcbo,handles)