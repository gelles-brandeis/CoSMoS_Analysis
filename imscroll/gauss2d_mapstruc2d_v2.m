function pc=gauss2d_mapstruc2d_v2(mapstruc_cell,parenthandles)
%
% function gauss2d_mapstruc2d_v2(mapstruc_cell,parenthandles,handles)
%
% This function will apply a gaussian fit to aois in a series of images.
% The aois and frames will be specified in the mapstruc structure
% images == a m x n x numb array of input images
% mapstruc_cell == structure array each element of which specifies:
% mapstruc_cell{i,j} will be a 2D cell array of structures, each structure with
%  the form (i runs over frames, j runs over aois)
%    mapstruc_cell(i,j).aoiinf [frame# ave aoix aoiy pixnum aoinumber]
%               .startparm (=1 use last [amp sigma offset], but aoixy from mapstruc_cell 
%                           =2 use last [amp aoix aoiy sigma offset] (moving aoi)
%                           =-1 guess new [amp sigma offset], but aoixy from mapstruc_cell 
%                           =-2 guess new [amp sigma offset], aoixy from last output
%                                                                  (moving aoi)
%               .folder 'p:\image_data\may16_04\b7p18c.tif'
%                             (image folder)
%               .folderuse  =1 to use 'images' array as image source
%                           =0 to use folder as image source
% dum == a dummy zeroed frame for fetching and averaging images
% images == a m x n x numb array of input images
% folder == the folder location of the images to be read
%       
% parenthandles == the handles arrary from the top level gui
% handles == the handles array from the GUI
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


%dum=images(:,:,1);
% v1: Use AOI_Limits() function to consistently define AOI size for
% integration and fitting
% v2: attempting to modify variables to allow parallel processing 
%       changing 'for' loop to a 'parfor' loop
%dum=imsubtract(dum,dum);     % zeroed data frame
%pc.ImageData=[];
%pc.BackgroundData=[];

FirstImageData=[];
FirstBackgroundData=[];
Radius=parenthandles.RollingBallRadius;
Height=parenthandles.RollingBallHeight;

                             % get the first averaged frame/aoi
firstfrm=fetchframes_mapstruc_cell_v1(1,mapstruc_cell,parenthandles);

if any(get(parenthandles.BackgroundChoice,'Value')==[2 3])
                        % Here to use rolling ball background
   
    BackgroundFirstFrame=rolling_ball(firstfrm,Radius,Height);
else 
                        % Here to use Danny's newer background subtraction
    BackgroundFirstFrame=bkgd_image(firstfrm,Radius,Height);
end

%BackgroundFirstFrame=rolling_ball(firstfrm,Radius,Height);
[nfrms naois]=size(mapstruc_cell);      % naois =number of aois, nfrms=number of frames
                                    % Get the sigma value from the editable
                                    % text region for gaussina fit with
                                    % fixed sigma
sigma=str2num(get(parenthandles.SigmaValueString,'String'));
                                      
%****rowindex=0;                 % Initialize the row index for the pre allocated arrays
                            % pc.ImageData, and pc.BackgroundData
                            % Cycle over all the aois, first frame only

if isfield(parenthandles,'Pixnums')==0
            % Here if user did not set the small AOI size for integration
            % when gaussian fitting with a fixed sigma
    parenthandles.Pixnums(1)=mapstruc_cell{1,1}.aoiinf(5); % Width of aoi in first aoi
    guidata(gcbo,parenthandles)
elseif isempty(parenthandles.Pixnums)
            % Here if parenthandles.Pixnums exists but is empty.  Set to
            % pixnum for first aoi
    parenthandles.Pixnums(1)=mapstruc_cell{1,1}.aoiinf(5); % Width of aoi in first aoi
    guidata(gcbo,parenthandles)
end

%****if get(parenthandles.FitChoice,'Value')==4
%****    ImageData(naois*nfrms,:)=zeros(1,9);
%****    BackgroundData(naois*nfrms,:)=zeros(1,9);
%****else
%****    ImageData(naois*nfrms,:)=zeros(1,8);
%****    BackgroundData(naois*nfrms,:)=zeros(1,8);
%****end
                    % Pre-Allocate space
if get(parenthandles.FitChoice,'Value')==4
    % Gauss2dxy+int
    ImageDataParallel(:,:,nfrms)=zeros(naois,9);    % (aoiindx,DataEntryIndx,FrmIndx)
                                                    % Stacked matrices with
                                                    % each matrix containing the data for all the aois        
                                                    % in one frame.
    BackgroundDataParallel(:,:,nfrms)=zeros(naois,9);
else
    ImageDataParallel(:,:,nfrms)=zeros(naois,8);
    BackgroundDataParallel(:,:,nfrms)=zeros(naois,8);
end
                    % Pre-Allocate space
LastxyLowHigh(naois,:)=zeros(1,4);          % When gaussian tracking an aoi we must use the last xy location    
LastxyLowHighSmall(naois,:)=zeros(1,4);     % as input to the next xy fit.  Hence we store the last set of xy values
                                            % for just one frame. 

for aoiindx=1:naois
%****rowindex=rowindex+1;
                % Limits for the aoi
aoiy=mapstruc_cell{1,aoiindx}.aoiinf(4);  % Y (row) Center of aoi
aoix=mapstruc_cell{1,aoiindx}.aoiinf(3);  % X (col)center of aoifram
pixnum=mapstruc_cell{1,aoiindx}.aoiinf(5); % Width of aoi
[xlow xhi ylow yhi]=AOI_Limits([aoix aoiy],pixnum/2);
LastxyLowHigh(aoiindx,:)=[xlow xhi ylow yhi];
        % Use the next AOI limits for integration of a small AOI when
        % fitting a gaussian (with fixed sigma) to the larger AOI
[xlowsmall xhismall ylowsmall yhismall]=AOI_Limits([aoix aoiy],parenthandles.Pixnums(1)/2);
LastxyLowHighSmall(aoiindx,:)=[xlowsmall xhismall ylowsmall yhismall];
%ylow=round(aoiy-pixnum/2);xlow=round(aoix-pixnum/2);
%yhi=round(ylow+pixnum-1);xhi=round(xlow+pixnum-1);
firstaoi=firstfrm(ylow:yhi,xlow:xhi);
        % Again, use the following AOI for integration of a small AOI when
        % fitting a gaussian (with fixed sigma) to the larger AOI
firstaoismall=firstfrm(ylowsmall:yhismall,xlowsmall:xhismall);
                            % starting parameters for fit
                            %[ ampl xzero yzero sigma offset]
 mx=double( max(max(firstaoi)) );
 mn=double( mean(mean(firstaoi)) );
 inputarg0=[mx-mn pixnum/2 pixnum/2 pixnum/4 mn]; 
  switch (get(parenthandles.FitChoice,'Value'))
                               
      case 1                                % Here to fit and integrate the spot

                            % Now fit the first frame aoi
      outarg=gauss2dfit(double(firstaoi),double(inputarg0));
                            % Reference aoixy to original frame pixels for
                            % storage in output array.
      %pc.ImageData=[mapstruc(1).aoiinf(1) outarg(1) outarg(2)+xlow-1 outarg(3)+ylow-1 outarg(4) outarg(5) sum(sum(firstaoi))];
                   % [(aoi #)               amp          xzero         yzero       sigma      offset    (int intensity) ]  
      %aoiinf = %[(frms columun vec)  ave         x         y                           pixnum                       aoinum]
      % aoiinf is a column vector with (number of rows)= number of frames to be processed
      % The x and y coordinates already contain the shift from DriftList (see build_mapstruc.m)
                     % [aoi#     frm#       amp    xo    yo    sigma  offset (int inten)]  
      FirstImageData=[aoiindx   mapstruc_cell{1,aoiindx}.aoiinf(1)   outarg(1)   outarg(2)+xlow   outarg(3)+ylow   outarg(4)   outarg(5)   sum(sum(firstaoi))];
      %pc.ImageData=[pc.ImageData;aoiindx mapstruc_cell{1,aoiindx}.aoiinf(1) outarg(1) outarg(2)+xlow outarg(3)+ylow outarg(4) outarg(5) sum(sum(firstaoi))];
      case 2
     % Here if we only integrate the aoi, not fitting
                               % the spot to a gaussian.  Note that we
                               % retain the original aoi coordinates, but
                               % have a zero offset in our output matrix
      FirstImageData=[aoiindx mapstruc_cell{1,aoiindx}.aoiinf(1:5) 0 sum(sum(firstaoi))];
      %pc.ImageData=[pc.ImageData;aoiindx mapstruc_cell{1,aoiindx}.aoiinf(1:5) 0 sum(sum(firstaoi))];
      case 3                % Here to integrate spot, moving center.
                            % We find the max only within the original aoi, and center our aoi about 
                            % this maximum point.  The spot max can
                            % therefore move only within the chosen aoi. Any further and we lose it
      maxind=maxfind(firstaoi);
      maoix=maxind(2)+xlow-1;maoiy=maxind(1)+ylow-1;    % x and y for aoi maximum, with indices referenced 
                                                      % to the original image frame
      [mxlow mxhi mylow myhi]=AOI_Limits([maoix maoiy],pixnum/2);
%      mylow=round(maoiy-pixnum/2);mxlow=round(maoix-pixnum/2);
%      myhi=round(mylow+pixnum-1);mxhi=round(mxlow+pixnum-1);
      mfirstaoi=firstfrm(mylow:myhi,mxlow:mxhi);
                % [frame# amp xcenter ycenter sigma offset (int aoi)]
                % (aoi# added later as first element in each row)
      FirstImageData=[aoiindx mapstruc_cell{1,aoiindx}.aoiinf(1) 0 maoix maoiy 0 0 sum(sum(mfirstaoi))];
      %pc.ImageData=[pc.ImageData;aoiindx mapstruc_cell{1,aoiindx}.aoiinf(1) 0 maoix maoiy 0 0 sum(sum(mfirstaoi))];
      
      case 4                            % Here to fit to 2D gaussian
                                    % Fit the first aoi
                                    %[amplitude xo sigx yo sigy bkgnd]
      outarg=gauss2dxyfit(double(firstaoi),double([mx-mn pixnum/2  pixnum/4 pixnum/2 pixnum/4 mn]) );
        %  [ aoi#    frm#    ampl.    xo   sigmax   yo   sigmay    offset   (int inten)  ]   
      FirstImageData=[aoiindx mapstruc_cell{1,aoiindx}.aoiinf(1) outarg(1) outarg(2)+xlow outarg(3) outarg(4)+ylow outarg(5) outarg(6) sum(sum(firstaoi))];
%      FirstImageData=[aoiindx mapstruc_cell{1,aoiindx}.aoiinf(1) outarg(1) outarg(2)+xlow-1 outarg(3) outarg(4)+ylow-1 outarg(5) outarg(6) sum(sum(firstaoi))];
      %pc.ImageData=[pc.ImageData; aoiindx mapstruc_cell{1,aoiindx}.aoiinf(1) outarg(1) outarg(2)+xlow-1 outarg(3) outarg(4)+ylow-1 outarg(5) outarg(6) sum(sum(firstaoi))];
      case 5                            
                                   % Here to just integrate the AOI using a
                                   % linear interpolation for when the AOI
                                   % only partially overlaps pixels
       shiftedx=mapstruc_cell{1,aoiindx}.aoiinf(3);
       shiftedy=mapstruc_cell{1,aoiindx}.aoiinf(4);
       FirstImageData=double([aoiindx mapstruc_cell{1,aoiindx}.aoiinf(1:5) 0 double(linear_AOI_interpolation(firstfrm,[shiftedx shiftedy],pixnum/2)) ]);
       %pc.ImageData=double([pc.ImageData;aoiindx mapstruc_cell{1,aoiindx}.aoiinf(1:5) 0 double(linear_AOI_interpolation(firstfrm,[shiftedx shiftedy],pixnum/2)) ]); 
       case 6                       
                                   % Here to integrate both the image AND
                                   % the background (for later subtraction)
                                   % Here to just integrate the AOI using a
                                   % linear interpolation for when the AOI
                                   % only partially overlaps pixels
                                   % First integrate the data
       shiftedx=mapstruc_cell{1,aoiindx}.aoiinf(3);
       shiftedy=mapstruc_cell{1,aoiindx}.aoiinf(4);
       FirstImageData=double([aoiindx mapstruc_cell{1,aoiindx}.aoiinf(1:5) 0 double(linear_AOI_interpolation(firstfrm,[shiftedx shiftedy],pixnum/2)) ]);
       %pc.ImageData=double([pc.ImageData;aoiindx mapstruc_cell{1,aoiindx}.aoiinf(1:5) 0 double(linear_AOI_interpolation(firstfrm,[shiftedx shiftedy],pixnum/2)) ]);
                                   % Then integrate the background
       shiftedx=mapstruc_cell{1,aoiindx}.aoiinf(3);
       shiftedy=mapstruc_cell{1,aoiindx}.aoiinf(4);
       FirstBackgroundData=double([ aoiindx mapstruc_cell{1,aoiindx}.aoiinf(1:5) 0 double(linear_AOI_interpolation(BackgroundFirstFrame,[shiftedx shiftedy],pixnum/2)) ]);
       %pc.BackgroundData=double([ pc.BackgroundData;aoiindx mapstruc_cell{1,aoiindx}.aoiinf(1:5) 0 double(linear_AOI_interpolation(BackgroundFirstFrame,[shiftedx shiftedy],pixnum/2)) ]);
       case 7                                % Here to fit and integrate the spot
                            %  inputarg0 = [ ampl xzero yzero sigma offset]
                            % Now fit the first frame aoi
              % Note: inputarg now skips sigma:  put in as a fixed value
              % the outarg will be [amp x y offset] (skips sigma)
              
      outarg=gauss2dfit_fixed_sigma(double(firstaoi),double([inputarg0(1:3) sigma inputarg0(5)]));
               
                            % Reference aoixy to original frame pixels for
                            % storage in output array.
      %pc.ImageData=[mapstruc(1).aoiinf(1) outarg(1) outarg(2)+xlow-1 outarg(3)+ylow-1 outarg(4) outarg(5) sum(sum(firstaoi))];
                   % [(aoi #)               amp          xzero         yzero       sigma      offset    (int intensity) ]  
      %aoiinf = %[(frms columun vec)  ave         x         y                           pixnum                       aoinum]
      % aoiinf is a column vector with (number of rows)= number of frames to be processed
      % The x and y coordinates already contain the shift from DriftList (see build_mapstruc.m)
      FirstImageData=[aoiindx mapstruc_cell{1,aoiindx}.aoiinf(1) outarg(1) outarg(2)+xlow outarg(3)+ylow sigma outarg(4) sum(sum(firstaoismall))];
      %pc.ImageData=[pc.ImageData;aoiindx
      %mapstruc_cell{1,aoiindx}.aoiinf(1) outarg(1) outarg(2)+xlow outarg(3)+ylow outarg(4) outarg(5) sum(sum(firstaoi))];
       case 8 

        [1 aoiindx]   
                                   % Here for prism-dispersed imaging.  We
                                   % identify to which class the image belongs. 
                                   % classes: [ROG RO RG OG R O G Z]= 1:8
                                   % 
                                   % shiftedx=mapstruc_cell{1,aoiindx}.aoiinf(3);         
                                  % shiftedy=mapstruc_cell{1,aoiindx}.aoiinf(4);
       oneaoiinfo2=mapstruc_cell{1,aoiindx}.aoiinf;         % [frame# ave aoix aoiy pixnum aoinumber]
                                                    % Note: aoix and aoiy are drift-corrected already (inside build_2d_mapstruc_aois_frms() ) 
       HalfOutputImageSize= parenthandles.aoiImageSet.HalfOutputImageSize;    % Image region boundaries defined
                                                                        % by the current aoiImageSet, which
                                                           % should be the calibration aoiImageSet w/ examplex
                                                         % of each single dye class of image = R, O or G
                                                         
       RegisterFlag=0;                                      % =0  => register the image
       RoundingPixelFraction=[0 0];                         % Register image to pixel center
                                        % Fetch image from region offset around AOI and register
                                        % image so AOI is centered on a pixel (gfoloder image source --add tiff tif later):
      
       ExImageStruc=RegisterImage(parenthandles.gfolder,oneaoiinfo2,HalfOutputImageSize,RoundingPixelFraction, RegisterFlag);
       ExImage=uint16(sum(ExImageStruc.frames,3)/oneaoiinfo2(1,2)); % Registered averaged image.  This image will be classified as 1:8
                % Next, get the tstR, tstO, tstG from handles.aoiImageSet
                 % and then call SpotCoefficients( )
       ExImage_xy=oneaoiinfo2(1,3:4);   % Drift-corrected xy for this AOI      
       NearR=Nearest_Images(ExImage_xy,5,parenthandles.aoiImageSet,5);        % 5 nearest R calibration images
       NearO=Nearest_Images(ExImage_xy,6,parenthandles.aoiImageSet,5);        % 5 nearest O calibration images
       NearG=Nearest_Images(ExImage_xy,7,parenthandles.aoiImageSet,5);        % 5 nearest G calibration images 
       %SC=SpotCoefficients(ExImage,NearR.AveImage,NearO.AveImage,NearG.AveImage);   % Find optimized [b p j k] values: linear least squares
                            %Find optimized [b p j k] values: nonlinear
                            %least squares for which p,j,k>0, but b is unconstrained  
       options=optimset('fminsearch');
        options.MaxFunEvals=500000;
        options.TolFun=1e-6;
        options.TolX=1e-6;
        options.MaxIter=10000;
       SC=fminsearch('SpotCoefficients_PositiveNonlinear',[-150 .5 .5 .5],options,ExImage,NearR.AveImage,NearO.AveImage,NearG.AveImage);
                           %[ (aoi#)  (frm#) (b)  (p) (j) (k) (shiftedx) (shiftedy) ] 
       %FirstImageData=double([aoiindx oneaoiinfo2(1,1) SC.math' ExImage_xy ]);
      FirstImageData=double([aoiindx oneaoiinfo2(1,1) SC(1) abs(SC(2:4)) ExImage_xy ]);
                                   
    
 
 end            %END of switch
    %****if rowindex==1
            %Here for very first entry, should reach here only once
            % Allocate here b/c number of columns may differ 
        %****[nrosefirst ncolfirst]=size(FirstImageData);
                                            % Pre allocate space for arrays
        %****pc.ImageData(naois*nfrms,:)=zeros(1,ncolfirst);
        %****ImageData(naois*nfrms,:)=zeros(1,ncolfirst);
        %****pc.BackgroundData(naois*nfrms,:)=zeros(1,ncolfirst);
        %****BackgroundData(naois*nfrms,:)=zeros(1,ncolfirst);
    %****end

%****pc.ImageData(rowindex,:)=FirstImageData;    % Put data into output structure
%ImageData(aoiindx,:)=FirstImageData;    % Put data into output structure
ImageDataParallel(aoiindx,:,1)=FirstImageData;  %(aoiindx, DataIndx, FrameIndx)
    %****if ~isempty(FirstBackgroundData)
    if get(parenthandles.FitChoice,'Value')==6
            % Here only if FirstBackgroundData actually contains computed entries 
                            % If we are computing background, just
                            % place the first data into
                            % pc.BackgroundData
        %****pc.BackgroundData(rowindex,:)=FirstBackgroundData;
        %****BackgroundData(aoiindx,:)=FirstBackgroundData;
        BackgroundDataParallel(aoiindx,:,1)=FirstBackgroundData; % (aoiindx,  DataIndx,  FrameIndx)
    end
end             % End of aoiindx loop through all the aois for the first frame


                            %Now loop through the remaining frames


%****for framemapindx=2:nfrms
 for framemapindx=2:nfrms
    
                            % Print/save intermediates results
      if framemapindx/10==round(framemapindx/10)
       % save p:\matlab12\larry\data\intermed.dat pc
        framemapindx
      end
                            % Get the next averaged frame to process
     currentfrm=fetchframes_mapstruc_cell_v1(framemapindx,mapstruc_cell,parenthandles);
     if get(parenthandles.FitChoice,'Value')==6
        
                    % Here if user wants the background computed (this
                    % requires a couple seconds, so we only compute it if
                    % the user wants it
         if any(get(parenthandles.BackgroundChoice,'Value')==[2 3])
                        % Here to use rolling ball background
             BackgroundCurrentFrame=rolling_ball(currentfrm,Radius,Height);
         else 
                        % Here to use Danny's newer background subtraction
             BackgroundCurrentFrame=bkgd_image(currentfrm,Radius,Height);
         end
         
     else
         BackgroundCurrentFrame=currentfrm;
     end

switchvalue=get(parenthandles.FitChoice,'Value');
     parfor aoiindx2=1:naois   % Loop through all the aois for this frame

         %****rowindex=rowindex+1;                       % Increment row index
%****    [mpc npc]=size(pc.ImageData);                  % Get the last outputs
     %lastoutput=pc.ImageData(mpc,:);                % ImageData has the same form as aoifits

     pixnum=mapstruc_cell{framemapindx,aoiindx2}.aoiinf(5); % Width of current aoi

        % 3/8/2011: Note the following two lines (first line commented out).
        % There was some apparent confusion as to the meaning of the startparm variable.
        % It is, of course indicative of whether the aois move with the DriftList (=2 3 or 4 
        % if moving with DriftList) but here is was being interpreted as indicating that
        % the gaussian fit would progress by using the last output [x  y] gaussian center
        % as the center of the next aoi:  the aoi could then move off very
        % quickly.  The statement as now stands will keep the aoi being fit as merely the
        % aoi with a center that moves according to DriftList (the moving aoi information
        % is already specified in the mapstruc stucture)
     
     %if abs( mapstruc(framemapindx).startparm )==2
     %if abs( mapstruc_cell{framemapindx,aoiindx2}.startparm )==10000      % This will never be true:  keeps the aoi being
                                                            % fit as just the original aoi subject to some
                                                            % movement as specified in DriftList 
  
     
     %tst1=get(parenthandles.TrackAOIs,'Value')                                                       
     %****if get(parenthandles.TrackAOIs,'Value')==1
         
                            % Here for moving aoi (last output aoixy)
                            % Find data row with the current aoi and the
                            % last frame number processed
                 %   (aoi# in data list == current aoi#) & (frame# in data list==last frm# processed) ;
         %****logik=(pc.ImageData(:,1)==aoiindx2) &(pc.ImageData(:,2)==mapstruc_cell{framemapindx-1,aoiindx2}.aoiinf(1));
         %****logik=(ImageData(:,1)==aoiindx2) &(ImageData(:,2)==mapstruc_cell{framemapindx-1,aoiindx2}.aoiinf(1));
         %****lastoutput=pc.ImageData(logik,:);
         %****lastoutput=ImageData(logik,:);
         %****[xlow xhi ylow yhi]=AOI_Limits([lastoutput(4) lastoutput(5)],pixnum/2);
         %****[xlow xhi ylow yhi]=LastxyLowHigh(aoiindx2-1,:);
         %keyboard
%         ylow=round(lastoutput(4)-pixnum/2);xlow=round(lastoutput(3)-pixnum/2);
%         yhi=round(ylow+pixnum-1);xhi=round(xlow+pixnum-1);
     %****else                   % should have startparm ==1 if here  
                            % Here for aoi coordinates listed in mapstruc
                            % (fixed aoi, or a list of different aois)
         %****aoiy=mapstruc_cell{framemapindx,aoiindx2}.aoiinf(4);  % Y (row) Center of aoi
         %****aoix=mapstruc_cell{framemapindx,aoiindx2}.aoiinf(3);  % X (col)center of aoi  
         %****[xlow xhi ylow yhi]=AOI_Limits([aoix aoiy],pixnum/2);
               % Use the next AOI limits for integration of a small AOI when
               % fitting a gaussian (with fixed sigma) to the larger AOI
         %****[xlowsmall xhismall ylowsmall yhismall]=AOI_Limits([aoix aoiy],parenthandles.Pixnums(1)/2);
         %****[xlow xhi ylow yhi]=LastxyLowHigh(aoiindx2-1,:);
         %****[xlowsmall xhismall ylowsmall yhismall]=LastxyLowHighSmall(aoiindx2-1,:);
%         ylow=round(aoiy-pixnum/2);xlow=round(aoix-pixnum/2);
%         yhi=round(ylow+pixnum-1);xhi=round(xlow+pixnum-1);
     %****end                    % END of if..else
 

     TempLastxy=LastxyLowHigh(aoiindx2,:);
     xlow=TempLastxy(1);xhi=TempLastxy(2);ylow=TempLastxy(3);yhi=TempLastxy(4);
     TempLastxySmall=LastxyLowHighSmall(aoiindx2,:);
     xlowsmall=TempLastxySmall(1);xhismall=TempLastxySmall(2);
     ylowsmall=TempLastxySmall(3);yhismall=TempLastxySmall(4);
     currentaoi=currentfrm(ylow:yhi,xlow:xhi);
        % Again, use the following AOIfor integration of a small AOI when
        % fitting a gaussian (with fixed sigma) to the larger AOI

     currentaoismall=currentfrm(ylowsmall:yhismall,xlowsmall:xhismall);
     
                            % For now, always guess at starting parameters
     
     mx=double( max(max(currentaoi)) );
     mn=double( mean(mean(currentaoi)) );
     inputarg0=[mx-mn pixnum/2 pixnum/2 pixnum/4 mn];
    
                            % Now fit the current aoi

%     switch (get(parenthandles.FitChoice,'Value'))
     switch switchvalue
                               
         case 1                                % Here to fit and integrate the spot
          
      
          
         outarg=gauss2dfit(double(currentaoi),double(inputarg0));
%****         pc.ImageData(rowindex,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) outarg(1) outarg(2)+xlow outarg(3)+ylow outarg(4) outarg(5) sum(sum(currentaoi))];
         %****pc.ImageData((framemapindx-1)*naois+aoiindx2,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) outarg(1) outarg(2)+xlow outarg(3)+ylow outarg(4) outarg(5) sum(sum(currentaoi))];
         %****ImageData((framemapindx-1)*naois+aoiindx2,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) outarg(1) outarg(2)+xlow outarg(3)+ylow outarg(4) outarg(5) sum(sum(currentaoi))];
         ImageDataParallel(aoiindx2,:,framemapindx)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) outarg(1) outarg(2)+xlow outarg(3)+ylow outarg(4) outarg(5) sum(sum(currentaoi))];
 %       pc.ImageData(rowindex,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) outarg(1) outarg(2)+xlow-1 outarg(3)+ylow-1 outarg(4) outarg(5) sum(sum(currentaoi))];
         case 2
         % Here if we only integrate the aoi, not fitting
                               % the spot to a gaussian.  Note that we
                               % retain the original aoi coordinates, but
                               % have a zero offset in our output matrix
%****         pc.ImageData(rowindex,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1:5) 0 sum(sum(currentaoi))];
         %****pc.ImageData((framemapindx-1)*naois+aoiindx2,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1:5) 0 sum(sum(currentaoi))];
         %****ImageData((framemapindx-1)*naois+aoiindx2,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1:5) 0 sum(sum(currentaoi))];
         ImageDataParallel(aoiindx2,:,framemapindx)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1:5) 0 sum(sum(currentaoi))];
         
         case 3     % Here to integrate spot, moving center with max.
                            % We find the max only within the original aoi, and center our aoi about 
                            % this maximum point.  The spot max can
                            % therefore move only within the chosen aoi. Any further and we lose it
         maxind=maxfind(currentaoi);
         maoix=maxind(2)+xlow-1;maoiy=maxind(1)+ylow-1;    % x and y for aoi maximum, with indices referenced 
                                                      % to the original image frame
         [mxlow mxhi mylow myhi]=AOI_Limits([maoix maoiy],pixnum/2);
%         mylow=round(maoiy-pixnum/2);mxlow=round(maoix-pixnum/2);
%         myhi=round(mylow+pixnum-1);mxhi=round(mxlow+pixnum-1);
         mcurrentaoi=currentfrm(mylow:myhi,mxlow:mxhi);
                % [frame# amp xcenter ycenter sigma offset (int aoi)]
                
                % (aoi# added later as first element in each row)
%****         pc.ImageData(rowindex,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) 0 maoix maoiy 0 0 sum(sum(mcurrentaoi))];
         %****pc.ImageData((framemapindx-1)*naois+aoiindx2,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) 0 maoix maoiy 0 0 sum(sum(mcurrentaoi))];
         %****ImageData((framemapindx-1)*naois+aoiindx2,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) 0 maoix maoiy 0 0 sum(sum(mcurrentaoi))];
         ImageDataParallel(aoiindx2,:,framemapindx)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) 0 maoix maoiy 0 0 sum(sum(mcurrentaoi))];
        case 4     % Here to fit spot with 2D gaussian
        outarg=gauss2dxyfit(double(currentaoi),double([mx-mn pixnum/2  pixnum/4 pixnum/2 pixnum/4 mn]) );
%****        pc.ImageData(rowindex,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) outarg(1) outarg(2)+xlow outarg(3) outarg(4)+ylow outarg(5) outarg(6) sum(sum(currentaoi))];
        %****pc.ImageData((framemapindx-1)*naois+aoiindx2,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) outarg(1) outarg(2)+xlow outarg(3) outarg(4)+ylow outarg(5) outarg(6) sum(sum(currentaoi))];
        %****ImageData((framemapindx-1)*naois+aoiindx2,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) outarg(1) outarg(2)+xlow outarg(3) outarg(4)+ylow outarg(5) outarg(6) sum(sum(currentaoi))];
        ImageDataParallel(aoiindx2,:,framemapindx)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) outarg(1) outarg(2)+xlow outarg(3) outarg(4)+ylow outarg(5) outarg(6) sum(sum(currentaoi))];
