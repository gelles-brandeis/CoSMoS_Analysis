function pc=PlotImageClasses(aoiImageSet, ClassNumbers, fignums)
%
% function PlotImageClasses(aoiImageSet, ClassNumbers,fignums)
%
%  This routine will plot the xy positions of all the AOIs within the
%  input 'aoiImageSet' contained in each image class listed in
%  'ClassNumbers'.  Intended as an aid to see spatial distributions of the
%  AOIs in the FOV
%
% aoiImageSet == an aoiImageSet found using imscroll().  See
%           Update_aoiImageSet() header, type 'help Update_aoiImageSet'.
% ClassNumbers == M x 1 vector those classes whose xy coordinates will be 
%           plotted by this routine.  Identify the classes using an integer
%           according to:    [ROG RO RG OG R O G Z] = 1:8'
% fignums == M x 1 vector listing the figure numbers that will be used to
%           plot the xy coordinates.  Dimensions must match that of
%           ClassNumbers.

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



[roseCN colCN]=size(ClassNumbers);
if colCN>roseCN
    % insure ClassNumbers is a column
    ClassNumbers=ClassNumbers';
end

[roseFN colFN]=size(fignums);
if colFN>roseFN
    % insure fignums is a column
    fignums=fignums';
end
[roseCN colCN]=size(ClassNumbers);
[roseFN colFN]=size(fignums);
if (roseCN~=roseFN)|(colCN~=colFN)
            % Error check to insure the number of figures matches the number of specified classes 
    error('size of ClassNumbers and fignums must match')
end
colorCell{1}='ROG';colorCell{2}='RO';colorCell{3}='RG';
colorCell{4}='OG';colorCell{5}='R';colorCell{6}='O';
colorCell{7}='G';colorCell{8}='Z';
for indx=1:roseCN
    logik=aoiImageSet.ClassNumber==ClassNumbers(indx);
    xycoord=aoiImageSet.aoiinfoTotx(logik,3:4);
    figure(fignums(indx));plot(xycoord(:,1),xycoord(:,2),'o');title(['Class ' colorCell{ClassNumbers(indx)} ':' num2str(sum(logik))]);shg
end
