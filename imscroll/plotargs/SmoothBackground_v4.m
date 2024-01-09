function pc=SmoothBackground_v4(Bkgndaoifits, SGsmooth, Refaoifits, varargin)
%
% function SmoothBackground_v4(bkgndaoifits, SGsmooth, Refaoifits, <parenthandles>)
%
% Used to smooth the background traces recorded via imscroll gui by choosing
% AOIs made with 'make bkgnd AOI circle'
% There will be several background AOIs associated with each reference AOI,
% and this routine will ave and smooth those background AOIs (removing bad
% outlier jumps in the background traces.
%
% Bkgndaoifits == aoifits structure (stored by imscroll) for the background
%            AOIs chosen using the  'make bkgnd AOI circle' operations
% AOInums == 1 x N vector list of AOIs for which the function will obtain
%            smoothed background traces.  There is a reference set of AOIs
%            and each background trace is associated with one of the
%            reference AOIs.  This list of AOInums refers to the index
%            running over the reference AOIs.
% Refaoifits == aoifits structure (stored by imscroll) for the reference
%            AOIs.  It is the traces from these referece AOIs for which we
%            we seek to subtract a background.  Once the background is 
%            subtracted, the trace baseline should be at zero.
% SGsmooth == [ SG_PolyOrder   SG_Frames]  parameter for Savitsky-Golay 
%            smoothing of background traces, where
% SG_PolyOrder==   parameter specifying the order of polynomial 
%               used in Savitsky-Golay smoothing 
% SG_Frame ==   parameter specifying the window size (number of points) used
%              for Savitsky-Golay smoothing.  (must be odd) e.g. = 41 
% Output.data == data member same as Refaoifits.data, but the output has
%             had the smoothed background trace subtracted off
% Output Bkdata == a data listing containing the smoothed background data
% v4  This version differs from version 2 in that we fit the integrated
%    intensity values from the background AOIs to a plane in order to
%    determine the appropriate background value at the reference AOI.  In
%    version 2 we were just averaging the values from the background AOIs
%    to determine the background value at the reference AOI.

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

% Protocol:   Our Reference AOIs (Refaoifits) are circled by several close
% background AOIs (Bkgndaoifits).  We first average the data trace from the
% background AOIs, and smooth that averaged trace.  The background traces
% might still show nonspecific landings or dirt noise we would like to
% avoid so we frame-by-frame compute the std dev of the background AOI values
% We then compute the mean value of that std dev along the trace. = MeanStd
% We then re-compute the average background trace, eliminating outliers
% (that deviate from the prior average trace by more than 4*MeanStd).  That
% re-computed average is then smoothed and subtracted from the data AOI
% trace.

inlength=length(varargin);
                                                % Grab the handles structure 
                                                % parameters, if present
if inlength>0
    parenthandles=varargin{1}(:);        % Will be needed to determine xy shifts
                                         % in the positions of the
                                         % reference and background AOIs
                                         % when we fit to a plane.
    
end


RefaoifitsMinusBkgnd=Refaoifits;      % Save space for output.  We will  
                                    % later (below) replace) the data traces.
RefaoifitsMinusBkgnd.Bkdata=Refaoifits.data;  % Replicate the data list.  We

                                   % will replace these with the final
                                   % smoothed background traces that we use
AOInums=Refaoifits.aoiinfo2(:,6);   % List of AOI numbers in our reference Refaoifits
AOIsWithoutBkgndSubtraction=[];     % Will store a list of those reference AOIs for which
                                    % we are unable to subtract a background (b/c there are
                                    % no neighboring AOIs associated with them in the
                                    % background AOI set we chose).




