function pc=build_2d_mapstruc_aois_frms(handles)
%
% function build_2d_mapstruc_aois_frms(folder,handles)
%
% This function will be called from imscroll.  It is part of a renovation
% that will enable us to process all aois in a frame rather than loading a frome
% to process a singl aoi.  Previously the mapstruc was built to direct the
% processing of a single aoi (a 1D array of structures for one, one
% structure per frame).  This function will build a 2D array of structures,
% with one dimension (first index, rows),for all the frames (as before) and 
% the other dimension for all the aois (second dimension, columns).
% 
% folder == file path and name locating the folder for the tiff file (if used)
% mapstruc_cell{i,j} will be a 2D cell array of structures, each structure with
%  the form (i runs over frames, j runs over aois)
%    mapstruc_cell(i,j).aoiinf [frame# ave aoix aoiy pixnum aoinumber]
%               .startparm (=1 use last [amp sigma offset], but aoixy from mapstruc
%                           =2 use last [amp aoix aoiy sigma offset] (moving aoi)
%                           =-1 guess new [amp sigma offset], but aoixy from mapstruc
%                           =-2 guess new [amp sigma offset], aoixy from last output
%                                                                  (moving aoi)
%               .folder 'p:\image_data\may16_04\b7p18c.tif'
%                             (image folder)
%               .folderuse  =1 to use 'images' array as image source
%                           =0 to use folder as image source

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


folder=handles.TiffFolder;
    % next four lines because 'folder' cannot be empty, or we get an error
    % message when referencing folder(1,:) in build_mapstruc.m
[aa bb]=size(folder);
if (aa==0)&(bb==0);
    folder='folder not specified';
end

%folderpass=folder;
pixnum=str2double(get(handles.PixelNumber,'String')); % Fetch the pixel number (aoi width)
%frms=eval(get(handles.FrameRange,'String'));        % Fetch the frame range to fit

eval([get(handles.FrameRange,'String') ';']);
frms=ans;       % Vector of frames that will be processed
                %xypt=zeros(1,2);                                    
                %xypt(1)=str2double(get(handles.Xspot,'String'));    % Fetch the center location for the AOI
                %xypt(2)=str2double(get(handles.Yspot,'String'));    % (set earlier through ginput)

                                                    % Fit the spot.  The
                                                    % fits will use the
                                                    % frame ave as
                                                    % specified in the gui
                              %  ***************************                        

[mfrms nfrms]=size(frms);
if mfrms ==1
    frms=frms';                                 % frms now a column vector
end
[mfrms nfrms]=size(frms);                       % mfrms is the number of frames
ave=round(str2double(get(handles.FrameAve,'String')));  % Number of frames to average
% aoiinf=[frms  ave*ones(mfrms,1) xypt(1)*ones(mfrms,1) xypt(2)*ones(mfrms,1) pixnum*ones(mfrms,1)];
aoiinf=handles.FitData;                         % AOIs selected earlier (AOI button, tag=CollectAOI)
                                                %[framenumber ave x y pixnum aoinumber];
[maoi naoi]=size(aoiinf);                       % maoi is the number of aois
                                                % Now successively fit each AOI over the
mapstruc_cell=cell(mfrms,maoi);                 % cell array of structures, runs over(aois,frames)
                                            % specified frame range
for indx=1:maoi                                 % For loop over the different AOIs

                                                % Find out if user wants a
                                                % fixed or moving aoi
                                                % startparm=1 for fixed
                                                % startparm=2 for moving
    startparameter=get(handles.StartParameters,'Value');
    switch startparameter                          % This switch is not necessary yet, but will be when
                                                % more choises are added
        case 1
            inputstartparm=1;                      % Fixed AOI
        case 2
            inputstartparm=2;                      % Moving AOI
        case 3 
            inputstartparm=2;
        case 4
            inputstartparm=2;
    end
         

    folderuse=get(handles.ImageSource,'Value');    % Defines source of images (=1 for tiff folder, 2 for ram images, 3 for glimpse folder)
                                                % 
    if naoi==7
                    % naoi== # of columns in aoiinfo2
                        % Here for Danny's case where we add an extra
                        % column to aoiinfo2 and wish to integrate
                        % according to the specified pixnum (rather than
                        % the pixnum set in the gui.  The 7th column merely
                        % identifies the original AOI number for which the
                        % intermediate and large AOIs were constructed to
                        % surround.
           %[(frms columun vec)  ave         x                            y                           pixnum                       aoinum]           
        oneaoiinf=[frms  ave*ones(mfrms,1) aoiinf(indx,3)*ones(mfrms,1) aoiinf(indx,4)*ones(mfrms,1) aoiinf(indx,5)*ones(mfrms,1) aoiinf(indx,6)*ones(mfrms,1)];
    else
        oneaoiinf=[frms  ave*ones(mfrms,1) aoiinf(indx,3)*ones(mfrms,1) aoiinf(indx,4)*ones(mfrms,1) pixnum*ones(mfrms,1) aoiinf(indx,6)*ones(mfrms,1)];
    end
                        % build column of mapstruc_cell.  Column is an array of structures
                        % for a single aoi, all frames 
    mapstruc_cell(:,indx)=build_mapstruc_cell_column(oneaoiinf,inputstartparm,folder,folderuse,handles);
end

pc=mapstruc_cell;       % Output the cell array containing information for 
                        % processing the aois and frames



%***size(mapstruc);
                        % Use that mapstruc to fit a single aoi over the
                        % specified frame range (see build_mapstruc or
                        % gauss2d_mapstruc_v2 for listing of what 
                        % mapstruc contains
% ***oneargoutsStructure=gauss2d_mapstruc_v2(mapstruc,handles);

%   argouts=gauss2d_seq_ave(dum,images,folder,frms,xypt,pixnum,handles);       
                                                   
%***   [mcol mrose]=size(oneargoutsStructure.ImageData);
                                                    % Add column specifying
                                                    % the AOI number
 %***  oneargoutsStructure.ImageData=[ones(mcol,1)*aoiinf(indx,6) oneargoutsStructure.ImageData]; 
 %***  oneargoutsStructure.BackgroundData=[ones(mcol,1)*aoiinf(indx,6) oneargoutsStructure.BackgroundData]; 
   
 %***  if naoi==7
                        % naoi== # of columns in aoiinfo2
                        % Here for Danny's case where we generate 2 extra
                        % aois (of size specified in foldstruc.Pixnums)
                        % for each original aoi.  Add 2 columns to the
                        % argouts to maintain identify of the orignal aoi #
                        %   [  ....       pixnum    (original aoi#) ]
  %***      oneargoutsStructure.ImageData=[oneargoutsStructure.ImageData ones(mcol,1)*aoiinf(indx,5) ones(mcol,1)*aoiinf(indx,7)];
  %***      oneargoutsStructure.BackgroundData=[oneargoutsStructure.BackgroundData ones(mcol,1)*aoiinf(indx,5) ones(mcol,1)*aoiinf(indx,7)];

%***   end

 %*** argoutsImageData=[argoutsImageData;oneargoutsStructure.ImageData];
 %*** argoutsBackgroundData=[argoutsBackgroundData;oneargoutsStructure.BackgroundData];

                                                    
                                                    
 %***   if indx/5==round(indx/5)     % periodically save the output data file
                                 % just in case the loop is interrupted
 %***       aoifits.data=argoutsImageData;
 %***       aoifits.BackgroundData=argoutsBackgroundData;   
 %***       eval(['save ' handles.FileLocations.data outputName ' aoifits']);
 %***       handles.aoifits1=aoifits;                        % store our structure in the handles structure
 %***       handles.aoifits2=aoifits;
 %***       guidata(gcbo,handles);
 %***   end
%imageset=images;

%keyboard
                                      
%axes(handles.axes2);
%plot(argouts(:,1),argouts(:,5),'r')
%***sprintf('indx=%f',indx)
%***end
 