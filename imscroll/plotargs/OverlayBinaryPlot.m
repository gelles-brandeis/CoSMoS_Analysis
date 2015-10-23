function pc=OverlayBinaryPlot(PTCA,haxes,fignum,varargin)
%
% function OverlayBinaryPlot(CellArray,haxes,fignum,<trace_color>)
%
% Will use the BinaryInputTrace array calculated by detecting the high/low
% transitions in the InputTrace and overlay that on the axes3 plot of the
% present InputTrace 
%
% CellArray == e.g. Cell array for data e.g. cell array in
%                PTCA=handles.IntervalDataStructure.PresentTraceCellArray;
%            CellArrayDescription=['(1:AOIfits Filename) (2:AOI Number) (3:Upward Threshold, sigma units) (4:Down Threshold, sigma units)'...
%         '(5:Mean) (6:Std) (7:MeanStdFrameRange Nx2) (8:DataFrameRange Nx2) (9:TimeBase 1xM) [10:Interval array Nx5]'...
%         ' 11:InputTrace 2xP  12:DetrendedTrace 2xP 13:BinaryInputTrace Lx3  '...
%         '14:BinaryInputTraceDescription 15:DetrendFrameRange Lx2'];
% haxes  == handle to the axes for the gui display, typically handles.axes3
% fignum == number of figure upon which the plot will also be overlaid
%PTCA=handles.IntervalDataStructure.PresentTraceCellArray;

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

    % get the baseline data mean
 if length(varargin)>0                       % grab trace_color, if it exists
    trace_color=varargin{1};
 else trace_color='b';
    
 end 

 mn=PTCA{1,5};
    % and standard deviation
 sd=PTCA{1,6};
    % Up threshold used for detection
 UpThreshold=PTCA{1,3};
 % BinaryInputTrace=['(low or high =0 or 1) InputTrace(:,2) InputTrace(:,3)'];
 BinaryInputTrace=PTCA{1,13};
                % logical array for all the 0s and 1s (low/high not at
                % record beginning and end
 log01=(BinaryInputTrace(:,1)==0) | (BinaryInputTrace(:,1)==1);
                % logical array for the +-2 and +-3 labeling the low/highs
                % at the end(+)/beginning(-)
 log23=abs(BinaryInputTrace(:,1))>1;

 axes(haxes);
 hold on
  
% plot(BinaryInputTrace(log01,2), mn+sd*UpThreshold*BinaryInputTrace(log01,1),'b')
% plot(BinaryInputTrace(log01,2), mn+sd*UpThreshold*BinaryInputTrace(log01,1),'b.')
 plot(BinaryInputTrace(log01,2), mn+sd*UpThreshold*BinaryInputTrace(log01,1),trace_color)
 plot(BinaryInputTrace(log01,2), mn+sd*UpThreshold*BinaryInputTrace(log01,1),[trace_color '.'])
                % Plot end intervals in different color; abs( )-2 maps -+2 and -+3
                % to 0 and 1
 
  
 plot(BinaryInputTrace(log23,2), mn+sd*UpThreshold*( abs(BinaryInputTrace(log23,1))-2),'g')
 plot(BinaryInputTrace(log23,2), mn+sd*UpThreshold*( abs(BinaryInputTrace(log23,1))-2),'g.')

 hold off
 figure(fignum);
 
 hold on
% plot(BinaryInputTrace(log01,2), mn+sd*UpThreshold*BinaryInputTrace(log01,1),'b')
 plot(BinaryInputTrace(log01,2), mn+sd*UpThreshold*BinaryInputTrace(log01,1),trace_color)
 plot(BinaryInputTrace(log23,2), mn+sd*UpThreshold*( abs(BinaryInputTrace(log23,1))-2),'g')
% plot(BinaryInputTrace(log01,2), mn+sd*UpThreshold*BinaryInputTrace(log01,1),'b.')
 plot(BinaryInputTrace(log01,2), mn+sd*UpThreshold*BinaryInputTrace(log01,1),[trace_color '.'])
 plot(BinaryInputTrace(log23,2), mn+sd*UpThreshold*( abs(BinaryInputTrace(log23,1))-2),'g.')

 hold off
 pc=1;
 