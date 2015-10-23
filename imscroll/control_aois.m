function pc=control_aois(roi,AOIspacing)
%
% function      control_aois(roi,AOIspacing)
%
% Will create and aoiinfo2 matrix that will aid in forming a set of control
% AOIs at nonspecific sites.  The function creates a grid of AOIs that are
% spaced by a pixel number given by 'AOIspacing'
%
% AOIspacing == the grid of output AOIs are spaced by a pixel number 
%            spaced by 'AOIspacing'
% roi== use roi=roipoly; to define the circular region of the FOV in which
%       the AOI grid should appear

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

AOIspacing=round(AOIspacing);       % only use integer values for spacing
%xs=round([xyCorner(1,1) xyCorner(2,1)]);

%if xs(1)>xs(2)
%    xs=fliplr(xs);  % insures that x list in ascending order
    
%end
%ys=round([xyCorner(1,2) xyCorner(2,2)]);
%if ys(1)>ys(2)
%    ys=fliplr(ys);
%end
[Y X]=find(roi);            % Lists of indices of nonzero elements for roi mask
xmin=min(X);
xmax=max(X);
ymin=min(Y);
ymax=max(Y);
            % List of x and y grid values
%xlist=(xs(1):AOIspacing:xs(2));
%ylist=(ys(1):AOIspacing:ys(2));
xlist=[xmin:AOIspacing:xmax];
ylist=[ymin:AOIspacing:ymax];
xlength=length(xlist);
ylength=length(ylist);
xy=[];                  % Form the xy grid of points throughout FOV
for xindx=1:xlength
    for yindx=1:ylength
        xy=[xy; xlist(xindx) ylist(yindx)];
    end
end
            % Next remove points outside the circular FOV specified by the
            % roi.
            % Cycle through all the AOIs in our xy grid
xyout=[];   % Final output grid of AOIs
for indx=1:xlength*ylength
    if roi(xy(indx,2),xy(indx,1))==1        % true if spot is w/in roi
        xyout=[xyout;xy(indx,:)];
    end
end
aoiinfo2=zeros(length(xyout(:,1)),2);       % Space for output aoiinfo2 matrix
aoiinfo2(:,1)=1;            % frame 1
aoiinfo2(:,2)=1;            % ave = 1
aoiinfo2(:,3:4)=xyout;
aoiinfo2(:,5)=10;           % pixnum=10
aoiinfo2(:,6)=[1:length(xyout(:,1))]';
pc=aoiinfo2;





