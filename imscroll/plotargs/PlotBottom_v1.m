function pc = PlotBottom_v1(handles,parenthandles,oneargouts,argnumber)
%
% function PlotBottom_v1(handles,parenthandles,oneargouts,argnumber)
%
% Will be called from plotargout.m in order to plot the appropriat graph
% on the bottom plot of the gui.
% handles = the handles structure from the plotargout gui
% parenthandles = the handles structure from the original imscroll gui
%            that called the plotargout gui
% oneargouts = the set of fit parameters for the one AOI being plotted
              % argouts=[ aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi]
% argnumber = the value of the popup menu BottomPlotY that specified
%        what the user wants to see plotted
% folder  = folder containing the 'images' file 
%        e.g. p:\image_data\february_04_05\b9p142a.tif
% eventdata == optional arguement, allows this subroutine to again call
%        the calling callback if the Intervals2 is not loaded

% V1 remove folder from arguement 3/21/2010

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
pc=1;                               % Later on we set pc=10 in the instance where
                                % the user attempts to bi-color the plot
                                % but has not yet input the Intervals2
                                % (signals calling program to just plot
                                % the integrated trace.
if isfield(parenthandles,'gfolder')
folder=parenthandles.gfolder;
end

aoifits=parenthandles.aoifits2;
argouts=aoifits.data;          % argouts=[aoi# frame# amp x0 y0 sigma offset (int. AOI)]
frmmin=min(oneargouts(:,2));                     % Lowest frame number.
frmmax=max(oneargouts(:,2));                     % Highest frame number.
                                                % Get the gui specified
                                                % plot range of frames.
                                                %
                                                % 'plotfrms' is the range
                                                % of frames to plot
plotfrms = round( eval( get(handles.PlotRange,'String') ) );
if (plotfrms(1)<=frmmax) & (plotfrms(1)>= frmmin) & (plotfrms(2)<=frmmax) & (plotfrms(2)>=frmmin) & get(handles.PlotRangeToggle,'Value')
                            % Here if the PlotRange parameters is between
                            % acceptable limits, and the PlotRangToggle is
                            % depressed.
    plotfrmmin=min(plotfrms);                   % min and max frames to be included in plot
    plotfrmmax=max(plotfrms);
                                                % Logical array defining
                                                % the frames to be plotted
    frmlog=(oneargouts(:,2)>=plotfrmmin) & (oneargouts(:,2)<=plotfrmmax);
else
                                                % Here if entire range is
                                                % to be plotted
    frmlog=(oneargouts(:,2)>=frmmin) & (oneargouts(:,2)<=frmmax);
     set(handles.PlotRange,'String',[ '[ ' num2str(frmmin) '  ' num2str(frmmax) ' ]' ] );
end
                        % Next perform any specified data operations
if (get(handles.DataOperation,'Value'))==1           % DataOperation toggle is depressed ==1 
                                                % if we are to perform some data operation

    operationArg=get(handles.ButtonChoice,'Value')
  
    if operationArg==1                          % Here to subtract background AOIs
                                                % Get the list of AOIs to
                                                % be used as backgrounds
        aoiliststr=get(handles.AOIList,'String');

        aoilist=eval(aoiliststr);            % Vector listing the backgound AOIs
        [datrows datcols]=size(argouts);
        logaoi=logical([]);
                                    %We need a matrix with an ave bkgnd int. aoi for
                                    % each frm number
                                                % Pick out all rows of the
                                                % argouts matrix containing
                                                % background aoi info.
                                                % This will contain info.
                                                % from all the frames
        for indxx=1:datrows
                            % compare aoi for each row of argouts with the list of aois used for background subtraction  
            logaoi=[logaoi;any(aoilist==argouts(indxx,1))];
        end
                                                % Next average all the
                                                % integrated aoi data for a
                                                % given framenumber
                                                
        subargouts=argouts(logaoi,:);           % Contains argouts rows with info. on background aois
                                                % Frame # limits
        frmmin=min(subargouts(:,2));frmmax=max(subargouts(:,2));
        bkgndintaoi=[];
                                                % Average the background
                                                % int. aoi for each
                                                % framenumber
        for frmindx=frmmin:frmmax   
                                                % Logical array picking all
                                                % rows with present frame
                                                % number
            logfrm=(frmindx==subargouts(:,2));
                                                % Now average the (int. aoi)
                                                % for the background aois
                                                % with the present frm #
            bkgndintaoi=[bkgndintaoi;frmindx sum(subargouts(logfrm,8))/length(aoilist)];
        end
                            % Now subtract ave background from (int aoi)
        oneargouts(:,8)=oneargouts(:,8)-bkgndintaoi(:,2);
                            % Next store the modified trace into the
                            % detrended trace of PTCA, =PTCA{1,12)
                            % This is to allow us to get mean/std of
                            % subtracted traces  ljf:1/4/09
                            % Get the PTCA
        PTCA=handles.IntervalDataStructure.PresentTraceCellArray;
                            % Store subtracted trace as the detrended trace
         
        PTCA{1,12}(:,2)=oneargouts(:,8);
        handles.IntervalDataStructure.PresentTraceCellArray=PTCA;
        guidata(gcbo,handles);
    
    elseif operationArg ==2                     % Here to load a time base file
                                                % Next statement load a vid
                                                % structure
     % eval(['load ' folder(1:length(folder)-3) 'mat -mat'])
      eval(['load ' folder 'header.mat -mat'])
      
      timebase=[oneargouts(:,2) [vid.ttb(oneargouts(:,2))-vid.ttb(1)]' ];       %First column
                              % is the frame number, second column is the time base in ms
      timebase(:,2)=timebase(:,2)*.001;
        
    end                                         % End of (if operationArg==) in ButtonChoice
end                                             % End of (if DataOperation) depressed 
if argnumber < 7                                % Plots are simply frm# vs. (some parameter)

    if exist('timebase')==0                     % 'Timebase' will exist if we have loaded a
                                                % time base file 'vid'
                                                 % Here if 'timebase' is not yet defined
         timebase=oneargouts(:,1:2);             % Define timebase as frame #
    end
        
    figure(25);plot(timebase(frmlog,2),oneargouts(frmlog,argnumber+2),'b',timebase(frmlog,2),oneargouts(frmlog,argnumber+2),'r');
    axes(handles.axes3)
    plot(timebase(frmlog,2),oneargouts(frmlog,argnumber+2),'b',timebase(frmlog,2),oneargouts(frmlog,argnumber+2),'r');
else
    switch argnumber
        case 7                                  % Plot Sigma vs. Amplitude
            figure(25);plot(oneargouts(frmlog,6),oneargouts(frmlog,3),'b.');
            axes(handles.axes3)
            plot(oneargouts(frmlog,6),oneargouts(frmlog,3),'b.');
        case 8                                  % Plot sigma vs X
            figure(25);plot(oneargouts(frmlog,6),oneargouts(frmlog,4),'b.');
            axes(handles.axes3)
            plot(oneargouts(frmlog,6),oneargouts(frmlog,4),'b.');
        case 9                                  % Plot sigma vs Y
            figure(25);plot(oneargouts(frmlog,6),oneargouts(frmlog,5),'b.');
            axes(handles.axes3)
            plot(oneargouts(frmlog,6),oneargouts(frmlog,5),'b.');
        case 10                                  % Plot Amplitude vs X
            figure(25);plot(oneargouts(frmlog,3),oneargouts(frmlog,4),'b.');
            axes(handles.axes3)
            plot(oneargouts(frmlog,3),oneargouts(frmlog,4),'b.');
        case 11                                  % Plot Amplitude vs Y
            figure(25);plot(oneargouts(frmlog,3),oneargouts(frmlog,5),'b.');
            axes(handles.axes3)
            plot(oneargouts(frmlog,3),oneargouts(frmlog,5),'b.');
        case 12                                  % Plot X vs Y
            figure(25);plot(oneargouts(frmlog,4),oneargouts(frmlog,5),'b.');
            axes(handles.axes3)
            plot(oneargouts(frmlog,4),oneargouts(frmlog,5),'b.');
        case 13
        %Plot the integrated trace, and color the sections where a 
        %co-localized spot has been detected
         %Plot the integrated intensity
        
            if isempty(handles.IntervalDataStructure2.CumulativeIntervalArray)
                  % Here if the Intervals structure has not been loaded
                set(handles.BottomPlotY,'Value',6);     % Change dropdown menu to just display
                                                % integrated trace (not bicolor trace since
                                                % the Intervals structure is not loaded 
                pc=10;          % Signals the calling program to just replot
                                % the integrated trace (b/c the next commented
                                % statement did not work w/in this function
                %DisplayBottom_Callback(handles.DisplayBottom, eventdata, handles)
            else
                  % Here if the Intervals structure has been loaded, in which
                  % case we can color the sections of the trace where a spot
                  % has been detected
                dat=extract_aoifits_aois(aoifits);
                cia=handles.IntervalDataStructure2.CumulativeIntervalArray;
                offset=0;
                LowColor=[0.5 0.5 0.5];      % gray
                HighColor=[0 0 1];           % red
                %keyboard
                AOInum=oneargouts(1,1);     % Number of the AOI being plotted
                                                                                     % 24=figure number
                ColorColocalizations_plotargout_Bottomaxes3(dat,cia,AOInum,LowColor,HighColor,offset, 25, handles);            
           
            end            
    end
end
  
    
                                                % Now check for manual or
                                                % auto axis scale
if (get(handles.AxisScale,'Value')) ==0
    figure(25);axis auto
    axes(handles.axes3);axis auto
else
    figure(25);axis(eval(get(handles.BottomAxisLimits,'String')))
    axes(handles.axes3);axis(eval(get(handles.BottomAxisLimits,'String')))
end

                    % Change X limits if toggle is depressed
if get(handles.CustomXLimitsBottomToggle,'Value')==1
                    % Toggle depressed: use x limits from matrix
    set(handles.axes3,'Xlim',[handles.XLimitsMatrixBottom(handles.RowXLimitsMatrixBottom,:)]);
else
      % auto scaling used above: store the auto scaled x axis limits
    handles.DefaultXLimitsBottom=get(handles.axes3,'Xlim');
end
guidata(gcbo,handles);  
