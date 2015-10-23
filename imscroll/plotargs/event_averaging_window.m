function pc=event_averaging_window(cia,vid,WindowWidth,StepWidth,frmrange)
%
% function event_averaging_window(cia,vid,WindowWidth,StepWidth,frmrange)
%
%
% This function will compute the  number of high and low events and 
% the average (and median) length of events (high and low events) that begin 
% within a sliding window that is stepped throughout a specified frame range.
%
% The output structure contains members that describe the output content
%
% cia == Cumulative Interval Array from the Intervals structure created in
%        imscroll during interval detection (e.g. dwell times of a binding
%        protein  (=Intervals.CumulativeIntervalArray )
%         Intervals.CumulativeIntervalArrayDescription=
%        [  1:(low or high =-2,0,2 or -3,1,3)      2:(frame start)        3:(frame end)   …    
%        4: (delta frames)        5:(delta time (sec))     6:(interval ave intensity)       7:AOI#   ]
% vid == the header file structure for the glimpse sequence connected with
%       the Intervals structure
% WindowWidth == width of the sliding window (in frames)
% StepWidth== step size (in frames) used to increment the window position
%            within the limits of the specified frame range.
% frmrange == [beginning ending] two element vector specifying the starting
%            and ending frame over which the sliding window will scan.

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


tb=vid.ttb;         % Time base for the glimpse file
tb=tb-tb(1);
tb=tb*1e-3;         % The time base is now in seconds,with time zero being
                    % the first frame of the glimpse sequence.
            % Count the number of elements needed for output
frmrange=round(frmrange);       % Insure that the frmrange entries are integer
WindowWidth=round(WindowWidth);
StepWidth=round(StepWidth);
WindowStart=frmrange(1);
WindowEnd=WindowStart+round(WindowWidth)-1;   % We will include events that 
                        % start within the range: WindowStart<=EventStart AND 
                        % EventStart<=WindowEnd so the number of frames
                        % included in our window will equal the WindowWidth
                        % value
count=0;        % Element count
flagg=0;        % flag to end loop count
while flagg==0
    if ( WindowStart<=frmrange(2) ) & ( WindowEnd<=frmrange(2) )
                % Here if sliding window is within limits set by frmrange
        count=count+1;                  
        WindowStart=WindowStart+StepWidth;  % Increment the window edges
        WindowEnd=WindowEnd+StepWidth;
    else
        flagg=1;
    end
end
NumbLow=zeros(count,3);     
   % [(window center frms)  (window center time)  (number of low events within window) ]   
                                % Will hold the number of low events within the window (Nums(3,:))
                                % Also Nums(1,:) will be the window center
                                % in frames, and Nums(2,:) will be the
                                % window center in time

NumbHigh=zeros(count,3);     
   % [(window center frms)  (window center time)  (number of High events within window) ]   
                                % Will hold the number of High events within the window (Nums(3,:))
                                % Also Nums(1,:) will be the window center
                                % in frames, and Nums(2,:) will be the
                                % window center in time

DurationLow=zeros(count,6); 
   % [(window center frms)  (window center time)  (ave duration of low events within window units:frms)  (median duration of low events within window, units:frms)  (ave duration units:time)  (median duration units:time)] 
                            % Will hold the average duration of low events
                            % that start within the window
                            % (Durationlow(3,:)) and the median duration of
                            % low events that start within the window
                            % (DurationLow(4,:))
DurationHigh=zeros(count,6);    
   % [(window center frms)  (window center time)  (ave duration of high events within window,units:frames)  (median duration of high events within window, units:frames) (ave duration units:time)  (median duration units:time)] 
                            % Will hold the average duration of low events
                            % that start within the window
                            % (Durationlow(3,:)) and the median duration of
                            % low events that start within the window
                            % (DurationLow(4,:))
logikhigh=(cia(:,1)==-3)|(cia(:,1)==1)|(cia(:,1)==3);
ciaHigh=cia(logikhigh,:);     % List of all the high events
logiklow=(cia(:,1)==-2)|(cia(:,1)==0)|(cia(:,1)==2);
ciaLow=cia(logiklow,:);       % List of all the low events

        % Now again loop through all the sliding window positions
WindowStart=frmrange(1);
WindowEnd=WindowStart+round(WindowWidth)-1;   % We will include events that 
                        % start within the range: WindowStart<=EventStart AND 
                        % EventStart<=WindowEnd so the number of frames
                        % included in our window will equal the WindowWidth
                        % value
count=1;        % Element count
flagg=0;        % flag to end loop count
while flagg==0
    centerFrame=mean([WindowStart WindowEnd]);
    centerTime=mean([tb(WindowStart) tb(WindowEnd)]);
                % Pick all low events that start within our window
    logiklow=( WindowStart<=ciaLow(:,2) ) & ( WindowEnd>=ciaLow(:,2) );
    NumbLow(count,:)=[centerFrame centerTime sum(logiklow)];
                      %  windowCenter   windowCenter    avefrms               medianfrms                  avetime                mediantime        
    DurationLow(count,:)=[centerFrame centerTime mean(ciaLow(logiklow,4)) median(ciaLow(logiklow,4)) mean(ciaLow(logiklow,5)) median(ciaLow(logiklow,5)) ];
    
                % Pick all high events that start within our window
    logikhigh=( WindowStart<=ciaHigh(:,2) ) & ( WindowEnd>=ciaHigh(:,2) );
    NumbHigh(count,:)=[centerFrame centerTime sum(logikhigh)];
    
                      %  windowCenter   windowCenter    avefrms                 medianfrms                     avetime                    mediantime        
    DurationHigh(count,:)=[centerFrame centerTime mean(ciaHigh(logikhigh,4)) median(ciaHigh(logikhigh,4)) mean(ciaHigh(logikhigh,5)) median(ciaHigh(logikhigh,5)) ];
    
            % Increment the window edges                  
    WindowStart=WindowStart+StepWidth;  % Increment the window edges
    WindowEnd=WindowEnd+StepWidth;
             % Test if the new window falls entirely within our frame range
    if ( WindowStart<=frmrange(2) ) & ( WindowEnd<=frmrange(2) )
                % Here if sliding window is within limits set by frmrange
        count=count+1;
    else
        flagg=1;
    end
end
pc.NumbLowDescription = '[1:(window center frms)  2:(window center time)  3:(number of low events within window) ] ';
pc.NumbLow=NumbLow;
pc.NumbHighDescription = '[1:(window center frms)  2:(window center time)  3:(number of High events within window) ] ';
pc.NumbHigh=NumbHigh;
pc.DurationLowDescription='[1:(window center frms)  2:(window center time)  3:(ave duration of low events within window units:frms)  4:(median duration of low events within window, units:frms)  5:(ave duration units:time)  6:(median duration units:time)] ';
pc.DurationLow=DurationLow;
pc.DurationHighDescription='[(window center frms)  (window center time)  (ave duration of high events within window,units:frames)  (median duration of high events within window, units:frames) (ave duration units:time)  (median duration units:time)]';
pc.DurationHigh=DurationHigh;

    