%       pc.ImageData(rowindex,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) outarg(1) outarg(2)+xlow-1 outarg(3) outarg(4)+ylow-1 outarg(5) outarg(6) sum(sum(currentaoi))];
        case 5
                                   % Here to just integrate the AOI using a
                                   % linear interpolation for when the AOI
                                   % only partially overlaps pixels
       shiftedx=mapstruc_cell{framemapindx,aoiindx2}.aoiinf(3);
       shiftedy=mapstruc_cell{framemapindx,aoiindx2}.aoiinf(4);
%****       pc.ImageData(rowindex,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1:5) 0 double(linear_AOI_interpolation(currentfrm,[shiftedx shiftedy],pixnum/2))];
       %****pc.ImageData((framemapindx-1)*naois+aoiindx2,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1:5) 0 double(linear_AOI_interpolation(currentfrm,[shiftedx shiftedy],pixnum/2))];
       %****ImageData((framemapindx-1)*naois+aoiindx2,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1:5) 0 double(linear_AOI_interpolation(currentfrm,[shiftedx shiftedy],pixnum/2))];
       ImageDataParallel(aoiindx2,:,framemapindx)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1:5) 0 double(linear_AOI_interpolation(currentfrm,[shiftedx shiftedy],pixnum/2))];
       
       case 6
                                   % Here to integrate both the image AND
                                   % the background (for later subtraction)
                                   % Here to just integrate the AOI using a
                                   % linear interpolation for when the AOI
                                   % only partially overlaps pixels
                                   % First integrate the data
       shiftedx=mapstruc_cell{framemapindx,aoiindx2}.aoiinf(3);
       shiftedy=mapstruc_cell{framemapindx,aoiindx2}.aoiinf(4);
