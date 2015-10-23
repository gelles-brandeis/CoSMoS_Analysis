function pc=RemoveBaseDrift_1D(InputTrace,FrameRange)
%
% function RemoveBaseDrift(InputTrace,FrameRange)
%
% Will create a SmoothedInputTrace that will be subtracted from InputTrace.
% Will be used to remove very slow drift in the baseline of data InputTrace 
% in which we are attempting to detect dye-protein landing events.  The user
% must feed in frame intervals and this function will use a Savitzky-Golay
% filter to smooth those intervals and subtract the smoothed result from
% the InputTrace.  The filter will use a window about 1/3 the size of the
% frame intervals so as to remove only 3 to 4 broad features from within
% each specified interval.  Between the specified intervals the SmoothedInputTrace
% will be connected by a staight line.  Going from the InputTrace beginning to the
% first interval, the SmoothedInputTrace will be a constant.  Also, from
% the last interval to the end of file the SmoothedInputTrace will be a
% constant.    Output will be InputTrace-SmoothedInputTrace.
%
% InputTrace == 1 x N input vector that will be smoothed by this function
%
% FrameRange == [framelow  framehigh]  Mx2 matrix specifying frame
%       intervals over which this function will smooth the InputTrace using a 
%       Savitzky-Golay filter (window size about (1/3)*(framehigh-framelow)
%       for each frame interval.
%
% SmoothedInputTrace == internal variable that will be the smoothed version
%       of the InputTrace vector.
%
% Output:     pc.DetrendedTrace=InputTrace-SmoothedInputTrace;
%             pc.SmoothedInputTrace=SmoothedInputTrace;


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


ITlength=length(InputTrace);
if isempty(FrameRange)
    FrameRange=[1 ITlength];        % Smooth entire array if no FrameRange is specified
end
[FRrows FRcol]=size(FrameRange);
                        % Start with zeroed array
SmoothedInputTrace=zeros(size(InputTrace));

                        % Sort first column of FrameRange
[dum I]=sort(FrameRange(:,1));
                        % Make the FrameRange intervals in ascending order
FrameRange=FrameRange(I(:,1),:);
% First, apply the quadratic Savitzky-Golay filter to the specified intervals
for indx=1:FRrows
                        % set window length to be equal to 1/3 the number
                        % of points in the interval
    window=floor((FrameRange(indx,2)-FrameRange(indx,1))/3);
                        % Make window an odd integer
    if window/2==round(window/2)
        window=window+1;
    end

    SmoothedInputTrace(FrameRange(indx,1):FrameRange(indx,2))=...
                      sgolayfilt(InputTrace(FrameRange(indx,1):FrameRange(indx,2)),2,window);
end
    % Next deal with the beginning and end of SmoothedInputTrace
if 1<FrameRange(1,1)
                        % If intervals do not include trace beginning, make
                        % the SmoothedInputTrace=const until the first
                        % interval
    SmoothedInputTrace(1:FrameRange(1,1)-1)=SmoothedInputTrace(FrameRange(1,1));
end
if FrameRange(FRrows,2)<ITlength
                        % If last interval does not include trace end, make
                        % the SmoothedInputTrace=const until the end of
                        % the array
    SmoothedInputTrace(FrameRange(FRrows,2)+1:ITlength)=SmoothedInputTrace(FrameRange(FRrows,2));
end

% Next connect the intervals in between the FrameRange segments with
% straight lines
if FRrows>1            % only do this if we have more than one interval
    for indx=1:FRrows-1
                       % Number of points between the indx and indx+1 intervals
        diffx=FrameRange(indx+1,1)-FrameRange(indx,2);
        if diffx>1
                       % Here if there are points between the indx and
                       % indx+1 intervals -> now fill in with a straight
                       % line
                       
                       % Work between end of one interval and beginning of
                       % next interval
            Ystart=SmoothedInputTrace(FrameRange(indx,2));
        
            diffy=SmoothedInputTrace(FrameRange(indx+1,1))-SmoothedInputTrace(FrameRange(indx,2));
      
            SmoothedInputTrace(FrameRange(indx,2)+1:FrameRange(indx+1,1)-1)=...
                Ystart+ diffy*[1:(diffx-1)]/diffx;
        end
    end
end
% Now we have formed the entire SmoothedInputTrace.  Just subtract it from
% the InputTrace and you're done
keyboard
pc.DetrendedInputTrace=[InputTrace(:,1) InputTrace-SmoothedInputTrace];
pc.SmoothedInputTrace=[InputTrace(:,1) SmoothedInputTrace];


        