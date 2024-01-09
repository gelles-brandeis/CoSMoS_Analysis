function pc=SmoothBackground(Bkgndaoifits, SGsmooth, Refaoifits)
%
% function SmoothBackground(bkgndaoifits, SGsmooth, Refaoifits)
%
% Used to smooth the background traces recorded via imscroll gui by choosing
% AOIs made with an AOI grid followed by
% MapButton>'Remove AOIs Near AOIs' > 'Retain AOIs Near AOIs'.
% There will be several background AOIs associated with each reference AOI,
% and this routine will ave and smooth those background AOIs (removing bad
% outlier jumps in the background traces.
%
% Bkgndaoifits == aoifits structure (stored by imscroll) for the background
%            AOIs chosen using the  Remove/Retain AOIs Near AOIs operations
% AOInums == 1 x N vector list of AOIs for which the function will obtain
%            smoothed background traces.  There is a reference set of AOIs
%            and each background trace is associated with one of the
%            reference AOIs.  This list of AOInums refers to the index
%            running over the reference AOIs.
% SGsmooth == [ SG_PolyOrder   SG_Frames]  parameter for Savitsky-Golay 
%            smoothing of background traces, where
% SG_PolyOrder==   parameter specifying the order of polynomial 
%               used in Savitsky-Golay smoothing 
% SG_Frame ==   parameter specifying the window size (number of points) used
%              for Savitsky-Golay smoothing.  (must be odd) e.g. = 41 

% Copyright 2016 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.

% Protocol:   Our Reference AOIs (Refaoifits) are circled by several close
% background AOIs (Bkgndaoifits).  We first average the data trace from the
% background AOIs, and smooth that averaged trace.  The background traces
% might still show nonspecific landings or dirt noise we would like to
% avoid so we find the one background trace that deviates the least from
% the smoothed average background trace, hoping that one trace will then be
% absent of nonspecific protein landings or dirt landings.  That one chosen
% background trace is then smoothed (Savitsky-Golay) and we subtract that
% smoothed background trace from the reference data trace, yielding the 
% TraceDiffRef variable.  That background-subtracted trace will usually
% have a baseline (so long as the reference trace is not mostly in the high
% state), which is now close to zero.  We calculate the (small) mean of that
% baseline and add it to (include it in) the smoothed background so that 
% when we form the (Referece data trace)-(smoothed background trace) then
% the result has a baseline that will be zero (or as close as we can
% arrange to it being zero).




RefaoifitsMinusBkgnd=Refaoifits;      % Save space for output.  We will  
                                    % later (below) replace) the data traces.
RefaoifitsMinusBkgnd.Bkdata=Refaoifits.data;  % Replicate the data list.  We

                                   % will replace these with the final
                                   % smoothed background traces that we use
AOInums=Refaoifits.aoiinfo2(:,6);   % List of AOI numbers in our reference Refaoifits

