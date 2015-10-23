function pc=build_mapstruc(aoiinf,startparm,folder,folderuse,handles)
%
% function build_mapstruc(aoiinf,startparm,folder,folderuse)
%
% Will assemble the mapstruc structure needed to direct the fitting
% routine gauss2d_mapstruc.m  Each of the arguements can be arrays
% whose rows will be successive entries into the mapstruc structure.
% If an input arguement has but a single row (e.g. likely for 'folder'),
% that row will be repeated for each element of the output mapstruc.

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

[maoi naoi]=size(aoiinf);
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

mapstruc(maoi)=struct('aoiinf',aoiinf(maoi,:),'startparm',startparm(1,:),...
                    'folder',folder(1,:),'folderuse',folderuse(1,:) );
 
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
        mapstruc(indx)= struct('aoiinf',aoiinf(indx,:),'startparm',startparm(indx,:),...
                    'folder',folder(indx,:),'folderuse',folderuse(indx,:) );           
    end        
                
                
 pc=mapstruc;
 else   
                        %Here if the number of entries for any parameter was not either
                        % 1 or maoi
     pc='error in build_mapstruc';
 end
 
     % 