function pc=Near_Far_AOIs(xycoord, xylist, PixelDistance)
%
% function Near_Far_AOIs(xycoord, xylist, PixelDistance)
%
% This routine will find the subset of xy coordinates from the input list
% 'xylist' that are closest to the single xy coordinate input 'xycoord'.
% For example, if NearPts=15, the routine will find the 15 xy coordinates
% from the 'xycoord' list nearest to the site specified by the single xy
% coordinate 'xycoord'.
%
% xycoord == [x y]  a single xy coordinate pair.  The routine will
%        calculate distances between this site and all the locations 
%        specified in the xylist, then return those coordinates from the
%        xylist closest to xycoord.
% xylist == M x 2 matrix of [x  y].  The routine finds those xy pairs
%        from this list that are closest in distance to xycoor.
% PixelDistance == distance in pixels that will be used to choose subsets
%            from the list of AOI coordinates in 'xylist'.  This function 
%            will find those AOIs that are closer than 'PixelDistance' from
%            from the coordinate 'xycoord' and store (and output) that list 
%            of close AOIs in Output.NearXYList.  Similarly, this function  
%            will find those AOIs that are further than 'PixelDistance' from 
%            the coordinate 'xycoord' and store (and output) that list of 
%            AOIs in Output.FarXYList
%
% Output.NearXYList ==  N x 3 [x y distance] list of AOI coordinates that
%                   drawn from the input xylist.  This list of AOI
%                   coordinates are those those in xylist that are within a
%                   distance 'PixelDistance' of the coordinate 'xycoord'.
% Output.FarXYList ==  N x 3 [x y distance] list of AOI coordinates that
%                   are drawn from the input xylist.  This list of AOI
%                   coordinates are those those in xylist that are greater
%                   than a distance 'PixelDistance' from the 
%                   coordinate 'xycoord'.
% Output.SortedXYList == M x 2 [x y distance] xylist sorted for increasing distance from xycoord
% Output.IndexXYList == Sorting index for the xylist.  e.g. xylist(I,:)
%                   is the xylist sorted with increasing distance from the
%                   input xycoord site.
% Output.logikFar == Logical array that picks Far entries from xylist
% Output.logikNear == Logical array that picks Near entries from xylist

% Copyright 2016 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.

[rose col]=size(xylist);                % Get the size of the  xy input list


distance=sqrt((xycoord(1) - xylist(:,1)).^2 + (xycoord(2) - xylist(:,2)).^2 );
logikNear=distance<=PixelDistance;          % Find xylist entries closer to xycoord than PixelDistance 
 pc.NearXYList=[ xylist(logikNear,:) distance(logikNear)];  % Store list of close AOIS
 
logikFar=distance>PixelDistance;          % Find xylist entries further than PixelDistance from xycoord  
 pc.FarXYList=[ xylist(logikFar,:) distance(logikFar)];  % Store list of far AOIS
 
 
[sortDistance I]=sort(distance(:,1));

SortedXYList=xylist(I,:);               % xylist sorted for increasing distance from xycoord


IndexXYList=I;                          % Sorting index for the xylist

pc.SortedXYList=[SortedXYList distance(I)];
pc.IndexXYList=I;
pc.logikFar=logikFar;               % Logical array that picks Far entries from xylist
pc.logikNear=logikNear;             % Logical array that picks Near entries from xylist
