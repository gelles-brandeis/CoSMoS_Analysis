function pc=NextFrame(increment,handles)
%
% This function will be used to increment the frame number that is being
% displayed in imscroll.  In a typical run we jump between fields, and the
% frames pertinent for a particular field may be irregularly spaced.  To 
% increment the frame number we will note which field we wish to view, and
% then use the handles.fieldfrms cell array to specify the pertinent
% frames for each field.
%
% increment == +-number of frames to nominally increment the current frame
%         number (sign sensitive i.e positive or negative).  It is a
%         'nominal' increment because we still need to use a frame number
%         pertinent to the field we are viewing.  The actual frame we jump
%         to will therefore be closest to CurrentFrame+increment that is 
%         still a view of the particular field we are viewing
% handles== handles structure of the gui

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


[Y I]=min(abs(CurrentFrameset-CurrentFrame-increment));  % Find the frame number
                                        % in the current frame set that is
                                        % closest to CurrentFrame+increment
                                        % Note that increment may by + or -
pc=CurrentFrameset(I);                  % Output the new frame to display
