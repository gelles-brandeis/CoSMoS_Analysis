function pc=ColorColocalizations_plotargout_Bottomaxes3(dat,cia,AOInum,LowColor,HighColor,offset, fignum, handles)
% function ColorColocalizations_plotargout_Bottomaxes3(dat,cia,AOInum,LowColor,HighColor, offset, fignum, handles)
%  
% For use only within the plotargout sub-gui of imscroll
% Plots integrated traces with different colors for the baseline (no
% co-loclaization) and co-localization intervals
%
% dat == m x n x (number of AOIs), integrated trace data made using aoifits
%      (from imscroll) and dat=extract_aoifits_aois(aoifits);
%
% cia == Intervals.CumulativeIntervalArray, summarizes the detected
%       co-localizations in the same traces contained in the dat variable
% AOInum == AOI number to be plotted
% LowColor== color for the trace during baseline (non-colocalization)
%        intervals.  e.g. [.5 .5 .5] is gray, [0 0 0] is black
% HighColor == color for the trace during the co-localization intervals
%        e.g. [1 0 0] is red, [0 1 0] is green, [0 0 1] is blue
% offset == y axis offset of the trace.  e.g. offset = 1000 will move the
%        y values for the trace high by 1000
% handles == handles structure used within the plotargout gui

% Copyright 2022 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.

%figure(fignum);clf;hold on   % Clear the current figure
figure(fignum);clf;hold off
%keyboard
axes(handles.axes3);hold off
logik=cia(:,7)==AOInum;
subcia=cia(logik,:);         % picks out lines for this AOI
            % Pick out low intervals in this cia
logikl=(subcia(:,1)==2)|(subcia(:,1)==0)|(subcia(:,1)==-2);
lowcia=subcia(logikl,:);     % Contains cia lines with low states for this AOI
  [lowrose lowcol]=size(lowcia);     % Defines number of low (non co-localization) intervals when rose>0
[rosedat coldat numdat]=size(dat);
indxdat=[1:rosedat]';         % Vector of the indices for the rows in the dat matrix
if lowrose>0
    for frmslow=1:lowrose
                % Get the index in the dat array corresponding to the starting frame number for this interval  
        logikfrms2indxStart=lowcia(frmslow,2)==dat(:,2,AOInum);
        StartindxL=indxdat(logikfrms2indxStart);
                % Get the index in the dat array corresponding to the ending frame number for this interval  
        logikfrms2indxEnd=lowcia(frmslow,3)==dat(:,2,AOInum);
         EndindxL=indxdat(logikfrms2indxEnd);
                % Plot one low interval for this AOI
        figure(fignum);plot(dat(StartindxL:EndindxL,2,AOInum),dat(StartindxL:EndindxL,8,AOInum),'Color',LowColor);hold on
        axes(handles.axes3);
        plot(dat(StartindxL:EndindxL,2,AOInum),dat(StartindxL:EndindxL,8,AOInum)+offset,'Color',LowColor);hold on
        %figure(fignum);plot(dat(StartindxL:EndindxL,2,AOInum),dat(StartindxL:EndindxL,8,AOInum)+offset,'Color',LowColor);shg
    end
end
            % Pick out high intervals in this cia
logikh=(subcia(:,1)==3)|(subcia(:,1)==1)|(subcia(:,1)==-3);
highcia=subcia(logikh,:);     % Contains cia lines with high (co-localization) intervals for this AOI
 [rose col]=size(highcia);     % Defines number of high intervals when rose>0

if rose>0
    for indx=1:rose
                        % Get the index in the dat array corresponding to the starting frame number for this interval  
        logikfrms2indxStart=highcia(indx,2)==dat(:,2,AOInum);
        StartindxH=indxdat(logikfrms2indxStart);
        if StartindxH>1
            StartindxH=StartindxH-1;        % High interval connects to end of preceeding low interval
        end
                % Get the index in the dat array corresponding to the ending frame number for this interval  
        logikfrms2indxEnd=highcia(indx,3)==dat(:,2,AOInum);
        EndindxH=indxdat(logikfrms2indxEnd);
        if EndindxH<rosedat
            EndindxH=EndindxH+1;        % High interval connects to beginning of next low interval
        end
                % Plot one high interval for this AOI
         figure(fignum);plot(dat(StartindxH:EndindxH,2,AOInum),dat(StartindxH:EndindxH,8,AOInum)+offset,'Color',HighColor);hold on
         axes(handles.axes3);
         plot(dat(StartindxH:EndindxH,2,AOInum),dat(StartindxH:EndindxH,8,AOInum)+offset,'Color',HighColor);hold on
        %figure(fignum);plot(dat(StartindxH:EndindxH,2,AOInum),dat(StartindxH:EndindxH,8,AOInum)+offset,'Color',HighColor);shg
        
    end
end

 pc=1;
 %hold off
 
 
 % *******************