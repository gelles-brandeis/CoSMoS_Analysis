function pc=SpotCoefficients_PositiveNonlinear(argin,imagein,Red,Orange,Green)
% 
% function SpotCoefficients_PositiveNonlinear(imagein,Red,Orange,Green)
%
% Given a test 'image' that is comprised of a linear combination of Red, 
% Orange and Green spot images  (b*I+p*Red+j*Orange+k*Green), this routine 
% will calculate the optimum numerical values of (b, p, j, k).  Defining
%
%    ChiSq=sum( (b*I+ abs(p)*Red+ abs(j)*Orange+ abs(k)*Green- image).^2)
%
% (I= all ones), the routine calculates the (b,p,j,k) set that minimizes
% the ChiSq value.
% Note that the background coefficient may be + or -, but the coefficients
% of the Red, Orange and Green contributions are all positive definite.
% imagein == m x n image of fluorescent spots comprised of some combination
%        of offset Red, Orange and Green spots in the prism 
%        dispersed microscope.
% Red == m x n image of the offset red fluorescent spot 
% Orange == m x n image of the offset orange fluorescent spot
% Green == m x n image of the offset green fluorescent spot
%
% Usage:  argout=fminsearch('SpotCoefficients_PositiveNonlinear',argin,[],imagein,Red,Orange,Green)
%

% output.math=[b p j k]'   optimized values for b p j and k values
%                 calculated using algebraic expressions (via  mathematica)
% output.matlab=[b p j k]'   optimized values for b p j and k values
%                 calculated numerically (via  matlab function)
% output.chisq==sum(sum( (S -b*ones(size(S))-p*R - j*O - k*G).^2 ));  % Chi squared difference of fit
% See notes from 3/8/2016  also B31p120a_two_color_oligos_calibration_test.doc for equations  

% Copyright 2016 Larry Friedman, Brandeis University.

% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this software. If not, see <http://www.gnu.org/licenses/>.

S=double(imagein);        % Use more compact notation, following 3/8/2016 notes
R=double(Red);
O=double(Orange);
G=double(Green);
b=argin(1);
p=abs(argin(2));
j=abs(argin(3));
k=abs(argin(4));
                    % Sum of squares difference between our linear combination of 
                    % nearby calibration Red, Orange and Green spots and
                    % the unknown image S.  Note that the background can be
                    % positive or negative, but the contributions from each
                    % of the calibration spots must be positive.
pc=sum(sum((b+p*R+j*O+k*G-S).^2));