function pc=BinaryOnly01(Bin2013)
%
% function BinaryOnly01(Bin2013)
%
% Will be used as part of the editing process in plotargout gui.  The
% Bin2013 (N x 2) array will have low=-2,0,2 and high=-3,1,3.  This
% function will merely create a true binary trace that defines low=0 and
% high = 1 alwarys.  The output true binary trace will be the same size as
% the input.
%Bin2013 = [N x 2] matrix with low defined alternately as -2,0 or 2 and high
%         defined as alternately -3,1 or 3

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

[rosebin colbin]=size(Bin2013);
for indx=1:rosebin
    if any(Bin2013(indx,2)==[-3 1 3])
        Bin2013(indx,2)=1;
    elseif any(Bin2013(indx,2)==[-2 0 2])
        Bin2013(indx,2)=0;
    end
end
pc=Bin2013;
