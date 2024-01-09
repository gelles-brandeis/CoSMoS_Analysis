function pc=RetainAOIsNearAOIs(handles)
% function RetainAOIsNearAOIs(handles)
%
%   This just repeates the functionality of the Callback to MapButton 
%   (executing case 21) in the imscroll gui.  It was necessary to write this
%   also as a function so that it could be called within another Callback
%   (MapButton again, but from the portion executing case 22) and have the
%   current function (RetainAOIsNearAOIs) update the handles structure
%   (which would not work when just using Callbacks).  In this instance the
%   curreent function alterst the handles.FitData matrix and the 
%   handles.RefAOINearLogik.  The handles structure is then
%   returned to the calling Callback (MapButton executing 
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

% Retain AOIs near AOIs
        if handles.NearFarFlagg==0
            sprintf('User must first perform ''Remove AOIs Near AOIs'' ')
            return          % Stop without executing the current 'Retain AOIs Near AOIs'
        end
       
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
    
       TotalNearLogik=aoiinfo2(:,6)<0;     % Logical array size of starting aoiinfo2 
                                % We'll use this to OR the criterion of
                                % being close to any AOI in refaoiinfo2
                                % TotalNearLogik starts out all logical zeros

       for indx=1:refrose

                                    % Cycle through AOIs in our reference list
                              %  (xycoord,               xylist,        PixelDistance)
           Nearlist=Near_Far_AOIs(Refaoiinfo2(indx,3:4),aoiinfo2(:,3:4), PixelDistance);
           TotalNearLogik=TotalNearLogik | Nearlist.logikNear; % When finished with the 
                        % loop, an entry will be true (1) only if that
                        % row of aoiinfo2 lists an AOI
                            % that is closer than PixelDistance to some
                            % AOI in our refaoiinof2 list
           %keyboard

       end
       aoiinfo2=aoiinfo2(TotalNearLogik,:);     % Keep only AOIs that are close to 
                                        % some AOI in our refaoiinfo2 list
       handles.FitData=aoiinfo2;        
       handles.FitData=update_FitData_aoinum(handles.FitData);
       handles.NearPixelDistance=PixelDistance;       % Save the distance used to pick AOIs here
       RefAOINearLogik=cell(refrose,1); % Cell array that will store logical arrays
                                        % that identify which AOIs in
                                        % aoiinfo2 that each AOI in
                                        % refaoiinfo2 is close to by our
                                        % PixelDistance criteria
                                        
       % keyboard
       for indxx=1:refrose
           Nearlist=Near_Far_AOIs(Refaoiinfo2(indxx,3:4),aoiinfo2(:,3:4), PixelDistance);
           RefAOINearLogik{indxx}=Nearlist.logikNear;
       end
       handles.RefAOINearLogik=RefAOINearLogik;     % Cell array, one array for each AOI in Refaoiinfo2.
                                          % Each logic array identifies which AOIs in
                                           % aoiinfo2 that each AOI in
                                           % refaoiinfo2 is close to by our
                                           % PixelDistance criteria
                       % e.g.  aoiinfo2(handles.RefAOINearLogik{12},:) picks
                       % out the rows in aoiinfo2 corresponding to the AOIs 
                       % that are close to the AOI number=12
                       % from the Refaoiinfo2 list.
       %guidata(gcbo,handles);            
       %slider1_Callback(handles.ImageNumber, eventdata, handles)
    pc=handles;