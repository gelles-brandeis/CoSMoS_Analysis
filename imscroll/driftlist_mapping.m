function pc=driftlist_mapping(driftlist,fitparmvector,TrackingField)
%
% function driftlist_mapping(driftlist,fitparmvector,TrackingField)
%
% A driftlist is typically constructed using points in one of the two
% microscope fields (either >635 or <635 nm) and will be able to
% compenstate for drift in that field.  In order to compensate for drift in
% the opposite field we need to transform the driftlist into the other
% field. 
% fitparmvector == 2 x 3 matrix f(ij) [f11 f12 f13;  f21 f22 f23] 
%          (stored by mapping gui) for mapping the aois where:  
                %       x2=f11*x1 + f12*y1  +f13
                %       y2=f21*x1  +f22*y1  +f23   or
                % inverse map  with denom=1/(f11*f22-f12*f21)
         % x1 = denom*f22*x2    + denom*(-f12)*y2+ (f12*f23-f13*f22)*denom
         % y1 = denom*(-f21)*x2 + denom*f11*y2+    (f21*f13-f23*f11)*denom
% driftlist =[ frm#   deltax   deltay]  N x 3 matrix defining drift
%       correction for imscroll
% TrackingField ==2  if we defined the driftlist in field#1 and wish to
%     transform the driftlist so that is will now track aois in field#2
%               ==1  if we defined the driftlist in field#2 and wish to
%     transform the driftlist so that is will now track aois in field#1

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

f11=fitparmvector(1,1);  f12=fitparmvector(1,2) ;  f13=fitparmvector(1,3);
f21=fitparmvector(2,1);  f22=fitparmvector(2,2) ;  f23=fitparmvector(2,3);
if TrackingField==2
                % Here if we measured the drift in field # 1 but we are now
                % wanting to track aois moving in field #2.  See notes in
                % file and B22p148,149
                % Get the deltax and deltay from current driftlist
    dx1=driftlist(:,2);
    dy1=driftlist(:,3);
    dx2=f11*dx1 + f12*dy1;      % Transform driftlist to field #2
    dy2=f21*dx1 + f22*dy1;
                                % Output the transformed driftlist
    pc=[driftlist(:,1) dx2 dy2];
elseif TrackingField==1
                % Here if we measured the drift in field # 2 but we are now
                % wanting to track aois moving in field #1.  See notes in
                % file and B22p148,149
                % Get the deltax and deltay from current driftlist
    dx2=driftlist(:,2);
    dy2=driftlist(:,3);
    denom=(1/(f11*f22-f12*f21));
    dx1=denom*f22*dx2 + denom*(-f12)*dy2;      % Transform driftlist to field #1
    dy1=denom*(-f21)*dx2 + denom*f11*dy2;
    pc=[driftlist(:,1) dx1 dy1];
end
