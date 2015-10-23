function pc=getframes2_v1(handles,parenthandles)
%
% function getframes2(handles,parenthandles)
%
% Will be called from the imscroll program in order to fetch image frames
% for display.
%
% dum == a dummy zeroed frame for fetching and averaging images
% images == a m x n x numb array of input images
% folder == the folder location of the images to be read
% handles == the handles array from the GUI
% parenthandles == handles array from imscroll gui (top level gui)

% V1  removed dum2, images2, folder2 from arguements

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

if isfield(parenthandles,'TiffFolder2')
    folder2=parenthandles.TiffFolder2;
end
images2=parenthandles.images;
%dum2=uint32(imsubtract(dum2,dum2));
imagenum2=round(get(handles.SliderFrame2,'value'));        % Retrieve the value of the slider
ave2=round(str2double(get(handles.AveNumber2,'String')));   % Fetch the number of frames to ave
                                                  % for display purposes
%if get(handles.ImageSource2,'Value') ==0         % toggle button out = 0 for using folder
 %   for aveindx=imagenum2:imagenum2+ave2-1         % Read in the frames and average them

 %       dum2=imadd(dum2,imread([folder2],'tiff',aveindx));
 %   end

%else
                                                % Here to ave over the
                                                % frames in 'images'
%    dum2=sum(images2(:,:,imagenum2:imagenum2+ave2-1),3);
%end


if get(handles.ImageSource2,'Value') ==1         % popup menu 'Tiff_Folder' 
    dum2=uint32( imread([folder2],'tiff',imagenum2) );
    dum2=dum2-dum2;                                % zero array same size as the images
    for aveindx=imagenum2:imagenum2+ave2-1         % Read in the frames and average them

%        dum2=imadd(dum2,uint32( imread([folder2],'tiff',aveindx) ) );
        dum2=dum2+uint32( imread([folder2],'tiff',aveindx) ) ;
    end

elseif get(handles.ImageSource2,'Value') ==2     % popup menu 'RAM'
                                                % Here to ave over the
                                                % frames stored in 'images'
                                                % variable
    dum2=sum(images2(:,:,imagenum2:imagenum2+ave2-1),3);
elseif get(handles.ImageSource2,'Value') ==3     % pupup menu 'Glimpse_Folder'
                                                % use Glimpse file directly
     dum2=uint32( glimpse_image(parenthandles.gfolder2,parenthandles.gheader2,imagenum2) );
     dum2=dum2-dum2;                               % Zeroed array same size as the images
     for aveindx=imagenum2:imagenum2+ave2-1         % Read in the frames and average them

%        dum2=imadd(dum2,uint32( glimpse_image(parenthandles.gfolder2,parenthandles.gheader2,aveindx) ) );
        dum2=dum2+uint32( glimpse_image(parenthandles.gfolder2,parenthandles.gheader2,aveindx) ) ;
    end
end
%pc=imdivide(dum2,ave2);                           % Divide by number of frames to get the 
pc=dum2/ave2;                             % average for output to the
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