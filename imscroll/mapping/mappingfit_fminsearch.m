function pc=mappingfit_fminsearch(indata,varargin)
%
% function mappingfit(indata,<inputarg0>)
%
% Used to map the xy points in image1 to xy points in image2.  The mapping
% will be done first for x1y1 -> x2 and then x1y1 -> y2.  That is, rather
% than a simple linear mapping of e.g. x2 =m*x1+b,we put in some y
% dependence as well so that e.g. x2 = mxx21*x1 + mxy21*y1 +bx (similar for y
% mapping)
% Will fit the 'indata' (nx2 matrix of xy pairs + mapped x or y coordinate) .
%
% indata     == cell array indata{1} = n x 2 list of xy points in the image1
%                          indata{2} = n x 1 list of x2 (or y2) points in
%                                      the image2 field
% inputarg0  == optional starting parameters for the fit
%                 [ mxx21 mxy21 bx](mapping x1y1 to x2) or 
%                  [myx21 myy21 by] (mapping x1y1 to y2)
%
% The form of the fit will be:
%                 x2 = mxx21*x1 + mxy21*y1 + bx
%                 y2 = myx21*x1 + myy21*y1 + by
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

inlength=length(varargin);
                                                % Grab the starting
                                                % parameters if they are
                                                % present
if inlength>0
    inputarg0=varargin{1}(:);                   %mxx21=varargin{1}(1);
                                                %mxy21=varargin{1}(2);
                                                %bx=varargin{1}(3);
                                                
end
options=optimset('Display','off');              % suppress the screen printing 
                                                %during the lsqcurvefit()
                                                %call
                                             
%pc =lsqcurvefit('mappingfunc',inputarg0,indata{1},indata{2},-10000*ones(1,3),10000*ones(1,3),options);
 
pc=fminsearch('mappingfunc_fminsearch',inputarg0,[],indata{1},indata{2});