%****       pc.ImageData(rowindex,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1:5) 0 double(linear_AOI_interpolation(currentfrm,[shiftedx shiftedy],pixnum/2))];
       %****pc.ImageData((framemapindx-1)*naois+aoiindx2,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1:5) 0 double(linear_AOI_interpolation(currentfrm,[shiftedx shiftedy],pixnum/2))];
       %****ImageData((framemapindx-1)*naois+aoiindx2,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1:5) 0 double(linear_AOI_interpolation(currentfrm,[shiftedx shiftedy],pixnum/2))];
       ImageDataParallel(aoiindx2,:,framemapindx)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1:5) 0 double(linear_AOI_interpolation(currentfrm,[shiftedx shiftedy],pixnum/2))];
                                   % Then integrate the background
       shiftedx=mapstruc_cell{framemapindx,aoiindx2}.aoiinf(3);
       shiftedy=mapstruc_cell{framemapindx,aoiindx2}.aoiinf(4);
%****       pc.BackgroundData(rowindex,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1:5) 0 double(linear_AOI_interpolation(BackgroundCurrentFrame,[shiftedx shiftedy],pixnum/2))];
       %****pc.BackgroundData((framemapindx-1)*naois+aoiindx2,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1:5) 0 double(linear_AOI_interpolation(BackgroundCurrentFrame,[shiftedx shiftedy],pixnum/2))];
       %BackgroundData((framemapindx-1)*naois+aoiindx2,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1:5) 0 double(linear_AOI_interpolation(BackgroundCurrentFrame,[shiftedx shiftedy],pixnum/2))];
       %****BackgroundData((framemapindx-1)*naois+aoiindx2,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1:5) 0 double(linear_AOI_interpolation(currentfrm,[shiftedx shiftedy],pixnum/2))];
      % BackgroundDataParallel(aoiindx2,:,framemapindx)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1:5) 0 double(linear_AOI_interpolation(currentfrm,[shiftedx shiftedy],pixnum/2))];
       BackgroundDataParallel(aoiindx2,:,framemapindx)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1:5) 0 double(linear_AOI_interpolation(BackgroundCurrentFrame,[shiftedx shiftedy],pixnum/2))];
       
       case 7                                % Here to fit and integrate the spot
          % Note:the inputarg0 now skips the sigma:  put in as a fixed #
          % The outarg will be [amp x y offset]
       outarg=gauss2dfit_fixed_sigma(double(currentaoi),double([inputarg0(1:3) sigma inputarg0(5)]));
