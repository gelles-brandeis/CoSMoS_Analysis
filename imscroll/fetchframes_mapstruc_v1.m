function pc=fetchframes_mapstruc_v1(mapentry,mapstruc,handles)
%
% function fetchframes_mapstruc_v1(mapentry,mapstruc,handles)
%
% Will be called from the gauss2d_mapstruc program in order to fetch image frames
% for fitting spot parameters.
%
% dum == a dummy zeroed frame for fetching and averaging images
% images == a m x n x numb array of input images
% mapentry == the index into the mapstruc
% mapstruc == structure array each element of which specifies:
% mapstruc == structure array each element of which specifies:
%    mapstruc(n).aoiinf [frame# ave aoix aoiy pixnum aoinumber]
%               .startparm (=1 use last [amp sigma offset], but aoixy from mapstruc
%                           =2 use last [amp aoix aoiy sigma offset]
%                           =-1 guess new [amp sigma offset], but aoixy from mapstruc
%                           =-2 guess new [amp sigma offset], but aoixy from last output
%               .folder 'p:\image_data\may16_04\b7p18c.tif'
%                             (image folder)
%               .folderuse  =3 to use glimpse files
%                           =2 to use 'images' array as image source
%                           =1 to use folder as image source

% V1 remove dum, images,folder from arguements

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

if isfield(handles,'TiffFolder')
    folder=handles.TiffFolder;
end
%dum=uint32(dum);  
ave=mapstruc(mapentry).aoiinf(2);       % Number of frames to ave (first frame)
framenumber=mapstruc(mapentry).aoiinf(1); % First frame number                                                 
if mapstruc(mapentry).folderuse ==1         %  = 0 for using folder
 dum=uint32(imread([folder],'tiff',framenumber)); 
 dum=dum-dum;                               % zeroed array same size as the images
    for aveindx=framenumber:framenumber+ave-1         % Read in the frames and average them
        
        %dum=imadd(dum,uint32(imread([folder],'tiff',aveindx)));
        dum=dum+uint32(imread([folder],'tiff',aveindx));
    end

elseif mapstruc(mapentry).folderuse ==2  
                                                % Here to ave over the
                                                % frames in 'images'
    dum=sum(images(:,:,framenumber:framenumber+ave-1),3);
elseif mapstruc(mapentry).folderuse ==3          % Here to Glimpse file images
 dum=uint32( glimpse_image(handles.gfolder,handles.gheader,framenumber) );
 dum=dum-dum;                           % zeroed array same size as the images
    for aveindx=framenumber:framenumber+ave-1        % Read in the frames and average them


        %dum=imadd(dum,uint32( glimpse_image(handles.gfolder,handles.gheader,aveindx) ) );
        dum=dum+uint32( glimpse_image(handles.gfolder,handles.gheader,aveindx) );

    end
end

%pc=imdivide(dum,ave);                           % Divide by number of frames to get the 
pc=dum/ave;                                                % average for output to the
                                                % calling program.






%keyboard
%frms=getframes(dum,images,folder,handles)        % Retrieve the frame(s) for display
%imagenum=get(handles.ImageNumber,'value');        % Retrieve the value of the slider

%set(handles.ImageNumberValue,'String',num2str(val ) ); 
%axes(handles.axes1);
%imagesc(images(:,:,val));colormap(gray)
%dum=imread([folder tiff_name(val)],'tiff');
%dum=imread([folder cook_name(val)],'tiff');
%dum=imread([folder],'tiff',val);                    %*** NEED TO CHANGE IMREAD
%[drow dcol]=size(dum);
%ave=str2double(get(handles.FrameAve,'String'));     % Fetch the number of frames to ave
%dum=zeros(drow,dcol);                              % for display purposes
%for aveindx=val:val+ave-1                          % Grab the frames
%dum=dum+double(imread([folder],'tiff',aveindx));    % ***NEED TO CHANGE IMREAD
%dum=dum+double( imread([folder tiff_name(aveindx)],'tiff') );
%dum=dum+double( imread([folder cook_name(aveindx)],'tiff') );
%end
%dum=dum/ave; 