function pc=ShiftAOI(AOInumber,FrameNumber,AOIinfo,DriftList)
%
% function ShiftAOI(AOInumber,FrameNumber,AOIinfo,DriftList)
%
% This function will provide the [deltax deltay] pixel shift for each AOI
% due to a drifting field of view.  The function uses the drift information
% contained in the 'Driftlist' variable to compute the relevant shifts.
%
% AOINumber == the number of the aoi (as numbered in AOIinfo) for which the
%           function computes a shift
% FrameNumber == the current frame number being displayed
% AOIinfo == the aoiinfo list of AOI centers and initial frame number, as
%            contained in the handles.FitData of imscroll
%             [framenumber ave x y pixnum aoinumber]
% DriftList == matrix of frame-by-frame shifts
%                [(frame number) (pixel shift x) (pixel shift y)]
%      [    1             0                   0
%           2   (x of frame 2)-(x of frame1) (y of frame 2)-(y of frame1)
%           3    (x of frame 3)-(x of frame2) (y of frame 3)-(y of frame2)
%                                        ...
%                                         ...
%       N   (x of frame N)-(x of frame N-1) (y of frame N)-(y of frameN-1)]
%
%  The routine will shift the aoi forward or backward depending on whether
%  the current frame number is greater or less than the frame number at
%  which the aoi was initially chosen.  This means that the aoi will always
%  be spatially fixed within the FOV (i.e. always moves with the drift of the FOV)


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

aoilogic=AOIinfo(:,6)==AOInumber;      
currentxy=AOIinfo(aoilogic,3:4);       % Pick off original xy coordinates and
InitialFrame=AOIinfo(aoilogic,1);      % original frame where aoi was marked
                    % Get the index of the entries corresponding to the 
                    % (initially chosen)  and (current frame) numbers for the aoi 

Iinitial=find(DriftList(:,1)==InitialFrame);
Icurrent=find(DriftList(:,1)==FrameNumber);
                    % Both Iinitial and Icurrent should be single numbers
                    % (not vectors).
if Icurrent>Iinitial
    if Iinitial+1==Icurrent        % needed b/c e.g sum(5,2:3) will give a single number output
                                   % (summing across the row as opposed to
                                   % sum(5:10,2:3 giving two outputs that sum down the columns 
        XYshift=DriftList(Icurrent,2:3);
    else
        XYshift=sum( DriftList( (Iinitial+1):Icurrent,2:3) );
    end
elseif Icurrent<Iinitial
    if Icurrent+1==Iinitial        
        XYshift=-DriftList(Iinitial,2:3);
    else
        XYshift=-sum( DriftList( (Icurrent+1):Iinitial,2:3) );
    end
else 
    XYshift=[0 0];
end
pc=XYshift;


       