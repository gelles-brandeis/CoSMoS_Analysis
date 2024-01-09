function pc=SpotCoefficients_GridSearch(imagein,Red,Orange,Green,pjkRange)
%
% function SpotCoefficients_GridSearch(imagein,Red,Orange,Green,bRange,pjkRange)
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
% pjkRange == grid in p j and k over which the search is conducted
%
% output.grid=[b p j k]'   optimized values for b p j and k values
%                 calculated using a grid search with spacing = 'delta'
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
S=double(imagein);        % Use more compact notation
R=double(Red);
O=double(Orange);
G=double(Green);
mn=min(min(S));
mx=max(max(S));
brange=mn:1:mx;         % Grid for b (background) values ranges from the min to max of S
I=ones(size(S));
bindx=mn;                   % Starting value of background b
pc.chisq=sum(sum( (bindx*I+ 0*R+ 0*O+ 0*G- S).^2)); % Starting value of chisquare
pc.grid=[mn pjkRange(1)*ones(1,3)];   % Starting value of [b p j k]

for pindx=pjkRange
    for jindx=pjkRange
        for kindx=pjkRange
           %keyboard
            dfit=(S-(bindx*I +pindx*R + jindx*O + kindx*G) );
            mnd=min(min(dfit));
            mxd=max(max(dfit));
            meen=mean(mean(dfit));
            %for bindx=(pc.grid(1)+meen-(mx-mn)):(pc.grid(1)+meen+(mx-mn))
            for bindx=(pc.grid(1)+meen-(50)):10:(pc.grid(1)+meen+(50))
            %for bindx=-200:0
                chisq=sum(sum( (bindx*I +pindx*R + jindx*O + kindx*G -S).^2));
                if chisq<pc.chisq
                    pc.chisq=chisq;
                    pc.grid=[bindx pindx jindx kindx];
                end
            end
        end
    end
end


