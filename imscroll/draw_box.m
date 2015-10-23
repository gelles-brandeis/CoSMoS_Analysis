function pc=draw_box(center_xy,x_radius,y_radius,linecolor)
%
% function draw_box(center_xy,x_radius,y_radius,linecolor)
%
% This function will draw a box centered at ( center_xy(1),center_xy(2) ) of the current
% figure.  The box will enclose an area of (2*x_radius+1)*(2*y_radius+1) pixels.
%
% center_xy == gives the coordinates of the box center as the (x,y) coordinate
%                of the current figure
% x_radius  == gives the distance (in pixels) from the box center to y edge of the box
% y_radius == gives the distance (in pixels) from the box center the x edge of the box
% linecolor  == ascii character giving the color of the line that will be
%                 drawn  e.g. ='[0 0 1]' for blue
%
% The box will be drawn with the corners given by the xy coordinates:
%   [x] = [center_xy(1)-x_radius  center_xy(1)+x_radius  center_xy(1)+x_radius  center_xy(1)-x_radius]
%   [y]   [center_xy(2)-y_radius  center_xy(2)-y_radius  center_xy(2)+y_radius  center_xy(2)+y_radius] 
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

xvec = [center_xy(1)-x_radius  center_xy(1)+x_radius  center_xy(1)+x_radius  center_xy(1)-x_radius center_xy(1)-x_radius];
yvec =[center_xy(2)-y_radius  center_xy(2)-y_radius  center_xy(2)+y_radius  center_xy(2)+y_radius center_xy(2)-y_radius] ;
line(xvec,yvec,'color',linecolor,'LineWidth',.5)
pc=1;
