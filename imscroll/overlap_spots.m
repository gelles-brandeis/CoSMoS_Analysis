function pc=overlap_spots(AllSpots1,AllSpots2,radius,MappingFlag,MappingFile12)
%
%  function overlap_spots(AllSpots1,AllSpots2,radius,MappingFlag,MappingFile12)
%
% This function will identify overlaps for the spot landings recorded in 
% AllSpots1 and AllSpots2.  The criterion is that the spots must appear in
% the same frame number and within a distance of one another set by the
% 'radius' parameter.  The MappingFlag parameter indicates whether the
% spots in AllSpots2 must be mapped into the field of AllSpots1
% (MappingFlag = 1 => mapping must be performed, 0 => no mapping is to be
% performed) using the mapping between the fields 1 and 2 set by the file 
% 'MappingFile12'.
% 
% AllSpots1 == AllSpots structure for spots detected in field #1  by 
%           the imscroll gui. 
% AllSpots2 == AllSpots structure for spots detected in field #2  by 
%           the imscroll gui. 
% radius == (pixels) distance criterion for overlap.  Spots must be within a
%          distance specified by 'radius' to be counted as overlapping
%           e.g. radius = 1.5 is typical
% MappingFlag == flag for performing the mapping.  
%              MappingFlag = 1 => mapping must be performed
%                          = 0 => no mapping is to be performed
% MappingFile12 == full path to the mapping file for mapping between fields
%                   1 and 2 e.g.
%            ='P:\matlab12\larry\fig-files\imscroll\mapping\fitparms.dat'

% Members of the AllSpots structure:
               %AllSpotsCells: {10554x3 cell}
%    AllSpotsCellsDescription: '{m,1}= [x y] list of spots in frm m, {m,2}= # of spots in list, {m,3}= frame#]'
%                 FrameVector: [1x10554 double]
%                  Parameters: [1 5 8]
%        ParametersDescripton: '[NoiseDiameter  SpotDiameter  SpotBrightness] used for picking spots'
%                   aoiinfo2: [14x6 double]
%        aoiinfo2Description: '[frm#  ave  x  y  pixnum  aoi#]'

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



