function pc=ProximityClassAve(aoiImageSet, aoiXY, NearPts)
%
% function ProximityClassAve(aoiImageSet, aoiXY, NearPts)
%
% This routine will form the image class averages representing different
% examples of possible fluorescent spot combinations.  We use the data in
% aoiImageSet and the (x y) coordinate pair for the input AOI (aoiXY).  The
% routine will use nearby exemplary images from aoiImageSet (only the 
% 'NearPts' number of exemplary images that are nearest to the aoiXY input
% AOI) to construct those exemplary images.  
%
% aoiImageSet == saved by imscroll.  See header of Update_aoiImageSet( ) or 
%                Import_aoiImageSet( ) for full definition
% aoiXY == [ x y]  pixel coordinates for the input AOI.  This function will
%                be constructing image class averages using exemplary
%                images closest in distance to this input AOI
% NearPts == the number of closest images to use from the aoiImageSet
%         data set.  For example, with Nearpts=15 we use the 15 points in the
%         aoiImageSet list that lie closest to the [x y]=aoiXY input pair
%
% Output  == ImageClass, acell array of images that are the same dimension,
%             orientation and pixel registry as that in InputImage

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


% First we find the classes represented in the aoiImageSet (we assume there
% will be times in which not all classes are represented
MaxClassNumber=max(aoiImageSet.ClassNumber);        % maximum class number in aoiImageSet
ClassSet=[];                % will list the class numbers in aoiImageSet
for indx=1:MaxClassNumber(1)
    if any(indx==aoiImageSet.ClassNumber)
        % Here if there are examples of this class number = indx in aoiImageSet 
        ClassSet=[ClassSet indx];   % Add this indx=class number to the set contained in aoiImageSet
    end
end
pc=cell(MaxClassNumber,1);          % Reserve space for all the class image averages
   % Now we cycle through all the classes represented in aoiImageSet
for indx=ClassSet
    logik=(aoiImageSet.ClassNumber==indx);               % Picks out indices for cell arrays matching this one class
    OneaoiImageSetImages=aoiImageSet.centeredImage(logik);     % Cell array of image structures in this one class
    
     %[(framenumber when marked)  ave x y pixnum aoinumber Class#  ImagesPerAOI  ImageFrameStart  rxLo rxHi ryLo ryHi]'
    OneaoiImageSetTotx=aoiImageSet.aoiinfoTotx(logik,:);          % N x 13 matrix with AOI Totx information for this one class
   
    distance=( (OneaoiImageSetTotx(:,3)-aoiXY(:,1)).^2 + (OneaoiImageSetTotx(:,4)-aoiXY(:,2)).^2);           % Distances of all exemplary images in this class to input AOI
    [sortDistance I]=sort(distance(:,1));
    if sum(logik)<NearPts
                    % Here if there are fewer than 'NearPts' AOIs in
                    % aoiImageSet that are in this class
       NearPtsmin=sum(logik);
    else
                    % Here if the # of aoiImageSet AOIs in this class exceeds 'NearPts' 
        NearPtsmin=NearPts;
    end
   
    CloseTotx=OneaoiImageSetTotx(I(1:NearPtsmin),:);           %  L x 13 Just keep a number 'NearPts' of Images Totx closest to aoiXY
    CloseImageSet=OneaoiImageSetImages(I(1:NearPtsmin));       %  L cell arrarys, keep a number 'NearPts' of Images closest to aoiXY
                        % Next we need to average all the exemplary class images 
                        % we have identified as being close to aoiXY.
    dumImage=zeros(size(CloseImageSet{1}.FrameAve));
    for indxN=1:NearPtsmin
                             % Add up all the near averaged centered images in this class
                             % Note we multiply each image by the number of
                             % images that went into the average
                             % (ImagesPerAOI --see Update_aoiImageSet( )  )
        dumImage=dumImage+CloseTotx(indxN,8)*CloseImageSet{indxN}.FrameAve;   
    end
    pc{indx}=uint16(dumImage/sum(CloseTotx(:,8)));          % Dividing now by total number of images that went into the average
            % The pc{ } cell array is now the set of exemplary images in each class. We
            % have used only those images in aoiImageSet that were close to
            % the aoiXY in computing the class average
end





    
     