%****       pc.ImageData(rowindex,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) outarg(1) outarg(2)+xlow outarg(3)+ylow sigma outarg(4) sum(sum(currentaoismall))];
       %****pc.ImageData((framemapindx-1)*naois+aoiindx2,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) outarg(1) outarg(2)+xlow outarg(3)+ylow sigma outarg(4) sum(sum(currentaoismall))];
       %****ImageData((framemapindx-1)*naois+aoiindx2,:)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) outarg(1) outarg(2)+xlow outarg(3)+ylow sigma outarg(4) sum(sum(currentaoismall))];
       
                % [aoinumber framenumber amplitude xcenter ycenter sigma offset integrated_aoi (integrated pixnum) (original aoi#)]
       ImageDataParallel(aoiindx2,:,framemapindx)=[aoiindx2 mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) outarg(1) outarg(2)+xlow outarg(3)+ylow sigma outarg(4) sum(sum(currentaoismall))];
       
       %       pc.ImageData(rowindex,:)=[aoiindx2
 %       mapstruc_cell{framemapindx,aoiindx2}.aoiinf(1) outarg(1) outarg(2)+xlow-1 outarg(3)+ylow-1 outarg(4) outarg(5) sum(sum(currentaoi))];

       case 8 
       [framemapindx aoiindx2]                            % Here for prism-dispersed imaging.  We
                                   % identify to which class the image belongs. 
                                   % classes: [ROG RO RG OG R O G Z]= 1:8
                                   % 
                                   % shiftedx=mapstruc_cell{1,aoiindx}.aoiinf(3);         
                                   % shiftedy=mapstruc_cell{1,aoiindx}.aoiinf(4);
                                   
                        % oneaoiinfo2 == information for current frame
                        % number and AOI, (aoix and aoiy already drift corrected) 
       
       oneaoiinfo2=mapstruc_cell{framemapindx,aoiindx2}.aoiinf;         % [frame# ave aoix aoiy pixnum aoinumber]
      
                                                         % Note: aoix and aoiy are drift-corrected already (inside build_2d_mapstruc_aois_frms() ) 
       
       HalfOutputImageSize= parenthandles.aoiImageSet.HalfOutputImageSize;    % Image region boundaries defined
                                                                        % by the current aoiImageSet, which
                                                         % should be the calibration aoiImageSet w/ examplex
                                                         % of each single dye class of image = R, O or G
                                                         
       RegisterFlag=0;                                      % =0  => register the image
       RoundingPixelFraction=[0 0];                         % Register image to pixel center
                                        % Fetch image from region offset around AOI and register
                                        % image so AOI is centered on a pixel (gfoloder image source --add tiff tif later):
       ExImageStruc=RegisterImage(parenthandles.gfolder,oneaoiinfo2,HalfOutputImageSize,RoundingPixelFraction, RegisterFlag);
       ExImage=uint16(sum(ExImageStruc.frames,3)/oneaoiinfo2(1,2)); % Registered averaged image.  This image will be classified as 1:8
                % Next, get the tstR, tstO, tstG from handles.aoiImageSet
                 % and then call SpotCoefficients( )
       ExImage_xy=oneaoiinfo2(1,3:4);   % Drift-corrected xy for this frame number and AOI       
       NearR=Nearest_Images(ExImage_xy,5,parenthandles.aoiImageSet,5);        % 5 nearest R calibration images
       NearO=Nearest_Images(ExImage_xy,6,parenthandles.aoiImageSet,5);        % 5 nearest O calibration images
       NearG=Nearest_Images(ExImage_xy,7,parenthandles.aoiImageSet,5);        % 5 nearest G calibration images 
       %SC=SpotCoefficients(ExImage,NearR.AveImage,NearO.AveImage,NearG.AveImage);   % Find optimized [b p j k] values
                           %[ (aoi#)  (frm#) (b)  (p) (j) (k) (shiftedx) (shiftedy) ]
        options=optimset('fminsearch');
        options.MaxFunEvals=500000;
        options.TolFun=1e-6;
        options.TolX=1e-6;
        options.MaxIter=10000;
        %keyboard
       SC=fminsearch('SpotCoefficients_PositiveNonlinear',[-150 .5 .5 .5],options,ExImage,NearR.AveImage,NearO.AveImage,NearG.AveImage);
                           %[ (aoi#)  (frm#) (b)  (p) (j) (k) (shiftedx) (shiftedy) ] 

       
       %ImageDataParallel(aoiindx2,:,framemapindx)=double([aoiindx2 oneaoiinfo2(1,1) SC.math' ExImage_xy ]);
       ImageDataParallel(aoiindx2,:,framemapindx)=double([aoiindx2 oneaoiinfo2(1,1) SC(1) abs(SC(2:4)) ExImage_xy ]);
      
      
     end            %END of switch
    
           
     end             %END of for loop aoiindx2
    
     
if get(parenthandles.TrackAOIs,'Value')==1
         
                            % Here for moving aoi (last output aoixy)
                            % Save the last fit xy locations 
     for aoiindx3=1:naois
        lastoutput=ImageDataParallel(aoiindx3,:,framemapindx);
        pixnum=mapstruc_cell{framemapindx,aoiindx3}.aoiinf(5); % Width of aoi
        [Txlow Txhi Tylow Tyhi]=AOI_Limits([lastoutput(4) lastoutput(5)],pixnum/2);
        LastxyLowHigh(aoiindx3,:)=[Txlow Txhi Tylow Tyhi];
       [Txlow Txhi Tylow Tyhi]=AOI_Limits([lastoutput(4) lastoutput(5)],parenthandles.Pixnums(1)/2);
        LastxyLowHighSmall(aoiindx3,:)=[Txlow Txhi Tylow Tyhi];
     end
else
        % Here for non-moving aoi, just use fixed aoi coordinates stored in the mapstruc_cell{frm#,aoi#} 
    for aoiindx4=1:naois
        aoiy=mapstruc_cell{framemapindx,aoiindx4}.aoiinf(4);  % Y (row) Center of aoi
        aoix=mapstruc_cell{framemapindx,aoiindx4}.aoiinf(3);  % X (col)center of aoifram
        pixnum=mapstruc_cell{framemapindx,aoiindx4}.aoiinf(5); % Width of aoi
        [xlow xhi ylow yhi]=AOI_Limits([aoix aoiy],pixnum/2);
        LastxyLowHigh(aoiindx4,:)=[xlow xhi ylow yhi];
        % Use the next AOI limits for integration of a small AOI when
        % fitting a gaussian (with fixed sigma) to the larger AOI
        [xlowsmall xhismall ylowsmall yhismall]=AOI_Limits([aoix aoiy],parenthandles.Pixnums(1)/2);
        LastxyLowHighSmall(aoiindx4,:)=[xlowsmall xhismall ylowsmall yhismall];
    end
end

 end           % end of for loop framemapindx


 
%****if rowindex==1
            %Here for very first entry, should reach here only once
            % Allocate here b/c number of columns may differ 
        %****[nrosefirst ncolfirst]=size(FirstImageData);
                                            % Pre allocate space for arrays
        %****pc.ImageData(naois*nfrms,:)=zeros(1,ncolfirst);
        %****ImageData(naois*nfrms,:)=zeros(1,ncolfirst);
        %****pc.BackgroundData(naois*nfrms,:)=zeros(1,ncolfirst);
        %****BackgroundData(naois*nfrms,:)=zeros(1,ncolfirst);
    %****end
                    % Pre-Allocate space
if get(parenthandles.FitChoice,'Value')==4
    pc.ImageData(naois*nfrms,:)=zeros(1,9);    % (aoiindx,DataEntryIndx,FrmIndx)
                                                    % Stacked matrices with
                                                    % each matrix containing the data for all the aois        
                                                    % in one frame.
    pc.BackgroundData(naois*nfrms,:)=zeros(1,9);
else
    pc.ImageData(naois*nfrms,:)=zeros(1,8);
    pc.BackgroundData(naois*nfrms,:)=zeros(1,8);
end
                            % ImageDataParallel(aoiindx,DataEntryIndx,FrmIndx)
                            % Reshaping data matrices for output
                            % The form ImageData and BackgroundData matrices was required to
                            % satisfy the parallel processing loop requirements for indexing  

for frameindex=1:nfrms
    pc.ImageData((frameindex-1)*naois+1:(frameindex-1)*naois+naois,:)=ImageDataParallel(:,:,frameindex);
    pc.BackgroundData((frameindex-1)*naois+1:(frameindex-1)*naois+naois,:)=BackgroundDataParallel(:,:,frameindex); 
end
 
 
 
 

 
     
     
                            % Define the aoi
 %    aoiy=mapstruc(framemapindx).aoiinf(4);  % Y (row) Center of aoi
 %    aoix=mapstruc(framemapindx).aoiinf(3);  % X (col)center of aoi
 %    pixnum=mapstruc(framemapindx).aoiinf(5) % Width of aoi
 %    ylow=round(aoiy-pixnum/2);xlow=round(aoix-pixnum/2);
 %    yhi=round(ylow+pixnum-1);xhi=round(xlow+pixnum-1);
 %    currentaoi=currentfrm(ylow:yhi,xlow:xhi);
                                             % Starting param for fit

                                             
                                             
  %   if mapstruc(framemapindx).startparm==1
  %       [mpc npc]=size(pc);                  % here to use last output
  %       inputarg0=pc(mpc,:);
  
  %   else                                     %  here to guess at new param
  %       mx=double( max(max(currentaoi)) );
  
  %mn=double( mean(mean(currentaoi)) );
   %      inputarg0=[mx-mn pixnum/2 pixnum/2 pixnum/4 mn];     
   %end
     



%inlength=length(varargin);  
                                                % Fetch the first frame
%firstfrm=imread([imfold tiff_name(frms(1))],'tiff');
%firstfrm=imread([imfold cook_name(frms(1))],'tiff');
%firstfrm=getframes_fit(dum,images,folder,frms(1),handles);             %*****NEED TO CHANGE IMREAD
                                                % Define the AOI for
                                                % processing
                 
%ylow=round(xlow=round(xypt(1)-pixnum/2);xhi=xlow+pixnum-1;
%xypt(2)-pixnum/2);yhi=ylow+pixnum-1;
%firstaoi=firstfrm(ylow:yhi,xlow:xhi);

                                                % Grab the starting
                                                % parameters if they are
                                                % present
                    
 %if inlength>0
 %   inputarg0=varargin{1}(:);                   %amp=varargin{1}(1);
                                                %centerx=varargin{1}(2);
                                                %omegax=varargin{1}(3);
                                                %centery=varargin{1}(4);
                                                %omegay=varargin{1}(5);
                                                %offset=varargin{1}(6);
                                                
 %  else                                        % Here to guess at inputarg)
 %   mx=double( max(max(firstaoi)) );
  %  mn=double( mean(mean(firstaoi)) );
  %  inputarg0=[mx-mn pixnum/2 pixnum/2 pixnum*.2 mn];                                            
  %end
                                            % Loop through fitting successive
                                            % image frames
%pc=[];
          
%for frmindx=frms

%    if frmindx/20==round(frmindx/20)
%       save p:\matlab12\larry\data\intermed.dat pc
%        frmindx
%    end
%    frm=imread([imfold tiff_name(frmindx)],'tiff');  % ****NEED TO CHANGE
                                                        %IMREAD STATMENT
  %  frm=imread([imfold cook_name(frmindx)],'tiff');
%    frm=imread([imfold],'tiff',frmindx);
                                                    % Get the current
                                                    % averaged frame
%frm=getframes_fit(dum,images,folder,frmindx,handles);
%    aoi=frm(ylow:yhi,xlow:xhi);

%    argout=gauss2dfit(double(aoi),double(inputarg0));   % Fit the current aoi
                                                  % Reference the gaussian
%    argstore=argout;                              % centerx and centeryto 
%    argstore(2)=xlow+argstore(2)-1;               % to the initial array
%    argstore(3)=ylow+argstore(3)-1;
                                                  % Recalculate xlow,ylow
                                                  % so as to move the aoi
                                                  % along with a moving gaussian
%    xlow=round(argstore(2)-pixnum/2);xhi=xlow+pixnum-1;
%    ylow=round(argstore(3)-pixnum/2);yhi=ylow+pixnum-1;
%    inputarg0=argout
%    inputarg0(2)=argstore(2)-xlow+1;              % Adjust the next start centerx,y
%    inputarg0(3)=argstore(3)-ylow+1;              % to reflect the moved aoi
%    argout'
%    argstore'
%    inputarg0'
%    pc=[pc;frmindx argstore'];
%end
