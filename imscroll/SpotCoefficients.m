function pc=SpotCoefficients(imagein,Red,Orange,Green)
%
% function SpotCoefficients(imagein,Red,Orange,Green)
%
% Given a test 'image' that is comprised of a linear combination of Red, 
% Orange and Green spot images  (b*I+p*Red+j*Orange+k*Green), this routine 
% will calculate the optimum numerical values of (b, p, j, k).  Defining
%
%    ChiSq=sum( (b*I+ p*Red+ j*Orange+ k*Green- image).^2)
%
% (I= all ones), the routine calculates the (b,p,j,k) set that minimizes
% the ChiSq value.
% imagein == m x n image of fluorescent spots comprised of some combination
%        of offset Red, Orange and Green spots in the prism 
%        dispersed microscope.
% Red == m x n image of the offset red fluorescent spot 
% Orange == m x n image of the offset orange fluorescent spot
% Green == m x n image of the offset green fluorescent spot
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
            % Now define all the terms appearing in our matrix of equations
            % that must be solved
[rose col]=size(S);
m=rose*col;
A=sum(sum(R));
B=sum(sum(O));
C=sum(sum(G));
D=sum(sum(S));
Z=sum(sum(R.*R));
F=sum(sum(R.*O));
E=sum(sum(R.*G));
H=sum(sum(R.*S));
L=sum(sum(O.*R));
N=sum(sum(O.*O));
Q=sum(sum(O.*G));
T=sum(sum(O.*S));
V=sum(sum(G.*R));
W=sum(sum(G.*O));
X=sum(sum(G.*G));
Y=sum(sum(G.*S));
                % Defining:
 % mat=[ m A B C; A Z F E; B L N Q; C V W X]
 % bb=[D H T Y]' ;   (notes from 3/8/2016)
 % We wish to solve for b p j and k in the equation:  mat*[b p j k]' = bb
 % The solution may be found by explicitly solving for the algegraic
 % expression (done in Mathematica) or just letting Matlab solve it
 % numberically.  I expect the expression will be faster (but they look
 % really messy).
b=(-D*E*N*V + C*H*N*V + D*F*Q*V - B*H*Q*V - C*F*T*V + B*E*T*V +... 
    D*E*L*W - C*H*L*W + A*H*Q*W - A*E*T*W - D*F*L*X + B*H*L*X -... 
    A*H*N*X + A*F*T*X + C*F*L*Y - B*E*L*Y + A*E*N*Y - A*F*Q*Y -... 
    D*Q*W*Z + C*T*W*Z + D*N*X*Z - B*T*X*Z - C*N*Y*Z +... 
    B*Q*Y*Z)/((C^2)*F*L - B*C*E*L + A*C*E*N - A*C*F*Q - B*C*F*V +... 
    (B^2)*E*V + A*C*N*V - E*m*N*V - A*B*Q*V + F*m*Q*V - A*B*E*W -... 
    A*C*L*W + E*L*m*W + (A^2)*Q*W + A*B*F*X + A*B*L*X - F*L*m*X -... 
    (A^2)*N*X - (C^2)*N*Z + B*C*Q*Z + B*C*W*Z - m*Q*W*Z - (B^2)*X*Z +... 
    m*N*X*Z);

p=(C*D*E*N - (C^2)*H*N - C*D*F*Q + B*C*H*Q + (C^2)*F*T -... 
    B*C*E*T - B*D*E*W + B*C*H*W + A*D*Q*W - H*m*Q*W - A*C*T*W +... 
    E*m*T*W + B*D*F*X - (B^2)*H*X - A*D*N*X + H*m*N*X + A*B*T*X -... 
    F*m*T*X - B*C*F*Y + (B^2)*E*Y + A*C*N*Y - E*m*N*Y - A*B*Q*Y +... 
    F*m*Q*Y)/((C^2)*F*L - B*C*E*L + A*C*E*N - A*C*F*Q - B*C*F*V +... 
    (B^2)*E*V + A*C*N*V - E*m*N*V - A*B*Q*V + F*m*Q*V - A*B*E*W -... 
    A*C*L*W + E*L*m*W + (A^2)*Q*W + A*B*F*X + A*B*L*X - F*L*m*X -... 
    (A^2)*N*X - (C^2)*N*Z + B*C*Q*Z + B*C*W*Z - m*Q*W*Z - (B^2)*X*Z +... 
    m*N*X*Z);

j=(-C*D*E*L + (C^2)*H*L - A*C*H*Q + A*C*E*T + B*D*E*V -... 
    B*C*H*V - A*D*Q*V + H*m*Q*V + A*C*T*V - E*m*T*V + A*B*H*X +... 
    A*D*L*X - H*L*m*X - (A^2)*T*X - A*B*E*Y - A*C*L*Y + E*L*m*Y +... 
    (A^2)*Q*Y + C*D*Q*Z - (C^2)*T*Z - B*D*X*Z + m*T*X*Z + B*C*Y*Z -... 
    m*Q*Y*Z)/((C^2)*F*L - B*C*E*L + A*C*E*N - A*C*F*Q - B*C*F*V +... 
    (B^2)*E*V + A*C*N*V - E*m*N*V - A*B*Q*V + F*m*Q*V - A*B*E*W -... 
    A*C*L*W + E*L*m*W + (A^2)*Q*W + A*B*F*X + A*B*L*X - F*L*m*X -... 
    (A^2)*N*X - (C^2)*N*Z + B*C*Q*Z + B*C*W*Z - m*Q*W*Z - (B^2)*X*Z +... 
    m*N*X*Z);

