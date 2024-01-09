function pc=Nearest_Images(xycoord,ClassNumber, aoiImageSet, NearPts)
%
% function Nearest_Images(xycoord, ClassNumber, aoiImageSet, NearPts)
%
% This routine uses the xy coordinates (xycoord) and specified class number
% (ClassNumber = 1:8 = [ROG RO RG OG R O G Z]) to retrieve averaged images
% from the input aoiImageSet (from aoiImageSet.centeredImage.FrameAve).
% The calibration images retrieved from aoiImageSet were recorded at xy 
% locations close to that of the input 'xycoord' and are examles of the 
% image class specified by 'ClassNumber'.  For example,  if NearPts=10, 
% the routine will find the 10 images from within aoiImageSet recorded at
% at xy locations nearest to the site specified by the single xy
% coordinate 'xycoord' (all images will be of the class specified by 
% 'ClassNumber')
%
% xycoord == [x y]  a single xy coordinate pair.  The routine will
%        calculate distances between this site and all the locations 
%        specified in the aoiImageSet, then return those images from the
%        aoiImageSet closest to xycoord (and matching the 'ClassNumber').
% ClassNumber == integer 1-8 specifying the class number of the images to
%        be retrieved from aoiImageSet 1:8 map to [ROG RO RG OG R O G Z]
% aoiImageSet == an aoiImageSet found using imscroll().  See
%           Update_aoiImageSet() header, type 'help Update_aoiImageSet'.
% NearPts == The number of images that will be retrieved  by this routine.
%        If NearPts =5 the routine will find  the 5 images  from 
%        the 'aoiImageSet' list nearest to the site specified by the single xy
%        coordinate 'xycoord' and matching the class number specified by 'ClassNumber'.
%
% Output.images=[m n NearPts] stacked matrix containing individual images
%                retrieved by this routine from the specified aoiImageSet
% output.AveImage= [m n] one image consisting of the averaged Output.images 
% Output.xycoords= [NearPts 3] list of [x y distance] for the xy
%       coordinates of the retrieved images and distance from the input 'xycoord'
% Output.indices = [NearPts 1] list of indices for the aoiImageSet that
%       reference the images retrieved.  For example
%       aoiImageSet.aoiinfoTotx(Output.indices,3:4) retrieves the list of
%       xy coordinates specified by Output.xycoords
% Ouput.Properties== Nearptx X 4 matrix [Xmean Ymean X2moment Y2moment]
%       taken from the aoiImageSet.centeredImage{M}.Properties of the 
%       set of nearest points

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

logik=aoiImageSet.ClassNumber==ClassNumber;	% Pick out examples of image class
                                            % specified by ClassNumber
              % Subset of aoiinfoTotx matching specified class #
SubaoiinfoTotx=aoiImageSet.aoiinfoTotx(logik,:);
              % Get the list of nearest xy coord in SubaoiImageSet of this class
              % Note: Indices retrieved are w/in the SubaoiinfoTotx, not the
              % original aoiImageSet.aoiinfoTotx


NearestSet=Nearest_AOIs(xycoord,SubaoiinfoTotx(:,3:4),NearPts);
        % NearestSet.SortedXYList == M x 2 [x y distance^2] xylist sorted for increasing distance from xycoord
        % NearestSet.CloseXYList == NearPts x 2 [x y distance] list of sites from xylist closest
        %                     to  xycoord
        % NearestSet.IndexXYList == Sorting index for the xylist.  e.g. xylist(I,:)
        %                   is the xylist sorted with increasing distance from the
        %                   input xycoord site.


        % NearestSet.IndexXYList(1:NearPts)lists the indices w/in SubaoiImageSet
        % SubaoiinfoTotx(NearestSet.IndexXYList(1:NearPts),6) lists the AOI # (which also =index) w/in aoiImageSet
        % for the retrieved images
      
         %{M}.aoiinfo2_output =[frm#  ave(=1)  newx  newy  pixnum  aoi#] provides the 
newxy=zeros(NearPts,2);         % store blue spot coordinates w/in these frames
pc.Properties=zeros(NearPts,4);

for indxxx=1:NearPts
    newxy(indxxx,:)=aoiImageSet.centeredImage{SubaoiinfoTotx(NearestSet.IndexXYList(indxxx),6)}.aoiinfo2_output(3:4);
    pc.Properties(indxxx,:)=aoiImageSet.centeredImage{SubaoiinfoTotx(NearestSet.IndexXYList(indxxx),6)}.Properties(1:4);
end
    % [ (x in original FOV) (y in original FOV)  (x in current small image)  (y in current small image)   (distance btwn this image and xycoord)] 
 
pc.xycoords= [aoiImageSet.aoiinfoTotx( SubaoiinfoTotx(NearestSet.IndexXYList(1:NearPts),6),3:4)...
                         newxy sqrt(NearestSet.SortedXYList(1:NearPts,3))] ;
pc.indices=SubaoiinfoTotx(NearestSet.IndexXYList(1:NearPts),6);         % Indices (=aoi number) w/in aoiImageSet
dum=aoiImageSet.centeredImage{pc.indices(1)}.FrameAve;     % ex of registered image
[rose col]=size(dum);               % Get size of images
pc.images=uint16(zeros(rose,col,NearPts));      % Reserve Space

for indx=1:NearPts
                % Fetch the images near to xycoord that match ClassNumber 
    pc.images(:,:,indx)=aoiImageSet.centeredImage{pc.indices(indx)}.FrameAve;
end
ImagesPerAOI=aoiImageSet.aoiinfoTotx(pc.indices,9);    % The number of images averaged in preparing the aoiImageSet.centeredImage{}.FrameAve
AveImage=zeros(rose,col);
for indxx=1:NearPts
    AveImage=AveImage+double(pc.images(:,:,indxx))*ImagesPerAOI(indxx);
end
pc.AveImage=uint16(AveImage/sum(ImagesPerAOI));

    
%pc.AveImage=uint16(sum(pc.images,3)/NearPts);