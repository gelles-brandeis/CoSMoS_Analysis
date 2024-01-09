function pc = Find_Landings_MultipleFrameIntervals(InputTrace,MultipleFrameIntervals,UpThreshold,DownThreshold,MinUpFrames,MinDownFrames)
%
%function Find_Landings_MultipleFrameIntervals((InputTrace,MultipleFrameIntervals,UpThreshold,DownThreshold,MinUpFrames,MinDownFrames)
%
% Will delineate high and low intervals in the InputTrace, thus recognizing when and 
% how long dye-labeled protein bindings occur. 
%
% InputTrace == [ frame#  data] where the data will be the integrated
%    intensity from an aoi in which dye-proteins are landing
% MultipleFrameIntervals = [framelow framehigh],an Nx2 vector specifying the
%         multiple frame intervals to examine for events.  
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
%   (includes only those portions of InputTrace specified by the
%                     MultipleFrameIntervals parameter )
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

[framerose framecol]=size(MultipleFrameIntervals);
pc.BinaryInputTrace = [];
pc.IntervalData = [];
Min0=MinDownFrames;             % Minimum length of 0 interval
for frmindx=1:framerose
            % logical matrix picks out frames between limits
    logik= (InputTrace(:,1)>=MultipleFrameIntervals(frmindx,1)) & ...
                     (InputTrace(:,1)<=MultipleFrameIntervals(frmindx,2));
    subInputTrace=InputTrace(logik,:);
            % subInputTrace=[(frm#)  (0/1)]
            % Find intervals for this section of the InputTrace array
   
   if Min0>1
            %  Remove the 0 intervals that are too short
            % First we need to pull out the trace section that is not the first or last interval
        dumsubInputTrace=[subInputTrace(:,2) subInputTrace];
                % dumsubInputTrace = [(0/1)  (frm#)  (0/1) ]
        dumdat=Find_Landings_Beginning_End(dumsubInputTrace); 
        midBinaryTrace=subInputTrace(dumdat.BeginningIndex+1:dumdat.EndingIndex-1,2);
             %midBinaryTrace = (N x 1) consisting of the middle of the binary trace
             % i.e. the binary trace other than the first and last intervals
            % Now remove 0 intervals whose frame length is shorter than Min0
        if length(midBinaryTrace>Min0)
                % Above test is necessary b/c sometimes the entire trace is
                % the first+last interval, so there is no midBinaryTrace
            midBinaryTrace=RemoveFalseNegatives(midBinaryTrace,Min0);
            lengthTrace=length(subInputTrace(:,2));         % Length of the trace
            % Now replace the subInputTrace (binary trace) with one that
            % has had the short 0 intervals removed (other than the first
            % and last intervals of the trace)
            subInputTrace(:,2)=[subInputTrace(1:dumdat.BeginningIndex,2) ; midBinaryTrace' ; subInputTrace(dumdat.EndingIndex:lengthTrace,2)]; 
        end
       
        % dat.BeginningIndex === index of final entry of beginning interval
        % dat.EndingIndex ==index of first entry of ending interval
% We now  have an intermediate matrix (with 0s and 1s for low and high)
% denoted by BinaryInputTrace = [(0 or 1) InputTrace(:,1) InputTrace(:,2)]
%
%  (except for for the first and last intervals which are marked with -2/-3
%  and +2/+3 as noted above)            
   end
    dum=Find_Landings_OneFrameInterval(subInputTrace,UpThreshold,DownThreshold,MinUpFrames,MinDownFrames);
            % Append interval data onto our growing list
    pc.BinaryInputTrace=[pc.BinaryInputTrace; dum.BinaryInputTrace];
    pc.IntervalData=[pc.IntervalData; dum.IntervalData];
end


    