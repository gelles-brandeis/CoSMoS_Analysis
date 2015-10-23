function pc=MappingPointsCompare(inputxy,ghandles)
%
% function MappingPointsCompare(inputxy,ghandles)
%
% The program will find the closest aoi
% in the MappingPoints list, in order to allow the user to remove poorly
% chosen points from the list used to determine the mapping function.
%
% inputxy == [x y] the x and y coordinates of our input aoi.  We are
%               trying to find which aoi in the aoiinfo2 list is actually
%               closest spatially to this input aoi
% ghandles == the handles structure from the calling gui.  e.g.
%           handles.MappingPoints = [Field1point Field2point] (see below)
% MappingPoints = list of aois output by imscroll when the user is tracking a
%              time course for the appearence of dye spots
%              [frame#  ave  x   y  pixnum  aoinum frame#  ave  x   y  pixnum  aoinum]
%
% The function will return the aoinum from the aoiinfo2 list that
% identifies the aoi minimizing:
%   (inputxy(1) - x)^2  + (inputxy(2) - y)^2 )

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

Mapping_Points=ghandles.MappingPoints;           % Current list of fixed aois (see above)
                                    %
                                    % If we are in a 'moving aois' mode, we
                                    % need to shift the xy coordinates of
                                    % the aois in our list to reflect the
                                    % present frame
[maoi naoi]=size(Mapping_Points);
                                    % maoi = number of aois in our list


                                    % Correct the xy centers of the aois
                                    % using the above computed
                                    % OptionalXYshift (will be zero
                                    % correction if we are not in 'moving
                                    % aoi' mode
                                    %
                                    % Look in both fields for a nearby
                                    % point
distancelist1=[(Mapping_Points(:,3)-inputxy(1)).^2+(Mapping_Points(:,4)-inputxy(2)).^2 Mapping_Points(:,6)];
distancelist2=[(Mapping_Points(:,9)-inputxy(1)).^2+(Mapping_Points(:,10)-inputxy(2)).^2 Mapping_Points(:,12)];
distancelist=[distancelist1;distancelist2];

                                     % The above computes the distances
                                     % between the input aoi and all the
                                     % aois in the MappingPoints list
                                               
[sortdistance I]=sort(distancelist(:,1));   % Now sort list (ascending)
pc=distancelist(I(1),2);                    % Get the aoi number of the aoi in aoiinfo2
                                            % that is closest to the input
                                            % aoi
                                        
                                           