for indxroot=AOInums'
  
            % Cycle through all the reference AOIs
    if indxroot/20==round(indxroot/20)
        indxroot
    end
    
    refAOInum=AOInums(indxroot);           % Identifies the referece AOI for which we 
                                % will fetch and smooth background traces
    logikRef=Refaoifits.aoiinfo2(:,6)==refAOInum;   % Picks out one line of Refaoiinfo2 matrix
    Refaoiinfo2sub=Refaoifits.aoiinfo2(logikRef,:);
    
        % Pick out the aoiinfo2 list of background AOIs that pair with the
        % current value of reference AOI
                            %[(framenumber when marked) ave x y pixnum aoinumber]
    Bkgndaoiinfo2=Bkgndaoifits.aoiinfo2(Bkgndaoifits.RefAOINearLogik{refAOInum},:);
    [rose col]=size(Bkgndaoiinfo2);     % rose=# of background AOIs in this list
    
    if rose>0
          
            % Here if we are able to subtract background AOIs for the current
            % reference AOI specified by refAOInum=AOInums(indxroot)
        logik=Bkgndaoifits.data(:,1)==Bkgndaoiinfo2(1,6);   % Pull out the integrated
                                % trace for the first AOI in our list
        dat1=Bkgndaoifits.data(logik,:);    % All data rows for first AOI in our list,
                                    % so the rows of dat1 cover all the
                                    % frames of data for this AOI
                                  
        [rosedat coldat]=size(dat1);        % rosedat == # of frames in a data trace,  rose==# of background AOIs in this list
        dat=zeros(rosedat,coldat,rose);      % Save space for the integrated traces of the bkgnd AOIs in our list
        datonly=zeros(rose,rosedat);        % Will save just the integrated data.  One trace along each row
                            % rosedat = # of frames in a data trace
        for indx=1:rose
                % Cycle through the AOIs in our Bkgndaoiinfo2 list,
                % fetching the integrated traces for each
            logik=Bkgndaoifits.data(:,1)==Bkgndaoiinfo2(indx,6);
            dat(:,:,indx)=Bkgndaoifits.data(logik,:);   % Storing the data traces for the background AOIs
                                % associated with reference AOI number refAOInum 
            datonly(indx,:)=dat(:,8,indx)'; % Data trace stored in a row
 
        end
        frames=dat(:,2,1);             % Store a vector list of the frame numbers in one trace
        AveBkgndData=dat(:,:,1);       % Create data matrix containing list of frame numbers and data
                    % (# of rows)=# of frames of data in the sequence
      
        stdDev=std(datonly);       % (1 x rosedat)=(1 x #of frms), std deviation of bkgnd AOIs for each frame
                                    % Large deviations of baseline do not show up in these values of std,
                                    % just the noise of the pts in each frame
        MedianFrm=median(datonly);  % (1 x rosedat)=(1 x #of frms), median of bkgnd AOIs computed for each frame
                                    % Large deviations of baseline do not show up in these values of median,
                                    % just the noise of the pts in each
                                    % frame.  Median is less subject to large deviations by a single bkgnd AOI  
        MeanStd=mean(stdDev);       % 1 x 1, The mean std dev of the bkgnd AOIs, averaged frame-by-frame along the entire trace 
        AveBkgndData(:,8)=sum(dat(:,8,:),3)/rose;  % Substitute average of all the background traces
                                  % into the integrated trace column
                     % rose = # of bkgnd AOIs for the current reference AOI 
    
                     
        SmoothedMedianTrace=sgolayfilt(MedianFrm,SGsmooth(1),SGsmooth(2));
            % Find the background trace with the smallest std deviation from
            % the smoothed median background trace.                          
        SDvaluesMed=zeros(rose,1); %  Here we will store the std dev values for each 
                        % (bkgnd trace) - (smoothed median background trace)
              % rose = # of bkgnd AOIs for the current reference AOI                          
        for indx4=1:rose
        
        
            % rose = # of bkgnd AOIs for the current reference AOI, so
            % we cycle through all the bkgnd AOIs for the current
            % reference AOI
            % Calculate std for the difference between each
            % background trace and the smoothed averaged (or median) background trace
            
            SDvaluesMed(indx4,1)=std(datonly(indx4,:)-SmoothedMedianTrace);
        end             
         [MinSDBkTraceMinusMedianTrace I]=min(SDvaluesMed);     % Minimum standard deviation of (bkgnd trace)-(smoothed median trace)
                     
                    % Next, we want to SG smooth the ave trace, 
                       
        %MedianBkgndData=median(dat(:,8,:),3);
        SmoothedAveTrace=sgolayfilt(AveBkgndData(:,8),SGsmooth(1),SGsmooth(2));
        % Now we look frame-by-frame for outliers among the bkgnd AOIs
        % We throw out pts that are more than 4*MeanStd off the SmoothedAveTrace trace 
        %AveBkgndTraceNoOuts=zeros(rosedat,1);   % Average background trace after removing outliers
        AveBkgndTraceNoOuts=datonly(I,:)';       % Starting off with the bkgnd trace with minimum deviation of (bkgnd trace)-(smoothed median trace)
                                             % We will replace it frame-by-frame w/ the averaged bkgnd trace (excluding outliers) 

        for indx=1:rosedat
                    % Cycle through all the frames
           %logik=abs(dat(indx,8,:)-SmoothedAveTrace(indx))<4*MeanStd;   % Retain bkgnd values only within 4*MeanStd of smoothed background
           logik=abs(dat(indx,8,:)-SmoothedMedianTrace(indx))<4*MinSDBkTraceMinusMedianTrace;   % Retain bkgnd values only within 4*MinSDBkTraceMunusMedianTrace of smoothed background
           
           if sum(logik)>2
                                % Need at least three points to fit to a plane 
               BkgndSubdata=zeros(sum(logik),2);    % [(AOI number) (integrated intensity)]
               BkgndSubdata(:,1)=dat(indx,1,logik); % AOI number
               BkgndSubdata(:,2)=dat(indx,8,logik); % integrated intensity
                                    % Obtain the drift-corrected xy positions
                                % for both the reference and background AOIs
                                % Refaoiinfo2subShifted and Bkgndaoiinfo2Shifted
                                % are both aoiinfo2 matrices
               % keyboard
               Refaoiinfo2subShifted=DriftShift(Refaoiinfo2sub,frames(indx), parenthandles.DriftList);  % 1 x 6
               Bkgndaoiinfo2Shifted=DriftShift(Bkgndaoiinfo2,frames(indx), parenthandles.DriftList);    % sum(logik) x 6
               planedata=zeros(sum(logik),3);      %[ x y z ] for Background AOI integrated intensity
               for indxAOInumber=1:sum(logik)
                                % cycle over the Background AOIs we will use
                   logikaoi=Bkgndaoiinfo2Shifted(:,6)==BkgndSubdata(indxAOInumber,1);   % Pick out one of the background AOIs numbers
                                                %      [x    y          z]
                   planedata(indxAOInumber,:)=[Bkgndaoiinfo2Shifted(logikaoi,3:4) BkgndSubdata(indxAOInumber,2)];
               end
               Aparm=plane_fit_LinearLeastSquares(planedata);   % Outputs [A1  A2  A3]
                                                % where z=A1*x + A2*y + A3
               AveBkgndTraceNoOuts(indx) = (Aparm(1)*Refaoiinfo2subShifted(1,3) + Aparm(2)*Refaoiinfo2subShifted(1,4) + Aparm(3));     % Populating a column vector
               % Replace with average of bkgnd traces (excluding outliers) so long as all the traces are not outliers
               % If all the traces contain outliers, the we just retain the
               % dataonly(I,:) value from above, which is the value from
               % the one bkgnd trace with minimum std dev of (bkgnd trace)-(smoothed median trace)
           elseif sum(logik>0)
               % Here if we cannot fit to a plane (<3 background points) but
               % we still have 1 or 2 background points
               AveBkgndTraceNoOuts(indx)=mean(dat(indx,8,logik));     % Form ave of all the bkgnd traces (having 
                                                        % frame-by-frame removed the outlier bkgnd AOIs) 
           end
        end
        SmoothedAveTraceNoOuts=sgolayfilt(AveBkgndTraceNoOuts,SGsmooth(1),SGsmooth(2));
     
        logik=Refaoifits.data(:,1)==refAOInum; % reAOInum is the current reference AOI number that we are
                            % currently operating on (to remove the baseline offset) 
        Refdat=Refaoifits.data(logik,:);        % Pick out data for the reference AOI
     
                %*** Pick one of the following three statements:
        %RefTraceMinusBkgnd=Refdat(:,8)- SmoothedMedianTraceAll;
        RefTraceMinusBkgnd=Refdat(:,8)- SmoothedAveTraceNoOuts;
        %RefTraceMinusBkgnd=Refdat(:,8)- SmoothedMedianTraceAllNoOutlier';
        %*******        % [Refdat(:,2) RefTraceMinusBkgnd] = [(frm#)  (background-corrected intensity)] 
        
   
       % logik=Refaoifits.data(:,1)==refAOInum;      % Find all data trace entries for current reference AOI number
        %RefaoifitsMinusBkgnd.data(logik,8)=RefTraceMinusBkgnd;    % Replace the data entries for the current AOI
                                    % with background corrected data
        RefaoifitsMinusBkgnd.Bkdata(logik,8)=SmoothedAveTraceNoOuts;         % Replace .Bkdata member with the smoothed ave bkgnd trace                                   
        RefaoifitsMinusBkgnd.data(logik,8)=RefTraceMinusBkgnd;    % Replace the data entries for the current AOI
                                    % with background corrected data
         
    
         %keyboard                          
                                    
    else
             % Here if we are UNABLE to subtract background AOIs for the current
            % reference AOI specified by refAOInum=AOInums(indxroot)
            
            % Add this reference AOI to our list of AOIs for which we did
            % not subtract the background
       AOIsWithoutBkgndSubtraction=[AOIsWithoutBkgndSubtraction;refAOInum];     
       sprintf('No background AOIs for ref AOI number %i',refAOInum)
    end
 

end
                                % Add member listing reference AOIs for which we were
                                % unable to subtract a background (no
                                % neighboring AOIs in our chosen bkgnd AOI set)
RefaoifitsMinusBkgnd.AOIsWithoutBkgndSubtraction=AOIsWithoutBkgndSubtraction;

pc=RefaoifitsMinusBkgnd;        % Output an aoifits structure containing a pc.data with background
                    % corredted data, and pc.Bkdata containing a data
                    % listing with the smoothed background data.
    
% We formed the ave and median trace of all the background AOIs for a particular Reference AOI (=SmoothedMedianTrace).
%{ We found the trace with the minimum deviation from the SmoothedMedianTrace, and the std dev of that difference:-->MinSDBkTraceMinusMedianTrace 
%{ Averaged all the background traces, but omitted points in a trace that are more than 4*MinSDBkTraceMinusMedianTrace away from the SmoothedMedianTrace
%{ -->AveBkgndTraceNoOuts  (average background trace with no outliers included) - -
%{ Smoothed the AveBkgndTraceNoOuts-->SmoothedAveTraceNoOuts, then subtracted it from the associated Reference AOI data trace -->  RefaoifitsMinusBkgnd.data
%{ Also retained the SmoothedAveTraceNoOuts for each Reference AOI -->  RefaoifitsMinusBkgnd.Bkdata


