function pc=compare_aoi_fit(oneargout,images,pixwidth,ave,folder,parenthandles)
%
% function compare_aoi_fit(oneargout,images,pixwidth,ave,folder,handles)
%
% A function for comparing the aoifits we obtain using gauss2d_mapstruc.m
% (gui is imscroll, outputs in structure 'aoifits') with the original image
% data.  The output will be two images of dimension pixwidth+1.  One
% image will be centered on the aoi from the original raw data, and the
% other image will be the gaussian fit to the aoi data.  The output will be
% in the form of two stacked matrices (a three dimensional matrix).
%
% oneargout  =[aoinumber framenumber aml xzero yzero sigma offset intAOI]
%               (one line from the aoifit.dat member of the aoifit
%               structure output by our imscroll gui)
% images     == the m x n x frames threee dimensional stacked array of image
%                  data
% pixwidth  == the output images will be of size pixwidth+1
% ave == the number of frames averaged in the fitting process
%               (specified in aoifit.parameter(1) )
% folder == the folder location of the images to be read
% handles == the handles array from the GUI

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


frmnum=oneargout(2);                            % The framenumber that we fit
                                                % Get the averaged image
                                                % data
%presentframe=sum(images(:,:,frmnum:frmnum+ave-1),3);
%presentframe=imdivide(presentframe,ave);

dum=images(:,:,1);

%a b]=size(dum);
%um=uint16(zeros(a,b));


dum=imsubtract(dum,dum);


presentframe=getframes(dum,images,folder,parenthandles);

                                                 % Form the fit to our data
fitfrm=gauss2dfit_eval(double(presentframe),oneargout(1,3:7));
                                                 % Pick off the region of
                                                 % interest surrounding our
                                                 % aoi
ycenter=round(oneargout(5));
xcenter=round(oneargout(4));
xargs=( xcenter-round((pixwidth-1)/2) ):( xcenter+round( (pixwidth-1)/2) );
yargs=( ycenter-round((pixwidth-1)/2) ):( ycenter+round( (pixwidth-1)/2) );

pc=zeros(length(yargs),length(xargs),2);
pc(:,:,1)=presentframe(yargs,xargs);
pc(:,:,2)=fitfrm(yargs,xargs);



