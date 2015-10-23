function pc=mappingfunc_rot_mag_trans(inarg,xydata1,xydata2)
%
% function mappingfunc_rot_mag_trans(inarg,xydata1,xydata2)
%
% This function could be called ( but is not called at the moment, we instead
% use a more general function 'mappingfunc' with 6 fit parameters)
% from mappingfit() while using the
% lscurvefit() function to map the x1y1 image1 point pairs onto x2 or y2
% points.  
% The form of the mapping is
% x2=M*cos(theta)*x1 +  M*sin(theta)*y1 - M*( xz*cos(theta)+yz*sin(theta) )
% y2=-M*sin(theta)*x1 + M*cos(theta)*y1 + M*( xz*sin(theta)-yz*cos(theta) )
%
% which is a translation xp=x1-xz, yp=y1-yz  followed by a rotation
% [xpp ypp]'=[cos(theta) sin(theta); -sin(theta) cos(theta)]*[xp yp]'
% follows by a magnification
% [x2 y2]'=[M 0;0 M]*[xpp ypp]'
%
% where the input arguements are given in inarg according to
% inarg  == [ M theta xz yz]
% xdyata1 == n x 2 list of [x1(:) y1(:)] points
% xdyata2 == n x 2 list of [x2(:) y2(:)] points
%
% First made 12/11/2009;  Also see derivation notes in folder 
% call via argout=fminsearch('mappingfunc_rot_mag_trans',inargz,[],xydata1,xydata2)

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

M=inarg(1);
theta=inarg(2);
xz=inarg(3);
yz=inarg(4);
pc= sum( (xydata2(:,1)-M*cos(theta)*xydata1(:,1) -M*sin(theta)*xydata1(:,2)...
           +M*(xz*cos(theta)+yz*sin(theta)) ).^2)+...
    sum( (xydata2(:,2)+M*sin(theta)*xydata1(:,1) -M*cos(theta)*xydata1(:,2)...
           -M*(xz*sin(theta)-yz*cos(theta)) ).^2);