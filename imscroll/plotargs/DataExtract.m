function pc=DataExtract(CellArray,framerange,argnum)
%
% function DataExtract(CellArray,framerange,argnum)
%
% Will take a data cell array CellArray derived from a single aoi data  
% and extract only those frames specified by the framerange
% parameter.  The function will return a [frame data] Nx2 matrix where the
% 'data' from the CellArray is specified by the argnum parameter
% Will be used for interval detection purposes where argnum = 8 for the
% integrated aoi data.
%

% CellArray == e.g. Cell array for data e.g. cell array in
%                PTCA=handles.IntervalDataStructure.PresentTraceCellArray;
%         CellArrayDescription=['(1:AOIfits Filename) (2:AOI Number) (3:Upward Threshold, sigma units) (4:Down Threshold, sigma units)'...
%         '(5:Mean) (6:Std) (7:MeanStdFrameRange Nx2) (8:DataFrameRange Nx2) (9:TimeBase 1xM) [10:Interval array Nx5]'...
%         ' 11:InputTrace 2xP  12:DetrendedTrace 2xP 13:BinaryInputTrace Lx3  '...
%         '14:BinaryInputTraceDescription 15:DetrendFrameRange Lx2'];
% framerange ==[framelow framehigh] an Mx2 matrix specifying one or several
%          frame regions to include in the output matrix
%
% argnum == 11 or 12 specifying which arguement of CellArray to place in the 'data'
%         column of the output matrix.

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

ChosenTrace=CellArray{1,argnum};    % Operate on either the original or detrended trace
                    % i.e. the InputTrace or DetrendedTrace
pc=[];
[rose col]=size(framerange);
for indx=1:rose
                % logical matrix picking out frames between limits
                % specified by frmrange parameter
    log= ( ChosenTrace(:,1)>= framerange(indx,1) ) & (ChosenTrace(:,1)<=framerange(indx,2) );
                % Add selected frames plus data to output list
 
    pc=[pc;ChosenTrace(log,1) ChosenTrace(log,2)];
end