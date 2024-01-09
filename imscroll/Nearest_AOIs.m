function pc=Nearest_AOIs(xycoord, xylist, NearPts)
%
% function Nearest_AOIs(xycoord, xylist, NearPts)
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
% xylist == M x 2 matrix of [x y] pairs.  The routine finds those xy pairs
%        from this list that are closest in distance to xycoor.
% NearPts == The number of xy pairs that will be specified  by the routine.
%        If NearPts =15 the routine will find  the 15 xy coordinates  from 
%        the 'xycoord' list nearest to the site specified by the single xy
%        coordinate 'xycoord'.
%
% Output.SortedXYList == M x 2 [x y distance] xylist sorted for increasing distance from xycoord
% Output.CloseXYList == NearPts x 2 [x y distance] list of sites from xylist closest
%                     to  xycoord
% Output.IndexXYList == Sorting index for the xylist.  e.g. xylist(I,:)
%                   is the xylist sorted with increasing distance from the
%                   input xycoord site.


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
if rose<NearPts
                % Here if NearPts is larger than the number of sites in our xylist input than
   NearPtsmin=rose;         % In this case we will find all the sites specified in the xylist
else
    NearPtsmin=NearPts;
end

distance=sqrt((xycoord(1) - xylist(:,1)).^2 + (xycoord(2) - xylist(:,2)).^2 );
[sortDistance I]=sort(distance(:,1));

SortedXYList=xylist(I,:);               % xylist sorted for increasing distance from xycoord

CloseXYList=xylist(I(1:NearPts),:);      % NearPts number of closest sites from the input xylist  

IndexXYList=I;                          % Sorting index for the xylist

pc.SortedXYList=[SortedXYList distance(I)];
pc.CloseXYList=[CloseXYList distance(I(1:NearPts))];
pc.IndexXYList=I;
