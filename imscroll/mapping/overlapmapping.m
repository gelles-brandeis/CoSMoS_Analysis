function pc=OverlapMapping(handles)
%
% function OverlapMapping(handles)
%
%  Used to map one RBG image onto a second RGB image.  The first RGB image
%  will be e.g. elongated Cy5 spots (false color image as RGB triples for
%  each pixel) that we map onto the preceeding Cy3 open complexes (also false 
%  color imaged as RGB triples).  The output of this function will then be
%  added (as a matrix) to the second RGB image matrix (colored orthogonal
%  to the first) so that we can see the overlap regions.
% 
% The function assumes that the input is an x1y1 image.
% Output will be an RGB image mapped into x2y2 field.
% The function will use the mapping parameters stored in the 'UserData' of
% handles.FitDisplay  (i.e.
% fitparmvector=get(handles.FitDisplay,'UserData'), and will use the
% mappingfuncxy(fitparmvector(:,:),xypts) and
% to map the x1y1 points to x2y2
% (fitparmvector is 2 x 3, xypts is N x 2 ,  type: 'help mappingfuncxy')
%
%
% handles == handles structure (intended to be the handles structure from
%        the Mapping gui.  This handles structure also includes the handles
%        from the imscroll gui, accessed using
%        parenthandles=guidata(handles.parenthandles_fig);    )
%
%

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

parenthandles=guidata(handles.parenthandles_fig);   % Get the parenthanles handles
                                                % structure of the imscroll
                                                % gui
[rose col]=size(handles.avefrm1);           % Define the size of the output frame
                                            % Fetch the mapping parameters
fitparmvector=get(parenthandles.FitDisplay,'UserData');
                                    % Map the field1 image into intensity
                                    % values ranging 0-255
map_avefrm1=(handles.avefrm1-handles.clowval1)*255/(handles.chival1-handles.clowval1);
                                    % Create the false color version of the
                                    % image in field 1
falsecolor_avefrm1=ind2rgb(map_avefrm1,handles.ColorMap1);
                   % Form the output matrix, initially all zeros
pc=zeros(rose,col,3);
                    % First try going through the false color image indices
                    % in the slow pixel by pixel method to see if it is
                    % fast enough for our purposes.
for indx_y=1:rose
    for indx_x=1:col
                    % Get the [x2 y2] output pixel indices mapped from the input
                    % [indx_x indx_y] input pixel pair
        x2y2_indices=round( mappingfuncxy(fitparmvector,[indx_x indx_y]) );
                    % Test that the output is within the frame limits
        if (x2y2_indices(1)>0)&&(x2y2_indices(1)<=col) &&(x2y2_indices(2)>0) && (x2y2_indices(2)<=rose)
                    % If within limits, then assign the RGB value to the proper pixel of the
                    % output matrix
        pc(x2y2_indices(2), x2y2_indices(1), :)=falsecolor_avefrm1(indx_y,indx_x,:);
        end
    end
end
%         Get rid of zero lines running through the mapped image by
%         averaging over all the immediate neighbors
for indx_y=2:rose-1
    for indx_x=2:col-1
        if (pc(indx_y,indx_x,1)==0)&&(pc(indx_y,indx_x,2)==0) && (pc(indx_y,indx_x,3)==0)
                                % Here if our pixel is zero
                                % logic will find neighboring zeros, so we
                                % do not count them in averaging
            logic=pc(indx_y-1:indx_y+1, indx_x-1:indx_x+1, 1)==0;
                                % average around our zero pixel so long as
                                % there are no more than 3 neighboring
                                % zeros
            if sum(sum(logic))<=3
                pc(indx_y,indx_x,1)=sum(sum(pc(indx_y-1:indx_y+1, indx_x-1:indx_x+1, 1)) )/(9-sum(sum(logic)));
            end
            logic=pc(indx_y-1:indx_y+1, indx_x-1:indx_x+1, 2)==0;
            if sum(sum(logic))<=3
                pc(indx_y,indx_x,2)=sum(sum(pc(indx_y-1:indx_y+1, indx_x-1:indx_x+1, 2)) )/(9-sum(sum(logic)));
            end
            logic=pc(indx_y-1:indx_y+1, indx_x-1:indx_x+1, 3)==0;
            if sum(sum(logic))<=3
                pc(indx_y,indx_x,3)=sum(sum(pc(indx_y-1:indx_y+1, indx_x-1:indx_x+1, 3)) )/(9-sum(sum(logic)));
            end
        end
    end
end






    

