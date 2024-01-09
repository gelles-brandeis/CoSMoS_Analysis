function pc=Update_aoiImageSet_v1(handles,BeginOrAdd)
%
% function Update_aoiImageSet_v1(handles,BeginOrAdd)
%
% This routine is called from withing imscroll (selected under MappingMenu)
% and will build an AOI list together with images of a region surrounding
% those AOIs, and optionally add that list+images to the existing set.  
% The AOI list+images (aoiImageSet)will be used for storing exemplary 
% prism-dispersed images that are identified as
% belonging to particular image classes (particular
% combinations of different colored fluorescent spots).  The file thus
% saved will be used later and compared to data images so as to identify
% those data images as belonging to one of the image classes.
% 
% handles == handles structure from imscroll
% BeginOrAdd ==0 or 1 Create the handles.aoiinfo2x structure anew (0) or add AOIs
%              to the existing handles.aoiinfo2 structure (1).
% handles.aoiImageSet{M}.aoiinfoTot ==[(framenumber when marked) ave x y pixnum aoinumber]
%              This 1 x 6 vector (one row for each of M AOIs) is the same form as handles.FitData, but may contain
%              more AOIs since we will be successively adding .Fitdata lists
%              to this .aoiinfoTot list.  Note that the 'framenumber' is
%              that for this reference AOI, not the accompanying images.
% handles.aoiImageSet{M}.aoiinfoTotx==[(framenumber when marked) ave x y pixnum aoinumber Class#...
%                                  ImageFrameStart  (ImagesPerAOI =(ImageFrameStart-ImageFrameEnd)) rxLo rxHi ryLo ryHi]
%               (one 13 element row for this Mth AOI)
% handles.aoiImageSet{M}.aoiinfoTotxDescription = '[(framenumber when marked) ave x y pixnum aoinumber Class# ...
%                                                                     ImageFrameStart ImagesPerAOI  rxLo rxHi ryLo ryHi]'
% handles.aoiImageSet{M}.HalfOutputImageSize ==[rxLo rxHi ryLo ryHi]  boundaries
%              for the registered images stored.  See RegisterImage( )
% handles.aoiImageSet{M}.ImageFrameStart== The images that accompany this Mth AOI will
%              begin at the frame number specified
% handles.aoiImageSet{M}.ImageFrameEnd== The images that accompany this Mth AOI will
%              end at the frame number specified
% handles.aoiImageSet{M}.rawImage == output from the
%              RegisterImage( ) function.  A structure
%              with three members: 
%              {M}.rawImage.frames(rose+2, col+2,n) contains n=ImagesPerAOI stacked images in one   
%              matrix of dimention (rose+2) X (col+2) X n
%              Unaltered images of regions surrounding the AOIs
%              listed in .aoiinfoTot.  The size of the raw images will be
%              two pixels larger than the HalfOutputImageSize parameters 
%              (HalfOutputImageSize+2) used for the registered images.
%              {M}.rawImage.FrameAve(rose,col) one image frame of dimention (rose) X (col)
%              that is the average of all n images in {M}.frames
%              {M}.rawImage aoiinfo2_output =[frm#  1  newx  newy  pixnum  aoi#] provides the 
%               new x and y locations for the AOI center, referenced to
%               images contained in the stacked matrix {M}.rawImage.frames
% handles.aoiImageSet{M}.centeredImage == output from the
%              RegisterImage( ) function.  A structure
%              with three members: 
%              {M}.centeredImage.frames(rose,col,n) contains n stacked images in one   
%              matrix of dimention (rose) X (col) X n (n=ImagesPerAOI)
%              images with AOIs registered to a pixel center.
%              the images sizes are set using HalfOutputImageSize and the
%              RegisterImage( ) function.
%              {M}.centeredImage.FrameAve one image frame of dimention (rose) X (col)
%              that is the average of all n images in {M}.centeredImages.frames
%              {M}.centeredImage.aoiinfo2_output =[frm#  1  newx  newy  pixnum  aoi#] provides the 
%               new x and y locations for the AOI center, referenced to
%               images contained in the stacked matrix {i}.frames
% handles.aoiImageSet{M}.ClassNumber== single number, each entry is 1-8 specifying which
%              image class this AOI is associated with
% handles.aoiImageSet{M}.ClassDescription == '[ROG RO RG OG R O G Z] = 1:8'
%              translates the .ClassNumber code to specific color
%              combinations, R=red, O=orange, G=green dye colors
% handles.aoiImageSet{M}.filepath == listing the glimpse folder
%              or Tiff file from which each AOI was derived (from either
%              handles.gfolder or handles.TiffFolder, depending of setting
%              of ImageSource (value = 3 or 1, repsectively)
% handles.aoiImageSet{M}.GlimpseOrTiff ==  single entry either
%              'G' or 'T' specifying that the original image file was
%              either from a Glimpse or Tiff file.

% v1 2/18/2016  Altered the aoiImageSet architecture to be aoiImageSet{M}
% M cell arrays, one cell array (with numberous members, above) for each AOI
% stored (previously, the aoiImageSet structure had numberous members, and 
% each member had M rows, images or elements)

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


% First create a DumaoiImageSet structure in both instances where
% BeginOrAdd = either 0 or 1.  Then, if BeginOrAdd =1 we merely
% add that handles structure to the existing handles.aoiImageSet, following the code
% already made in Import_aoiImageSet. If instead BeginOrAdd=0 we merely set
% handles.aoiImageSet=DumaoiImageSet and we're done.

% We first branch depending on whether we create the handles.aiinfo2x
% structure anew or add to an existing structure

 aoiinfo2=handles.FitData;                    % Save the exiting (before adding new) 
                                              % aoiinfo2 and aoiImageSet data to gui_files directory
  if (isfield(handles,'aoiImageSet')) & (~isempty(handles.aoiImageSet)) & (~isempty(aoiinfo2))
        % Here if aoiImageSet exits, is not empty and aoiinfo2 is not empty 
    aoiImageSet=handles.aoiImageSet;         % save aoiinfo2 and aoiImageSet data to gui_files directory
    eval(['save ' handles.FileLocations.gui_files 'aoiImageSet.dat  aoiinfo2 aoiImageSet -mat']) 
 else
                                        % If there is not prior aoiImageSet
                                        % then just save the existing
                                        % aoiinfo2 to gui_files
     % eval(['save ' handles.FileLocations.gui_files 'aoiImageSet.dat  aoiinfo2 -mat']) 
  end
   
    % HalfOutputImageSize
    %XYRegionPresetMenuValue=8;                  % Preset value for the 'Image Region'
    %rxLo=str2num(handles.XYRegionPreset{XYRegionPresetMenuValue}.EditUniqueRadiusXLo);
    %rxHi=str2num(handles.XYRegionPreset{XYRegionPresetMenuValue}.EditUniqueRadiusX);
    %ryLo=str2num(handles.XYRegionPreset{XYRegionPresetMenuValue}.EditUniqueRadiusLo);
    %ryHi=str2num(handles.XYRegionPreset{XYRegionPresetMenuValue}.EditUniqueRadius);
    rxLo=str2num(get(handles.EditUniqueRadiusXLo,'String'));
    rxHi=str2num(get(handles.EditUniqueRadiusX,'String'));
    ryLo=str2num(get(handles.EditUniqueRadiusLo,'String'));
    ryHi=str2num(get(handles.EditUniqueRadius,'String'));
    HalfOutputImageSize =[rxLo rxHi ryLo ryHi];
    DumaoiImageSet.HalfOutputImageSize =HalfOutputImageSize;
 
    % Descriptions
   DumaoiImageSet.aoiinfoTotxDescription='[(framenumber when marked)  ave x y pixnum aoinumber Class# ImageFrameStart ImagesPerAOI rxLo rxHi ryLo ryHi]';
    DumaoiImageSet.ClassDescription = '[ROG RO RG OG R O G Z] = 1:8';
    
   % Class Number
   [rose col]=size(handles.FitData);
   ClassNumber=get(handles.ImageClass,'Value');      % Value off the ImageClass 
                                       % popup specifying class# of these AOIs/images
   DumaoiImageSet.ClassNumber=ones(rose,1)*ClassNumber;
     
  % Image Frames Start and End values
   ImagesPerAOI=str2num(get(handles.FrameAve,'String'));
   ImageFrameStart=str2num(get(handles.ImageNumberValue,'String'));
   ImageFrameEnd=ImageFrameStart+ImagesPerAOI-1;
   DumaoiImageSet.ImageFrameStart=ones(rose,1)*ImageFrameStart;    % Images stored with each AOI will begin with this frame number
   DumaoiImageSet.ImageFrameEnd=ones(rose,1)*ImageFrameEnd;    % Images stored with each AOI will end with this frame number

   % aoiinfoTotx
  
   DumaoiImageSet.aoiinfoTotx=[handles.FitData ones(rose,1)*[ClassNumber ImageFrameStart ImagesPerAOI rxLo rxHi ryLo ryHi] ];
   
   % Filepath
   ImageSource=get(handles.ImageSource,'Value');        % 1=> Tiff, 3=>Glimpse
   if ImageSource==1
                    % Files are Tiff
       filepath{1}=handles.TiffFolder;      % full Filepath to tiff file
       DumaoiImageSet.filepath=repmat(filepath,rose,1);    % Cell array that is rose x 1
       DumaoiImageSet.GlimpseOrTiff=repmat('T',rose,1);    % Vector array that is rose x 1
   else
                    % Files are Glimpse
       filepath{1}=handles.gfolder;      % Filepath to glimpse folder 
       DumaoiImageSet.filepath=repmat(filepath,rose,1);    % Cell array that is rose x 1
       DumaoiImageSet.GlimpseOrTiff=repmat('G',rose,1);    % Vector array that is rose x 1
   end
   
   % Raw Images
   DumaoiImageSet.rawImage=cell(rose,1);           % reserve cell array space, one for each AOI
   aoiinfo2_raw=handles.FitData;                        % [(framenumber when marked)  ave x y pixnum aoinumber]
   aoiinfo2_raw(:,1)=ImageFrameStart;                   % First image frame to be stored
   aoiinfo2_raw(:,2)=ImagesPerAOI;                      % Number of successive images we will use

   RegisterFlag=1;                                      % =1  =>do not register the image
   RoundingPixelFraction=[0 0];                         % Register image to pixel center (but not yet)
   if ImageSource==3
       % Glimpse source
      for indx=1:rose
          [rose indx]
                        % Cycle through all the AOIs
                        % NOTE: we use (HalfOutputImageSize +2), ADDING 2 PIXELS around the edge for this unaltered image 
         DumaoiImageSet.rawImage{indx}=RegisterImage(handles.gfolder,aoiinfo2_raw(indx,:),HalfOutputImageSize+2,RoundingPixelFraction, RegisterFlag);
                         % To save time later on, for each AOI we will also  
                        % store the average of the raw frames
         DumaoiImageSet.rawImage{indx}.FrameAve=uint16(sum(DumaoiImageSet.rawImage{indx}.frames,3)/ImagesPerAOI);
      end
   else
       % Here to fetch frames from a Tiff file (not yet implemented)
   end

   
   % Registered Images
    DumaoiImageSet.centeredImage=cell(rose,1); 
   RegisterFlag=0;                                     % =0 => Register the image, in this case
                                                        % to the pixel center since RoundingPixelFraction=[0 0]
    if ImageSource==3
       % Glimpse source
      for indx=1:rose
           [rose indx]
                        % Cycle through all the AOIs, now registering images to pixel center 
         
         DumaoiImageSet.centeredImage{indx}=RegisterImage(handles.gfolder,aoiinfo2_raw(indx,:),HalfOutputImageSize,RoundingPixelFraction, RegisterFlag);
                        % To save time later on, for each AOI we will also  
                        % store the average of the centered frames
         DumaoiImageSet.centeredImage{indx}.FrameAve=uint16(sum(DumaoiImageSet.centeredImage{indx}.frames,3)/ImagesPerAOI);
      end
                        
         
    else
       % Here to fetch frames from a Tiff file (not yet implemented)
    end
    

    if BeginOrAdd==0
            % Here to create a new handles.aoiImageSet structure
            % At this point we have only aoiinfo2 (handles.FitData) but no aoiImageSet 
        handles.aoiImageSet=DumaoiImageSet;
        handles.FitData=[handles.aoiImageSet.aoiinfoTotx(:,1:6)];
        handles.FitData=update_FitData_aoinum(handles.FitData);     % Update the aoi numbering
            % The handles.FitData need not be altered since this is the first set of AOIs  
    else
            % BeginOrAdd ==1, Here to add the DumaoiImageSet we have constructed to the already
            % existing handles.aoiImageSet
        
          
        if any(~(handles.aoiImageSet.HalfOutputImageSize==DumaoiImageSet.HalfOutputImageSize))
                    % Here only if the image size in the current and added
                    % sets differ
           error('Disagreement in HalfOutputImageSize:  images in added sets should be the same size')
        end
                    % Add the prior cumulative FitData (aoiinfo2) to the new aoiinfo2 set  
        handles.FitData=[handles.aoiImageSet.aoiinfoTotx(:,1:6); DumaoiImageSet.aoiinfoTotx(:,1:6)];  
        handles.FitData=update_FitData_aoinum(handles.FitData);     % Update the aoi numbering

                    % Add to the existing ..aoiinfoTotx
        handles.aoiImageSet.aoiinfoTotx=[handles.aoiImageSet.aoiinfoTotx; DumaoiImageSet.aoiinfoTotx];
                        
                    % Update the AOI numbering in ..aiinfoTotx
        handles.aoiImageSet.aoiinfoTotx(:,1:6)=update_FitData_aoinum(handles.aoiImageSet.aoiinfoTotx(:,1:6));
        
                    % Add to list of image start and end frames
        handles.aoiImageSet.ImageFrameStart=[handles.aoiImageSet.ImageFrameStart; DumaoiImageSet.ImageFrameStart];
        handles.aoiImageSet.ImageFrameEnd=[handles.aoiImageSet.ImageFrameEnd; DumaoiImageSet.ImageFrameEnd];  
    
                    % Add to list of raw and centered images:  column vector of cell arrays 
         handles.aoiImageSet.rawImage=[handles.aoiImageSet.rawImage; DumaoiImageSet.rawImage];
         handles.aoiImageSet.centeredImage=[handles.aoiImageSet.centeredImage; DumaoiImageSet.centeredImage];
         
                    % Add to list of class numbers: column vector with
                    % entries 1-8 specifying class
         handles.aoiImageSet.ClassNumber=[handles.aoiImageSet.ClassNumber; DumaoiImageSet.ClassNumber];
         
                   % Add to list of file paths designating from where the
                   % data was taken M x 1 cell array
         handles.aoiImageSet.filepath=[handles.aoiImageSet.filepath; DumaoiImageSet.filepath];
         
                    % Add to list of file types 'G' or 'T' for Glimpse or Tiff
                    % M x 1 vector
         handles.aoiImageSet.GlimpseOrTiff=[handles.aoiImageSet.GlimpseOrTiff; DumaoiImageSet.GlimpseOrTiff];
  
    end 
         
     % Update the handles structure
  guidata(gcbo,handles)
  aoiinfo2=handles.FitData;
  aoiImageSet=handles.aoiImageSet;

  outputName=get(handles.OutputFilename,'String');            % Get the name of the output file
  eval(['save ' handles.FileLocations.data outputName ' aoiinfo2 aoiImageSet']);      % Save the current parameters in data directory   
                                    % Update the AOIs displayed
     
        
  pc=1;      
 % Correct the Import_aoiImageSet to properly save the image structures as was done here above       
   
  
   
   
   
   
   
   
   
