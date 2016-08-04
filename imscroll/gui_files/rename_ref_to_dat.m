% This script should need to be RUN ON ONE OCCASION, specifically at 
% the first time a user installs the imscroll program.  
% This script will copy and rename all the *.ref files in the directory of
% this script to *.dat files for use with the imscroll analysis gui.
% The *.dat files in this directory are used by imscroll to save a user's
% intermediate results.  Updating the imscroll program through github will
% only update the *.ref files and leave the *.dat files untouched.  This
% means that subsequent updating of the imscroll program will not alter a users
% *.dat files.  This script affords the means to first provide a starting
% set of *.dat files, while avoiding any overwrite of those *.dat files
% when a user updates the imscroll program.

[PATH,NAME,EXT]=fileparts(mfilename('fullpath'));   % Retrieve path, etc for this script
refnames=dir([PATH '/*.ref']);                  % list of file names in directory of this script
numfiles =size(refnames);                       % Number of files in this director
%keyboard
for indx=1:numfiles
   
    % Need to get the length of each file name, then use that 
    % length minus 3 (removing 'ref') in the destination,
    % and append the 'dat ' to the end of the name instead
     namenum=length(refnames(indx).name);        % Length of the filename, including the 'ref' suffix
            % Copy the file, replacing the 'ref' suffix with 'dat'
   copyfile([PATH '/' refnames(indx).name],[PATH '/' refnames(indx).name(1:namenum-3) 'dat'])
end

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

