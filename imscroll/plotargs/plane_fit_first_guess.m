function pc=plane_fit_first_guess(p1, p2, p3)
%
% function plane_fit_first_guess(p1, p2, p3)
%
% To be used to obtain first guess for fitting parameters [A1  A2  A3] 
% order to fit data to a plane:
%
%   z(x,y) = x*A1 +y*A2 + A3
%
%
% p1 == [x1  y1  z1], one of the data points (used to obtain first 
%      guess of A1, A2 and A3 
% p2 == [x2  y2  z2], one of the data points (used to obtain first 
%      guess of A1, A2 and A3 
% p1 == [x3  y3  z3], one of the data points (used to obtain first 
%      guess of A1, A2 and A3 
% 
% Output = [A1  A2  A3]  parameters in above equation for a plane that
%         contains the points p1, p2 and p3
% 
%  See notes from 11/10/2018

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

% components of vector p2-p1
%alpha1=p2(1)-p1(1);
%alpha2=p2(2)-p1(2);
%alpha3=p2(3)-p1(3);
% components of vector p3-p1
%beta1=p3(1)-p1(1);
%beta2=p2(2)-p1(2);
%beta3=p3(3)-p1(3);
% components of cross product between (p2-p1) X (p3-p1) (which is
% perpendicular to our plane)
gamma=cross(p2-p1,p3-p1);   % vector Gamma =
                            % gamma(1) i  + gamma(2) j   + gamma(3) k

% A point P=[x y z] in the plane will obey (P - p1) (dot product) Gamma = 0
% yielding the equation
% z= -x (gamma(1)/gamma(3))  - y (gamma(2)/gamma(3))  - (gamma4/gamma(3)), where
% gamma=[gamma1  gamma2 gamma3] is defined in the above cross product, and
gamma4= -(gamma(1)*p1(1) + gamma(2)*p1(2) + gamma(3)*p1(3) );

% This yields
A1=-gamma(1)/gamma(3);
A2=-gamma(2)/gamma(3);
A3=-gamma4/gamma(3);
pc=[A1 A2 A3];

