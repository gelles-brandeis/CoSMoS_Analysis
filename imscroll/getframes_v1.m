function pc=getframes_v1(handles)
%
% function getframes_v1(handles)
%
% Will be called from the imscroll program in order to fetch image frames
% for display.
%
% dum == a dummy zeroed frame for fetching and averaging images
% images == a m x n x numb array of input images
% folder == the folder location of the images to be read
% handles == the handles array from the GUI

% V1  eliminate dum, images, folder from arguements.  Just use handles inputs

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
%images=handles.images;
%dum=imsubtract(dum,dum);
%dum=uint32(dum);                                        % Needed so we can ave large numbers of frames
imagenum=round(get(handles.ImageNumber,'Value'));        % Retrieve the value of the slider
ave=round(str2double(get(handles.FrameAve,'String')));   % Fetch the number of frames to ave
                                                  % for display purposes
if get(handles.ImageSource,'Value') ==1         % popup menu 'Tiff_Folder'
    dum=uint32( imread([folder],'tiff',imagenum) );
    dum=dum-dum;                                % zero array same size as the images
    for aveindx=imagenum:imagenum+ave-1         % Read in the frames and average them

       % dum=imadd(dum,uint32( imread([folder],'tiff',aveindx) ) );
        dum=(dum+uint32( imread([folder],'tiff',aveindx) ) );
    end

elseif get(handles.ImageSource,'Value') ==2     % popup menu 'RAM'
                                                % Here to ave over the
                                                % frames stored in 'images'
                                                % variable
    images=handles.images;
    dum=sum(uint32(images(:,:,imagenum:imagenum+ave-1)),3);
elseif get(handles.ImageSource,'Value') ==3     % pupup menu 'Glimpse_Folder'
                                                % use Glimpse file directly
   
     dum=uint32( glimpse_image(handles.gfolder,handles.gheader,imagenum) );
     dum=dum-dum;                               % Zeroed array same size as the images
     for aveindx=imagenum:imagenum+ave-1         % Read in the frames and average them

        %dum=imadd(dum,uint32( glimpse_image(handles.gfolder,handles.gheader,aveindx) ) );
        dum=dum+uint32( glimpse_image(handles.gfolder,handles.gheader,aveindx) );
    end
end

%pc=imdivide(dum,ave);
pc=dum/ave;                                % Divide by number of frames to get the 
                                               % average for output to the
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