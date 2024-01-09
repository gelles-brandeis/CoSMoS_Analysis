function pc=RescaleTracesUsingBackground(Refaoifits,Bkgndaoifits,SGsmooth,parenthandles)
%
% function RescaleTracesUsingBackground(Refaoifits,Bkgndaoifits,SGsmooth,parenthandles)
% 
% Fluorescence intensity across a FOV can vary due to variations in laser excitation
% intensity.  This function takes the data traces from a reference aoifits
% (for a set a data AOIs) and uses the traces from the associated background 
% aoifits ('make bkgnd AOI circle') to correct the traces from reference
% aoifits for variations in the laser excitation.  This function will
% output an aoifits structure identical to Refaoifits except that data 
% traces will be substituted with the re-scaled data traces. 
%
% Bkgndaoifits == aoifits structure (stored by imscroll) for the background
%            AOIs chosen using the  'make bkgnd AOI circle' operations
% Refaoifits == aoifits structure (stored by imscroll) for the reference
%            AOIs.  It is the traces from these referece AOIs for which we
%            we seek correct for variations in the laser excitation across
%            a FOV.  THE LAST 4 AOIs in Refaoifits SHOULD BE OUTSIDE THE
%            VISIBLE FOV>  THESE WILL PROVIDE A MEASURE OF THE CAMERA
%            OFFSET (i.e. THE INTEGRATED INTENSITY WITH ZERO LASER
%            EXCITATION).
% SGsmooth == [ SG_PolyOrder   SG_Frames]  parameter for Savitsky-Golay 
%            smoothing of background traces, where
% SG_PolyOrder==   parameter specifying the order of polynomial 
%               used in Savitsky-Golay smoothing (e.g. 2 for a quadratic fit) 
% SG_Frame ==   parameter specifying the window size (number of points) used
%              for Savitsky-Golay smoothing.  (must be odd) (e.g. set to
%              maybe 1/5 the length of a trace)
% parenthandles== handles from the imscroll gui.  It is called
%              parenthandles inside the plotargout gui.  Inside the
%              plotargout gui we obtain it using
%              parenthandles = guidata(handles.parenthandles_fig); 
% 
% Original script in B34p92a.doc

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

%eqn to correct for excitation variation:
%equation  A: (Refaoifits-Bkgndaoifits)/ ( (Bkgndaoifits-AveOffsetTrace)/(Bkdgndaoifits-AveOffsetTrace)N)
% Protocol of function 
% (1) Run the SmoothBackground_v5 w/ Refaoifits and Bkgndaoifits?Subaoifits
% (2) average all the smoothed offset aoifits to obtain a single trace for the smoothed offset trace (zero excitation trace)
%   -->AveOffsetTrace
% (3) Calculate set of values for and the distribution of the median for(Bkgndaoifits-AveOffsetTrace) traces for all the AOIs
%  For each AOI, we find the median of the deviation of that AOI's smoothed background from the AveOffsetTrace  
%  --> MedBkgndValues,   mn=median(MedBkgndValues), median of all the median deviations     
% (4) Pick N = ref AOI # for the median of (Bkgndaoifits – AveOffsetTrace)  
% (5) We use the smoothed background trace corresponding to N in step (4)
% and define ScaleTrace=BkgndSmoothed(:,8,N)-AveOffsetTrace';
% The ScaleTrace is our universal trace for the deviation of a smoothed background
% trace from the aveOffsetTrace.  All other traces j are rescaled by having 
% their background-subtracted trace multiplied frame-by-frame a rescaling
% quantity according to eqn A above:
% (background-subtracted trace) = (background-subtraced trace).*  ... 
% (BkgndSmoothed(:,8,N)-AveOffsetTrace').*(BkgndSmoothed(:,8,j)-AveOffsetTrace').^(-1)  


