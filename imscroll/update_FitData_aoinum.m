function pc=update_FitData_aoinum(FitData)
%
% function update_FitData_aoinum(FitData)
%
% After altering the aoi list, you need to reorder the aoinumbers so that
% no values are skipped.  Otherwise other programs get confused due to
% having aoi numbers that are greater than the total number of aois.  This
% function takes care of that task.

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

[aoinum b]=size(FitData);                % a = number of aois in the list

                                    % Number the aois without skipping any
                                    % values
                                    % column 6 contains the unique aoi number
pc=FitData;
for indx=1:aoinum
    pc(indx,6)=indx;
end
