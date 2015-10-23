function pc=Remove_Event_v1(IntervalArray,BinaryInputTrace,Frame,handles)
%
%   function Remove_Event_v1(IntervalArray,BinaryInputTrace,Frame)
%
% Will remove one high event from the BinaryInputTrace and IntervalArray 
% as specified by the 'Frame' input.  Will be called from the plotargouts.m
% routine.
%
% IntervalArray == ['(low or high =0 or 1) (frame start) (frame end) (delta frames) (delta time (sec))  (ave frame intensity)']
%             Used in the plotargouts routine to record high and low events
%             in a record of integrated intensity.  This is contained in
%             handles.IntervalDataStructure.PresentTraceCellArray{1,10}
%
% BinaryInputTrace ===['(low or high =0 or 1) InputTrace(:,1) InputTrace(:,2)'];
%             Used in the plotargouts routine to mark high and low events
%             in a record of integrated intensity.  This is contained in
%             handles.IntervalDataStructure.PresentTraceCellArray{1,13}
%
% Frame == the frame number mouse clicked by the user as being nearest to the 
%             high event the user wants removed from the lists.  Will be
%             used to search through (frame start) and (frame end) in the
%             IntervalArray to identify the undesired interval
% handles == handles structure from calling program (plotargout)

% V1 fixed bugs in the list of intervals in IntervalArray

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

PTCA=handles.IntervalDataStructure.PresentTraceCellArray;
[IArose IAcol]=size(IntervalArray);
                % Initialize our search variables
MinDiff=abs(Frame-IntervalArray(1,2));          % IntervalArray(1,2)=start frame for event
IAindex=1;
for indx=1:IArose
                % Check each high interval frame boundary in the list for 
                % proximity to the Frame (the > 2 in next statement allows
                % us to eliminate a high event on the beginning/end of
                % a trace)
    if (IntervalArray(indx,1)==1) | (abs(IntervalArray(indx,1)) > 2)
                % Here if the row lists a high event
        CurrentDiff=abs(Frame-IntervalArray(indx,2));   % lower boundary of high event
        if CurrentDiff<MinDiff
                                % Here if new closest frame is found
            IAindex=indx;       % Replace the running row index
            MinDiff=CurrentDiff; % Replace the running minimum frame difference
        end
        CurrentDiff=abs(Frame-IntervalArray(indx,3));   % upper boundary of high event
        if CurrentDiff<MinDiff
                                % Here if new closest frame is found
            IAindex=indx;       % Replace the running row index
            MinDiff=CurrentDiff; % Replace the running minimum frame difference
        end
    end
end
        % Now, the IAindex indicates the row of IntervalArray that contains
        % the high event we wish to eliminate
highframe=IntervalArray(IAindex,3);
lowframe=IntervalArray(IAindex,2);
        % Cycle through the BinaryInputTrace and zero the rows (1 -> 0 in the 
        % first column) that specify the high event we eliminate
[BITrose BITcol]=size(BinaryInputTrace);
for BITindx=1:BITrose
    if (BinaryInputTrace(BITindx,2)<=highframe) & (BinaryInputTrace(BITindx,2)>=lowframe)
                % Zero the high/low column when the frame is between our
                % limits
        BinaryInputTrace(BITindx,1)=0;
    end
end
    % Finally, remove the high event from our list in IntervalArray
%Logic tree: Intervals before and after the removed high event matter:
%high/low values:
%  old values (b4 removal)       new values(after removal)
% b4  (high event)   after      b4       event     after       instance
%  6     -3          6           6        -2          6          1
%  6     -3          0           6        -2         -2          2
%  6     -3          2           6        -2         -2          3
% -2      1          0          -2        -2         -2          4
% -2      1          2          -2        -2         -2          5
%  0      1          0           0         0          0          6
%  0      1          2           2         2          2          7
%  0      3          6           2         2          6          8
% -2      3          6          -2        -2          6          9
%  6      3          6           6        -2          6         10
%
%   Note 6= Not Applicable (no interval there ,so its just a filler entry in the table)

