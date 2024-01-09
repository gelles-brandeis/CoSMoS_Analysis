function pc=DetrendAfterBackgroundSubtraction(RefTraceMinusBkgnd, BaselineStdDev)
%
% function DetrendAfterBackgroundSubtraction(RefTraceMinusBkgnd, BaselineStdDev)
%
% This function may be used as part of the background subtraction protocol.  
% Using the circle of background AOIs we form an average background trace
% that we subtract off of the data trace (latter measured in the reference
% AOI), yielding 'RefTraceMinusBkgnd'.  There is still a little baseline
% offset from zero, and this function is intended to remove that residual.
% We will select points in the RefTraceMinusBkgnd that are within +-2*sigma 
% zero and fit those to a smoothed line.  That smoothed line will then be
% subtracted off from RefTraceMinusBkgnd to remove the small residual offset
% from zero that was cited above.
%
% RefTraceMinusBkgnd ==In the calling function (e.g. SmoothBackgroun_v5.m')
%             We Use the circle of background AOIs and form an average
%             background trace  that we subtract off of a data trace 
%     (latter measured in the reference AOI), yielding 
%     'RefTraceMinusBkgnd', [(frame number) intensity]
% handles == handles structure from the plotargout gui
% BaselineStdDev == the calling program obtains the standard deviation of
%          the expected baseline trace using the standard deviation of the
%          background AOI traces. The background AOIs are placed in a circle 
%          around each reference AOI, and the data traces are recorded at
%          the reference AOI sites).

% Copyright 2018 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.

StdDev=BaselineStdDev ;      % Standard deviation of the trace baseline 
%StdDev=get(handles.StdDev,'Value');       % standard deviation of a typical reference AOI
                            % The user must have obtained this value by using 'detrend trace' 
                            % followed by 'set mean/std frame range' in the plotargout gui
if StdDev>0
    % Here if the user has obtained a value for a typical reference AOI standard deviation
    logik=abs(RefTraceMinusBkgnd(:,2))<2.5*StdDev;       % Pick out the part of the trace that is close to zero
    BaselineData=RefTraceMinusBkgnd(logik,:);       % [(frm #)  intensity]
    [roseBase colBase]=size(BaselineData);
    [roseRef colRef]=size(RefTraceMinusBkgnd);
    if roseBase>roseRef/5
        % Here if our BaselineData set contains at least 20% of the number
        % of points that are in the RefTraceMinusBkgnd trace
        mnRef=min(RefTraceMinusBkgnd(:,1));  % minimum frame number contained in RefTraceMinusBkgnd
        if BaselineData(1,1)~=RefTraceMinusBkgnd(1,1);  
                    % Here if our BaselineData does not contain data from
                    % the first frame of RefTraceMinusBkgnd
                    
            % Extend first data point in BaselineData down to minimum frame contained in RefTraceMinusBkgnd 
            % Add a line [(first frame in RefTraceMinusBkgnd)  (First data value in BaselineData)]  
             BaselineData=[RefTraceMinusBkgnd(1,1) BaselineData(1,2); BaselineData  ];
        end
        
   
   
        mxBase=max(BaselineData(:,1));   % maximum frame number in our BaselineData set
        mxRef=max(RefTraceMinusBkgnd(:,1)); % maximum frame number contained in RefTraceMinusBkgnd
         mnRef=min(RefTraceMinusBkgnd(:,1));    % ***line from Debi
        if mxBase~=mxRef
                 % Here if our BaselineData does not contain data from
                 % the maximum frame of RefTraceMinusBkgnd
            logik1=mxBase==BaselineData(:,1);       % Pick out the line w/ maximum frame #
            % Extend first last point in BaselineData up to final frame contained in RefTraceMinusBkgnd 
            % Add a line [(last frame in RefTraceMinusBkgnd)  (last data value in BaselineData)] 
                        % Next line removed by Debi
            %BaselineData=[BaselineData;  RefTraceMinusBkgnd(mxRef,1) BaselineData(logik1,2) ];
                         % Next line from Debi
            BaselineData=[BaselineData;  RefTraceMinusBkgnd(mxRef-mnRef+1,1) BaselineData(logik1,2) ];
        end
        
        % Now we use BaselineData to interpolate points all along the trace
        SmoothedBaselineTrace=interp1(BaselineData(:,1),BaselineData(:,2),RefTraceMinusBkgnd(:,1));
        % We now want to smooth the resulting trace, and subtract it from
        % the starting trace to remove the residual
        SGSmooth=[2 max([201 round(roseRef/5)])];   % Make Smoothing window at least 201 points
        SGSmooth(2)=min([SGSmooth(2) round(roseRef/2)]);   % But Smoothing window no larger than length of trace/2
        if (SGSmooth(2)/2)==round(SGSmooth(2)/2)
        % Here if even (must be odd)
            SGSmooth(2)=SGSmooth(2)-1;
        end
    % Now smooth the baseline trace
        
        SmoothedBaselineTrace=sgolayfilt(SmoothedBaselineTrace,2,SGSmooth(2));
    % Now subtract the baseline trace from the input RefTraceMinusBkgnd trace
    %keyboard
        pc=[RefTraceMinusBkgnd(:,1) RefTraceMinusBkgnd(:,2)-SmoothedBaselineTrace];
    else
            % Here if BaselineTrace does NOT contain at least 20% of the number
        % of points that are in the RefTraceMinusBkgnd trace (in which case
        % we do not attempt to smooth and subtract
        pc=RefTraceMinusBkgnd;
    end
else
    % Here if the user has not obtained a standard deviation of a reference AOI trace
    % (in which case we cannot smooth and subtract)
    pc=RefTraceMinusBkgnd;
end
