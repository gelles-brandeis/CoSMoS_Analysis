function pc=plane_fit_LinearLeastSquares(data)
%
%  function plane_fit_LinearLeastSquares(data)
%
%  fit data to a plane:
%
%   z(x,y) = x*A1 +y*A2 + A3
%
%
%  
% data == [xi   yi   zi]  set of data points that lie on the plane 
% output == [A1   A2    A3]  parameters describing best least squares
%                         fit to a plane
%
%  Output is set of [A1   A2    A3] parameters that minimize the 
% least squares sum:
% pc= sum((data(:,3)- A1*data(:,1)-A2*data(:,2)-A3 ).^2);
%
% Expressions for A1, A2 and A3 are found analytically, so this should be
% faster than the iterative fit in plane_fit(arg,data)

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

x=data(:,1);  
y=data(:,2);
z=data(:,3);
N=length(x);        % Number of points in the data
R1=sum(x)/N;  r1=sum(x);   
R2=sum(y)/N;  r2=sum(y); 
R3=sum(z)/N;  r3=sum(z);
s1=sum(x.^2);
s2=sum(y.^2);
m1=sum(x.*y);
m2=sum(x.*z);
m3=sum(y.*z);
G=(s2-R2*r2)/(m1-R1*r2);
H=(m3 - R2*r3)/(m1-R1*r2);
I=(R1*G-R2);
K=(R3-R1*H);

%keyboard
A1=-G*(s1*H + r1*K-m2)/(s1*G - m1 - r1*I) + H;

A2 = (s1*H + r1*K -m2)/(s1*G - m1 - r1*I);

A3= I*(s1*H + r1*K - m2)/(s1*G - m1 - r1*I)  + K;

pc=[A1 A2 A3];

% Works!
