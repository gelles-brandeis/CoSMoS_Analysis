function pc=MakeMappingFile(aoiinfo2_field1, aoiinfo2_field2, filename)
%
% function MakeMappingFile(aoiinfo2a_field1, aoiinfo2b_field2, filename)
%
% Will be used to make a mapping file containing the usual fitparmvector
% and mappingpoints variables for use in mappinge between fields in
% imscroll.
% aoiinfo2_field1 == aoiinfo2 matrix defining the aois in field 1 that
%                 map to the aois in field 2 (defined by aoiinfo2_field2)
% aoiinfo2_field2 == aoiinfo2 matrix defining the aois in field 2 that
%                 map to the aois in field 1 (defined by aoiinfo2_field1)
%
% The number of aois listed in aoiinfo2_field1 must equal the number of
% aois listed in aoiinfo2_field2
%
% filename== full path and name for the output mapping file 
%       e.g. ='p:\matlab12\larry\fig-files\imscroll\mapping\b27p45h.dat'

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

                % Define the mappingpoints matrix
[rose col]=size(aoiinfo2_field1);
 aoiinfo2_field1=update_FitData_aoinum(aoiinfo2_field1);       % Update the numbering of the AOIs in the map
 aoiinfo2_field2=update_FitData_aoinum(aoiinfo2_field2);
mappingpoints=[aoiinfo2_field1 aoiinfo2_field2];    % There will be an error if the two aoiinfo2 
                                                    % are not the same size 
                % Now we must obtain the fitparmsvector

                
if rose>=3               % Map the two fields if we have 3 or more points
                                %  x2= mx21*x1 + bx21
                                %  y2= my21*y1 + by21
                                % first polyfit(x1,x2)=[slope intercept] as
                                % first guess
    fitparmx21=polyfit(mappingpoints(:,3),mappingpoints(:,9),1);
                                % Form a cell array, first member is a matrix of the
                                % x1y1 pairs
    inarray{1}=[ mappingpoints(:,3) mappingpoints(:,4)];
                                % second member is a vector of the output
                                % x2 points
    inarray{2} = mappingpoints(:,9);
                                % Input guess is [mxx21 mxy21 bx] with
                                % mxy21 = 0 at first
    %****fitparmx21more=mappingfit(inarray,[fitparmx21(1) 0 fitparmx21(2) ]);
    fitparmx21more=mappingfit_fminsearch(inarray,[fitparmx21(1) 0 fitparmx21(2) ]);
    rangex=[min(mappingpoints(:,3) ): max(mappingpoints(:,3) )];
                                % Get the linear fit result
    valx=polyval(fitparmx21,rangex);
                                % Get the more complex fit result
    valxmore=mappingfunc(fitparmx21more,inarray{1});
                                % Plot the x data and fit
    figure(20);subplot(121);plot(mappingpoints(:,3),mappingpoints(:,9),'o',...
                          rangex,valx,'r-', mappingpoints(:,3),valxmore,'x')
    xlabel('X1 Coordinate');ylabel('X2 Coordinate');title(['X Mapping:' num2str(fitparmx21more')])
                                % look at the diff btwn the input x2 and
                                % mapped x2 (not prox mapped =>systematic deviations)   
    %figure(21);plot(mappingpoints(:,3),mappingpoints(:,9)-valxmore,'o');
                                % then polyfit(y1,y2)
    fitparmy21=polyfit(mappingpoints(:,4),mappingpoints(:,10),1);
                                % Form a cell array, first member is a
                                % matrix of the x1y1 pairs
      inarray{1}=[ mappingpoints(:,3) mappingpoints(:,4)];
                                % second member is a vector of the output
                                % y2 points
    inarray{2} = mappingpoints(:,10);
                                % Input guess is [myx21 myy21 bx] with
                                % myx21 = 0 at first
       %***fitparmy21more=mappingfit(inarray,[0 fitparmx21(1) fitparmx21(2) ]);
       fitparmy21more=mappingfit_fminsearch(inarray,[0 fitparmx21(1) fitparmx21(2) ]);
     rangey=[min(mappingpoints(:,4) ): max(mappingpoints(:,4) )];
                                % Get the linear fit result
    valy=polyval(fitparmy21,rangey);
                                % Get the more complex fit result
    valymore=mappingfunc(fitparmy21more,inarray{1});
                                % Plot the y data and fit
   
    figure(20);subplot(122);plot(mappingpoints(:,4),mappingpoints(:,10),'o',...
                          rangey,valy,'-',mappingpoints(:,4),valymore,'x')
        xlabel('Y1 Coordinate');ylabel('Y2 Coordinate');title(['Y Mapping:' num2str(fitparmy21more')])
                                  % look at the diff btwn the input y2 and mapped y2 
                                  % (not prox mapped => systematic deviations  
    %figure(22);plot(mappingpoints(:,4),mappingpoints(:,10)-valymore,'o');
     
                                                                 % Place fitparm into 'Value' of FitDisplay 
                                                                 % as a two row matrix
                                                               
        fitparmvector=[fitparmx21more';fitparmy21more'];
  
                                                                 % display as row [mxx21 mxy21 bx21 myx21 myy21 by21]' 
  
        %save p:\matlab12\larry\fig-files\imscroll\mapping\fitparms.dat fitparmvector mappingpoints 
        eval(['save ' filename ' fitparmvector mappingpoints']);
       mappingpoints
else
    sprintf('aoiinfo2 matrix must contain at least 3 aois')                                
    
end
pc.fitparmvector=fitparmvector;
pc.mappingpoints=mappingpoints;


                

