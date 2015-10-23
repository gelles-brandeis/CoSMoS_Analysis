function pc=gauss2d_seq_ave(dum,images,folder,frms,xypt,pixnum,handles,varargin)
%
% function gauss2d_seq_ave(dum,images,folder,frm,xypt,pixnum,handles,<stinarg>)
%
% This function will apply a gaussian fit to an AOI in a series of images.
% dum == a dummy zeroed frame for fetching and averaging images
% images == a m x n x numb array of input images
% folder == folder in which the tiff files are located (Glimpse output)
%           e.g. = 'p:\image_data\notebook_sequences\b5p12a\'
% frmstart == starting frame number for processing
% frmend   == ending frame number for processing
% frms  == vector of frame numbers that will be processec
% xpt  ==  [ x y]  coordinates for the AOI center,  intended to the output
%            from a ginput command.
% pixnum == the width of and AOI to process. i.e. the aoi will be 
%           pixnum x pixnum in dimension
% handles == the handles array from the GUI
% stinarg  == the <optional> set of starting parameters for the first frame
%                [amp centerx centery omega offset]
%
%  The function will make use of repeated applications of gauss2dfit.m

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


inlength=length(varargin);  
                                                % Fetch the first frame
%firstfrm=imread([imfold tiff_name(frms(1))],'tiff');
%firstfrm=imread([imfold cook_name(frms(1))],'tiff');
firstfrm=getframes_fit(dum,images,folder,frms(1),handles);             %*****NEED TO CHANGE IMREAD
                                                % Define the AOI for
                                                % processing
                 
xlow=round(xypt(1)-pixnum/2);xhi=xlow+pixnum-1;
ylow=round(xypt(2)-pixnum/2);yhi=ylow+pixnum-1;
firstaoi=firstfrm(ylow:yhi,xlow:xhi);

                                                % Grab the starting
                                                % parameters if they are
                                                % present
                    
 if inlength>0
    inputarg0=varargin{1}(:);                   %amp=varargin{1}(1);
                                                %centerx=varargin{1}(2);
                                                %omegax=varargin{1}(3);
                                                %centery=varargin{1}(4);
                                                %omegay=varargin{1}(5);
                                                %offset=varargin{1}(6);
                                                
    else                                        % Here to guess at inputarg)
    mx=double( max(max(firstaoi)) );
    mn=double( mean(mean(firstaoi)) );
    inputarg0=[mx-mn pixnum/2 pixnum/2 pixnum*.2 mn];                                            
end
                                            % Loop through fitting successive
                                            % image frames
pc=[];
          
for frmindx=frms

    if frmindx/20==round(frmindx/20)
        save p:\matlab12\larry\data\intermed.dat pc
        frmindx
    end
%    frm=imread([imfold tiff_name(frmindx)],'tiff');  % ****NEED TO CHANGE
                                                        %IMREAD STATMENT
  %  frm=imread([imfold cook_name(frmindx)],'tiff');
%    frm=imread([imfold],'tiff',frmindx);
                                                    % Get the current
                                                    % averaged frame
frm=getframes_fit(dum,images,folder,frmindx,handles);
    aoi=frm(ylow:yhi,xlow:xhi);

    argout=gauss2dfit(double(aoi),double(inputarg0));   % Fit the current aoi
                                                  % Reference the gaussian
    argstore=argout;                              % centerx and centeryto 
    argstore(2)=xlow+argstore(2)-1;               % to the initial array
    argstore(3)=ylow+argstore(3)-1;
                                                  % Recalculate xlow,ylow
                                                  % so as to move the aoi
                                                  % along with a moving gaussian
    xlow=round(argstore(2)-pixnum/2);xhi=xlow+pixnum-1;
    ylow=round(argstore(3)-pixnum/2);yhi=ylow+pixnum-1;
    inputarg0=argout
    inputarg0(2)=argstore(2)-xlow+1;              % Adjust the next start centerx,y
    inputarg0(3)=argstore(3)-ylow+1;              % to reflect the moved aoi
    argout'
    argstore'
    inputarg0'
    pc=[pc;frmindx argstore'];
end
