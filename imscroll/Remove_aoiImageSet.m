function pc=Remove_aoiImageSet(handles,AOINumber)
%
% function Remove_aoiImageSet(handles,AOINumber)
% 
% This routine will remove one AOI from the aoiImageSet stored in 
% handles.aoiImageSet used by imscroll( ).  See header in
% Update_aoiImageSet() or Import_aoiImageSet for the aoiImageSet description.
%

% Copyright 2016 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.


% We must go through each member of the aoiImageSet structure and remove
% the information for a single AOI.  We must also take care to update the
% AOI numbering in our lists.
old_aoiImageSet=handles.aoiImageSet;
aoiindx=old_aoiImageSet.aoiinfoTotx(:,6);               % List of AOI numbers
aoiindx=aoiindx';                                       % now a row vector
mxaoinumber=max( old_aoiImageSet.aoiinfoTotx(:,6));     % AOI numbering runs from
                                                        % 1 to mxaoinumber
logik=(aoiindx~=AOINumber);              % Flags all AOI #s NOT EQUAL to AOINumber
aoiNumberList=aoiindx(logik);            % aoiNumberList is of length (mxaoinumber-1)
                                         % with entries listing all AOI #s except AOINumber
LaoiNumberList=length(aoiNumberList);    % Should equal (mxaoinumber-1)

                                                        
% Descriptions
new_aoiImageSet.aoiinfoTotxDescription=old_aoiImageSet.aoiinfoTotxDescription;
new_aoiImageSet.ClassDescription=old_aoiImageSet.ClassDescription;

% Class Number
new_aoiImageSet.ClassNumber=old_aoiImageSet.ClassNumber(aoiNumberList);

 % Image Frames Start and End values
 new_aoiImageSet.ImageFrameStart=old_aoiImageSet.ImageFrameStart(aoiNumberList);
 new_aoiImageSet.ImageFrameEnd=old_aoiImageSet.ImageFrameEnd(aoiNumberList);
 
  % aoiinfoTotx
 logik=(old_aoiImageSet.aoiinfoTotx(:,6)~=AOINumber);       % Flag all rows with AOI # NOT EQUAL to AOINumber
 new_aoiImageSet.aoiinfoTotx= old_aoiImageSet.aoiinfoTotx(logik,:);
                                        % Now update the AOI numbering since we lack the AOINumber entry  
  new_aoiImageSet.aoiinfoTotx(:,1:6)=update_FitData_aoinum(new_aoiImageSet.aoiinfoTotx(:,1:6));
  
  % Filepath
  new_aoiImageSet.filepath=cell(LaoiNumberList,1);
  for cellindx=1:LaoiNumberList
      new_aoiImageSet.filepath{cellindx}=old_aoiImageSet.filepath{aoiNumberList(cellindx)};
  end

    % Glimpse or Tiff
new_aoiImageSet.GlimpseOrTiff=old_aoiImageSet.GlimpseOrTiff(aoiNumberList); 
  
  % rawImage
 new_aoiImageSet.rawImage=cell(LaoiNumberList,1);
 for cellindx=1:LaoiNumberList
      new_aoiImageSet.rawImage{cellindx}=old_aoiImageSet.rawImage{aoiNumberList(cellindx)};
 end 
 
    % centeredImage (registered images)
    new_aoiImageSet.centeredImage=cell(LaoiNumberList,1);
for cellindx=1:LaoiNumberList
      new_aoiImageSet.centeredImage{cellindx}=old_aoiImageSet.centeredImage{aoiNumberList(cellindx)};
end 
  
    % HalfOutputImageSize
new_aoiImageSet.HalfOutputImageSize=old_aoiImageSet.HalfOutputImageSize;

    % Now update the handles 
%handles.aoiImageSet=new_aoiImageSet;
%guidata(gcbo,handles);

pc=new_aoiImageSet;



    