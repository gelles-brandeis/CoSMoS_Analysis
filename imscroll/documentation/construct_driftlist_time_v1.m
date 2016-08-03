function pc=construct_driftlist_time_v1(xy_cell,vid,CorrectionRange,SequenceLength,Polyorderxy,varargin)
%
% function    construct_driftlist_time_v1(xy_cell, vid, CorrectionRange, SequenceLength, Polyorderxy,<SG_Smooth>)
%
% xy_cell==cell array of structures containing the information gleaned from
%         gaussian tracking multiple spots for the purpose of drift correction.
%        e.g.  xy_cell{1}.dat
%              xy_cell{1}.range
%              xy_cell{1}.userange    where
% xy_cell{1}.dat ==one dat matrix containing the x 
%         y coordinates of one spot tracked with a gaussian fit in imscroll.
%         Each cell array is of the form
%         obtained by processing an aoifits structure with the
%         dat=draw_aoifits_aois(aoifits,'y') function.  Therefore,
%         dat(:,4,1) contains the x coordinate and dat(:,5,1) the y
%         coordinate
% xy_cell{1}.range==[ low high] frame range that the dat matrix covers.  
%         For example we might have xy_cell{1}.range=[100 500] though the
%         image sequence might be [1 2305] i.e. the dat matrx will
%         generally cover a continuous subset of all the imagee, and the data
%         will generally not be useable throughout this range.  the
%         '.range' member lists only the range over which the spot was
%         tracked for this entry, not the range over which the tracked spot
%         contains usefull data (specified in the next entry)
% xy_cell{1}.userange==[low high] useable frame range over which
%         each dat_cell entry x-y coordinates may be used for drift
%         correction.  e.g. xy_cell{1}=[150 450] where the
%         xy_cell{1}.range=[100 500] is a possibility.
% xy_cell{1}.ttb = [(frame #) time] 
%              Optional time base from vid.ttb for whatever glimpse file this data
%              was obtained.  Note that the frame# range must match that of
%              the xy_cell{}.dat member.  If no *.ttb member is specified the program will
%              use the vid.ttb from the 'vid' input variable.  This allows
%              a user to specify data from different glimpse files if
%              needed.  If all data is from one glimpse file, just inputing
%              the 'vid' arguement will be sufficient.
% vid == structure from the glimpse image file header.  Among its members are
%       vid.ttb and vid.nframes for the time base (in ms) and  total number of frames
% CorrectionRange==[lowc hic] low and high frame number between which we 
%         performing a drift correction in the file.  Generally, the drift
%         correction occurs over just a subset of the frames in the file
% SequenceLength == e.g. 3606 the total number of images in the glimpse
%         image file for which we will construct a driftlist
% PolyOrderxy == [n m] where n and m are integers specifying the polynomial
%         order of fit respectively applied to the x (n) and y (m) drift curves 
% SG_Smooth == OPTIONAL parameter for Savitsky-Golay smoothing instead
%               of polynomial smoothing of drift.  
%                =[ SG_PolyOrderX   SG_FrameX  SG_PolyOrderY    SG_FrameY] 
%                where:
% SG_PolyOrder==   parameter specifying the order of polynomial (X or Y drift) 
%               used in Savitsky-Golay smoothing (must be odd). e.g. = 5
% SG_Frame ==   parameter specifying the window size (number of points) used for
%              Savitsky-Golay smoothing.  (must be odd) e.g. = 41 (X or Y drift) 
% OUTPUT will be a 
% driftlist(SequenceLength,3)=[(frame#) (x difference) (y difference)]
% See B21p53
%
% Usage:
%(1) drifts_time= construct_driftlist_time_v1(xy_cell,vid,CorrectionRange,SequenceLength,Polyorderxy,<SG_Smooth>)
%(2) drifts=driftlist_time_interp(drifts_time.cumdriftlist,vid);
% OR if using gui_drift_correction as the step (1)
% (2) drifts=driftlist_time_interp(Drift.drift_correction_cumfit_glimpse,vid);
%foldstruc.DriftList=drifts.diffdriftlist;

% V1:  LJF 12/6/2013  Add option to use Savitsky-Golay smoothing rather 
%                    than just a single polynomial fit.
%  alternatively:
% dat_cell == cell array of dat matrices.  Each dat matrix contains the x 
%         y coordinates of one spot tracked with a gaussian fit in imscroll.
%         Each cell array is of the form
%         obtained by processing an aoifits structure with the
%         dat=draw_aoifits_aois(aoifits,'y') function.  For example
%         we might have dat_cell{1}=dat(:,:,2), dat_cell{2}=dat(:,:,5) etc
%         where the different dat() matrices could originate from different
%         aoifits structures.
% datrange_cell== cell array listing the frame range overwhich each
%         dat_cell entry covers.  For example we might have 
%         datrange_cell{1}=[50 300] for the dat_cell{1} input,
%         datrange_cell{2}=[100 600] for the dat_cell{2} input, etc
% userange_cell== cell array listing the useable frame range over which
%         each dat_cell entry x-y coordinates may be used for drift correction.
%         e.g. datrange_cell{1}=[100 250], datrange_cell{2}=[150 575], etc
% dat_cell, datrange_cell and userange_cell should all have the same number
% of matching entries.
%
%
%  form the various variables as xcell, ycell, dxcell, dycell, dx, dy,
%  cumx,cumy, fitx, valx fity, valy, ddx, ddy, driftlist
%
inlength=length(varargin);
                                                % Grab the Savitsky-Golay
                                                % parameters, if present
if inlength>0
    SG_Smooth=varargin{1}(:);                   %[ SG_PolyOrder   SG_Frame]
    SG_PolyOrderX=SG_Smooth(1);                  %
    SG_FrameX=SG_Smooth(2);                      %
    SG_PolyOrderY=SG_Smooth(3);                  %
    SG_FrameY=SG_Smooth(4);                      %
                                               
end
sz=max(size(xy_cell));      % sz = number of tracked aois used in making this driftlist

for indx=1:sz
    if ~isfield(xy_cell{indx},'ttb')
                    % Here if the 'ttb' field was not defined => just set it 
                    % equal to the vid.ttb time base from the input vid
                    % structure
        frms=xy_cell{indx}.dat(:,2);        % frame numbers for which data is defined
                                            % for this aoi
        
        xy_cell{indx}.ttb=[frms vid.ttb(frms)'];     % [(frm #)  (time from glimpse file)]    
    end
end
[rosecell aoinum]=size(xy_cell);
                        % Replace SequenceLength by SequenceLength+20, then
                        % shorten it again at end of program so that we do
                        % not have to treat special cases such as when the
                        % use range of an aoi runs to the end of the file.
                        % This way, we never have xy_cell{}.userange running
                        % to the very end of a file, and all expressions
                        % can be treated the same.
ActualSequenceLength=SequenceLength;
SequenceLength=SequenceLength+20;

           % aoinum is the number of aois tracked for correcting drift
           % rosecell should be equal to 1
           
                       % First form the x1 and y1 coordinate lists for the
                       % various aois
                       % These will run from frame 1 out to
                       % frame=SequenceLength, filling in zeros where there
                       % is no coordinate tracked for that aoi
x1=cell(1,aoinum);
y1=cell(1,aoinum);
dx1=cell(1,aoinum);
dy1=cell(1,aoinum);
for x1y1indx=1:aoinum
    lolimit=xy_cell{x1y1indx}.range(1);
    hilimit=xy_cell{x1y1indx}.range(2);
   % if hilimit==SequenceLength
                        % just in case tracking went to very end of file,
                        % shorten it by one so some of the upcoming
                        % expressions don't fail
                 % NO:  fixed by replacing SequenceLength by
                 % SequenceLength+20, then shortening it at the end
     %   hilimit=hilimit-1;
    %end
                        % dat=[(frm#)  ()  () (xcoor) (ycoord) ...]
    dat=xy_cell{x1y1indx}.dat;
    if lolimit==1
                        % Here if low frame limit of xy coordinates =1
                        %
                        % x1{}=[(frame#) (x coord of spot} (glimpse time)], y1{}= ""
                        % fill in zeros as coord if spot not tracked for
                        % some frames
        x1{x1y1indx}=[dat(:,2) dat(:,4) xy_cell{x1y1indx}.ttb(:,2); [hilimit+1:SequenceLength]' zeros(length(hilimit+1:SequenceLength),2)];
        y1{x1y1indx}=[dat(:,2) dat(:,5) xy_cell{x1y1indx}.ttb(:,2); [hilimit+1:SequenceLength]' zeros(length(hilimit+1:SequenceLength),2)];
    else
        x1{x1y1indx}=[[1:lolimit-1]' zeros(lolimit-1,2); dat(:,2) dat(:,4) xy_cell{x1y1indx}.ttb(:,2); [hilimit+1:SequenceLength]' zeros(length(hilimit+1:SequenceLength),2)];
        y1{x1y1indx}=[[1:lolimit-1]' zeros(lolimit-1,2); dat(:,2) dat(:,5) xy_cell{x1y1indx}.ttb(:,2); [hilimit+1:SequenceLength]' zeros(length(hilimit+1:SequenceLength),2)];
    end
                        % And form the deltax and deltay lists
    dx1{x1y1indx}=[0; diff(x1{x1y1indx}(:,2))];             % [(dx between frames)]
    dy1{x1y1indx}=[0; diff(y1{x1y1indx}(:,2))];             % [(dy between frames)]
end
                        % Now we must zero out the dx1 and dy1 entries that
                        % are at unuseable frame numbers
for dxyzindx=1:aoinum
    lowuserange=xy_cell{dxyzindx}.userange(1);
    hiuserange=xy_cell{dxyzindx}.userange(2);
    if ( lowuserange~=1 )
        dx1{dxyzindx}(1:lowuserange)=0;
        dx1{dxyzindx}(hiuserange+1:SequenceLength)=0;
        dy1{dxyzindx}(1:lowuserange)=0;
        dy1{dxyzindx}(hiuserange+1:SequenceLength)=0;
    else
            % Here if lowuserange==1 (we then DO NOT need to zero out dx1 and dy1
            % for frames 1 up to lowuserane)
        dx1{dxyzindx}(hiuserange+1:SequenceLength)=0;
        dy1{dxyzindx}(hiuserange+1:SequenceLength)=0;
    end
end
            % initialize numerator and denominator of dx, dy
dxnum=zeros(SequenceLength,1);
dynum=zeros(SequenceLength,1);
dxdenom=zeros(SequenceLength,1);
dydenom=zeros(SequenceLength,1);
            % dx and dy entries from frame M represent the difference in 
            % spot coordinates between the frame M-1 and M


for dxyindx=1:aoinum
    dxnum=dxnum+dx1{dxyindx};
    dynum=dynum+dy1{dxyindx};
                        % Each entry in denominator will equal the number
                        % of nonzero elements in the dx or dy cell arrays
                        % so that we average only over those regions with
                        % multiple tracked aois (if only one element exists
                        % the denominator will be 1, and if no elements
                        % exit we should be at a frame number in a range we
                        % are not correcting drift)
    dxdenom=dxdenom+(dx1{dxyindx}~=0);
    dydenom=dydenom+(dy1{dxyindx}~=0);
end
dx=dxnum.*dxdenom.^(-1);
dy=dynum.*dydenom.^(-1);
                        % At various places we divided by zero, resulting
                        % in NaN.  We now zero out those entries
logikx=isnan(dx);
dx(logikx)=0;
logiky=isnan(dy);
dy(logiky)=0;
                        % Sum the frame differences to a cumulative track
                        % of the exemplary x and y coordinate drifting in
                        % the file
cumx=cumsum(dx);
cumy=cumsum(dy);
                        % Fit the cumulative traces to polynomials
crange=[CorrectionRange(1):CorrectionRange(2)];
                        % Note that the fit is to the time, not the frame number 
if inlength>0
                        % Here to apply Savitsky-Golay smoothing to the 
                        % cumulative drift
    valx=sgolayfilt(cumx(crange),SG_PolyOrderX,SG_FrameX);
    valy=sgolayfilt(cumy(crange),SG_PolyOrderY,SG_FrameY);
else
                        % Here to use a simple polynomial fit to the 
                        % cumulative drift.
    mn=mean(vid.ttb(crange));
    fitx=polyfit((vid.ttb(crange)-mn)',cumx(crange),Polyorderxy(1));
    valx=polyval(fitx,vid.ttb(crange)-mn);
    fity=polyfit((vid.ttb(crange)-mn)',cumy(crange),Polyorderxy(2));
    valy=polyval(fity,vid.ttb(crange)-mn);
end

                        % Plot the concatenated xy coord and fits against time 
figure(27);plot(vid.ttb(crange),cumx(crange),'b',vid.ttb(crange),valx,'r');
gtext(['xdrift, polyfit order:' num2str(Polyorderxy(1))])
xlabel('glimpse time (ms)');ylabel('x pixel')
figure(28);plot(vid.ttb(crange),cumy(crange),'b',vid.ttb(crange),valy,'r');
gtext(['ydrift, polyfit order:' num2str(Polyorderxy(2))])
xlabel('glimpse time (ms)');ylabel('y pixel')
                        % Plot the concatenated xy coord and fits against normalized time 
tm=( vid.ttb-vid.ttb(1) )*1e-3;     % tm is time is sec with tm=0 at first corrected frame 
figure(29);plot(tm(crange),cumx(crange),'b',tm(crange),valx,'r');
%gtext(['xdrift, polyfit order:' num2str(Polyorderxy(1))])
xlabel('time (s)');ylabel('x pixel')
figure(30);plot(tm(crange),cumy(crange),'b',tm(crange),valy,'r');
%gtext(['ydrift, polyfit order:' num2str(Polyorderxy(2))])
xlabel('time (s)');ylabel('y pixel')
                        % Plot the concatenated xy coord and fits against frames 

figure(31);plot(crange,cumx(crange),'b',crange,valx,'r');
%gtext(['xdrift, polyfit order:' num2str(Polyorderxy(1))])
xlabel('frames');ylabel('x pixel')
figure(32);plot(crange,cumy(crange),'b',crange,valy,'r');
%gtext(['ydrift, polyfit order:' num2str(Polyorderxy(2))])
xlabel('frames)');ylabel('y pixel')
                % Construct the cumulative driftlist from the polynomial fits
cumdriftlist=zeros(SequenceLength,4);
cumdriftlist(:,1)=[[1:SequenceLength]'];
cumdriftlist(crange,2)=valx;
cumdriftlist(crange,3)=valy;

cumdriftlist(1:ActualSequenceLength,4)=vid.ttb;          % Place the time base into the 4th column
                                                     % (time base of the glimpse file used for  
                                                     % constructing this drift list.

                        % Now truncate the driftlist to match the actual
                        % length of the image sequence file (see note at
                        % top of program
 cumdriftlist=cumdriftlist(1:ActualSequenceLength,:);
                 % Construct the difference driftlist from the polynomial fits

ddx=diff(valx);
ddy=diff(valy);
drange=[CorrectionRange(1)+1:CorrectionRange(2)];
diffdriftlist=zeros(SequenceLength,4);
diffdriftlist(:,1)=[[1:SequenceLength]'];
diffdriftlist(drange,2)=ddx;
diffdriftlist(drange,3)=ddy;
diffdriftlist(1:ActualSequenceLength,4)=vid.ttb;             % Place the time base into the 4th column
                                                        % (time base of the glimpse file used for  
                                                        % constructing this drift list.
                        % Output the driftlist
                        %
                        % Now truncate the driftlist to match the actual
                        % length of the image sequence file (see note at
                        % top of program)
diffdriftlist=diffdriftlist(1:ActualSequenceLength,:);
pc.cumdriftlist=cumdriftlist;
pc.diffdriftlist=diffdriftlist;

pc.cumdriftlist_description='[ (frame#)  (cumulative x)  (cumulative y)  (glimpse time)]';
pc.diffdriftlist_description='[ (frame#)  dx  dy   (glimpse time)], e.g. dx(N) = cumulative x(N) - cumulative x(N-1)';
pc.xy_cell=xy_cell;
pc.vid=vid;
pc.SequenceLentgh=ActualSequenceLength;
pc.CorrectionRange=CorrectionRange;





