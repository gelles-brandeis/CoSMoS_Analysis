function pc=SubImages_v1(ImageSource1,xy1,frms1,pixnum1,ImageSource2,xy2,frms2,pixnum2,AOInum,handles,varargin)
%
% function  SubImages(ImageSource1,xy1,frms1,pixnum1,ImageSource2,xy2,frms2,pixnum2,AOInum,handles,<parenthandles>)
% 
% Will build an image matrix out of the sub images of AOI1 from
% ImageSource1 over the specified frame range, displayed side-by-side with
% subimages of AOI2 from ImageSource2.  Intended to allow us to easily view
% for instance the holoenzyme landing and transcript production images
%
% ImageSource1==1  to use frames from the tiff file in folder handles.TiffFolder
%               2  to use frames stored in handles.images
%               3  to use Glimpse files directly from Glimpse folder handles.gfolder
%               4  to use Glimpse files directly from Glimplse folder handles.goflder2
%               5  to use frames from the tiff file in folder handles.TiffFolder2 
% xy1 == [x y (aoi#)]= [column row] coordinates of the center for AOI1 that we
%          wish to display in the output matrix, and aoi number from list
% frms1== [frmlow:frmhi] vector of frame numbers out of which we will
%               extract the image regions centered on our AOI
% pixnum1 == half width of the AOI that will be displayed.  That is, we
% will display pixels: 
%  Image( (xy1(2)-pixnum1):(xy1(2)+pixnum1), (xy1(1)-pixnum1):(xy1(1)+pixnum1) )
%  so that each AOI will be of size (2*pixnum1+1) x (2*pixnum1+1)
%
% AOInum == [numberx numbery] specifies the number of AOI images to place
%   'across' (x direction) in the output matrix, and the number of image
%   pairs to place up-down (y direction) in the output (i.e. there will be
%   numberx AOIs displayed across and 2*numbery AOIs displayed up-down)
% handles == handles structure from the calling gui
% varargin{1} == parenthandles = handles structure from the top level gui 'imscroll'
%
% ImageSource2, xy2, frms2, pixnum2 pertain to the AOI2 that will be
% displayed, and are defined just as the variables above for AOI1.
%parenthandles = guidata(handles.parenthandles_fig);       % handles structure from the
                                                          % top level gui 'imscroll'
                                                          
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

parenthandles=varargin{1};

frmave=str2double(get(parenthandles.FrameAve,'String'));
%frmave=2;

oneAOIdum= uint32(16000*ones(2*(2*pixnum1+2)+3,2*pixnum1+2) );   % size of one AOI pair with an extra row
                                                % and column for separating
                                       % white space in x direction and
                                       % four extra white pixels between
                                       % AOI pairs in the y direction
% x: AOI-1 white pixel-AOI-1 w pix-AOI ...
% y: AOI1-1 wh pix - AOI2- 4 wh pix- AOI1- 1 wh pix- AOI2- 4 wh pix ...
                                             
pc=repmat(oneAOIdum,AOInum(2),AOInum(1));       % replicates the dummy AOI matrix in a tiled array
        % Create stacked arrays for the AOI images 
dum1=uint32( ones(2*pixnum1+1,2*pixnum1+1,length(frms1)) );
dum2=uint32( ones(2*pixnum2+1,2*pixnum2+1,length(frms2)) );

% Retrieve the AOIs from the appropriate image source, place them in the
% stacked arrays
    % gui handles structure contains members:
          % handles. AOIgfolder1, AOIgheader1, AOIDumgfolder1
          %handles. AOIgfolder2, AOIgheader2, AOIDumgfolder2
          %handles. AOITiffFile1, AOIDumTiffFile1
          %handles. AOITiffFile2, AOIDumTiffFile2
          %handles. AOIRAM1, AOIDumRAM1
          %handles. AOIRAM2, AOIDumRAM2
    % Need to place the appropriate handles members into the fold.* structure used
    % as an input for the get_image_frames() function:
%               fold.gfolder, gheader, Dumgfolder
%               fold.TiffFolder, DumTiffFolder
%               fold.images
if ImageSource1==1                  % here to use Tiff folder
    fold.TiffFolder=handles.AOITiffFile1;
    fold.DumTiffFolder=handles.AOIDumTiffFile1;

elseif ImageSource1==3                  % here for Glimpse folder useage.  Add additional
                                    % useage options later

    fold.gfolder=handles.AOIgfolder1;
    fold.gheader=handles.AOIgheader1;
    fold.Dumgfolder=handles.AOIDumgfolder1;
    
end
xydum=round(xy1(1:2));             % [x y] coordinates of aoi 1
for indx1=(frms1)
    Im1=get_image_frames(ImageSource1,frmave,indx1,fold,parenthandles);
    
   XYshift=[0 0];                  % initialize aoi shift due to drift
    if any(get(parenthandles.StartParameters,'Value')==[2 3 4])
                                    % here to move the aois in order to
                                    % follow drift
   % Note:  the aois in imscroll must be from aoiinfo2, that is, they must
   % be derived from the list that includes info wrt the frm# they were
   % selected in order to properly shift them
   % Also the parenthandles.Driftlist must be correct (obviously)
   % ***Above 4 line comment no longer true: we pick off the original xy
   % coordinates right out of the relevant aoifits structure (which now
   % contains an aoiinfo2 member as well

                          %aoi#  frm#  (list of aois & frm selected) driftlist
        %XYshift=ShiftAOI(xy1(3),indx1,parenthandles.FitData,parenthandles.DriftList);
        XYshift=ShiftAOI(xy1(3),indx1,parenthandles.aoifits1.aoiinfo2,parenthandles.DriftList);

        xydum=round(xy1(1:2)+XYshift);        % Shift the aoi center
    end     
    
    logik=(frms1==indx1);                   % Identify element # of frms1                    
    %dum1indx=find(logik);                   % Index of dum1 into which we
                                            % will place aoi image
    
    dum1(:,:,logik)=Im1((xydum(2)-pixnum1):(xydum(2)+pixnum1), (xydum(1)-pixnum1):(xydum(1)+pixnum1) );    
%    dum1(:,:,indx1-frms1(1)+1)=Im1((xydum(2)-pixnum1):(xydum(2)+pixnum1), (xydum(1)-pixnum1):(xydum(1)+pixnum1) );
end

if ImageSource2==1                  % here to use Tiff folder
    fold.TiffFolder=handles.AOITiffFile2;
    fold.DumTiffFolder=handles.AOIDumTiffFile2;
elseif ImageSource2==3                  % here for Glimpse folder useage.  Add additional
                                    % useage options later
    fold.gfolder=handles.AOIgfolder2;
    fold.gheader=handles.AOIgheader2;
    fold.Dumgfolder=handles.AOIDumgfolder2;
end

xydum=round(xy2(1:2));                     % [x y] coordinates of aoi 2

for indx2=(frms2)                   % Loop through framenumber limits
                                    % Fetch the image frame
    Im2=get_image_frames(ImageSource2,frmave,indx2,fold,parenthandles);
    
    XYshift=[0 0];                  % initialize aoi shift due to drift
    if get(parenthandles.StartParameters,'Value')==2
                                    % here to move the aois in order to
                                    % follow drift
   % Note:  the aois in imscroll must be from aoiinfo2, that is, they must
   % be derived from the list that includes info wrt the frm# they were
   % selected in order to properly shift them
   % Also the parenthandles.DriftList must be correct (obviously)

                          %aoi#  frm#  (list of aois & frm selected) driftlist
        %XYshift=ShiftAOI(xy2(3),indx2,parenthandles.FitData,parenthandles.DriftList);
        XYshift=ShiftAOI(xy2(3),indx2,parenthandles.aoifits2.aoiinfo2,parenthandles.DriftList);
        xydum=round(xy2(1:2)+XYshift);        % Shift the aoi center
    end 
  
    
  logik=(frms2==indx2);                     %Identify element of dum2 into 
                                       % which we will place the aoi image 
    dum2(:,:,logik)=Im2((xydum(2)-pixnum2):(xydum(2)+pixnum2), (xydum(1)-pixnum2):(xydum(1)+pixnum2) );
 %   dum2(:,:,indx2-frms2(1)+1)=Im2((xydum(2)-pixnum2):(xydum(2)+pixnum2), (xydum(1)-pixnum2):(xydum(1)+pixnum2) );
end

                                % We will store the centers of each gallery
                                % image so that we can later draw a box
                                % centered on that point

galleryxy1Centers=[];                      
galleryxy2Centers=[];
                   %now populate the output matrix with the AOI images
for AOIindx=1:length(frms1)               % Runs over number of AOIs
    indx1=AOIindx-1;                      % Subtract 1 to get xindx1 and yindx1 
                                          % to run over rows and columns
                                          % correctly
    xindx1=mod(indx1,AOInum(1))+1;        % +1 so it will run 1 to AOInum(1)        
                                    % see 12/30/06 notes, B15p117
                              % xindx1 is the AOI indx across rows
                                % yindx1 is the AOI pair indx down columns
    yindx1=1+floor(indx1/AOInum(1));
    A=(xindx1-1)*(2*pixnum1+2) + 1;       % left side of AOI1, AOI2
    AR=A+2*pixnum1;                   % A+(2*pixnum1) = right side of AOI1
    B = (yindx1-1)*( 2*(2*pixnum1+2)+3 )+1; % Top of AOI1
    C = B + 2*pixnum1;                      % Bottom of AOI1
    D = C+ 2;                               % Top of AOI2
    E = D+ 2*pixnum1;                       % Bottom of AOI2
                                % Store the centers of the images.  The 0.5
                                % is to offset from the pixel center to
                                % edge so the box (later) is drawn around
                                % region that is acutally integrated
    galleryxy1Centers=[galleryxy1Centers;(A+ pixnum1-0.5) (B+pixnum1-0.5)];
    galleryxy2Centers=[galleryxy2Centers;(A+ pixnum1-0.5) (D+pixnum1-0.5)];    
% [AOIindx indx1 xindx1 yindx1]
    pc(B:C,A:AR) = dum1(:,:,AOIindx);         % AOI1 placement
    pc(D:E,A:AR) = dum2(:,:,AOIindx);         % AOI2 placement (below AOI1)
end
                                % Store the gallery image centers in the
                                % handles structure
handles.galleryxy1Centers=galleryxy1Centers;
handles.galleryxy2Centers=galleryxy2Centers;
guidata(gcbo,handles);


    
