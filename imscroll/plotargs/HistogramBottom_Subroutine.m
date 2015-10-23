function pc = HistogramBottom_Subroutine(handles,parenthandles,oneargouts,argnumber)
%
% function HistogramBottom_Subroutine(handles,parenthandles,oneargouts,argnumber)
%
% Will be called from plotargout.m in order to histogram the data
% on the bottom plot of the gui.
% handles = the handles structure from the plotargout gui
% parenthandles = the handles structure from the original imscroll gui
%            that called the plotargout gui
% oneargouts = the set of fit parameters for the one AOI being plotted
              % argouts=[ aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi]
% argnumber = the value of the popup menu BottomPlotY that specified
%        what the user wants to see plotted

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
    
    
        
    end                                         % End of (if operationArg==) in ButtonChoice
end                                             % End of (if DataOperation) depressed 


    
    
[margs nargs]=size(oneargouts);
bnst=get(handles.BinNumber,'String');
bn=round(str2num(bnst));

figure(25);hist(oneargouts(:,argnumber+2),bn)
axes(handles.axes3);hist(oneargouts(:,argnumber+2),bn)
pc=1;