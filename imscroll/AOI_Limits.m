function [xlow xhi ylow yhi]=AOI_Limits(AOICenterxy,AOIhalfwidth)
%
%function [xlow xhi ylow yhi]=AOI_Limits(AOICenterxy,AOIhalfwidth)
%
% This function will define the x and y limits to our AOI so that we have a
% consistent definition throughout the program.
%
% AOICenterxy== [x y] coordinates of the AOI as returned by the ginput()
%             function
% xlow xhi == the low x pixel number and hi x pixel number defining the 
%          limits of our AOI 
% ylow yhi == the low y pixel number and hi y pixel number defining the 
%          limits of our AOI
% AOIhalfwidth == 1/2 the edge length (in pixels) of our AOI.  e.g. a 
%                3x3 AOI will have a AOIhalfwidth=1.5, or =2 for a 4x4 AOI

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

xlow=round(AOICenterxy(1)-AOIhalfwidth+0.5);
xhi=round(xlow+2*AOIhalfwidth-1);
ylow=round(AOICenterxy(2)-AOIhalfwidth+0.5);
yhi=round(ylow+2*AOIhalfwidth-1);
