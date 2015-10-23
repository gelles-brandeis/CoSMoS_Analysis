function pc=guimacavi(images,loindx,hiindx,dispscale,avifolder,frmave,handles)
%
% function guimacavi(images,loindx,hiindx,dispscale,avifolder,frmave,handles)
%
% This function will return a movie after reading in images from one of 
% JC and LF files of  iccd data.  The user can take the output and play 
% it as a movie (e.g. movie(pc) )
%
% images == the (rows) x (columns) x (frm #) matrix of images used for
%        making the avi 
% loindx == the low number for the index of the file.  For example, if
%        the user wants a movie containing files 5 through 45 the user
%        will set loindx=5 and hiindx = 45
% hiindx == the high number for the index of the file
% dispscale == [min max] sets the scale for the image display
% avifolder == folder in which avi will be placed
% 
% frmave = the number of frames to average.  This will be a running ave
%        (careful not to exceed number of frames: hiindx only to maxfrm#-frmave)
% handles == the 'handles' structure from the gui.  This allows us to
%           access such things as the magnified frame limits

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

dum=images(:,:,1);
dum=imsubtract(dum,dum);
   if get(handles.Magnify,'Value')==1      % =1 to plot the magnified image
       limitsxy=eval(get(handles.MagRangeYX,'String'));
                                                % = [xlo xhi ylo yhi]
   else
       [ros col]=size(dum);
       limitsxy=[1 col 1 ros];                  % Use entire image              
   end

movieindx=1;
colormap(gray(256));
for inum = loindx : hiindx					% read in images to be averaged

%      figure(1);surf(double(imread([imfold filenum],'tiff'))-50,...
%         'Edgecolor','none');camlight left;lighting phong;view([-25 80]);axis([0 100 0 100 0 25])

%      figure(1);surf(double(imread([imfold filenum],'tiff'))-50,'Facecolor','red',...
%         'Edgecolor','none');camlight left;lighting phong;view([-25 80]);axis([0 100 0 100 0 25])
%      figure(1);pcolor(double(imread([imfold tiff_name(inum)],'tiff'))-50 );caxis([5 35]);colorbar;shading flat
%    figure(1);image(imread([imfold tiff_name(inum)],'tiff') );colormap(gray(256));figure(1)
   %     if flagg==1
%        dum=movframes(:,:,inum);
        dum=imdivide(sum(images(:,:,inum:inum+frmave-1),3) ,frmave);      
    %    else
  
%        dum=imread([imfold tiff_name(inum)],'tiff') ;
     %   dum=readstacked(imfold,inum:inum+frmave-1);
     %   dum=imdivide(sum(dum,3) ,frmave);
          %   end
   
%    figure(3);imagesc(dum(:,1:300),dispscale);colormap(gray(256));axis('equal');axis('off');set(gcf,'color','white')
dum=double(dum);
                                                % Now scale the image to be
                                                % between 0 and 255, using
                                                % just the image
                                                % intensities set by
                                                % 'dispscale'
                                                % Following johnson's
                                                % tiff2movie() mfile
    hilim=dispscale(2);lolim=dispscale(1);
                                                % Set all above hilim to
                                                % equal hilim value
   dum=dum.*(dum<=hilim) +hilim*(dum>hilim);
                                                % Set all below lolim to
                                                % equal lolim value
   dum=dum.*(dum>=lolim)+lolim*(dum<lolim);
                                                % Now map the image to be
                                                % between 1 and 255
   dum=(dum-lolim)/(hilim-lolim)*254 +1;
                                                % Pick out the aoi limits
    dum=dum(limitsxy(3):limitsxy(4),limitsxy(1):limitsxy(2));
   
   
   pc(movieindx)=im2frame(dum,gray(256));
   	movieindx=movieindx+1;
    if movieindx/20==round(movieindx/20)
        movieindx
    end
end                                                % End of for loop
%if mkavi =='yes'
    sprintf('making an avi file \n')

    movie2avi(pc,avifolder,'fps',10,'quality',100,'compression','none');
%end
%caxis('auto')
pc=1;                                           % output just the number 1
