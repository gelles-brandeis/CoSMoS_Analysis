function pc=DriftShift(aoiinfo2,frame, driftlist)
%
% function DriftShift(aoiinfo2, frame, driftlist)
%
% This function will output an aoiinfo2 matrix with AOI coordinates being
% drift-corrected so as to reflect the input frame number 'frame'.  The
% output aoiinfo2 will be the same as the input exept that the xy
% coordinates will have been drift-corrected using the input 'driftlist'
%
% aoiinfo2 == matrix from imscroll summarizing a list of AOI locations
%           [(framenumber when marked)  ave   x  y   pixnum  aoinumber]
% frame  == integer frame number.  The xy coordinates for the output
%          aoiinfo2 matrix will be drift-corrected to reflect this frame
%          number using the input 'driftlist'.
% driftlist == [(frame #)   deltaX    deltaY    (glimpse time)]
%          driftlist as used in imscroll gui to correct xy coordinate for
%          stage drift
% Output == output aoiinfo2 will be the same as the input exept that the xy
%         coordinates will have been drift-corrected using the input 'driftlist'

% Copyright 2018 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.

pc=aoiinfo2;                % Output will be same as input aoiinfo2
                            % except that we will shift all the xy coord

AOIlist=aoiinfo2(:,6);

for indx=AOIlist'
   
                % Cycle through all AOIs containied in our aoiinfo2 list
    
    
%       OptionalXYshift=ShiftAOI(AOInum,FrameRange(frmindex),handles.AllSpots.aoiinfo2,handles.DriftList); 
    AOInum=indx; 
    %keyboard
    logik = pc(:,6)==AOInum;         % Pick out row matching the current AOI number
    OptionalXYshift=ShiftAOI(AOInum,frame,aoiinfo2,driftlist);
   
        pc(logik,3:4)=pc(logik,3:4)+OptionalXYshift;     % This will be shift [x y] coordinates of our AOI if necessary
end