%aoifits.dataDescription:
%[aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi (integrated pixnum) (original aoi#)]
%Intervals.CumulativeIntervalArrayDescription
%(low or high =-2,0,2 or -3,1,3) (frame start) (frame end) (delta frames) (delta time (sec)) (interval ave intensity) AOI#
        % step (1)
%Subaoifits=SmoothBackground_v2(Bkgndaoifits,SGSmooth, Refaoifits);	
Subaoifits=SmoothBackground_v5(Bkgndaoifits, SGsmooth, Refaoifits, parenthandles); % Smooth the background 
                                    %traces and subtract them from the data traces
                                    % Subaoifits.Bkdata = smoothed averaged background traces
                                    % Subaoifits.data = data aoi traces that are background subtracted

dumaoifits=Subaoifits;              % make a copy
dumaoifits.data=dumaoifits.Bkdata;	% Place smoothed traces into data member
BkgndSmoothed=extract_aoifits_aois(dumaoifits);     %== (trace length)x8x(number of AOIs) 
                                                % dat matrices containing the smoothed 
                                                % background traces for the reference
                                                % AOIs plus the 4 camera offset AOIs

OffsetTraces=[];			% 4 x (trace length), one row for each of the smoothed offset traces
aoinum=max(Refaoifits.data(:,1));    % Number of data AOIs +4, where the +4 arises due 
                                    % to the four final AOIs measureing camera offset
for indx=aoinum-3:aoinum
                            % Cycles through the last 4 data AOIs, 
                            % i.e. those AOIs measuring the camera offset
OffsetTraces=[OffsetTraces;BkgndSmoothed(:,8,indx)'];
end
        % Step (2)
AveOffsetTrace=mean(OffsetTraces);			% average the four offset traces, obtaining the 
							% offset trace we will use in our calculations
MedBkgndValues=[];
for indx=1:aoinum-4
                            % Cycle through all the data AOIs (do not use the final 4 AOIs
                            % b/c those are outside the visible FOV and are
                            % used just to measure the camera offset
MedBkgndValues=[MedBkgndValues;indx median(BkgndSmoothed(:,8,indx)-AveOffsetTrace')];
end
                % Step (3)
mn=median(MedBkgndValues(:,2));			% median of all the medians
[Y I]=min(abs(MedBkgndValues(:,2)-mn))		% Find the trace that yields closest to the 
                                    % median value deviation from the offset trace
                % Step (4)
N=I;			% This will be our ‘reference’ AOI for rescaling 
% all the other traces, N=134
ScaleTrace=BkgndSmoothed(:,8,N)-AveOffsetTrace';	% (trance length) x 1
                                                    % Serves as (Bkgndaoifits-offsetaoifits)N

SubRefdat=extract_aoifits_aois(Subaoifits);		% These contain the reference AOI data traces
                                            % that have had the smoothed background 
                                            % traces subtracted off
                                            % (trace length) x 8 x (number of AOIs = aoinum)    
ScaledRefdat=SubRefdat;			% Make a copy.  We will next substitute in the re-scaled 
                                % verstions of these traces using equation A
                                % (trace length) x 8 x (number of AOIs = aoinum)   

% Loop through all the background-subtracted data 
% traces, rescaling them according to equation A
%keyboard
RescalingFactors=zeros(length(AveOffsetTrace),2,aoinum); % [(Frmnumber) (RescalingFactor) (refaoinumber)]  
                        % Will store the frame-by-frame
                        % rescaling factors for each reference trace

for indx=1:aoinum
    
%ScaledRefdat(:,8,indx)= ScaledRefdat(:,8,indx).*( (BkgndSmoothed(:,8,indx)-AveOffsetTrace').* ScaleTrace.^(-1)).^(-1);
RescalingFactors(:,:,indx)=[BkgndSmoothed(:,2,indx) ScaleTrace.*(BkgndSmoothed(:,8,indx)-AveOffsetTrace').^(-1)];
ScaledRefdat(:,8,indx)=ScaledRefdat(:,8,indx).*RescalingFactors(:,2,indx);
end


% Now, for the output we duplicate the Refaoifits and substitute the
% re-scaled, background-subtracted data for the original data
% However, note that the data is not sorted in the same manner as the
% original rows of the Refaoifits.data matrix (which should not matter)
% NO:  now the sorting is the same as originally in Refaoifits.data
pc=Refaoifits;
%pc.data=[];

for indx=1:aoinum
    logik=pc.data(:,1)==indx;       % Pick out data for the reference AOI
    pc.data(logik,:)=ScaledRefdat(:,:,indx);    %Replace the data entries for the current AOI
                                                % with the re-scaled, background-subtracted data 
    %pc.data=[pc.data;ScaledRefdat(:,:,indx)];
end

pc.Bkdata=Subaoifits.Bkdata;      % Contains the smoothed averaged background data, 2D matrix
pc.AveCameraOffsetTrace=AveOffsetTrace;
pc.SmoothedBackgroundTraces=BkgndSmoothed;  % Smoothed bkgnd traces, (frms)x8x(aoinum)
pc.SmoothedBackgroundReferenceAOInumber=N;  % AOI number whose smoothed background trace
        % is our reference background.  All traces are rescaled to reflect the 
        % laser intensity indicated by the difference btwn this AOI 
        % smoothed background trace and the AveCameraOffsetTrace
        % For rescaling, each trace j is frame-by-frame multipled by:
% (pc.SmoothedBackgroundTraces(:,8,N)-pc.AveCameraOffsetTrace).*...
%       (pc.SmoothedBackgroundTraces(:,8,j)-pc.AveCameraOffsetTrace)
pc.RescalingFactors=RescalingFactors;       % [(frmnumber) (RescalingFactor) (aoinum)]        
        
% add the AveCameraOffsetTrace = AveOffsetTrace
% add N=smoothed background trace index that is our reference background 
%       All traces are rescaled to reflect the laser intensity indicated
%       by the difference btwn this AOI smoothed background trace and the
%       AveCameraOffsetTrace
% add smoothed background traces: aoinum x 8 x 3 matrix
% add frame-by-frame rescaling multiplier for traces, or just the formula
%      used to create rescaled traces

% AveOffsetTrace     == 1 x (trance length) offset trace (ave of the 4) used to indicate the camera output when there is 
% zero input
% 
% BkgndSmoothed  == (trace length) x8x(aoi number) dat matrices containing the smoothed background traces for the 280 reference 
% AOIs plus the 4 camera offset AOIs
% 
% Bkgndaoifits	== (aoifits structure)  for the background aois from the circle of 
%  aois surrounding each data aoi
% 
% MedBkgndValues	== (aoi number -4) x2 [aoi#   median deviation of (smoothed background)-(camera offset trace=AveOffsetTrace]
% 
% OffsetTraces		==4x(trace length)  four camera offset traces for the four AOIs outside the visible FOV
% 
% Refaoifits	==(aoifits structure) for the data AOIs + 4 camera offset AOIs
% 
% ScaleTrace == (trace length) x 1) BkgndSmoothed(:,8,N)-AveOffsetTrace', 
% this trace indicates the background value above the camera offset (i.e. above the AveOffsetTrace)
% 
% SubRefdat  == (trace length) x8x (aoi nubmer)       These contain the reference AOI data traces that have had the smoothed 
% background traces subtracted off
% 
% ScaledRefdat ==(trace length) x8x (aoi number)  The data traces from SubRefdat now re-scaled using equation A to 
% compensated for variations in the laser excitation across the FOV
% 
% Subaoifits == (aoifits structure) output from SmoothBackground_v2 containing smoothed 
% background traces and reference AOI data traces that have had the smoothed 
% background traces  subtracted off from them




