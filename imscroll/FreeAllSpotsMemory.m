function pc=FreeAllSpotsMemory(AllSpots)
%
%   function FreeAllSpotsMemory(AllSpots)
%
%  Will remove all the unused (zero rows) entries in the AllSpots.AllSpots{:,1} cell
%  arrays that list the spots in a specified frame range (from imscroll).
%  This is intended just to save space before saving the array to disk.
%AllSpots.AllSpotsCells=cell(3,3);  % Will be a cell array {N,4} N=# of frames computed, and
                         % AllSpots{m,1}= [x y] list of spots, {m,2}= # of spots in list, {m,3}= frame#
                         % {1,4}=vector of all frame numbers stored in this cell array
%AllSpots.AllSpotsCellsDescription='{m,1}= [x y] list of spots in frm m, {m,2}= # of spots in list, {m,3}= frame#]';
%AllSpots.FrameVector=[];         % Vector of frames whose spots are stored in AllSpotsCells
%AllSpots.Parameters=[ 1 5 50];  % [NoiseDiameter  SpotDiameter  SpotBrightness] used for picking spots
%AllSpots.ParametersDescripton='[NoiseDiameter  SpotDiameter  SpotBrightness] used for picking spots';
%AllSpots.aoiinfo2=[];       
%AllSpots.aoiinfo2Description='[frm#  ave  x  y  pixnum  aoi#]';

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


frms=AllSpots.FrameVector;      % Vector listing the frame numbers in which spots were located
[frmrose frmcol]=size(frms);    
for frmindx=1:max(frmrose,frmcol)
    spotnum=AllSpots.AllSpotsCells{frmindx,2};      % Number of spots found for the frame number frms(frmindx)
                                                    % Next, keep only those nonzero xy spot coordinate entries 
    AllSpots.AllSpotsCells{frmindx,1}=AllSpots.AllSpotsCells{frmindx,1}(1:spotnum,1:2);
end
                % Output the new array (smaller than the input)
pc=AllSpots;
