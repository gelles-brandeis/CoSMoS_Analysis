function pc=threegauss2dfit(indata,varargin)
%
% function threegauss2dfit(indata,<inputarg0>)
%
% Will fit the 'indata' (2D matrix) to a gaussian function.
%
% indata     == input 2D matrix (e.g. image intensity) that will be fit to a gaussian 
% inputarg0  == optional starting parameters for the fit
%                 [amp centerx centery omega offset] 
%
% The form of the exponential will be:
% amp1*exp( -( (x-centerx1).^2/(2*omega1^2)+(y-centery1).^2/(2*omega1^2)  )+... 
% amp2*exp( -( (x-centerx2).^2/(2*omega2^2)+(y-centery2).^2/(2*omega2^2)  )+... 
% amp3*exp( -( (x-centerx3).^2/(2*omega3^2)+(y-centery3).^2/(2*omega3^2)  )+offset
%
% inputarg0  == [ amp1 centerx1 centery1 omega1 ...
%              amp2 centerx2 centery2 omega2 ...
%                 amp3 centerx3 centery3 omega3 offset]
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

inlength=length(varargin);
                                                % Grab the starting
                                                % parameters if they are
                                                % present
if inlength>0
    inputarg0=varargin{1}(:);                   %amp=varargin{1}(1);
                                                %centerx=varargin{1}(2);
                                                %centery=varargin{1}(3);
                                                %omega=varargin{1}(4);
                                                %offset=varargin{1}(5);
end
[mrow ncol]=size(indata);                       % Form the xdata input array
xdata=zeros(mrow,ncol,2);
                                                % xdata(:,:,2) will run in
                                                % the Y dimension,
                                                % xdata(:,:,1) in the X
xdata(:,:,2)=diag( [0:mrow-1])*ones(mrow,ncol);
xdata(:,:,1)=ones(mrow,ncol)*diag( [0:ncol-1]);
options=optimset('Display','off');              % suppress the screen printing 
                                                %during the lsqcurvefit()
                                                %call
                                             
%pc =lsqcurvefit('gauss2dfunc',inputarg0,xdata,indata,-10000*ones(1,5),100000*ones(1,5),options);
                            % Constrain fit so that center must be within the  AOI  
                            %                     [lower bounds=0],     [upper bounds]  
%pc =lsqcurvefit('gauss2dfunc',inputarg0,xdata,indata,[0 0 0 0 0],[100000 inputarg0(2)*2 inputarg0(3)*2 10000 100000],options);

% In gauss2d_mapstruc2d_v2 we use e.g. input frame: firstaoi=firstfrm(ylow:yhi,xlow:xhi);
%  FirstImageData=[aoiindx   mapstruc_cell{1,aoiindx}.aoiinf(1)   outarg(1)   outarg(2)+xlow   outarg(3)+ylow   outarg(4)   outarg(5)   sum(sum(firstaoi))];
% in order to relate the coordinate outputs of the single gaussian fit to the actual image coordinates

pc =lsqcurvefit('threegauss2dfunc',inputarg0,xdata,indata,zeros(13,1),... 
        [100000 inputarg0(2)*2 inputarg0(3)*2 10000 ...
        100000 inputarg0(6)*2 inputarg0(7)*2 10000 ...
        100000 inputarg0(10)*2 inputarg0(11)*2 10000 100000],options);
