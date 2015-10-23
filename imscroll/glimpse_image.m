function pc=glimpse_image(folder,gheader,image_number)
%
% function glimpse_image(folder,gheader,image_number)
%
% Will retrieve one image from a glimpse-saved image sequence.
%
% folder == full path to the glimpse-saved folder containing the series of
%           glimpse files
% gheader == structure contained in the 'header.mat' file within the folder
%          specified by 'folder' variable.  The gheader members will be
%          for example:
%           moviefile: 'd:\glimpse\larryfj00269\header.glimpse'
%         username: 'larryfj'
%        description: [1x0 char]
%            nframes: 13206
%           time1: 3.2470e+009
%                ttb: [1x13206 double]
%          depth: 1
%         offset: [1x13207 double]
%     filenumber: [1x13207 double]
%          width: 302
%         height: 512 
%
% image_number == the image frame that the user wants this function to
%               retrieve and output from the glimpse-saved sequence
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

fid=fopen([folder  num2str(gheader.filenumber(image_number)) '.glimpse'],'r','b');
         % Above will open the appropriate image-containing file in 'read' 
         % mode as a big endian byte ordering format 
         %
         % Next, position the file position pointer at the location of the
         % desired image   (referenced to 'bof' == beginning of file )
fseek(fid,gheader.offset(image_number),'bof');
         % Now retrieve the image
         %
pc=fread(fid,[gheader.width,gheader.height],'int16=>int16');
            % Now convert output to same range and data type as the tiff
            % files we deal with
pc=uint16(pc+32768);
fclose(fid);
