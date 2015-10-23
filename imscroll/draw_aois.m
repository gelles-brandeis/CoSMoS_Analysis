function pc=draw_aois(aoiinfo2,frame,aoisize,driftlist)
%
% function pc=draw_aois(aoiinfo2,frame,aoisize,driftlist)
%
% This function will use the list of aois in aoiinfo2, reposition all aois
% at their location for frame 'frame' (using data in driftlist)and draw at
% those locations with the box side specified in 'aoisize'
%
% aoiinfo2 == array that is saved from imscroll.  The aoiinfo2 matrix is of
%          the form:
%   [ (frame #)  (frame average) (x coordinate=column) (ycoordinate=row)...
%                            (aoi side dimension in pixels)  (aoi number) ]
% frame == common frame number to be used in positioning all the aois
% aoisize==  side (in pixels) dimension of the aoi box to be drawn
% driftlist ==[(frame #) (x shift from last frame) (y shift from last frm)]
%
% Function will output the aoiinfo2 matrix showing the xy locations of the aois
% at their shifted positions.

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

[rose col]=size(aoiinfo2);
pc=aoiinfo2;
for indx=1:rose
                        % Cycle through for each aoi
                        % Get the shift in aoi center due to drift
   XYshift=ShiftAOI(indx,frame,aoiinfo2,driftlist);
                        % Draw the box for the shifted aoi location 
                        % Use draw_box_v1 to draw at pixel boundaries
   draw_box(aoiinfo2(indx,3:4)+XYshift,(aoisize)/2,...
                              (aoisize)/2,'r');
   pc(indx,3:4)=pc(indx,3:4)+XYshift;
end