for indxroot=AOInums'
            % Cycle through all the reference AOIs
    if indxroot/20==round(indxroot/20)
        indxroot
    end
    refAOInum=AOInums(indxroot);           % Identifies the referece AOI for which we 
                                % will fetch and smooth background traces

        % Pick out the aoiinfo2 list of background AOIs that pair with the
        % current value of reference AOI

    Bkgndaoiinfo2=Bkgndaoifits.aoiinfo2(Bkgndaoifits.RefAOINearLogik{refAOInum},:);
    [rose col]=size(Bkgndaoiinfo2);     % rose=# of background AOIs in this list
    if col>0
        logik=Bkgndaoifits.data(:,1)==Bkgndaoiinfo2(1,6);   % Pull out the integrated
                                % trace for the first AOI in our list
        dat1=Bkgndaoifits.data(logik,:);    % All data rows for first AOI in our list,
                                    % so the rows of dat1 cover all the
                                    % frames of data for this AOI
    else
        error('No background AOIs for ref AOI number %i',refAOInum)
    end
    [rosedat coldat]=size(dat1);
    dat=zeros(rosedat,coldat,rose);      % Save space for the integrated traces of the bkgnd AOIs in our list
    for indx=1:rose
                % Cycle through the AOIs in our Bkgndaoiinfo2 list,
                % fetching the integrated traces for each
        logik=Bkgndaoifits.data(:,1)==Bkgndaoiinfo2(indx,6);
        dat(:,:,indx)=Bkgndaoifits.data(logik,:);   % Storing the data traces for the background AOIs
                                % associated with reference AOI number refAOInum 
 
    end
    AveBkgndData=dat(:,:,1);       % Create data matrix containing list of frame numbers and data
                    % (# of rows)=# of frames of data in the sequence
    AveBkgndData(:,8)=sum(dat(:,8,:),3)/rose;  % Substitute average of all the background traces
                                  % into the integrated trace column
                     % rose = # of bkgnd AOIs for the current reference AOI 


                        % Next, we want to SG smooth the ave trace, then
                        % pick single background trace that produces the
                        % smallest standard dev for the trace:
                        % (bkgnd trace) - (smoothed ave background trace)
    SmoothedAveTrace=sgolayfilt(AveBkgndData(:,8),SGsmooth(1),SGsmooth(2));
            % Find the background trace with the smallest deviation from
            % the smoothed background trace.
    SDvalues=zeros(rose,1); %  Here we will store the std dev values for each 
                        % (bkgnd trace) - (smoothed ave background trace)
              % rose = # of bkgnd AOIs for the current reference AOI 

    for indx1=1:rose
            % rose = # of bkgnd AOIs for the current reference AOI, so
            % we cycle through all the bkgnd AOIs for the current
            % reference AOI
            % Calculate std for the difference between each averaged
            % background trace and the averaged background trace
        SDvalues(indx1,1)=std(dat(:,8,indx1)-SmoothedAveTrace);
    end
    [mnSD I]=min(SDvalues);    % I provides the index of the minimum value
                % mnSD is the minimum standard deviation for differences
                % between the averaged smoothed background trace and all
                % the unsmoothed background traces.

                    % Smooth the single background trace that has the smallest
                    % deviation from the smoothed average of all background
                    % traces.
    SmoothedAveTraceAll=sgolayfilt(dat(:,8,I),SGsmooth(1),SGsmooth(2));

                    % Next, look at how each bkgnd trace does in bringing
                    % the baseline of the reference trace close to zero


    logik=Refaoifits.data(:,1)==refAOInum; % reAOInum is the current reference AOI number that we are
                            % currently operating on (to remove the baseline offset) 
    Refdat=Refaoifits.data(logik,:);        % Pick out data for the reference AOI
    TraceDiffRef=Refdat(:,8)-dat(:,8,I);
    logikRef=abs(TraceDiffRef)<3*mnSD;      % % Keep only points close to zero (w/in 3*std dev of bkgrnd trace from above)
               % **************This is likely catching too much of the
               % trace, resulting in our sometimes offset of the trace.
               % May need to reduce 3->2 ? or even just suppress this
               % entirely......Why are we having an offset, anyway?

    % Skip over next part: decided not to use sum of squares criterion

%if sum(logikRef)>SGsmooth(2)            % Use baseline sum of squares only if there are enough baseline pts close to zero
%    SumofSquares=zeros(rose,1); % Here we will store the sum of squares
%    for indx2=1:rose
%        TraceDiff=Refdat(:,8)-dat(:,8,indx2);   % Subtract off a background trace
%        SumofSquares(indx2,1)=sum(TraceDiff(logikRef).^2);
%    end
%    [SoS Isos]=min(SumofSquares);       % Identify background trace producing min sum of squares of baseline
%    SmoothedAveTraceAll=sgolayfilt(dat(:,8,Isos),SGsmooth(1),SGsmooth(2));  % Smooth that background trace 
%end
% If sum(logikRef>SGsmooth(2)) is FALSE, we jump here w/o
% using the sum of squares criterion, and our output will be (from
% above) the smoothed background trace that has the smallest
% deviation from the smoothed average of all background
% traces.
    

        % We next subtract off the mean of the remaining
        % baseline 
        % We can really only do this when 
        % we are convinced that a real baseline exists (i.e. the
        % trace is not at a 'high' value for the entire trace

    if sum(logikRef)>SGsmooth(2)
        % Here if the number of baseline points exceeds window size for S-G smoothing (TRUE unless the
        % reference trace is mostly in the high state)
        % Subtract off the residual mean of the baseline (should be small)
        % from the smoothed average trace.
        BkgrndTrace=SmoothedAveTraceAll+mean(TraceDiffRef(logikRef));    % Smoothed background for this reference AOI
        RefTraceMinusBkgnd=Refdat(:,8)- BkgrndTrace;       % Background corrected (Reference data trace)
    else
        % When sum(logikRef)>SGsmooth(2) is FALSE we do not subtract off
        % the mean of the residual baseline (b/c baseline too small in
        % length) and instead just use the smoothed background as
        % calculated above
        BkgrndTrace=SmoothedAveTraceAll;                    % Smoothed background for this reference AOI
        RefTraceMinusBkgnd=Refdat(:,8)- BkgrndTrace;       % Background corrected (Reference data trace)
    end
    logik=Refaoifits.data(:,1)==refAOInum;      % Find all data trace entries for current reference AOI number
    RefaoifitsMinusBkgnd.data(logik,8)=RefTraceMinusBkgnd;    % Replace the data entries for the current AOI
                                    % with background corrected data
    RefaoifitsMinusBkgnd.Bkdata(logik,8)=BkgrndTrace;

end
pc=RefaoifitsMinusBkgnd;        % Output an aoifits structure containing a pc.data with background
                    % corredted data, and pc.Bkdata containing a data
                    % listing with the smoothed background data.
    


