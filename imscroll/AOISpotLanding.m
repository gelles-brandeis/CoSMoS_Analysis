function pc=AOISpotLanding(AOInum,radius,handles,aoiinfo2,radius_hys)
%
% function AOISpotLanding(AOInum,radius,handles,aoiinfo2,radius_hys)
% 
% Will determine whether the spots landing in the field of view (stored in
% handles.AllSpots) occur within the AOI specified by AOInum.  Output will
% be an array [(frame number)  0,1] specifying whether the aoi contained a
% spot during each frame number covered by the handles.AllSpots cell array
%
% AOInum == number of the AOI in the handles.AllSpots.aoiinfo2 list
% radius == pixel radius, proximity of the spot to the AOI center in order
%          to be counted as a landing
% handles == handles structure containing members
%        AllSpots, Driftlist
% aoiinfo2 == [frm#  ave  x  y  pixnum  aoi#]  listing of information about the aois in use

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


FrameRange=handles.AllSpots.FrameVector;       % Vector of frames for which spots were found
[frmrose frmcol]=size(FrameRange);      % also, frmcol= #rows in AllSpots cell array
[asrose ascol]=size(handles.AllSpots.AllSpotsCells);

%aoiinfo2=handles.AllSpots.aoiinfo2;     %'[frm#  ave  x  y  pixnum  aoi#]';

if asrose~=frmcol
    sprintf('Error in AOISpotLanding: FrameRange and AllSpot sizes disagree')
  
end
pc=zeros(frmcol,2);                     % Allocate output matrix
logik=aoiinfo2(:,6)==AOInum;     % Find row of aoiinfo2 with this AOI
xycoordzero=aoiinfo2(logik,3:4);   % [x y] coordinate of our AOI
AmpHighLow=0;
for frmindex=1:frmcol
   
                % Cycle through all frames
    OptionalXYshift=[0 0];        % Initialize shift of AOI center due to drift
    if any(get(handles.StartParameters,'Value')==[2 3 4])
  
                                    % Here if we are in a 'moving aoi mode'
   
                                    % Setting AOI offset if we are in
                                    % moving AOI mode
%       OptionalXYshift=ShiftAOI(AOInum,FrameRange(frmindex),handles.AllSpots.aoiinfo2,handles.DriftList); 
       OptionalXYshift=ShiftAOI(AOInum,FrameRange(frmindex),aoiinfo2,handles.DriftList);
    end
                               %[frame#  ave  x   y  pixnum  aoinum (danny's original aoi#)]
   
    xycoord=xycoordzero+OptionalXYshift;     % This will be [x y] coordinates of our AOI, shifted if necessary
                                % Need to test all the spots in the
                                % AllSpots cell array for proximity to the
                                % xycoord location AllSpots{m,1}=[x y] spot list,
                                % {m,2}=# of spots found, {m,3}=frm #
     
                                        %Next, form vector of distances between 
                                        %our AOI and the spots in this
                                        %frame
 
    spotindexhigh=[1:handles.AllSpots.AllSpotsCells{frmindex,2}];       %Vector of spot indices found in this frame 
                                                            %handles.AllSpots.AllSpotsCells{frmindex,2}= # of frames for which information 
                                                           % is stored in AllSpotsCells cell array
                                                           % This is for the spots found with the High amplitude threshold  
                    % Distances btwn our AOI and spots found using high amplitude threshold 
    distanceshigh=sqrt(  (xycoord(1)-handles.AllSpots.AllSpotsCells{frmindex,1}(spotindexhigh,1)).^2 +(xycoord(2)-handles.AllSpots.AllSpotsCells{frmindex,1}(spotindexhigh,2)).^2  );
                    % Vector of spot indices for spots with Low amplitude threshold 
 
    spotindexlow=[1:handles.AllSpotsLow.AllSpotsCells{frmindex,2}];
  
                    % Distances btwn our AOI and spots found using Low amplitude threshold 
    distanceslow=sqrt(  (xycoord(1)-handles.AllSpotsLow.AllSpotsCells{frmindex,1}(spotindexlow,1)).^2 +(xycoord(2)-handles.AllSpotsLow.AllSpotsCells{frmindex,1}(spotindexlow,2)).^2  );
 
    if any(distanceshigh<radius)
                                        % Here if a spot  with high amplitude threshold was close
                                        % [frm#    1/0]
        AmpHighLow=1;
        pc(frmindex,:)=[handles.AllSpots.AllSpotsCells{frmindex,3} 1];    % Mark as high = 1 b/c spot was close to AOI
    elseif (AmpHighLow==1) & any(distanceslow<radius*radius_hys)
                 % Here if the last frame was high and this frame
                      % satisfies only a relaxed criteria (hysterisis) for
                      % being in a high state (lower amplitude spots, larger 
                      % distance between spots and AOI center)
           % Note: radius_hys=str2num(get(handles.UpThreshold,'String'))  
            
        pc(frmindex,:)=[handles.AllSpots.AllSpotsCells{frmindex,3} 1];    % Mark as high = 1 b/c spot was close to AOI
    else
                 % Here is there was no spot close to our AOI center
        AmpHighLow=0;
        pc(frmindex,:)=[handles.AllSpots.AllSpotsCells{frmindex,3} 0];    % Mark as low = 0 b/c no spot was close to AOI
    end
    %keyboard
end

end
