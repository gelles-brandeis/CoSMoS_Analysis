function pc=Remove_Close_AOIs_v1(aoiinfo2,Unique_Landing_Radius)
%
% pc=Remove_Close_AOIs_v1(xytot,Unique_Landing_Radius)
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
ListIndx=1;
for indx=1:landingcount
                        % Test each aoi against all the others
    tstaoi=xytot(indx,:);           % AOI under test
    dtest=sqrt( (xytot(:,1)-tstaoi(1,1)).^2 + (xytot(:,2)-tstaoi(1,2)).^2 );
    logik=dtest~=0;             % Pick all AOIs other than the one under test
    xytotdum=xytot(logik,:);
                                % Distance of test aoi to all others
    dtest=sqrt( (xytotdum(:,1)-tstaoi(1,1)).^2 + (xytotdum(:,2)-tstaoi(1,2)).^2 );
    logik=dtest>(Unique_Landing_Radius);     % Keep only aois that are not too close together
    if sum(logik)==landingcount-1
                    % Here if aoi under test is not close to any others
        xytotaccum(ListIndx,:)=tstaoi;  % In which case we keep the current tstaoi
                                        % and add it to the output list
        ListIndx=ListIndx+1;
    end
end


        % Now eliminate all the empty entries in the output list
logik=(xytotaccum(:,1)~=0)&(xytotaccum(:,2)~=0);
xytotaccum=xytotaccum(logik,:);         % Keep only nonzero elements (zero from initialization
[rose colm]=size(xytotaccum);
                        % Construct the output aoiinfo2 list
pc=[ones(rose,1)*frm  ones(rose,1)*ave    xytotaccum  ones(rose,1)*pixnum  [1:rose]' ]; 


