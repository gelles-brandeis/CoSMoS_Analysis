function pc=gauss2dxyfunc_bkgnd(inarg,xdata)
%
% function gauss2dxyfunc_bkgnd(inarg,xdata)
%
% This function will be called from gaus2dfit() while using the
% lscurvefit() function to fit a two dimensional gaussian.  The form of the
% function is:
% amp*exp( -( (x1-centerx).^2/(2*omegax^2)+(y1-centery).^2/(2*omegay^2)  )+offset
%                              +bkgndx*(x1-centerx)+bkgndy*(y1-centery)
%
% where the input arguements are given in inarg according to
% inarg  == [ amp centerx omegax centery omegay offset]
% xdata(:,:,1) == x matrix defining the x range of data
% xdata(:,:,2) == y matrix defining the y range of data
%                  e.g.  11 x 10 matrices running 0 to 1 in each dimension
%                    will be given by:
%                   xdata(:,:,1)=ones(11,10)*diag( [0:9]/10)
%                   xdata(:,:,2=diag([0:10]/11)*ones(11,10)

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


pc= inarg(1)*exp( -( (xdata(:,:,1)-inarg(2)).^2/(2*inarg(3)^2)+(xdata(:,:,2)-inarg(4)).^2/(2*inarg(5)^2) )  )+inarg(6)...
                                        +inarg(7)*(xdata(:,:,1)-inarg(2))+inarg(8)*(xdata(:,:,2)-inarg(4));