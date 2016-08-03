function pc=driftlist_time_interp(cumdriftlist,vid)
% function driftlist_time_interp(cumdriftlist,vid)
%
% This function constructs a driftlist=[(frm #) dx   dy  (glimpse time) ]
% using the **.cumdriftlist member of the strucure output by
% the function 'construct_driftlist_time.m' by interpolating all drift
% offsets based on the frame times for the glimpse file that has the time
% base given by vid.ttb
% 
% cumdriftlist == [ (frame#)  (cumulative x)  (cumulative y)  (glimpse time) ] 
%             This is the  **.cumdriftlist member of the structure output
%             by the function 'construct_driftlist_time.m'
% vid == The driftlist output by the current function is neede for a particular
%        glimpse file, and this 'vid' variable is the vid structure for the
%        header of that particulat glimpse file.  In particular, it
%        contains the needed vid.ttb glimpse time base that is used to
%        reference the offsets for the output driftlist.
%
% Usage:
%(1) drifts_time= construct_driftlist_time(xy_cell,vid,CorrectionRange,SequenceLength,Polyorderxy)
%(2) drifts=driftlist_time_interp(drifts_time.cumdriftlist,vid);
% OR if using gui_drift_correction as the step (1)
% (2) drifts=driftlist_time_interp(Drift.drift_correction_cumfit_glimpse,vid);
%foldstruc.DriftList=drifts.diffdriftlist;

vid.nframes=length(vid.ttb);                % This means that vid will no longer need the vid.nframes member as input
logikz=(cumdriftlist(:,2)~=0)|(cumdriftlist(:,3)~=0);    % Pick only rows with nonzero values of (cumulative x)
                                                % or nonzero values of (cumulative y)\
tmin=min(cumdriftlist(logikz,4));           % Range of times over which we 
tmax=max(cumdriftlist(logikz,4));           % can construct a driftlist by interpolation
output_times=[[1:vid.nframes]' vid.ttb'];    % For output file:[frm#    (glimpse time)]
logikvid=(output_times(:,2)>=tmin)&(output_times(:,2)<=tmax);
output_times_mod=output_times(logikvid,:);               % List of [frames times] for the output file
                                             % that we may use to determine drift offsets 
 
                        % Prepare variable for output cumulative driftlist
                     % [ (frm #)  (cumulative x)  (cumulative y)  (glimpse times)] 
output_cumdriftlist=[[1:vid.nframes]' zeros(vid.nframes,2) vid.ttb'];

                                    
            % Next use    YI = INTERP1(X,Y,XI) to obtain (cumulative x and y) values 
            % for the output driftlist by interpolating the (cumulative x and y) 
            % from the input cumdriftlist table
            % (output cumulative x)=interp1( (input times), (input cum x), (output times)) 
output_cumdriftlist( output_times_mod(:,1), 2)=interp1(cumdriftlist(:,4),cumdriftlist(:,2),output_times(logikvid,2));
            % (output cumulative y)=interp1( (input times), (input cum y), (output times)) 
output_cumdriftlist( output_times_mod(:,1), 3)=interp1(cumdriftlist(:,4),cumdriftlist(:,3),output_times(logikvid,2));
            % Note in the above that output_times_mod(:,1) is the list of output frames
            % whose times are between the allowed min and max values
output_diffdriftlist=output_cumdriftlist;
output_diffdriftlist(:,2)=[0;diff(output_cumdriftlist(:,2))];
output_diffdriftlist(:,3)=[0;diff(output_cumdriftlist(:,3))];
            % Now eliminate the first entry of dx and dy since those are not meaningful
            % output_times_mod(1,1) = first frm # containing a (cumulative x or y) value 
output_diffdriftlist(output_times_mod(1,1),2)=0;
output_diffdriftlist(output_times_mod(1,1),3)=0;
            % Test for times less than acceptable min or greater than acceptable max 
logikouthilow=(output_cumdriftlist(:,4)<tmin)|(output_cumdriftlist(:,4)>tmax);
output_cumdriftlist(logikouthilow,2)=0;
output_cumdriftlist(logikouthilow,3)=0;
output_diffdriftlist(logikouthilow,2)=0;
output_diffdriftlist(logikouthilow,3)=0;
pc.cumdriftlist=output_cumdriftlist;
pc.diffdriftlist=output_diffdriftlist;

pc.cumdriftlist_description='[ (frame#)  (cumulative x)  (cumulative y)  (glimpse time)]';
pc.diffdriftlist_description='[ (frame#)  dx  dy   (glimpse time)], e.g. dx(N) = cumulative x(N) - cumulative x(N-1)';

    

