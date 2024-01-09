function pc=Import_aoiImageSet(handles,BeginOrAdd)
%
% function Import_aoiImageSet(handles,BeginOrAdd)
%
% This routine is called from withing imscroll (selected under MappingMenu)
% and will import a previously saved  aoiImageSet  and update an AOI list together with images of a region surrounding
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
% handles.aoiImageSet.aoiinfoTot ==[(framenumber when marked) ave x y pixnum aoinumber]
%              This M x 6 for (M AOIs) is the same form as handles.FitData, but may contain
%              more AOIs since we will be successively adding .Fitdata lists
%              to this .aoiinfoTot list.  Note that the 'framenumber' is
%              that for this reference AOI, not the accompanying images.
% handles.aoiImageSet.aoiinfoTotx==[(framenumber when marked) ave x y pixnum aoinumber Class#...
%                                        (ImagesPerAOI =(ImageFrameStart-ImageFrameEnd))  ImageFrameStart rxLo rxHi ryLo ryHi]
% handles.aoiImageSet.aoiinfoTotxDescription = '[(framenumber when marked)  ave x y pixnum aoinumber Class# 
%                                                  ImagesPerAOI ImageFrameStart rxLo rxHi ryLo ryHi]'
% handles.aoiImageSet.HalfOutputImageSize ==[rxLo rxHi ryLo ryHi]  boundaries
%              for the registered images stored.  See RegisterImage( )
% handles.aoiImageSet.ImageFrameStart==[M x 1] The images that accompany this AOI will
%              begin at the frame number specified
% handles.aoiImageSet.ImageFrameEnd== [M x 1] The images that accompany this AOI will
%              end at the frame number specified
% handles.aoiImageSet.rawImage == {M} cell arrays output from the
%              RegisterImage( ) function.  Each cell array is a structure
%              with two members: 
%              {M}.frames contains n stacked images in one   
%              matrix of dimention (rose+2) X (col+2) X n
%              Unaltered images of regions surrounding the AOIs
%              listed in .aoiinfoTot.  The size of the raw images will be
%              two pixels larger than the HalfOutputImageSize parameters 
%              (HalfOutputImageSize+2) used for the registered images.
%              {M}.FrameAve one image frame of dimention (rose+2) X (col+2)
%              that is the average of all n images in {M}.frames
%              {M}.aoiinfo2_output =[frm#  1  newx  newy  pixnum  aoi#] provides the 
%              new x and y locations for the AOI center, referenced to
%              images contained in the stacked matrix {i}.frames
%handles.aoiImageSet.centeredImage == {M} cell arrays output from the
%              RegisterImage( ) function.  Each cell array is a structure
%              with two members: 
%              {M}.frames contains n stacked images in one   
%              matrix of dimention (rose+2) X (col+2) X n
%              images with AOIs registered to a pixel center.
%              the images sizes are set using HalfOutputImageSize and the
%              RegisterImage( ) function.
%              {M}.FrameAve one image frame of dimention (rose+2) X (col+2)
%              that is the average of all n images in {M}.frames
%              {M}.aoiinfo2_output =[frm#  ave(=1)  newx  newy  pixnum  aoi#] provides the 
%               new x and y locations for the AOI center, referenced to
%               images contained in the stacked matrix {i}.frames
%              {M}.properties =[(background intensity) Xmean Ymean X2moment Y2moment]
%                background intensity: computed by averaging intensity over nearby MT
%                   AOIs (from data in handles.BackgroundAOIsData)
%                Xmean Ymean: 1st moment coordinates of (intensity-background)
%                X2moment Y2moment:  (intensity-background.^2 moments with respect to
%                   the Xmean Ymean positions (in other words, the 2nd moment) 
% handles.aoiImageSet.ClassNumber== M x 1 vector, each entry is 1-8 specifying which
%              image class this AOI is associated with
% handles.aoiImageSet.ClassDescription == '[ROG RO RG OG R O G Z] = 1:8'
%              translates the .ClassNumber code to specific color
%              combinations, R=red, O=orange, G=green dye colors
% handles.aoiImageSet.filepath{} == M x 1 cell array listing the glimpse folder
%              or Tiff file from which each AOI was derived (from either
%              handles.gfolder or handles.TiffFolder, depending of setting
%              of ImageSource (value = 3 or 1, repsectively)
% handles.aoiImageSet.GlimpseOrTiff == M x 1 matrix whose entries are either
%              'G' or 'T' specifying that the original image file was
%              either from a Glimpse or Tiff file.

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
     %eval(['save ' handles.FileLocations.gui_files 'aoiImageSet.dat  aoiinfo2 -mat']) 
  end
   

[fn fp]=uigetfile;         % user navigates to a file
eval(['load ' [fp fn] ' -mat']);   % Load that file--> NEW values for aoiImageSet, aoiinfo2
if BeginOrAdd==0
    % Here to import a previously saved file containing aoiImageSet and
    % make that the current set (removing any existing set)
  
    handles.aoiImageSet=aoiImageSet;
    handles.FitData=aoiinfo2;  
    handles.FitData=update_FitData_aoinum(handles.FitData);

    outputName=get(handles.OutputFilename,'String');
                            % Save current values of aoiinfo2 and
                            % aoiImageSet to the data directory
    eval(['save ' handles.FileLocations.data outputName ' aoiinfo2 aoiImageSet']);
    guidata(gcbo,handles)
                                    % Update the AOIs displayed
    PlotImageClasses(aoiImageSet, 5:8, 25:28)
else
    % Here to import a previously saved file containing aoiImageSet and add
    % those AOIs to the existing set.
    
    
    if any(~(handles.aoiImageSet.HalfOutputImageSize==aoiImageSet.HalfOutputImageSize))
                    % Here only if the image size in the current and added
                    % sets differ
        error('Disagreement in HalfOutputImageSize:  images in added sets should be the same size')
    end
    
                    % Add and display the additional aoiinfo2 list
    handles.FitData=[handles.FitData; aoiinfo2];
    handles.FitData=update_FitData_aoinum(handles.FitData);     % Update the aoi numbering

                    % Add to the existing ..aoiinfoTotx
    handles.aoiImageSet.aoiinfoTotx=[handles.aoiImageSet.aoiinfoTotx; aoiImageSet.aoiinfoTotx];
        % Update the AOI numbering in ..aiinfoTotx
    handles.aoiImageSet.aoiinfoTotx(:,1:6)=update_FitData_aoinum(handles.aoiImageSet.aoiinfoTotx(:,1:6));
    
                    % Add to list of image start and end frames
    handles.aoiImageSet.ImageFrameStart=[handles.aoiImageSet.ImageFrameStart; aoiImageSet.ImageFrameStart];
    handles.aoiImageSet.ImageFrameEnd=[handles.aoiImageSet.ImageFrameEnd; aoiImageSet.ImageFrameEnd];
    
                    % Add to list of raw and centered images:  column vector of cell arrays 
    handles.aoiImageSet.rawImage=[handles.aoiImageSet.rawImage; aoiImageSet.rawImage];
    handles.aoiImageSet.centeredImage=[handles.aoiImageSet.centeredImage; aoiImageSet.centeredImage];
    
                    % Add to list of class numbers: column vector with
                    % entries 1-8 specifying class
    handles.aoiImageSet.ClassNumber=[handles.aoiImageSet.ClassNumber; aoiImageSet.ClassNumber];
    
                    % Add to list of file paths designating from where the
                    % data was taken M x 1 cell array
    handles.aoiImageSet.filepath=[handles.aoiImageSet.filepath; aoiImageSet.filepath];
    
                    % Add to list of file types 'G' or 'T' for Glimpse or Tiff
                    % M x 1 vector
    handles.aoiImageSet.GlimpseOrTiff=[handles.aoiImageSet.GlimpseOrTiff; aoiImageSet.GlimpseOrTiff];
    
                    % Update the handles structure
    aoiinfo2=handles.FitData;
    aoiImageSet=handles.aoiImageSet;
   % eval(['save ' handles.FileLocations.gui_files 'aoiImageSet.dat  aoiinfo2 aoiImageSet -mat'])
    outputName=get(handles.OutputFilename,'String');            % Get the name of the output file
    eval(['save ' handles.FileLocations.data outputName ' aoiinfo2 aoiImageSet']);      % Save the current parameters
    guidata(gcbo,handles)
                                    % Update the AOIs displayed
      PlotImageClasses(aoiImageSet, 5:8, 25:28)
    pc=1;
end
    
                    