function pc=get_image_frames(ImageSource,frmave,framenumber,handles,varargin)
%
% function get_image_frames(ImageSource,frmave,framenumber,handles,varargin)
%
%  Will be called from a program in order to fetch image frames for display
%  or analysis
%
% ImageSource ==1  to use frames from the tiff file in folder handles.TiffFolder
%               2  to use frames stored in handles.images
%               3  to use Glimpse files directly from Glimpse folder handles.gfolder
%               4  to use Glimpse files directly from Glimplse folder handles.goflder2
%               5  to use frames from the tiff file in folder handles.TiffFolder2
% frmave     == number of frames to average
% framenumber   == the frame number of the image that is to be retrieved
% handles    == a handles structure containing the various image folders,
%          files and dummy image frames.  The handles members include:
%               handles.TiffFolder, DumTiffFolder
%               handles.images
%               handles.gfolder, gheader, Dumgfolder
% varargin{1} == parent handles from the top gui figure
%
% Output will be a single (possibly averaged)frame 

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

if nargin>4
    parenthandles=varargin{1};
end


if ImageSource ==1                              % use tiff file in handles.TiffFolder 
    dum=handles.DumTiffFolder;                  % dummy zero array the same size as images
    for aveindx=framenumber:framenumber+frmave-1         % Read in the frames and average them

       % dum=imadd(dum,uint32( imread(handles.TiffFolder,'tiff',aveindx) ) );
        dum=dum+ uint32( imread(handles.TiffFolder,'tiff',aveindx) ) ;
    end

elseif ImageSource ==2                          % use RAM images in handles.images
                                                
    dum=uint32(sum(handles.images(:,:,framenumber:framenumber+frmave-1),3));

elseif ImageSource ==3                          % use images in Glimpse folder handles.gfolder
  
     dum=handles.Dumgfolder;                                          % use Glimpse file directly
     for aveindx=framenumber:framenumber+frmave-1         % Read in the frames and average them


       % dum=imadd(dum,uint32( glimpse_image(handles.gfolder,handles.gheader,aveindx) ) );
        dum=dum +uint32( glimpse_image(handles.gfolder,handles.gheader,aveindx) ) ;
       
     end
elseif ImageSource ==4                          % use images in Glimpse folder handles.gfolder2
    dum=handles.Dumgfolder2;
    for aveindx=framenumber:framenumber+frmave-1         % Read in the frames and average them

       % dum=imadd(dum,uint32( glimpse_image(handles.gfolder2,handles.gheader2,aveindx) ) );
        dum=dum+uint32( glimpse_image(handles.gfolder2,handles.gheader2,aveindx) ) ;
       
    end
elseif ImageSource ==5                              % use tiff file in handles.TiffFolder2 
    dum=handles.DumTiffFolder2;                  % dummy zero array the same size as images
    for aveindx=framenumber:framenumber+frmave-1         % Read in the frames and average them

        %dum=imadd(dum,uint32( imread(handles.TiffFolder2,'tiff',aveindx) ) );
        dum=dum+uint32( imread(handles.TiffFolder2,'tiff',aveindx) ) ;
    end
end

%pc=imdivide(dum,frmave);                           % Divide by number of frames to get the 
pc=dum/frmave;                                  % average for output to the
                                                % calling program.