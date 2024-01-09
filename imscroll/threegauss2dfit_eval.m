function pc=threegauss2dfit_eval(indata,inarg, varargin)
%
% function threegauss2dfit(indata,inputarg, ,<XtraPixels>)
%
% Used in conjunction with gauss2dfit(), this function will simply
% output the gaussian for comparing with the input data.  The
% purpose is simply to allow the user to visually arrive at a
% set of starting input parameters
%
% indata     == input 2D matrix that will be fit to a gaussian 
%                i.e. the raw data (used for sizing the output array)
% inputarg0  ==  parameters for the fit gaussian
%                 [amp centerx centery omega offset] 
% XtraPixels == <optional> [xtraX  xtraY] if supplied, this parameter specifies
%                 that the output image will be larger than the 'indata'
%                 image by the specified pixel numbers (needed if image is
%                 to be later registered).  e.g. [2 2] will add two pixels
%                 to both +-x and +-y so that if [rose col]=size(indata)
%                 the output image will be (rose+4) x (col+4) in dimension
%
% The form of the exponential will be:
% amp1*exp( -( (x-centerx1).^2/(2*omega1^2)+(y-centery1).^2/(2*omega1^2)  )+... 
% amp2*exp( -( (x-centerx2).^2/(2*omega2^2)+(y-centery2).^2/(2*omega2^2)  )+... 
% amp3*exp( -( (x-centerx3).^2/(2*omega3^2)+(y-centery3).^2/(2*omega3^2)  )+offset
%
% where the input arguements are given in inarg according to
% inarg  == [ amp1 centerx1 centery1 omega1 ...
%              amp2 centerx2 centery2 omega2 ...
%                 amp3 centerx3 centery3 omega3 offset]
%
% If you form the input subimage data using frame(ylow:yhi, xlow:xhi)
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


sizevar=size(varargin,2);
if sizevar>=1
            % Here, if we specified extra pixels in the output image
    XtraPixels=varargin{1};
else
            % Otherwise set the extra pixels parameter to zero
    XtraPixels=[ 0 0];
end
[mrow ncol]=size(indata);                       % Form the xdata input array
mrow=mrow+2*XtraPixels(2);              % Add extra pixels to y dimension of output
ncol=ncol+2*XtraPixels(1);              % Add extra pixels to x dimension of output
xdata=zeros(mrow,ncol,2);
                                                % xdata(:,:,2) will run in
                                                % the Y dimension,
                                                % xdata(:,:,1) in the X
xdata(:,:,2)=diag( [0:mrow-1])*ones(mrow,ncol);
xdata(:,:,1)=ones(mrow,ncol)*diag( [0:ncol-1]);

%pc= inarg(1)*exp( -( (xdata(:,:,1)-inarg(2)).^2/(2*inarg(4)^2)+(xdata(:,:,2)-inarg(3)).^2/(2*inarg(4)^2) )  )+inarg(5);

% In gauss2d_mapstruc2d_v2 we use e.g. input frame: firstaoi=firstfrm(ylow:yhi,xlow:xhi);
%  FirstImageData=[aoiindx   mapstruc_cell{1,aoiindx}.aoiinf(1)   outarg(1)   outarg(2)+xlow   outarg(3)+ylow   outarg(4)   outarg(5)   sum(sum(firstaoi))];
% in order to relate the coordinate outputs of the single gaussian fit to the actual image coordinates  

            % If extra pixels have been added to the output image edge, we need
            % to offset the xcenter and ycenter pixel coordinates for the
            % Gaussians (or the centers would otherwise be unchanged
            % relative to the edge, and the purpose is to move them away
            % from the edge so we may register the image)
inarg(2)=inarg(2)+XtraPixels(2);        % Offset the x1, x2 and x3 centers
inarg(6)=inarg(6)+XtraPixels(2);
inarg(10)=inarg(10)+XtraPixels(2);
inarg(3)=inarg(3)+XtraPixels(1);        % Offset the y1, y2, and y3 centers
inarg(7)=inarg(7)+XtraPixels(1);
inarg(11)=inarg(11)+XtraPixels(1);
pc= inarg(1)*exp( -( (xdata(:,:,1)-inarg(2)).^2/(2*inarg(4)^2)+(xdata(:,:,2)-inarg(3)).^2/(2*inarg(4)^2) )  )+...
       inarg(5)*exp( -( (xdata(:,:,1)-inarg(6)).^2/(2*inarg(8)^2)+(xdata(:,:,2)-inarg(7)).^2/(2*inarg(8)^2) )  )+...
         inarg(9)*exp( -( (xdata(:,:,1)-inarg(10)).^2/(2*inarg(12)^2)+(xdata(:,:,2)-inarg(11)).^2/(2*inarg(12)^2) )  )+ inarg(13);
