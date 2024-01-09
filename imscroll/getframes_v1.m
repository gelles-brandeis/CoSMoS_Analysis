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
     %keyboard
     dum=dum-dum;                               % Zeroed array same size as the images
     for aveindx=imagenum:imagenum+ave-1         % Read in the frames and average them

        %dum=imadd(dum,uint32( glimpse_image(handles.gfolder,handles.gheader,aveindx) ) );
        dum=dum+uint32( glimpse_image(handles.gfolder,handles.gheader,aveindx) );
     end
   
   
        % Set the laser indicators
     if isfield(handles.gheader,'lasers');
         
         if size(handles.gheader.lasers,1)<imagenum
             LaserIndicator = [0 0 0 0 0];
         else
             LaserIndicator=handles.gheader.lasers(imagenum,:);     % 0/1 binary indicator
                                                             % 1 x 5 [blue green orange red IR]
               % Check if from new scope, in which case the vid.laser_names
               % order is different (only 4 lasers)
             if length(LaserIndicator)==4
                % Here is from new scope
                 LaserIndicator=[LaserIndicator(1:2) 0 LaserIndicator(3:4)];
             end
         end
     else
         LaserIndicator = [0 0 0 0 0];          % For old glimpse files lacking the 'lasers' field
     end
        % Need to check
     if LaserIndicator(1,1)==1
         set(handles.BlueLaser,'BackgroundColor',[0 0 1]);
     else
         set(handles.BlueLaser,'BackgroundColor',[1 1 1]);
     end
     if LaserIndicator(1,2)==1
         set(handles.GreenLaser,'BackgroundColor',[0 1 0]);
     else
         set(handles.GreenLaser,'BackgroundColor',[1 1 1]);
     end
     if LaserIndicator(1,3)==1
         set(handles.OrangeLaser,'BackgroundColor',[1 .6 .2]);
     else
         set(handles.OrangeLaser,'BackgroundColor',[1 1 1]);
     end
     if LaserIndicator(1,4)==1
         set(handles.RedLaser,'BackgroundColor',[1 0 0]);
     else
         set(handles.RedLaser,'BackgroundColor',[1 1 1]);
     end
     if LaserIndicator(1,5)==1
         set(handles.IRLaser,'BackgroundColor',[.8 .2 0]);
     else
         set(handles.IRLaser,'BackgroundColor',[1 1 1]);
     end
                   % Set the filter indicator
     if isfield(handles.gheader,'filters');
       
         if size(handles.gheader.filters,2)<imagenum
             FilterIndicator = 1;
         else
             FilterIndicator=handles.gheader.filters(imagenum);     % Values 0-9
         end                                               % 
         
     else
         FilterIndicator = 1;          % For old glimpse files lacking the 'filters' field, just say 'Closed'
     end
     
             % Now write the filter text into the handles.Filter text region
            % Note the +1 b/c values run 0-9 but indices run 1-10
     set(handles.Filter,'String',handles.FilterListCell{FilterIndicator+1})
     
elseif (get(handles.ImageSource,'Value')==4)&(get(handles.MagChoice,'Value')==13)
     % Here if ImageSource value is 4, so the aoiImageSet must exist
    % Also MagChoice is 13 so we display only calibration images
    % near to the chosen AOI.  We use the AOI displayed in the
    % AOINumberDisplay text region, the nearby calibration image number
    % from the GlimpseNumber text region and the Class ID from the
    % ImageClass popup menu.
    
    NearNumber=str2num(get(handles.GlimpseNumber,'String'));    % =1 for nearest calibration image, =2 for next nearest,etc
    ClassNumber=get(handles.ImageClass,'Value');         % 1:8=[ROG RO RG OG R O G Z]
    aoiNum=str2num(get(handles.AOINumberDisplay,'String'));    % AOI # from the AOINumberDisplay
    aoiXY=handles.FitData(aoiNum,3:4);                  % (x y) of AOI# in AOINumberDisplay
    
    NI=Nearest_Images(aoiXY, ClassNumber, handles.aoiImageSet,NearNumber);
 
    ave=1;                                      % The image stored in AOIImageSet is already averaged
    dum=NI.images(:,:,NearNumber);              % Fetch one calibration image that is 'NearNumber' down in the list
                                        % of calibration images nearest to our current AOI 
    
elseif (get(handles.ImageSource,'Value') ==4) &(get(handles.MagChoice,'Value')~=13)    
                                % pupup menu 'aoiImageSet'
                                                % image the averaged registered images
                                                % from the aoiImageSet
     ave=1;     % Stored image in aoiImageSet is already averaged
     aoiNum=str2num(get(handles.AOINumberDisplay,'String'));    % AOI # from the AOINumberDisplay
     dum=handles.aoiImageSet.centeredImage{aoiNum}.FrameAve;    % Averaged image registered to pixel center
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