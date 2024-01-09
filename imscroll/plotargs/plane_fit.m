function pc=plane_fit(arg,data)
%
% function plane_fit(arg,data)
%
% To be used in conjuction with the Matlab function 'fminsearch' in
% order to fit data to a plane:
%
%   z(x,y) = x*A1 +y*A2 + A3
%
%
%  
% User must supply the input arguement as a starting parameter in
% 'fmins' as follows:
%   argout = fminsearch('plane_fit',arg,[],data);
%
% arg == [A1   A2    A3]  first guess of input parameters
%           Use program 'plane_fit_first_guess(p1,p2,p3) to obtain 
%           starting guess for [A1  A2  A3]
% data == [xi   yi   zi]  set of data points that lie on the plane 
%
% 
% pc= sum((data(:,2)-(arg(1)*exp(-data(:,1)*arg(2) )  ) ).^2);

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

A1=arg(1);
A2=arg(2);
A3=arg(3);
zfunc=A1*data(:,1) +A2*data(:,2) + A3;                    
pc= sum( (data(:,3)- zfunc ).^2 );

