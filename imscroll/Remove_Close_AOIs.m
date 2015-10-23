function pc=Remove_Close_AOIs(aoiinfo2,Unique_Landing_Radius)
%
% pc=Remove_Close_AOIs(xytot,Unique_Landing_Radius)
% 
% This function will output an
% aoiinfo2 structure containing a list of aois located at the landing sites.  
% specified in the xytot list.  Those aois (landings) are culled so that no 
% two aois will be closer than a distance specified by UniqueLandingRadius 
%
% aoiinfo2 == output of aoi location information from imscroll
%           [ frm#   ave#   x   y   pixnum   aoi#]
% UniqueLandingRadius == the list of output aois in aoiinfo2 will be culled 
%                       so that we eliminate those aois from the list that
%                       are closer that a distance 'UniqueLandingRadius'
%                       from any other aoi.  That is, we remove aois that
%                       are clustered together, retaining only those aois
%                       that are well isolated from others. (units: pixels)

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

frm=aoiinfo2(1,1);      
ave=aoiinfo2(1,2);      % Pick off frame, average and pixnum
pixnum=aoiinfo2(1,5);
xytot=aoiinfo2(:,3:4);                  % [ x y ] list of aoi centers

[landingcount colmn]=size(xytot);       % landingcount = starting # of aois in list
                                        % colmn = 2
xytotaccum=zeros(landingcount,2);       % [x y] list that we will be outputing
                                        % of max length of landingcount
                                        

ListIndx=1;       % Current index into the accumulating list out output aois.
                 
xytotdum=xytot;     % [x y] list we will be modifying, keeping the current
                    % test [x y] aoi as the first element and successively
                    % removing aois that are clustered
tstaoi=xytot(1,:);  % AOI currently under test, from top of list
[rose colmn]=size(xytotdum);      % ListLength == current length of remaining aoi list
                                        % This will be decreasing as we remove aois from list
xytotdum=xytotdum(2:rose,:);      % Current xy list minus minus the top aoi that is 
                                        % currently under test.
[ListLength colmn]=size(xytotdum);      % ListLength == current length of remaining aoi list
                                        % This will be decreasing as we remove aois from list
while ListLength>1
                  % Keep going until there are no aois in the list below
                  % the current one being tested for proximity to others.
    dtest=sqrt( (xytotdum(:,1)-tstaoi(1,1)).^2 + (xytotdum(:,2)-tstaoi(1,2)).^2 );
    logik=dtest>(Unique_Landing_Radius)^2;     % Keep only aois that are not too close together
    if sum(logik)==ListLength;         % True only if there were no aois
                                        % too close to tstaoi, the aoi under test
        xytotaccum(ListIndx,:)=tstaoi;  % In which case we keep the current tstaoi
                                        % and add it to the output list
        ListIndx=ListIndx+1;
    end
    xytotdum=xytotdum(logik,:);        % New xy list, keeping only those not too close to tstaoi
    tstaoi=xytotdum(1,:);              
    [rose colmn]=size(xytotdum);      % ListLength == current length of remaining aoi list
                                        % This will be decreasing as we remove aois from list
    xytotdum=xytotdum(2:rose,:);      % Current xy list minus minus the top aoi that is 
                                        % currently under test.
    [ListLength colmn]=size(xytotdum);      % ListLength == current length of remaining aoi list
                                        % This will be decreasing as we remove aois from list
end
        % Now eliminate all the empty entries in the output list
logik=(xytotaccum(:,1)~=0)&(xytotaccum(:,2)~=0);
xytotaccum=xytotaccum(logik,:);         % Keep only nonzero elements (zero from initialization
[rose colm]=size(xytotaccum);
                        % Construct the output aoiinfo2 list
pc=[ones(rose,1)*frm  ones(rose,1)*ave    xytotaccum  ones(rose,1)*pixnum  [1:rose]' ]; 


