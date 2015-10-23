function pc=BinaryTraceIntervals(BinaryInputTrace)
%
% function BinaryTraceIntervals(BinaryInputTrace)
%
% From the single binary input trace (0 and 1) this function will find all
% the continuous high and low interval lengths.  An output trace will also
% mark the first and last intervals of the trace (high/low=-3/-2, and
% high/low = 3/2 respectively).
%
% BinaryInputTrace=[(high/low=1/0)] (frm#) ]
%
% output.OutputBinaryTrace=[(high/low=-3/-2, 1/0, 3/2) (frm#)]
% output.IntervalData=[(high/low=-3/-2, 1/0, 3/2)   frmstart   frmend    (frmsend-frmstart+1)]

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

[bitrose bitcol]=size(BinaryInputTrace);
pc.IntervalData=[];
dat=Find_Landings_Beginning_End(BinaryInputTrace);      % Mark beginning and ending intervals, and trace
         %dat.BinaryInputTrace == Binary trace with high/low=-3/-2 and 3/2 marked at beginning and end
                                                % [(high/low)  frm# ]
        % dat.BeginningIndex === index of final entry of beginning interval
        % dat.EndingIndex ==index of first entry of ending interval

        
    % First enter the initial interval (already found via Find_Landings_Beginning_End() above)
    % that relabeled the first/last intervals in BinaryInputTrace
framestart=BinaryInputTrace(1,2);
frameend=BinaryInputTrace(dat.BeginningIndex,2);
        % And get a logical matrix that picks out the interval entries of
        % the InputTrace
loga=(BinaryInputTrace(:,2)>=framestart)&(BinaryInputTrace(:,2)<=frameend);
IntervalData=[dat.BinaryInputTrace(1,1) framestart frameend (frameend-framestart+1)];
                            % We will pass through the BinaryInputTrace array,
                            % with the Current state of low/high indicated
                            % by'CurrentBinary', and find the continuous
                            % incidendces of high or low to assemble a list of 
                            % high/low intervals.
CurrentBinary=BinaryInputTrace(dat.BeginningIndex+1,1);     % This should be 0 or 1 (no +-2 or +-3)
framestart=BinaryInputTrace(dat.BeginningIndex+1,2);              % First frame for the interval that follows the
                                                     % beginning interval
frameend=framestart;                                % Initial value = framestart;
             
              % Only look for events when the beginning and ending indices 
              % differ by more than one.  When they differ by just one,
     % there are no events (see end of 'Find_Landings_Beginning_End')
if dat.EndingIndex-dat.BeginningIndex>1   
    % Run the next loop all the way to dat.EndingIndex (rather
              % than to just dat.EndingIndex-1) in order to register the
              % interval prior to the final interval
             
    for indx=(dat.BeginningIndex+1):(dat.EndingIndex)
        if BinaryInputTrace(indx,1)~=CurrentBinary
            frameend=BinaryInputTrace(indx-1,2);        % Here if low/high state has changed
                                % Add interval to output list
        %Get a logical matrix that picks out the interval entries of
        % the InputTrace
            loga=(BinaryInputTrace(:,2)>=framestart)&(BinaryInputTrace(:,2)<=frameend);
        
            IntervalData=[IntervalData;CurrentBinary framestart frameend (frameend-framestart+1)];
                                % Change the current low/high state
            CurrentBinary=BinaryInputTrace(indx,1);
            framestart=BinaryInputTrace(indx,2);        % Denote a new start frame
        end
    end
end

    % Last, enter the final interval (already found via
    % Find_Landings_Beginning_End() above that relabeled the first/last
    % intervals in BinaryInputTrace
    framestart=BinaryInputTrace(dat.EndingIndex,2);
    frameend=BinaryInputTrace(bitrose,2);
        %Get a logical matrix that picks out the interval entries of
        % the InputTrace
    loga=(BinaryInputTrace(:,2)>=framestart)&(BinaryInputTrace(:,2)<=frameend);

    IntervalData= [IntervalData; dat.BinaryInputTrace(bitrose,1) framestart frameend (frameend-framestart+1)];
  % BinaryInputTrace=[(-2,-3,0,1,2,3)  (frm#) (raw ADU integrated int)]
 
pc.OutputBinaryTrace=dat.BinaryInputTrace;      % Binary trace with high/low=-3/-2 and 3/2 marked at beginning and end
                                                % [(high/low)  frm# ]
pc.BinaryInputTrace=BinaryInputTrace;           % Our original BinaryInputTrace =[(high/low)=1/0   frm#] 
pc.IntervalData=IntervalData;                   % [(highlow=-3/-2, 1/0, 3/2) frmstart   frmend  (frmend - frmstart +1) ]
