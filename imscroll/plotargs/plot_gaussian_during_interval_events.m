function pc=plot_gaussian_during_interval_events(Intervals, aoifits, min_frmlength, max_frmlength, increase_start, decrease_end, fignum)
%
% function plot_gaussian_during_interval_events(Intervals, aoifits, minfrmlength, max_frmlength, increase_start, decrease_end, fignum)
%
% Intervals == Intervals structure output from the imscroll -> plotarg gui
%
% aoifits == structure output from imscroll containing the gaussian fit
%            parameters and the integrated aois whose intervals are
%            summarized in the Intervals structure (above)
% min_frmlength == minimum frame length for an event to be included in the
%                  output list
% max_frmlength == maximum frame length for an event to be included in the
%                  output list
% increase_start == number of frames to remove from start of event(e.g. =1
%                in order to remove partial frames from event start
% decrease_end == number of frames to remove from end of event (e.g. =1 in
%                order to remove partial frames from event end
%
% fignum == figure number for the plot
%
% This function will plot the gaussian spot amplitude vs (spot sigma)
% for the spots that occur during the high intervals specified in the Intervals
% structure.  That is, the time periods for which a spot is detected (high
% intervals) are selected and the gaussian spot parameters  of amplitude and 
% (spot width sigma) are plotted only during those detected intervals.  This
% avoids plotting gaussian parameters for frames in which a spot was not
% detected.  
% The function outputs a matrix (with same row format as aoifits.data)
% containing the list of gaussian fit spots during the high intervals
% (subject to the specified minimum and maximum frame lengths).

% Part of program from binding_event_number.m
% cia == Cumulative Interval Array from the Intervals structure created in
%        imscroll during interval detection (e.g. dwell times of a binding
%        protein  (=Intervals.CumulativeIntervalArray )
%         Intervals.CumulativeIntervalArrayDescription=
%        [  1:(low or high =-2,0,2 or -3,1,3)      2:(frame start)        3:(frame end)   …    
%        4: (delta frames)        5:(delta time (sec))     6:(interval ave intensity)       7:AOI#   ]
%
% n == number of the binding event from each AOI.  That is, if n = 3 and 
%      hilo = 0 the user wants this function to return a list of events
%      that constitute the third low interval from each AOI  
%
% hilo == 0 or 1  
%         0: return low events
%         1: return high events

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

increase_start=round(increase_start);
decrease_end=round(decrease_end);
min_frmlength=round(min_frmlength);

if (min_frmlength-increase_start-decrease_end)<1
    error('minfrmlength must exceed increase_start+decrease_end')
end
cia=Intervals.CumulativeIntervalArray;
[eventnum ciacol]=size(cia);   % eventnum = number of events listed in cia 
logik=cia(:,1)<0;       % Negative number in first column occurs for start 
                        % events for each AOI
aoinum=sum(logik);      % aoinum = number of aois in list
aoicells=cell(aoinum,3);    % Form cell array.  The arrays will contain the 
                            % low events ( cell(m,1)) or high events
                            % (cell(m,2) )  for the mth AOI
                            % (cell(m,3)) for the AOI # for these events
starts=find(logik);     % starts = row indices of cia array that enumerate
                        % the first entry for each aoi
for indx=1:aoinum-1
    aoievents=cia(starts(indx):starts(indx+1)-1,:);     % submatrix of cia listing events for aoi = indx
    logikhigh=(aoievents(:,1)==-3)|(aoievents(:,1)==1)|(aoievents(:,1)==3);
    aoicells{indx,2}=aoievents(logikhigh,:);       % Capture and list all the high events
    logiklow=(aoievents(:,1)==-2)|(aoievents(:,1)==0)|(aoievents(:,1)==2);
    aoicells{indx,1}=aoievents(logiklow,:);        % Capture and list all the low events
    aoicells{indx,3}=aoievents(1,7);                % AOI number for these high and low events
end
            % Now for the last AOI
aoievents=cia(starts(aoinum):eventnum,:);        % submatrix of cia listing events for aoi = indx
 
logikhigh=(aoievents(:,1)==-3)|(aoievents(:,1)==1)|(aoievents(:,1)==3);
aoicells{aoinum,2}=aoievents(logikhigh,:);       % Capture and list all the high events
logiklow=(aoievents(:,1)==-2)|(aoievents(:,1)==0)|(aoievents(:,1)==2);
aoicells{aoinum,1}=aoievents(logiklow,:);        % Capture and list all the low events
aoicells{aoinum,3}=aoievents(1,7);               % AOI number for these high and low events
        % Now, aoicells{m,2} contain the list of all high events for the AOI number=aoicells{m,3}. Each row:  
 % (low or high =-2,0,2 or -3,1,3) (frame start) (frame end) (deltaframes) (delta time (sec)) (interval ave intensity) AOI#   
figure(fignum);dat=draw_aoifits_aois_v1(aoifits,'y');       
   % dat(:,:,m) contains the aoifits data for the mth aoi.  Each row:
% [aoinumber  framenumber  amplitude  xcenter  ycenter  sigma  offset  integrated_aoi  (integrated pixnum)  (original aoi#)]

% Reserve maximum space for the relevant data 
[rosepc colpc]=size(aoifits.data);
pc=zeros(rosepc,colpc);
pccount=1;              % rows count for filling pc
%keyboard
for aoiindx=1:aoinum
        % Cycle through the aois
    [highrose highcol]=size(aoicells{aoiindx,2});    % highrose = # of high events for aoi#=aoiindx    
    for eventindx=1:highrose
        frmstart=aoicells{aoiindx,2}(eventindx,2);   % start frame for high event
        frmend = aoicells{aoiindx,2}(eventindx,3);   % end frame for high event
        logik=(dat(:,2,aoiindx)>=frmstart+increase_start)&(dat(:,2,aoiindx)<=frmend-decrease_end);
                     % Place the high event data into the output matrix 
            if ( (sum(logik)>=min_frmlength)& (sum(logik)<=max_frmlength) )
                        % Here if the event length falls between the
                        % specified minimum and maximum frame length =>
                        % include it in our output list and plot
                %[pccount frmend frmstart increase_start decrease_end (frmend-frmstart-increase_start-decrease_end) sum(logik)]
                pc(pccount:(pccount+(frmend-frmstart-increase_start-decrease_end)),:)=dat(logik,:,aoiindx);
                pccount=pccount+(frmend-frmstart-increase_start-decrease_end)+1;    % Increase index for data storage
            end
    end
end
    % Get rid of unused space in the output matrix
logik=pc(:,1)~=0;
pc=pc(logik,:);
            % Plot spot sigma vs spot amplitude
figure(fignum);plot(pc(:,6),pc(:,3),'b.');shg