%  Note that we will also need to merge intervals before and after the 
%  removed event, and adjust the column 6 average intensity

 if (IntervalArray(IAindex,1)==-3)&& (IArose==1)
     instance=1;
 elseif (IntervalArray(IAindex,1)==-3)&& (IntervalArray(IAindex+1,1)==0)
     instance=2;
 elseif (IntervalArray(IAindex,1)==-3)&& (IntervalArray(IAindex+1,1)==2)
     instance=3;
 elseif (IntervalArray(IAindex,1)==1)&& (IntervalArray(IAindex-1,1)==-2)&&(IntervalArray(IAindex+1,1)==0)
     instance=4;
  elseif (IntervalArray(IAindex,1)==1)&& (IntervalArray(IAindex-1,1)==-2)&&(IntervalArray(IAindex+1,1)==2)
     instance=5;
  elseif (IntervalArray(IAindex,1)==1)&& (IntervalArray(IAindex-1,1)==0)&&(IntervalArray(IAindex+1,1)==0)
     instance=6;
  elseif (IntervalArray(IAindex,1)==1)&& (IntervalArray(IAindex-1,1)==0)&&(IntervalArray(IAindex+1,1)==2)
     instance=7;
  elseif (IntervalArray(IAindex,1)==3)&& (IArose==1)
     instance=10;
  elseif (IntervalArray(IAindex,1)==3)&& (IntervalArray(IAindex-1,1)==0)
     instance=8;
  elseif (IntervalArray(IAindex,1)==3)&& (IntervalArray(IAindex-1,1)==-2)
     instance=9;
 
 end
 switch instance
     case 1
            % The high event is the first event of the trace, and the only
            % event of the trace
         IntervalArray(IAindex,1)=-2;   % Mark the event as low
     case 2
            % The high event is the first event of the trace, and there is
            % another low event following that IS NOT the last event of
            % the trace
         IntervalArray(IAindex,1)=-2;   % Mark the event as low
                                        %
                       % Next, extend the end of the event to the end of 
                       % the low event that follows
         IntervalArray(IAindex,3)=IntervalArray(IAindex+1,3);
                        % Next adjust the average intensity
         %IntervalArray(IAindex,6)=(IntervalArray(IAindex,6)*IntervalArray(IAindex,4)+IntervalArray(IAindex+1,6)*IntervalArray(IAindex+1,4))/...
         %                                                     (IntervalArray(IAindex,4)+IntervalArray(IAindex+1,4));
         IntervalArray(IAindex+1,:)=[]; % Remove the next event (it has been merged into the IAindex event
     case 3
            %6     -3          2           6        -2         -2          3
            % % The high event is the first event of the trace, and there is
            % another low event following that IS the last event of
            % the trace
         IntervalArray(IAindex,1)=-2;   % Mark the event as low
                                        %
                       % Next, extend the end of the event to the end of 
                       % the low event that follows
         IntervalArray(IAindex,3)=IntervalArray(IAindex+1,3);
                        % Next adjust the average intensity
         %IntervalArray(IAindex,6)=(IntervalArray(IAindex,6)*IntervalArray(IAindex,4)+IntervalArray(IAindex+1,6)*IntervalArray(IAindex+1,4))/...
         %                                                     (IntervalArray(IAindex,4)+IntervalArray(IAindex+1,4));
         IntervalArray(IAindex+1,:)=[]; % Remove the next event (it has been merged into the IAindex event
     case 4
         
            % -2      1          0          -2        -2         -2    4
            % The high event is NOT the first event of the trace, and there is
            % another low event following that IS NOT the last event of
            % the trace, and there is a preceeding event that IS the first
            % event of the trace   We will keep  and extend the preceding  -2 event
            % Extend the end of the preceding event (b4 event) to the end of 
            % the low event that follows (after event)
         IntervalArray(IAindex-1,3)=IntervalArray(IAindex+1,3);
             % Next adjust the average intensity
         %IntervalArray(IAindex-1,6)=(IntervalArray(IAindex-1,6)*IntervalArray(IAindex-1,4)+IntervalArray(IAindex,6)*IntervalArray(IAindex,4)+IntervalArray(IAindex+1,6)*IntervalArray(IAindex+1,4))/...
         %                               (IntervalArray(IAindex-1,4)+IntervalArray(IAindex,4)+IntervalArray(IAindex+1,4));
        
          IntervalArray=[IntervalArray(1:IAindex-1,:);        % Remove the events IAindex-1, and IAindex that have been merged into the IAindex+1 event 
                        IntervalArray(IAindex+2:IArose,:)];
     case 5
            % -2      1          2          -2        -2         -2          5
             % The high event is NOT the first event of the trace, and there is
            % another low event following that IS the last event of
            % the trace, and there is a preceeding event that IS the first
            % event of the trace   We will keep  and extend the preceding  -2 event
            % Extend the end of the preceding event (b4 event) to the end of 
            % the low event that follows (after event)
         IntervalArray(IAindex-1,3)=IntervalArray(IAindex+1,3);
          % Next adjust the average intensity
         %IntervalArray(IAindex-1,6)=(IntervalArray(IAindex-1,6)*IntervalArray(IAindex-1,4)+IntervalArray(IAindex,6)*IntervalArray(IAindex,4)+IntervalArray(IAindex+1,6)*IntervalArray(IAindex+1,4))/...
         %                               (IntervalArray(IAindex-1,4)+IntervalArray(IAindex,4)+IntervalArray(IAindex+1,4));
        
          IntervalArray=[IntervalArray(1:IAindex-1,:)];        % Remove the events IAindex, and IAindex+1 that have been merged into the IAindex-1 event 
                        
     case 6
           % 0      1          0           0         0          0          6
         % The high event is NOT the first event of the trace, and there is
            % another low event following that IS NOT the last event of
            % the trace, and there is a preceeding event that IS NOT the first
            % event of the trace   We will keep  and extend the preceding  0 event
            % Extend the end of the preceding event (b4 event) to the end of 
            % the low event that follows (after event)
          IntervalArray(IAindex-1,3)=IntervalArray(IAindex+1,3);
          % Next adjust the average intensity
         %IntervalArray(IAindex-1,6)=(IntervalArray(IAindex-1,6)*IntervalArray(IAindex-1,4)+IntervalArray(IAindex,6)*IntervalArray(IAindex,4)+IntervalArray(IAindex+1,6)*IntervalArray(IAindex+1,4))/...
         %                               (IntervalArray(IAindex-1,4)+IntervalArray(IAindex,4)+IntervalArray(IAindex+1,4));
        
         IntervalArray=[IntervalArray(1:IAindex-1,:);        % Remove the events IAindex, and IAindex+1 that have been merged into the IAindex-1 event 
                        IntervalArray(IAindex+2:IArose,:)];
     case 7
           % 0      1          2           2         2          2          7
            % The high event is NOT the first event of the trace, and there is
            % another low event following that IS the last event of
            % the trace, and there is a preceeding event that IS NOT the first
            % event of the trace   We will keep  and extend the following  2 event
            % Extend the beginning of the following event (after) to the beginning of 
            % the low event that preceeds (b4 event)
         IntervalArray(IAindex+1,2)=IntervalArray(IAindex-1,2);
              % Next adjust the average intensity
         %IntervalArray(IAindex+1,6)=(IntervalArray(IAindex-1,6)*IntervalArray(IAindex-1,4)+IntervalArray(IAindex,6)*IntervalArray(IAindex,4)+IntervalArray(IAindex+1,6)*IntervalArray(IAindex+1,4))/...
         %                               (IntervalArray(IAindex-1,4)+IntervalArray(IAindex,4)+IntervalArray(IAindex+1,4));
         IntervalArray=[IntervalArray(1:IAindex-2,:);        % Remove the events IAindex-1, and IAindex that have been merged into the IAindex+1 event 
                        IntervalArray(IAindex+1,:)];         % Note the IAindex+1 is the last event
     case 8
               % 0      3          6           2         2          6          8
            % The high event is the last event of the trace, and there is
            % a preceeding event that IS NOT the first
            % event of the trace   We will change the IAindex exent to 2
            % extend it to the beginning of the preceeding 0 event
            % Extend the beginning of the this event (IAindex) to the beginning of 
            % the low event that preceeds (b4 event)
         IntervalArray(IAindex,1)=2;
         IntervalArray(IAindex,2)=IntervalArray(IAindex-1,2);
            % Next, adjust the average intensity
         %IntervalArray(IAindex,6)=(IntervalArray(IAindex-1,6)*IntervalArray(IAindex-1,4)+IntervalArray(IAindex,6)*IntervalArray(IAindex,4) )/...
         %                               ( IntervalArray(IAindex-1,4)+IntervalArray(IAindex,4) );
         IntervalArray=[IntervalArray(1:IAindex-2,:);        % Remove the events IAindex-1that have been merged into the IAindex event 
                        IntervalArray(IAindex,:)];         % Note the IAindex is the last event
     case 9
           %  -2      3          6          -2        -2          6    9
            % The high event is the last event of the trace, and there is
            % a preceeding event that IS the first
            % event of the trace   We will extend the preceeding -2 event
            % 
            % Extend the end of the b4 event (IAindex-1) to the end of 
            % the IAindex high 3 event
         IntervalArray(IAindex-1,3)=IntervalArray(IAindex,3);
            % Adjust the average intensity
         %IntervalArray(IAindex-1,6)=(IntervalArray(IAindex-1,6)*IntervalArray(IAindex-1,4)+IntervalArray(IAindex,6)*IntervalArray(IAindex,4) )/...
         %                               ( IntervalArray(IAindex-1,4)+IntervalArray(IAindex,4) );
         IntervalArray(IAindex,:)=[];        % Remove the events IAindex that has been merged into the IAindex-1 event 
                                             % Note the IAindex is the last event 
     case 10
          % 6      3          6           6        -2          6  10
          % The high event is the last  and only event of the trace
          % I do not think this actually occurs, (it wd be marked instead
          % as a -3)
          % Change the interval to a -2
          IntervalArray(IAindex,1)=-2;
 end
 tb=PTCA{1,9};                  % Time base for the trace
 [IArose IAcol]=size(IntervalArray);
 %InputTrace=PTCA{1,12};                     % Detrended trace used here
 RawInputTrace=PTCA{1,11};          % Uncorrected input trace used here 
                           % First 3 columns of IntervalArray are correct
                           % from above, now correctly define columns 4:6
 
 for IAindex=1:IArose
     startframe=IntervalArray(IAindex,2);
      rawstartframe=find(RawInputTrace(:,1)==startframe);
     endframe=IntervalArray(IAindex,3);
      rawendframe=find(RawInputTrace(:,1)==endframe);
     
     
                      %IntervalArray=[(-2,-3,0,1,2,3) startfrm  endfrm   deltafrms  deltatime  aveintensity  aoi#] 
     IntervalArray(IAindex,:)=[IntervalArray(IAindex,1:3) endframe-startframe+1 tb(IntervalArray(IAindex,3)+1)-tb(IntervalArray(IAindex,2)) ...
                                          sum(RawInputTrace(rawstartframe:rawendframe,2))/(rawendframe-rawstartframe+1)-PTCA{1,16}  IntervalArray(IAindex,7)];
 end

 
         

    % And output the altered variables
guidata(gcbo,handles);
pc.IntervalArray=IntervalArray;
pc.BinaryInputTrace=BinaryInputTrace;