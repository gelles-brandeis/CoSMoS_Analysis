function pc=RemoveAOIsNearAOIs(handles)
% function RemoveAOIsNearAOIs(handles)
%
%   This just repeates the functionality of the Callback to MapButton 
%   (executing case 20) in the imscroll gui.  It was necessary to write this
%   also as a function so that it could be called within another Callback
%   (MapButton again, but from the portion executing case 22) and have the
%   current function (RemoveAOIsNearAOIs) update the handles structure
%   (which would not work when just using Callbacks).  In this instance the
%   curreent function alterst the handles.FitData matrix.  The handles
%   structure is returned to the calling Callback (MapButton executing 
%   case 22) and then guidata is invoked to update the handles structure. 
%   
% Copyright 2018 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.

   
    
    % Remove AOIs near AOIs
        
        filestring=get(handles.InputParms,'String');
        eval(['load ' handles.FileLocations.data filestring ' -mat'])    % loads a reference 'aoiinfo2' list of
                               % stored AOIs.  Our current list of AOIs in 'handles.FitData' will
                               % be filtered in that we will retain only those AOIs from the current list
                               % that are not close to AOIs from this reference list we just loaded
        Refaoiinfo2=aoiinfo2;   % The AOI list that we just loaded is our reference list of AOIs
        handles.Refaoiinfo2=Refaoiinfo2;    % Save the list of AOIs used as our reference set of AOIs
        [refrose refcol]=size(Refaoiinfo2);  % rose = number of AOIs in our reference list
                    
                   % Now we re-define 'aoiinfo2' to refer to our current
                   % list of AOIs (that will then be filtered)
        aoiinfo2=handles.FitData;       % Contains list of current AOIs
                                    % [framenumber ave x y pixnum aoinumber];
        [rose col]=size(aoiinfo2);   % Dimensions of our current aoi list            
                     %Next, fetch the PixelDistance value that will serve
                     %as our distance criteria for choosing from our
                     %current AOI list
       PixelDistance=str2num(get(handles.EditUniqueRadius,'String'));
     

       for indx=1:refrose

                                    % Cycle through AOIs in our reference list
                              %  (xycoord,               xylist,        PixelDistance)
           Farlist=Near_Far_AOIs(Refaoiinfo2(indx,3:4),aoiinfo2(:,3:4), PixelDistance);
           aoiinfo2=aoiinfo2(Farlist.logikFar,:); % retain only those current aoiinfo2 entries
                            % that are more distant than PixelDistance
           handles.FitData=aoiinfo2;
           handles.FitData=update_FitData_aoinum(handles.FitData);
       end
       handles.FarPixelDistance=PixelDistance;      % Save the distance used to pick AOIs here
       
       handles.NearFarFlagg=1;                  % Setting NearFarFlagg=1 then allows user to perform
                                            % the 'Retain AOIs Near AOIs' operation.  This order of operations
                                         % is necessary so that size(RefAOINearLogik) properly reflects the total number
                                         % of AOIs ringing our reference AOIs w/o counting the Near AOIs that we remove
                                         % in the current step  (case 20)
        %guidata(gcbo,handles);
       
        %slider1_Callback(handles.ImageNumber, eventdata, handles)
        pc=handles;