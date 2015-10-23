function pc=Bin01TraceGaussian(parenthandles, aoifits_data, radius, amplitude, aoiinfo2, aoinumber, radius_hys, amp_hys )
%
% function  Bin01TraceGaussian(parenthandles, aoifits_data, radius, amplitude, aoiinfo2, aoinumber, radius_hys, amp_hys) 
% 
% This function will process a gaussian fit data trace in order to produce 
% a binary trace of high/low = one/zero = 1/0.  The function will score a high
% value (=1) whenever the gaussian parameters are such that the fit
% amplitude is above the value set by the input arguement 'amplitude', AND
% the xy position of the fit gaussian is within a distance of 'radius' from
% the center of the AOI.
%
% parenthandles == handles structure containing members: DriftList,
%                  StartParameters
% aoifits_data == aoifits.data, the member of the aoifits structure containing the data
%            traces.  The program will also work if just the single
%            matrix containing the data with the one AOI of interest is placed
%            here.
% radius == distance from AOI center in pixel.  The gaussian center must be
%           within a distance of 'radius' pixels from the AOI center to score 
%           as a one (= 1 = high) for that frame.
% amplitude == threshold amplitude of the gaussian.  The gaussian amplitude
%           must be greater than 'amplitude' in order to score as a one (=1
%           = high) for that frame).
% aoiinfo2 ==[(frm# when marked)  ave  x  y  pixnum  aoi#] matrix describing the
%            set of AOIs being processed, and includes the AOI being
%            processed by this function call
% aoinumber == index into aoiinfo2 that identifies which AOI in the list is
%            being processed by this call to the function.
% radius_hys == radius hysterisis factor:  A high state will not go low
%             until the [(gaussian center) - (AOI center)] distance exceeds
%             radius*radius_hys
% amp_hys == amplitude hysterisis factor:  A high state will not go low
%            until the amplitude drops below amplitude*amp_hys 

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

logik=aoifits_data(:,1)==aoinumber;
dat=aoifits_data(logik,:);      % Pulls out just the data for the curren AOI being processed
logik=aoiinfo2(:,6)==aoinumber;     % Find row of aoiinfo2 with this AOI
xycoordzero=aoiinfo2(logik,3:4);   % [x y] coordinate of our AOI
FrameRange=dat(:,2);              % List of frame numbers in the data list for our AOI
pc=[FrameRange zeros(length(FrameRange),1)];    % Initialize binary output trace as all zeros
RadHighLow=0;                 % Initialize hysterisis detectors for both the (gauss center)-(AOI center) distance
AmpHighLow=0;                 % and the gaussian amplitude

for frmindx = 1:length(FrameRange)
                    % Cycle through all frames
    OptionalXYshift=[0 0];        % Initialize shift of AOI center due to drift
%if 2>1   
    if any(get(parenthandles.StartParameters,'Value')==[2 3 4])
  
                                    % Here if we are in a 'moving aoi mode'
   
                                    % Setting AOI offset if we are in
                                    % moving AOI mode
       OptionalXYshift=ShiftAOI(aoinumber,FrameRange(frmindx),aoiinfo2,parenthandles.DriftList);
    end
    xycoord=xycoordzero+OptionalXYshift;     % This will be [x y] coordinates of our AOI, shifted if necessary
    logik=dat(:,2)==FrameRange(frmindx);
    currentdat=dat(logik,:);        % Pick out line of gaussian fit data for this frame
                                    %[  1:aoinumber   2:framenumber    3:amplitude    4:xcenter   5:ycenter    6:sigma   7:offset  
                                    %    8: integrated_aoi       9:(integrated pixnum)    10:(original aoi#)]
                                    
                                    % Now, compute the distance between the
                                    % gaussian center and the AOI center
    distance = sqrt( sum( ( xycoord-currentdat(4:5) ).^2 ) ) ;
                    % Test whether there was a spot in our AOI for this frame 

    if (distance<=radius) & (currentdat(3)>=amplitude)
                % Here if there was a gaussian spot landing in our AOI and
                % both the amplitude and spot center satisfied our criteria
                % for a spot landing
        RadHighLow=1;
        AmpHighLow=1;
        pc(frmindx,2)=1;        % Score this frame as a high (=1)
    elseif (RadHighLow==1) &( AmpHighLow==1) & (distance<=radius*radius_hys) & (currentdat(3)>=amplitude*amp_hys)
                      % Here if the last frame was high and this frame
                      % satisfies only a relaxed criteria (hysterisis) for
                      % being in a high state
                     
        pc(frmindx,2)=1;        % Continue to Score this frame as a high (=1)
    else
        RadHighLow=0;       % Dropped into a low state, so we reset the hysterisis detectors
        AmpHighLow=0;
    end
end


    