% Get the frm# and xy spot locations from the two AllSpots (AS) arrays
[as1rows as1col]=size(AllSpots1.AllSpotsCells);
[as2rows as2col]=size(AllSpots2.AllSpotsCells);
if as1rows~=as2rows
    sprintf('Error:  AllSpots..AllSpotsCells sizes must match'
    return
end
    % Here if the size of the arrays do match
eval(['load ' MappingFile12 ' -mat']);      % Loads fitparmvector and mappingpoints
spotnum1=[];        % [frame#  (# of spots found)]
spotnum2=[];
for indx=1:as1rows
        % loop over all the frames for which spots were detected: Get the
        % total number of spots
     spotnum1=[spotnum1;AllSpots1.AllSpotsCells{indx,2}];
     spotnum2=[spotnum2;AllSpots2.AllSpotsCells{indx,2}];
end
%xy1=zeros(sum(spotnum1,3),3);       % Allocate space to list all the spots
Overlaps.OverlapsCells=cell(as1rows,1);           % Allocate cell array.  
Overlaps.OverlapsCellsDescription='[x1 y1 x2 y2 x21 y21 frm# distance]'
Overlaps.OverlapNumber=zeros(as1rows,1);        % Number of overlapping spots for each frame
                % Each cell array will
                % contain the overlapping spots in one frame. 
                % cell{frmindx} =[x1 y1 x2 y2 x21 y21 frm# distance]
                % where x2 y2 are coordinates as listed in AllSpots2
                % and x21 y21 are coordinates of same point after  
                % mapping into the FOV1, and distance = separation of 
                % of the overlapping spots after mapping
                % both into FOV1 

for frmindx=1:as1rows
    if MappingFlag==0
                % No mapping performed, just directly compare the spots (I do not think this will be used)
        x1y1=AllSpots1.AllSpotsCells{frmindx,1};       %[x1 y1] list of spots in this frame in FOV1
        x2y2=AllSpots2.AllSpotsCells{frmindx,1};       %[x2 y2] list of spots in this frame in FOV2
        spotsinlist1=AllSpots1.AllSpotsCells{frmindx,2}; % Number of x1y1 spots in frm=frmindx
        spotsinlist2=AllSpots2.AllSpotsCells{frmindx,2}; % Number of x2y2 spots in frm=frmindx
        overlaps1frame=[];                          % Initialize list of overlapping spots in this frame
        for spotindx1=1:spotsinlist1
                                    % looping through all x1y1 spots in this frm = frmindx
                       % Distances between one x1y1 spot and all the x2y2 spots (latter are the x2y2 sites mapped to the FOV1)  
            distances12=sqrt(sum( (x2y2-[x1y1(spotindx1,1)*ones(spotsinlist2,1) x1y1(spotindx1,2)*ones(spotsinlist2,1)]).^2,2) ); 
            logik=distances12<radius;        % Select only those spots that are overlapping
            num1spot=sum(logik);            % Number of overlapping spots for this
            if num1spot>0
                % Here if there were overlaps (likely only 1 if any)
                overlaps1frame=[overlaps1frame;x1y1(spotindx1,1)*ones(num1spot,1) x1y1(spotindx1,2)*ones(num1spot,1) x2y2(logik,:) x2y2(logik,:) frmindx*ones(num1spot,1) distances12(logik)];
            end
        end         % End of spotindx1 loop
        [oneframerows oneframecol]=size(overlaps1frame);
        Overlaps.OverlapsCells{frmindx,1}=overlaps1frame;       % Store the list of overlapping spots
        Overlaps.OverlapNumber(frmindx,1)=oneframerows;         % Store just the number of overlapping spots
            % *****Now map the x2y2 spots to their x21y21 sites in FOV1
        
   
    else
        % Here if we must map the x2y2 spots to their equivalent x21y21 locations
        x1y1=AllSpots1.AllSpotsCells{frmindx,1};       %[x1 y1] list of spots in this frame
        x2y2=AllSpots2.AllSpotsCells{frmindx,1};       %[x2 y2] list of spots in this frame in FOV2
        x21y21=ProximityMapping_Multipoints(x2y2,fitparmvector,mappingpoints,1);  %  proximity map the x2y2 spots to their FOV1 sites = x21y21
        spotsinlist1=AllSpots1.AllSpotsCells{frmindx,2}; % Number of x1y1 spots in frm=frmindx
        spotsinlist2=AllSpots2.AllSpotsCells{frmindx,2}; % Number of x2y2 spots in frm=frmindx
        overlaps1frame=[];                          % Initialize list of overlapping spots in this frame
        for spotindx1=1:spotsinlist1
                                    % looping through all x1y1 spots in this frm = frmindx
                       % Distances between one x1y1 spot and all the x21y21
                       % spots  (x21y21 are the x2y2 spots mapped to their FOV1 sites) 
            distances12=sqrt(sum( (x21y21-[x1y1(spotindx1,1)*ones(spotsinlist2,1) x1y1(spotindx1,2)*ones(spotsinlist2,1)]).^2,2) ); 
            logik=distances12<radius;        % Select only those spots that are overlapping
            num1spot=sum(logik);            % Number of overlapping spots for this
            if num1spot>0
                % Here if there were overlaps (likely only 1 if any)
                overlaps1frame=[overlaps1frame;x1y1(spotindx1,1)*ones(num1spot,1) x1y1(spotindx1,2)*ones(num1spot,1) x2y2(logik,:) x2y2(logik,:) frmindx*ones(num1spot,1) distances12(logik)];
            end
        end             % End of spotindx1 loop
        [oneframerows oneframecol]=size(overlaps1frame);
        Overlaps.OverlapsCells{frmindx,1}=overlaps1frame;       % Store the list of overlapping spots
        Overlaps.OverlapNumber(frmindx,1)=oneframerows;         % Store just the number of overlapping spots
    end                 % End of if MappingFlag==0 
end                     % End of frmindx loop
            % *****Now map the x2y2 spots to their x21y21 sites in FOV1
% Map the AllSpots2 spots to their equivalent AllSpots1 locations via
% a 2 -> 1 mapping using the MappingFile12 

%****************************************
