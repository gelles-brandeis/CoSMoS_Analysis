function pc=aoiinfo2_ImageClasses(aoiinfo2, aoiImageSet, NearPts)
%
% function aoiinfo2_ImageClasses(aoiinfo2, aoiImageSet, NearPts)
%
%     Each (x y) AOI has its own set of image Classes that we may compare it to
% to determine which combination of fluorescent spots is in that AOI. 
% The image Class is specific to one AOI because the Class  
% is derived only from nearby exemplary images in aoiImageSet (only the 
% 'NearPts' number of exemplary images from aoiImageSet that are nearest to  
% each (x y) AOI) are used construct those exemplary image Classes.
%     Given an N x 6 input aoiinfo2 array, this routine will compute a set 
% of N cell arrays, where each cell arrary is a cell array of the 8
% (8 at least for now, but should work with more) images Classes (cell
% array of 8 images).  This set of N cell arrays can then be compared to
% the sequence of images contained in that AOI in order to determine the
% time sequence of fluorophores that are colocalized in that AOI
%
% aoiinfo2 == N x 6 matrix, handles.FitData =[[(framenumber when marked) ave x y pixnum aoinumber]  
% aoiImageSet== saved by imscroll.  See header of Update_aoiImageSet( ) or 
%                Import_aoiImageSet( ) for full definition
% NearPts== the number of closest images to use from the aoiImageSet
%         data set.  For example, with Nearpts=15 we use the 15 points in the
%         aoiImageSet list that lie closest to the [x y]=aoiXY input pair
%
% OUTPUT{N}== cell array with N elements, each element being a cell array 
%            of  8 (or more) images.  Each of the 8 images will be one Class 
%            average of some combination of fluorophores.  Each Class average 
%            image is computed from aoi images in aoiImageSet that are 
%            closest to one of the N AOIs listed in aoiinfo2.
% 

% Copyright 2016 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.

[aoiNum col]=size(aoiinfo2);        % aoiNum == number of AOIs in our input list
pc=cell(aoiNum,1);                  % reserve space for the output cell array of cell arrays
for indx=1:aoiNum
                            % Cycle through all the input AOIs in the
                            % aoiinfo2 list
                            % Find each set of image Classes
    pc{indx}=ProximityClassAve(aoiImageSet, aoiinfo(indx,3:4), NearPts);
end
