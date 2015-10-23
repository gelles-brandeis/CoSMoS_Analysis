function pc=smooth_trace(input_trace, stdThreshold, SG_Filter_Order, SG_Frame_Fraction)
%
% function smooth_trace(input_trace, stdThreshold, SG_Filter_Order, SG_Frame_Fraction)
%
% This will provide a baseline for an input trace.  It is intended to be a
% smoothed background that will be subtracted off the input trace so as to
% obtain a baseline with a mean close to zero.  We will use nearby control
% AOIS to form this smoothed trace, then subtract off the control baseline
% line (obtained through this function) to obtain a trace with a baseline
% near zero throughout.
%
% input_trace==[M x 2]  [(frame number) (integrated intensity)] input trace
% stdThreshold== e.g. =3 this function will smooth the part of the trace that is
%          within a factor of stdThreshold*(standard deviation) of the
%          trace mean    i.e. that part of the trace for which the
%          following is true:
%             abs(input_trace(:,2)-mn)<stdThreshold*smn
%      where mn=mean(input_trace(:,2), and smn=std(input_trace(:,2));
%SG_Filter_Order= savitsky golay filter order, e.g. =2 for quadratic
%          function smoothing of the specified window
%SG_Frame_Fraction = e.g. 0.25 for using 25% of the length of the entire
%        trace as a window size for smoothing by the savitsky-golay filter

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

dumdatt=input_trace;        % Dummy holde for the trace
mn=mean(dumdatt(:,2));            % mean of trace
smn=std(dumdatt(:,2));
logik=abs(dumdatt(:,2)-mn)<stdThreshold*smn;   % pick part of trace that
                                        % does not deviate from the mean by
                                        % more than stdThreshold*smn
goodFrac=sum(logik/length(dumdatt(:,2)));    % Fraction of the curve that
                                % satisfies above criterion.  Use this to
                                % judge whether one wishes to use this
                                % trace as a background
    
dumdatt(~logik,2)=mn;       % Replace outlier sections of the trace with the trace mean
sdumdatt=dumdatt;           % Will eventually be the smoothed trace
ln=length(dumdatt(:,2));    % Length of trace
smoothWindow=round(ln*SG_Frame_Fraction);  % Size of window to use in smoothing
if smoothWindow/2==round(smoothWindow/2)
    smoothWindow=smoothWindow+1;            % Here if smoothWindow is even (in which case we make it odd)
end
            % smoothWindow is now odd (as it must be)

sdumdatt(:,2)=sgolayfilt(sdumdatt(:,2),SG_Filter_Order,smoothWindow);    % Smoothing baseline for output
pc.smooth_input=sdumdatt;       % smoothed input trace
pc.goodFrac=goodFrac;           % Fraction of the input trace that is NOT outlier
                                % Use this as a criterion for whether the
                                % trace is suitable for use as a background
                                
                                
                                
% Next:  inside plotargout allow loading a control set of aoifits
% Specify # of closest traces, value for goodFrac (use defaults of 2 for
% SG_Fiter_Order and maybe 0.25 for SG_Frame_Fraction, 3 for stdThreshold.
% Then create another member of the aoifits structure that will be
% background subtracted traces.
% Re-do above so the function makes a first pass through the trace just
% smoothing with a savitsky-golay of order 2 over mayby 0.1 fraction (to
% remove e.g. a decaying baseline).  Then apply the thresholding to get rid
% of the outlier pulses.
% load P:\matlab12\larry\data\B30p145i.dat -mat for some example GreB
% traces