function pc=linear_AOI_interpolation(frm,xycenter,radius)
%
% function linear_AOI_interpolation(frm,xycenter,radius)
%
% This function will integrate an aoi specified by the center xy 
% coordinates of the aoi (xycenter) and the aoi size (radius = 1/2 the
% length of one side).  When the aoi overlaps only a fraction of a 
% particular pixel, the integration will include that same fraction of
% the pixel value in the output sum.
%
% frm == image frame that contains the aoi that will be integrated
% xycenter  ==  [xcoordinate ycoordinate]  the x and y coordinates of the 
%            aoi center (integral numbers specify the center of a pixel,
%            half integers specify the edge of a pixel)
% radius  ==  when an aoi is m x m pixels in dimensions, the radius is
%            defined as m/2, or half the length (in pixels) of one side of
%            the aoi.  e.g. a 6 x 6 pixel has a radius of 3 and a 7 x 7 aoi
%            has a radius of 3.5

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


            % Define a range of pixels that more than encompases the entire
            % aoi.  We will integrate only over this limited pixel range.
xpixels_low=floor(xycenter(1)-radius);   % Integer value for smallest x pixel coordinate 
xpixels_high=ceil(xycenter(1)+radius);   % Integer value for largest x pixel coordinate 
ypixels_low=floor(xycenter(2)-radius);   % Integer value for smallest y pixel coordinate
ypixels_high=ceil(xycenter(2)+radius);   % Integer value for largest y pixel coordinate
                %Initialize output sum of the AOI
pc=0;       

  % Use xpL and xpH (L=low H=high) for x coordinates of the pixel edge
  % Use ypL and ypH (L=low H=high) for y coordinates of the pixel edge
  % Use xaL and xaH (L=low H=high) for x coordinates of the AOI edge
  % Use yaL and yaH (L=low H=high) for y coordinates of the AOI edge
  % Use xoL and xoH for x coordinates of the edges of the region
  %                    overlapping the AOI and pixel
  % Use yoL and yoH for x coordinates of the edges of the region
  %                    overlapping the AOI and pixel
xaL=xycenter(1)-radius;
xaH=xycenter(1)+radius;
yaL=xycenter(2)-radius;
yaH=xycenter(2)+radius;
                % Cycle through all the pixels, figuring the fractional
                % overlap and proportionately adding to the sum.
                % Note that the pixel center has the integer coordinate and
                % the pixel edges are at half integers
for xpindx=xpixels_low:xpixels_high;
    for ypindx=ypixels_low:ypixels_high
         xpL=xpindx-.5;         % Define x coordinates of the pixel edge
         xpH=xpindx+.5;
         ypL=ypindx-.5;
         ypH=ypindx+.5;         % Define y coordinates of the pixel edge
                   % Next find the edges of the overlap between the pixel
                   % and aoi.  This is done be testing whether the pixel is
                   % cut by the low edge of the aoi, is contained inside
                   % the aoi, or is cut by the right edge of the aoi.
         flagx=1;  % flag = 1 means there is nonzero overlap of the pixel and aoi
         flagy=1;
                % First define x edges of overlap region
         if (xpL>xaL) & (xpH<xaH)   % true if x edges are fully within aoi
             xoL=xpL;               % Edges of overlap are just pixel edges
             xoH=xpH;
         elseif (xpL<=xaL) & (xpH>xaL)  % True if low edge of AOI cuts through pixel
             xoL=xaL;      % Low edge of overlap is low edge of aoi
             xoH=xpH;      % High edge of overlap is high edge of pixel
                        % Assumes that pixel is smaller than the AOI (it
                        % better be)
         elseif (xpL<xaH) & (xpH>=xaH)  % True if high edge of AOI cuts through pixel
             xoL=xpL;      % Low edge of overlap is low edge of pixel
             xoH=xaH;      % High edge of overlap is high edge of aoi
                        % Assumes that pixel is smaller than the AOI
         else
             flagx=0;   % Here is there is no overlap
             xoL=0;
             xoH=0;
         end
                % Next define y edges of overlap region
         if (ypL>yaL) & (ypH<yaH)   % true if y edges are fully within aoi
             yoL=ypL;               % Edges of overlap are just pixel edges
             yoH=ypH;
         elseif (ypL<=yaL) & (ypH>yaL)  % True if low edge of AOI cuts through pixel
             yoL=yaL;      % Low edge of overlap is low edge of aoi
             yoH=ypH;      % High edge of overlap is high edge of pixel
                        % Assumes that pixel is smaller than the AOI (it
                        % better be)
         elseif (ypL<yaH) & (ypH>=yaH)  % True if high edge of AOI cuts through pixel
             yoL=ypL;      % Low edge of overlap is low edge of pixel
             yoH=yaH;      % High edge of overlap is high edge of aoi
                        % Assumes that pixel is smaller than the AOI
         else
             flagy=0;   % Here if there is no overlap
             yoL=0;
             yoH=0;
         end  
                % Compute the overlap between the pixel and AOI in 
                %(pixels)^2.  This will be a number between 0 to 1 
         overlap_area=(xoH-xoL)*(yoH-yoL)*flagx*flagy;
                % add to the running total of aoi value, using a proportion
                % of 0 to 1 of the frame value at the pixel being
                % considered
         pc=pc+frm(ypindx,xpindx)*overlap_area;
    end
end
