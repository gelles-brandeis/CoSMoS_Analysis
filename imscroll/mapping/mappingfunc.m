function pc=mappingfunc(inarg,xdata)
%
% function mappingfunc(inarg,xdata)
%
% This function will be called from mappingfit() while using the
% lscurvefit() function to map the x1y1 image1 point pairs onto x2 or y2
% points.  
% The form of the mapping is
% x2 = mxx21 * x1 + mxy21* y1 + bx
% or
% y2 = myx21 * x1 + myy21 * y1 + by
%
% where the input arguements are given in inarg according to
% inarg  == [ mxx21 mxy21 bx21] (mapping to x2) or [ myx21 myy21 by] (when
%                                                          mapping to y2)
% xdata == n x 2 list of [x1(:) y1(:)] points that will be mapped onto
%          either an x2(:) or y2(:) list of output points
%
% see also mappingfunc_rot_mag_trans.m for fit to a transformation that is
% strictly a translation, magnification and rotation (4 free parameters)

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


pc= inarg(1)*xdata(:,1) + inarg(2)*xdata(:,2) + inarg(3);