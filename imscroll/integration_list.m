function pc=integration_list(xzero,yzero,pixnum_1,pixnum_2,imagematrix)
%
% function pc=integration_list(xzero,yzero,pixnum_1,pixnum_2,imagematrix)
%
% A tool for Danny's FRET calculation.  This will aid in finding the proper
% location of the large AOI used for background subtraction.  The function
% will vary the center of the large AOI and calculate the resulting
% integral for the AOI in the imagematrix.  An output list will contain the
% value of the integral indexed by the center x and center y value for the
% position of the AOI.
%
% xzero == x center of the small aoi containing the fluorescent spot of
%    interest
% yzero == y center of the small aoi contianing the fluorescent spot of
%    interest
% pixnum_1 == full width of the intermediate AOI that should be larger than
%        the spot of interest, thus containing all of the spot intensity
% pixnum_2 == full width of the large AOI that will be used for background
%        subtraction.  This should contain several times the pixel number
%        of the intermediate aoi  (i.e. (pixnum_2)^2 several times the
%        pixel number of (pixnum_1)^2
% imagematrix== image intensity matrix containing the fluorescent spots.
%       This is the image that will be used to compute the integrations
pc=[];
                % Lower edges of the intermediate AOI
xlow1=round(xzero-pixnum_1/2);
ylow1=round(yzero-pixnum_1/2);               
                % Higher edges of the intermediate AOI
xhi1=round(xlow1+pixnum_1-1);
yhi1=round(ylow1+pixnum_1-1);

% We now allow the center of the large AOI to vary.  It will always be a size 
% of pixnum_2 x pixnum_2, and will always contain the intermediate AOI 
% inside of it.  Other than that, the center will be allowed to be anywhere
            % Vary low edges of large AOI
          
for xlow2_vary=(xhi1-pixnum_2+1):xlow1
    for ylow2_vary=(yhi1-pixnum_2+1):ylow1
              % Define the high edges of the large AOI
        xhi2_vary=round(xlow2_vary+pixnum_2-1);
        yhi2_vary=round(ylow2_vary+pixnum_2-1);
                % Integrate the large AOI
        int=sum(sum(imagematrix(ylow2_vary:yhi2_vary, xlow2_vary:xhi2_vary) ));
                % Define the center of the large AOI.  The 0.01 is intended
                % to insure that the later integration routine properly
                % finds the AOI edge when it rounds the pixel coordinates
        xcenter2=xlow2_vary+pixnum_2/2-0.01;
        ycenter2=ylow2_vary+pixnum_2/2-0.01;
        [a b]=size(imagematrix(ylow2_vary:yhi2_vary, xlow2_vary:xhi2_vary) );
        pc=[pc; xcenter2 ycenter2 int a b];
    end
end
