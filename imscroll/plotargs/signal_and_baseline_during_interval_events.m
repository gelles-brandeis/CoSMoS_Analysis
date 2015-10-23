function pc=signal_and_baseline_during_interval_events(Intervals, aoifits, min_frmlength_high, min_frmlength_low, fignum)
%
% function signal_and_during_interval_events(Intervals, aoifits, min_frmlength_high, min_frmlength_low, fignum)
%
% Intervals == Intervals structure output from the imscroll -> plotarg gui
%
% aoifits == structure output from imscroll containing the gaussian fit
%            parameters and the integrated aois whose intervals are
%            summarized in the Intervals structure (above)
% min_frmlength_high == minimum frame length for a high event to be included in the
%                  output signal list
% min_frmlength_low == minimum frame length for a low event to be included in the
%                  output baseline list
%
% fignum == figure number for the plot
%
% This function will pick out signal (and basline) regions of integrated traces
% for the spots that occur during the high (and low) intervals specified in the Intervals
% structure.  That is, the time periods for which a spot is detected (high
% intervals) are selected and the gaussian spot parameters  of amplitude and 
% (spot width sigma) are plotted only during those detected intervals.  This
% avoids plotting gaussian parameters for frames in which a spot was not
% detected.  
% The function outputs a matrix (with same row format as aoifits.data)
% containing the list of integrated fit spots during the high intervals
% (subject to the specified minimum and maximum frame lengths), and another
% matrix (with same row format as aoifits.data)
% containing the list of integrated fit spots during the low intervals


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

cia=Intervals.CumulativeIntervalArray;
[eventnum ciacol]=size(cia);   % eventnum = number of events listed in cia 
logik=cia(:,1)<0;       % Negative number in first column occurs for start 
                        % events for each AOI
aoinum=sum(logik);      % aoinum = number of aois in list
aoicells=cell(aoinum,2);    % Form cell array.  The arrays will contain the 
                            % low events ( cell(m,1)) or high events
                            % (cell(m,2) )  for the mth AOI
starts=find(logik);     % starts = row indices of cia array that enumerate
                        % the first entry for each aoi
for indx=1:aoinum-1
    aoievents=cia(starts(indx):starts(indx+1)-1,:);     % submatrix of cia listing events for aoi = indx
    logikhigh=( (aoievents(:,1)==-3)|(aoievents(:,1)==1)|(aoievents(:,1)==3) )&( aoievents(:,4)>=min_frmlength_high);
    aoicells{indx,2}=aoievents(logikhigh,:);       % Capture and list all the high events subject to >=min_frmlength_high
    logiklow=( (aoievents(:,1)==-2)|(aoievents(:,1)==0)|(aoievents(:,1)==2) )& ( aoievents(:,4)>=min_frmlength_low );
    aoicells{indx,1}=aoievents(logiklow,:);        % Capture and list all the low events subject to >=min_frmlength_low
end
            % Now for the last AOI
aoievents=cia(starts(aoinum):eventnum,:);        % submatrix of cia listing events for aoi = indx
 
logikhigh=( (aoievents(:,1)==-3)|(aoievents(:,1)==1)|(aoievents(:,1)==3) )&( aoievents(:,4)>=min_frmlength_high) ;
aoicells{aoinum,2}=aoievents(logikhigh,:);       % Capture and list all the high events
logiklow=( (aoievents(:,1)==-2)|(aoievents(:,1)==0)|(aoievents(:,1)==2) ) & ( aoievents(:,4)>=min_frmlength_low );
aoicells{aoinum,1}=aoievents(logiklow,:);        % Capture and list all the low events
        % Now, aoicells{m,2} contain the list of all high events for the mth AOI. Each row:  
 % (low or high =-2,0,2 or -3,1,3) (frame start) (frame end) (deltaframes) (delta time (sec)) (interval ave intensity) AOI#   
figure(fignum);dat=draw_aoifits_aois_v1(aoifits,'y');       
   % dat(:,:,m) contains the aoifits data for the mth aoi.  Each row:
% [aoinumber  framenumber  amplitude  xcenter  ycenter  sigma  offset  integrated_aoi  (integrated pixnum)  (original aoi#)]

% Reserve maximum space for the relevant data 
[rosepc colpc]=size(aoifits.data);
HighFrames=zeros(rosepc,colpc+1);           % Add a column that will contain the event type
LowFrames=zeros(rosepc,colpc+1);            % for high or low =(-3,1 3) or (-2, 0,2)
HFcount=1;              % rows count for filling HighFrames
mnmx=zeros(aoinum,3);  % Store the high and low means from each aoi
                        % [aoi  mean(lows)  mean(highs)]
for aoiindx=1:aoinum
    HFcount_begin=HFcount;  % index as we begin to process events for this aoi
        % Cycle through the aois
    [highrose highcol]=size(aoicells{aoiindx,2});    % highrose = # of high events for aoi#=aoiindx    
    for eventindx=1:highrose
        frmstart=aoicells{aoiindx,2}(eventindx,2);   % start frame for high event
        frmend = aoicells{aoiindx,2}(eventindx,3);   % end frame for high event
                    % Pick out high event portion of trace, remove starting
                    % and ending frame to eliminate partial frame effects
        logik=(dat(:,2,aoiindx)>=frmstart+1)&(dat(:,2,aoiindx)<=frmend-1);
                     % Place the high event data into the output matrix 
            %***if ( (sum(logik)>=min_frmlength)& (sum(logik)<=max_frmlength) )
                        % Here if the event length falls between the
                        % specified minimum and maximum frame length =>
                        % include it in our output list and plot
                HighFrames(HFcount:(HFcount+sum(logik)-1),:)=[dat(logik,:,aoiindx) aoicells{aoiindx,2}(eventindx,1)*ones(sum(logik),1)];
                HFcount=HFcount+sum(logik);    % Increase index for data storage
            %***end
    end
    mnmx(aoinum,3)=mean(HighFrames(HFcount_begin:HFcount-1,8));     % Mean of integrated intensity for all the high events added for current aoi
end
LFcount=1;              % rows count for filling HighFrames

for aoiindx=1:aoinum
        % Cycle through the aois
    [lowrose lowcol]=size(aoicells{aoiindx,1});    % highrose = # of low events for aoi#=aoiindx    
    for eventindx=1:lowrose
        LFcount_begin=LFcount;  % index as we begin to process events for this aoi
        frmstart=aoicells{aoiindx,1}(eventindx,2);   % start frame for low event
        frmend = aoicells{aoiindx,1}(eventindx,3);   % end frame for low event
                    % Pick out low event portion of trace, remove starting
                    % and ending frame to eliminate partial frame effects
        logik=(dat(:,2,aoiindx)>=frmstart+1)&(dat(:,2,aoiindx)<=frmend-1);
                     % Place the high event data into the output matrix 
            %***if ( (sum(logik)>=min_frmlength)& (sum(logik)<=max_frmlength) )
                        % Here if the event length falls between the
                        % specified minimum and maximum frame length =>
                        % include it in our output list and plot
                LowFrames(LFcount:(LFcount+sum(logik)-1),:)=[dat(logik,:,aoiindx) aoicells{aoiindx,1}(eventindx,1)*ones(sum(logik),1)];
                LFcount=LFcount+sum(logik);    % Increase index for data storage
            %***end
    end
     mnmx(aoinum,2)=mean(LowFrames(LFcount_begin:LFcount-1,8));     % Mean of integrated intensity for all the low events added for current aoi
end



    % Get rid of unused space in the output matrix
logik=HighFrames(:,1)~=0;
HighFrames=HighFrames(logik,:);
logik=LowFrames(:,1)~=0;
LowFrames=LowFrames(logik,:);
pc.HighFrames=HighFrames;
pc.LowFrames=LowFrames;
            % Plot High and Low frames
figure(fignum);plot(pc.HighFrames(:,2),pc.HighFrames(:,8),'r',pc.LowFrames(:,2),pc.LowFrames(:,8),'b.');shg





