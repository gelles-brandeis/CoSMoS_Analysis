function pc=build_mapstruc_cell_column(aoiinf,startparm,folder,folderuse,handles)
%
% function build_mapstruc_cell_column(aoiinf,startparm,folder,folderuse)
%
% Will assemble the mapstruc structure needed to direct the fitting
% routine gauss2d_mapstruc.m  Each of the arguements can be arrays
% whose rows will be successive entries into the mapstruc structure.
% If an input arguement has but a single row (e.g. likely for 'folder'),
% that row will be repeated for each element of the output mapstruc.
%
% The output is a cell array of structures refering to a single aoi.
% Each structure contains information for processing one frame.  The 
% form of the structure is
% mapstruc_cell{i,j} will be a 2D cell array of structures, each structure with
%  the form (i runs over frames, j runs over aois)
%    mapstruc_cell_column(n).aoiinf [frame# ave aoix aoiy pixnum aoinumber]
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


               % aoiinf will have as many rows as there are frames to
               % process i.e. maoi = number of frames to process

[maoi naoi]=size(aoiinf);       % maoi is the number of aois= number of 
                                % cell array entries
                                
                                % Initialize the structure
                                % Each member of the structure will have as
                                % many rows as there are frames to process
                                % because we initialize mapstruc(maoi) by
                                % referencing the moai row
  
if startparm ==2                % == 2 for moving aois, in which case
                                % we will shift the xy coordinates using
    frmrange=aoiinf(:,1)';      % the handles.DriftList table
    for indxx=frmrange          % First column of the aoiinf matrix lists the
                                % frames over which we will process the
                                % aois
                                %                     (aoi#)     (frm#) aoiinfo
                                %
                                % Pick out the correct line (frame) in the
                                % aoiinf table
        logic=(indxx==aoiinf(:,1));
        aoiinf(logic,3:4)=aoiinf(logic,3:4)+ShiftAOI(aoiinf(1,6),indxx,handles.FitData,handles.DriftList);
        
    end
end
mapstruc_cell_column=cell(maoi,1);



[mstart nstart]=size(startparm);
[mfold nfold]=size(folder);
[mfolderuse nfolderuse]=size(folderuse);
if mstart==1
                        % Repeat startparm enough to fill structure
    startparm=repmat(startparm,maoi,1);
end
if mfold == 1
                        % Repeat folder enough to fill structure
    folder=repmat(folder,maoi,1);
end
if mfolderuse == 1
                        % Repeat folderuse enough to fill structure
    folderuse=repmat(folderuse,maoi,1);
end
[maoi naoi]=size(aoiinf);
[mstart nstart]=size(startparm);
[mfold nfold]=size(folder);
[mfolderuse nfolderuse]=size(folderuse);
if (mstart==maoi)&(mfold == maoi)&(mfolderuse==maoi)
    for indx=1:maoi
        mapstruc_cell_column{indx}= struct('aoiinf',aoiinf(indx,:),'startparm',startparm(indx,:),...
                    'folder',folder(indx,:),'folderuse',folderuse(indx,:) );           
    end        
                
                
 pc=mapstruc_cell_column;
 else   
                        %Here if the number of entries for any parameter was not either
                        % 1 or maoi
     pc='error in build_mapstruc';
 end
 
     % 