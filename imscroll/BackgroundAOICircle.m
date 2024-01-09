function pc=BackgroundAOICircle(InputAoiinfo2, AOIsize, AOIdistance)
%
% function BackgroundAOICircle(InputAoiinfo2, AOIsize, AOIdistance)
%
% This function will output aoiinfo2 and  RefAOINearLogik (see
% description in any aoifits file) variables that define background AOIs
% for the reference InputAoiinfo2 AOIs.  For each reference AOI listed in
% InputAoiinfo2, the function will calculate the coordinate for several
% AOIs that encircle that reference AOI (based on the parameters 
% AOIsize and AOIdistance).
%
% InputAoiinfo2 == aoiinfo2 variable listing a set of reference AOIs.  The
%           purpose of this function is to calculate a set of backbround AOIs 
%           appropriate for the reference AOIs listed in InputAoiinfo2.
% AOIsize == the spacing of the background AOIs is based on their size (we 
%            prefer that they minimally overlap) and the background AOI
%            size in pixels will be AOIsize x AOIsize (total area will then
%            be AOIsize^2).  i.e. AOIsize specifies the length of one side
%            (in pixels) of a square AOI
% AOIdistance == the circle of background AOIs that surrond each reference
%            AOI will be places with their centers set at a distance of 
%            AOIdistance (in pixels) away from each reference AOI
% output.aoiinfo2 == an aoiinfo2 variable listing the background AOIs for
%            the refernece AOIs specified in InputAoiinfo2
% output.RefAOINearLogik == logical array defined as in the aoifits
%           variable.  This means that e.g.
%           output.aoiinfo2(output.RefAOINearLogik{12},:) will pick out those
%           background AOIs in output.aoiinfo2 that are close to refernece 
%           AOI number 12 in InputAoiinfo2.


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

        % In polar coordinates (r,theta) the center of the background AOI circle will be
        % placed at a distance=AOIdistance from a reference AOI, and will 
        % spaced by angles theta = 2*delta, where 
delta=atan(AOIsize/AOIdistance/sqrt(2));
        % Note that AOIsize/sqrt(2) is 1/2 the diagnol of the background
        % AOIs we make (square AOIs with sides=AOIsize)

beta=2*delta*1.1;    % 1.1 factor and attempt to really insure the AOIs do not overlap
aoinumber=floor(2*pi/beta); % = number of AOIs we will space around the circle
if aoinumber<1
    error('AOIsize and AOIdistance are such that no AOI circle will be made')
end
if aoinumber<3
    sprintf('only 2 or fewer background AOIs created in circle')
end
[refrose refcol]=size(InputAoiinfo2);
bknumber=aoinumber*refrose;     % = total number of background AOIs that will be placed
pc.aoiinfo2=zeros(bknumber,refcol); % Reserve space for output background aoiinfo2
            % frm#   ave   x  y  pixnum    aoi#  referenceAOI#      (we will not retain referenceAOI# in the output matrix) 
bkaoiinfo2=[zeros(bknumber,1)   ones(bknumber,1)  zeros(bknumber,1)  zeros(bknumber,1)  AOIsize*ones(bknumber,1)  [1:bknumber]'  zeros(bknumber,1)];
outindx=1;  % Initialize row index of pc.aoiinfo2
for indx=1:refrose
        % Looping through all the reference AOIs
    xzero=InputAoiinfo2(indx,3);
    yzero=InputAoiinfo2(indx,4);
    AOIzero=InputAoiinfo2(indx,6);
    frmzero=InputAoiinfo2(indx,1);
        % Vector of AOIs in the background AOI circle for the current reference AOI 
    x=xzero+AOIdistance*cos(beta*[0:aoinumber-1]);
    y=yzero+AOIdistance*sin(beta*[0:aoinumber-1]);
    for subindx=1:aoinumber
                    % Enter the background AOI coordinates into the output matrix 
        bkaoiinfo2(outindx,3:4)=[x(subindx) y(subindx)];
        bkaoiinfo2(outindx,7)=AOIzero;      % Include the reference AOI#
        bkaoiinfo2(outindx,1)=frmzero;      % Reference AOI frame number
        outindx=outindx+1;              % Increment the row index
    end
end
      % Have now written all the xy coordinates for the background AOIs
      % Create the  output.RefAOINearLogik cell array
pc.RefAOINearLogik=cell(refrose,1);
for refindx=1:refrose
        % Loop through all the reference AOIs, finding all their background AOIs in the output aoiinfo2 matrix 
    logik=InputAoiinfo2(refindx,6)==bkaoiinfo2(:,7);    % Logical array, picks out rows
                                    % of bkaoiinfo2 that specify background
                                    % AOIs for  the
                                    % current reference AOI#
    pc.RefAOINearLogik{refindx,1}=logik;
end

    
pc.aoiinfo2(:,1:6)=bkaoiinfo2(:,1:6);      % 