k=(-(-(-B*D + m*T)*(-A*C + m*V) + (-A*B + L*m)*(-C*D +... 
           m*Y))*((-A*B + F*m)*(-A*B + L*m) - (-B^2 + m*N)*(-A^2 +... 
          m*Z)) + (-B*C*L*m + A*C*m*N + (B^2)*m*V - (m^2)*N*V - A*B*m*W +... 
       L*(m^2)*W)*((-A*D + H*m)*(-A*B + L*m) - (-B*D + m*T)*(-A^2 +... 
          m*Z)))/(-(-(-B*C + m*Q)*(-A*C + m*V) + (-A*B + L*m)*(-C^2 +... 
           m*X))*((-A*B + F*m)*(-A*B + L*m) - (-(B^2) + m*N)*(-A^2 +... 
          m*Z)) + (-B*C*L*m + A*C*m*N + (B^2)*m*V - (m^2)*N*V - A*B*m*W +... 
       L*(m^2)*W)*((-A*C + E*m)*(-A*B + L*m) - (-B*C + m*Q)*(-A^2 +... 
          m*Z)));

mathematicapc=[b p j k]';      
      %Next, iterative fit using Matlab function
%*** mat=[ m A B C; A Z F E; B L N Q; C V W X];
 %*** bb=[D H T Y]' ;
 %*** matlabpc= mat\bb;    
 
 pc.math=mathematicapc;         % Algebraic solution from mathematic equations
 pc.chisq=sum(sum( (S -b*ones(size(S))-p*R - j*O - k*G).^2 ));  % Chi squared difference for fit
 %***pc.matlab=matlabpc;          % Numerical Matlab solution
      
      
      
      
      %{
Within Mathematica:
mt = {{m, A, B, C}, {A, Z, F, E}, {B, L, N, Q}, {C, V, W, X}}
bb = {D, H, T, Y}

LinearSolve[mt, bb]

{(-D E N V + C H N V + D F Q V - B H Q V - C F T V + B E T V + 
    D E L W - C H L W + A H Q W - A E T W - D F L X + B H L X - 
    A H N X + A F T X + C F L Y - B E L Y + A E N Y - A F Q Y - 
    D Q W Z + C T W Z + D N X Z - B T X Z - C N Y Z + 
    B Q Y Z)/(C^2 F L - B C E L + A C E N - A C F Q - B C F V + 
    B^2 E V + A C N V - E m N V - A B Q V + F m Q V - A B E W - 
    A C L W + E L m W + A^2 Q W + A B F X + A B L X - F L m X - 
    A^2 N X - C^2 N Z + B C Q Z + B C W Z - m Q W Z - B^2 X Z + 
    m N X Z),         (C D E N - C^2 H N - C D F Q + B C H Q + C^2 F T - 
    B C E T - B D E W + B C H W + A D Q W - H m Q W - A C T W + 
    E m T W + B D F X - B^2 H X - A D N X + H m N X + A B T X - 
    F m T X - B C F Y + B^2 E Y + A C N Y - E m N Y - A B Q Y + 
    F m Q Y)/(C^2 F L - B C E L + A C E N - A C F Q - B C F V + 
    B^2 E V + A C N V - E m N V - A B Q V + F m Q V - A B E W - 
    A C L W + E L m W + A^2 Q W + A B F X + A B L X - F L m X - 
    A^2 N X - C^2 N Z + B C Q Z + B C W Z - m Q W Z - B^2 X Z + 
    m N X Z),      (-C D E L + C^2 H L - A C H Q + A C E T + B D E V - 
    B C H V - A D Q V + H m Q V + A C T V - E m T V + A B H X + 
    A D L X - H L m X - A^2 T X - A B E Y - A C L Y + E L m Y + 
    A^2 Q Y + C D Q Z - C^2 T Z - B D X Z + m T X Z + B C Y Z - 
    m Q Y Z)/(C^2 F L - B C E L + A C E N - A C F Q - B C F V + 
    B^2 E V + A C N V - E m N V - A B Q V + F m Q V - A B E W - 
    A C L W + E L m W + A^2 Q W + A B F X + A B L X - F L m X - 
    A^2 N X - C^2 N Z + B C Q Z + B C W Z - m Q W Z - B^2 X Z + 
    m N X Z),         (-(-(-B D + m T) (-A C + m V) + (-A B + L m) (-C D + 
           m Y)) ((-A B + F m) (-A B + L m) - (-B^2 + m N) (-A^2 + 
          m Z)) + (-B C L m + A C m N + B^2 m V - m^2 N V - A B m W + 
       L m^2 W) ((-A D + H m) (-A B + L m) - (-B D + m T) (-A^2 + 
          m Z)))/(-(-(-B C + m Q) (-A C + m V) + (-A B + L m) (-C^2 + 
           m X)) ((-A B + F m) (-A B + L m) - (-B^2 + m N) (-A^2 + 
          m Z)) + (-B C L m + A C m N + B^2 m V - m^2 N V - A B m W + 
       L m^2 W) ((-A C + E m) (-A B + L m) - (-B C + m Q) (-A^2 + 
          m Z)))}
 %}
 