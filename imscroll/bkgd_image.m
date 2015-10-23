function [ background ] = bkgd_image(image,Rs,Rn)
%bkgd_image(image, Rs, Rn) takes a single image and calculates a rolling
%ball background using a disk, with the necessary inputs as the image 
%matrix, the diameter of an average spot , and a noise radius large enough 
% to smooth noise but small enough to not connect spots.  (Default Rs=5, Rn=2).

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


%setup default R and H values
if (nargin < 3) || isempty(Rn)
 Rn = 2;
end
if (nargin < 3) || isempty(Rs)
 Rs = 5;
end
% the first process is a morphological closing of the noise and opening of 
% noise, to smooth and divide baseline noise to either highs or lows
se_noise=strel('disk',Rn,0);
I0=imclose(image,se_noise);
I1=imopen(image,se_noise);

% now morphologically open both images, using the structural element
% se_spot

se_spot=strel('disk',Rs,0);
I2=imopen(I0,se_spot);
I3=imopen(I1,se_spot);

%now average these two to get noise-averaged baseline background

background=(imadd(I2,I3)/2);

end

