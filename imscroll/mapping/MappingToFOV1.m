function pc=ProximityMapping(xy,fitparmvector,mappingpoints,OutputField)
%
%function  MappingToFOV1(x2y2,fitparmvector,mappingpoints)
%
% Will perform proximity mapping on the x2y2 coordinates and map them from
% FOV2 to FOV1 using the mapping parameters stored in fitparmvector and the
% list of mapping pairs listed in mappingpoints.
%
% xy ==[ x  y] M x 2 list of input coordinates
% fitparmvector == mapping fit parameters from a mapping file made in 
%            the imscrol gui
% mappingpoints == list of mapping pairs from a mapping file made in the
%            imscroll gui
% OutputField == specifies the output field for the mapping
%              =1 if user is mapping FOV2 to FOV 1 (out: x1y1)
%              =2 if user is mapping FOV1 to FOV 2 (out: x2y2)


                % modified from the GoButton  in imscroll
 
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

                % handles.Fitdata=[ frm# ave AOIx  AOIy pixnum aoinum]
                % nowpts=[handles.FitData(:,3) handles.FitData(:,4)]; 
nowpts=xy;
               
   % Use proximity mapping method
[rosenow colnow]=size(nowpts);
mappednow=zeros(rosenow,2);
for indx=1:rosenow
                            % Use 15 nearest points for mapping to field1
    mappednow(indx,:)=proximity_mapping_v1(mappintpoints,nowpts(indx,:),15,fitparmvector,OutputField);
end
                 %**handles.FitData(:,3:4)=mappednow;
                 %**
pc=mappednow;
      

                                % only keep points with pixel indices >=1
     %** log=(handles.FitData(:,3)>=1 ) & (handles.FitData(:,4) >=1) & (handles.FitData(:,3) <=1024) & (handles.FitData(:,4) <=1024);
     %** handles.FitData=handles.FitData(log,:);
     %** handles.FitData=update_FitData_aoinum(handles.FitData);
     %**guidata(gcbo,handles)
     %**********************************
     % Retain only those points with indices >=1 and <=1024
logik=(pc(:,1)>=1) & (pc(:,2)>=1) & (pc(:,1)<=1024) & (pc(:,2)<=1024);
pc=pc(logik,:);