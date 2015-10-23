function pc=Find_Landings_Beginning_End(BinaryInputTrace)
%
% function Find_Landings_Beginning_End(BinaryInputTrace)
%
% Will be called from Find_Landings_OneFrameInterval() in order to find and
% mark the high and low regions at the beginning and end of the InputTrace
%
% BinaryInputTrace == same as in Find_Landings_OneFrameInterval()
%                  [(0 or 1)  InputTrace(:,1) InputTrace(:,2) ]
%                 where
%        InputTrace == [frame# data] and the 0 or 1 designate a low or high
%        value of the data
%
%
%  The output will relabel the first column of BinaryInputTrace only for the
%  first and last events in the trace.  The first continuous 0 or 1  interval at the
%  beginning of the trace will be labeled with -2, -3 respecively (substituting
%  for the 0 or 1 in BinaryInputTrace), and the last 0 or 1 interval 
%  at the end of the trace we be relabeled using +2, +3 respectively.
%  Ex. the first column of BinaryInputTrace may be altered according to:
%
% [0 0 0 1 1 0 0 0 1 1 0 1 1 1 1]' -> [-2 -2 -2 1 1 0 0 0 1 1 0 3 3 3 3 ]'
%  output.BinaryInputTrace    (relabeled as described above)
%  output.BeginningIndex     == index of final entry of beginning interval
%                              (=3 in above example)
%  output.EndingIndex     == index of first entry of ending interval
%                            (=12 in above example)

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

flagg=0;
flaggnone=0;
[rose col]=size(BinaryInputTrace);
                    % Note the first 0 or 1 entry
BeginningInterval=BinaryInputTrace(1,1);
                    % Now relabel all subsequent entries up until the first
                    % change
indxb=1;
while flagg==0
    if BinaryInputTrace(indxb,1)==BeginningInterval;
                        % Still continuous with initial 0/1, set equal
                        % to -2- (0 or 1)= -2 or -3
        BinaryInputTrace(indxb,1)= -2 -BeginningInterval;
        indxb=indxb+1;
        if indxb>rose
                        % Stop if we reach end of trace
            flagg=1;    
                        % Set flagg to say there are no events
            flaggnone=1;
        end
    else
                        % Found the first change, stop relabeling the
                        % BinaryInputTrace array
        flagg=1;
    end
end
                    % Next, note the final 0 or 1 entry
EndingInterval=BinaryInputTrace(rose,1);
                    % And relabel all prior entries of the same type until the 
                    % first change
indxe=rose;
flagg=0;
                    % If flaggnone ==1 there are no events, so do not look
                    % for an ending interval.  If flaggnone ~=1 do not
                    % bother searching for  an ending interval
if flaggnone~=1
    while flagg==0
        if BinaryInputTrace(indxe,1)==EndingInterval;
                        % Still continuous with ending 0/1, set equal
                        % to +2+ (0 or 1)= _+2 or +3
            BinaryInputTrace(indxe,1)= 2 +EndingInterval;
            indxe=indxe-1;
        else
                        % Found the first change, stop relabeling the
                        % BinaryInputTrace array
            flagg=1;
        end
    end
end
                       % Output the altered array with the beginning and
                       % ending intervals relabeled.
    
pc.BinaryInputTrace=BinaryInputTrace;
if flaggnone==1 
                    % Here if there were no events
                    % When the beginning and ending indices differ by only
                    % one, the calling program will know not to look for
                    % events in the data (and avoid an error)
    pc.BeginningIndex=round(rose/2);
    pc.EndingIndex=pc.BeginningIndex+1;
else
pc.BeginningIndex=indxb-1;
pc.EndingIndex=indxe+1;
end
