function pc=threegauss2dfunc(inarg,xdata)
%
% function threegauss2dfunc(inarg,xdata)
%
% This function will be called from gaus2dfit() while using the
% lscurvefit() function to fit a two dimensional gaussian.  The form of the
% function is:
% amp1*exp( -( (x-centerx1).^2/(2*omega1^2)+(y-centery1).^2/(2*omega1^2)  )+... 
% amp2*exp( -( (x-centerx2).^2/(2*omega2^2)+(y-centery2).^2/(2*omega2^2)  )+... 
% amp3*exp( -( (x-centerx3).^2/(2*omega3^2)+(y-centery3).^2/(2*omega3^2)  )+offset
%
% where the input arguements are given in inarg according to
% inarg  == [ amp1 centerx1 centery1 omega1 ...
%              amp2 centerx2 centery2 omega2 ...
%                 amp3 centerx3 centery3 omega3 offset]
% xdata(:,:,1) == x matrix defining the x range of data
% xdata(:,:,2) == y matrix defining the y range of data
%                  e.g.  11 x 10 matrices running 0 to 1 in each dimension
%                    will be given by:
%                   xdata(:,:,1)=ones(11,10)*diag( [0:9])
%                   xdata(:,:,2)=diag([0:10])*ones(11,10)
%
% % If you form the input subimage data using frame(ylow:yhi, xlow:xhi)
% then the output coordinates from this can be re-aligned with the original
% image using e.g.   ximage1 = xout1+xlow,  yimage1 = yout1+ylow   
% etc for xout2,3 and yout2,3.

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

% In gauss2d_mapstruc2d_v2 we use e.g. input frame: firstaoi=firstfrm(ylow:yhi,xlow:xhi);
%  FirstImageData=[aoiindx   mapstruc_cell{1,aoiindx}.aoiinf(1)   outarg(1)   outarg(2)+xlow   outarg(3)+ylow   outarg(4)   outarg(5)   sum(sum(firstaoi))];
% in order to relate the coordinate outputs of the single gaussian fit to the actual image coordinates  

pc= inarg(1)*exp( -( (xdata(:,:,1)-inarg(2)).^2/(2*inarg(4)^2)+(xdata(:,:,2)-inarg(3)).^2/(2*inarg(4)^2) )  )+...
       inarg(5)*exp( -( (xdata(:,:,1)-inarg(6)).^2/(2*inarg(8)^2)+(xdata(:,:,2)-inarg(7)).^2/(2*inarg(8)^2) )  )+...
         inarg(9)*exp( -( (xdata(:,:,1)-inarg(10)).^2/(2*inarg(12)^2)+(xdata(:,:,2)-inarg(11)).^2/(2*inarg(12)^2) )  )+ inarg(13);

            % Tying all the sigmas together:
%pc= inarg(1)*exp( -( (xdata(:,:,1)-inarg(2)).^2/(2*inarg(4)^2)+(xdata(:,:,2)-inarg(3)).^2/(2*inarg(4)^2) )  )+...
%       inarg(5)*exp( -( (xdata(:,:,1)-inarg(6)).^2/(2*inarg(4)^2)+(xdata(:,:,2)-inarg(7)).^2/(2*inarg(4)^2) )  )+...
%         inarg(9)*exp( -( (xdata(:,:,1)-inarg(10)).^2/(2*inarg(4)^2)+(xdata(:,:,2)-inarg(11)).^2/(2*inarg(4)^2) )  )+ inarg(13);