function pc=aoicompare(inputxy,ghandles)
%
% function aoicompare(inputxy,ghandles)
%
% This function is intended to help located corresponding aois
% in the Cy3 and and alexa488 aoi lists during the tricolor oligo
% experiment.  We will input the x and y coordinates of one aoi from
% e.g. the Cy3 list, and look for the corresponding aoi in the 
% alexa488 list (aoiinfo2).  The program will find the closest aoi
% in the aoiinfo2 list, and it is up to the user to make the decision
% as to whether those two aois are actually coincident.
%
% inputxy == [x y] the x and y coordinates of our input aoi.  We are
%               trying to find which aoi in the aoiinfo2 list is actually
%               closest spatially to this input aoi
% ghandles == the handles structure from the calling gui.  e.g.
%           handles.FitData = aoiinfo2 (see below)
% aoiinfo2 = list of aois output by imscroll when the user is tracking a
%              time course for the appearence of dye spots
%              [frame#  ave  x   y  pixnum  aoinum (danny's original aoi#)]
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

aoiinfo2=ghandles.FitData;           % Current list of fixed aois (see above)
                                    %
                                    % If we are in a 'moving aois' mode, we
                                    % need to shift the xy coordinates of
                                    % the aois in our list to reflect the
                                    % present frame
[maoi naoi]=size(aoiinfo2);
                                    % maoi = number of aois in our list
OptionalXYshift=zeros(maoi,2);      % Initialize list of xy coordinate shifts

if get(ghandles.StartParameters,'Value')==2
                                    % Here if we are in a 'moving aoi mode'
    imagenum=get(ghandles.ImageNumber,'value');        % Retrieve the value of the slider
    imagenum= round(imagenum);

    for indx=1:maoi
                                    % Go through all aois and compute the
                                    % relevant xy shift of the aoicenter
     
        OptionalXYshift(indx,:)=ShiftAOI(indx,imagenum,aoiinfo2,ghandles.DriftList);
     
    end
else
end

                                    % Correct the xy centers of the aois
                                    % using the above computed
                                    % OptionalXYshift (will be zero
                                    % correction if we are not in 'moving
                                    % aoi' mode

aoiinfo2(:,3:4)=aoiinfo2(:,3:4)+OptionalXYshift; 
                                    
distancelist=[(aoiinfo2(:,3)-inputxy(1)).^2+(aoiinfo2(:,4)-inputxy(2)).^2 aoiinfo2(:,6)];
                                     % The above computes the distances
                                     % between the input aoi and all the
                                     % aois in the aoiinfo2 list
                                               
[sortdistance I]=sort(distancelist(:,1));   % Now sort list (ascending)
pc=distancelist(I(1),2);                    % Get the aoi number of the aoi in aoiinfo2
                                            % that is closest to the input
                                            % aoi
                                        
                                           
