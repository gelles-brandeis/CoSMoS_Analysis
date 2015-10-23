function pc=Find_Landings_OneFrameInterval(InputTrace,UpThreshold,DownThreshold,MinUpFrames,MinDownFrames)
%
% function Find_Landings_OneFrameInterval(InputTrace, UpThreshold,DownThreshold,MinUpFrames,MinDownFrames)
%
% Will delineate high and low intervals in the InputTrace, thus recognizing when and 
% how long dye-labeled protein bindings occur.  
%
% InputTrace == [ frame#  data] where the data will be the integrated
%    intensity from an aoi in which dye-proteins are landing
% UpThreshold == threshold for the 'data'.  When the data in a 'low' state 
%       rises above the value specified by UpThreshold, a 'high' interval 
%      will begin
% DownThreshold == threshold for the 'data'.  When the data in a 'high' state 
%       drops below the value specified by DownThreshold, a 'low' interval 
%      will begin
% MinUpFrames == minimum number of Frames that the data must remain in the
%        high state in order to be considered a high interval
% MinDownFrames == minumum number of frames that the data must remain in
%        the low state in order to be considered a low interval
%
% Output is a structure of the form:      output.BinaryInputTrace
%                                         outout.IntervalData
% with 
% BinaryInputTrace = [(0 or 1) InputTrace(:,1) InputTrace(:,2)]
%
% IntervalData=[ (0 or 1 for low or high) (starting frame) (ending frame) (delta frames)]
%                  (list of all the high and low intervals)

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

    
[rose col]=size(InputTrace);
                            % First data frame, default will be low unless
                            % the data is above the UpThreshold
BinaryInputTrace=[ (InputTrace(1,2)>UpThreshold) InputTrace(1,:)];
CurrentBinary=BinaryInputTrace(1,1);
                        % Next go through the rest of the InputTrace
                        % assigning each point to either the high (1) or
                        % low (0) state
for indx=2:rose
    if CurrentBinary==1     % In high state
        if InputTrace(indx,2)<DownThreshold
                            % here if going high -> low
            CurrentBinary=0;
            BinaryInputTrace=[BinaryInputTrace; 0 InputTrace(indx,:)];
        else
                            % here if remaining high
            BinaryInputTrace=[BinaryInputTrace; 1 InputTrace(indx,:)];
        end
   
    elseif CurrentBinary ==0
        if InputTrace(indx,2)>UpThreshold
                            % Here if going low -> high
            CurrentBinary=1;  
            BinaryInputTrace=[BinaryInputTrace; 1 InputTrace(indx,:)];
        else
                            % Here if remaining low
            BinaryInputTrace=[BinaryInputTrace; 0 InputTrace(indx,:)];
        end
    end
   
end
% We now  have an intermediate matrix (with 0s and 1s for low and high)
% denoted by BinaryInputTrace = [(0 or 1) InputTrace(:,1) InputTrace(:,2)]

        %Now mark the first interval 0s or 1s with -2 or -3 respectively,
        %and the ending interval 0s or 1s with +2 or +3 respectivley
dat=Find_Landings_Beginning_End(BinaryInputTrace);
BinaryInputTrace=dat.BinaryInputTrace;
        % dat.BeginningIndex === index of final entry of beginning interval
        % dat.EndingIndex ==index of first entry of ending interval
% We now  have an intermediate matrix (with 0s and 1s for low and high)
% denoted by BinaryInputTrace = [(0 or 1) InputTrace(:,1) InputTrace(:,2)]
%
%  (except for for the first and last intervals which are marked with -2/-3
%  and +2/+3 as noted above)

IntervalData=[];
    % First enter the initial interval (already found via Find_Landings_Beginning_End() above)
    % that relabeled the first/last intervals in BinaryInputTrace
framestart=InputTrace(1,1);
frameend=InputTrace(dat.BeginningIndex,1);
        % And get a logical matrix that picks out the interval entries of
        % the InputTrace
loga=(BinaryInputTrace(:,2)>=framestart)&(BinaryInputTrace(:,2)<=frameend);
IntervalData=[BinaryInputTrace(1,1) framestart frameend (frameend-framestart+1) ...
             sum(BinaryInputTrace(loga,3))/(frameend-framestart+1)];
                            % We will pass through the BinaryInputTrace array,
                            % with the Current state of low/high indicated
                            % by'CurrentBinary', and find the continuous
                            % incidendces of high or low to assemble a list of 
                            % high/low intervals.
CurrentBinary=BinaryInputTrace(dat.BeginningIndex+1,1);     % This should be 0 or 1 (no +-2 or +-3)
framestart=InputTrace(dat.BeginningIndex+1,1);              % First frame for the interval that follows the
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
            frameend=InputTrace(indx-1,1);        % Here if low/high state has changed
                                % Add interval to output list
        %Get a logical matrix that picks out the interval entries of
        % the InputTrace
            loga=(BinaryInputTrace(:,2)>=framestart)&(BinaryInputTrace(:,2)<=frameend);
        
            IntervalData=[IntervalData;CurrentBinary framestart frameend (frameend-framestart+1)...
                                  sum(BinaryInputTrace(loga,3))/(frameend-framestart+1)];
                                % Change the current low/high state
            CurrentBinary=BinaryInputTrace(indx,1);
            framestart=InputTrace(indx,1);        % Denote a new start frame
        end
    end
end

    % Last, enter the final interval (already found via
    % Find_Landings_Beginning_End() above that relabeled the first/last
    % intervals in BinaryInputTrace
    framestart=InputTrace(dat.EndingIndex,1);
    frameend=InputTrace(rose,1);
        %Get a logical matrix that picks out the interval entries of
        % the InputTrace
    loga=(BinaryInputTrace(:,2)>=framestart)&(BinaryInputTrace(:,2)<=frameend);

    IntervalData= [IntervalData; BinaryInputTrace(rose,1) framestart frameend (frameend-framestart+1)...
                              sum(BinaryInputTrace(loga,3))/(frameend-framestart+1)];
  % BinaryInputTrace=[(-2,-3,0,1,2,3)  (frm#) (raw ADU integrated int)]
  % Put in a fix for instance where there are no events: above will have
  % e.g labeled a -2 event at both beginning and end and we only want one
  % event in such a case
  
 if (length(IntervalData(:,1)==2)&(IntervalData(1,1)==IntervalData(2,1)))
     framestart=InputTrace(1,1);frameend=InputTrace(rose,1);
     IntervalData=[BinaryInputTrace(rose,1) framestart frameend rose sum(InputTrace(1:rose,2))/rose];
 end
 
 
                             
pc.BinaryInputTrace=BinaryInputTrace;
pc.IntervalData=IntervalData;

