function pc=RemoveFalseNegatives(BinaryTrace,Min0)
%
% function RemoveFalseNegatives(BinaryTrace,Min0)
% 
% ****Operates on the entire input trace 'BinaryTrace'
% Will remove low events ('0' intervals) whose duration in frames is less
% than Min0.  The input 'BinaryTrace' represents the portion of the 
% binary trace between the very first (-2/-3) and very last (2/3) events.
% That is, the 'BinaryTrace' consists of only 0's and 1's for each frame,
% and this function will remove those streches of 0's that are under Min0
% frames in duration.
%
% BinaryTrace == 1 x N input trace consisting of 0's and 1's.  Each entry
%              in this vector represents one frame in a trace.
% Min0 == minumum number of frames for a continuous series of 0's .  If a
%      continuous series of 0's lasts under Min0 in duration, then this
%      function will change that series of 0's into 1's.  e.g is Min0 = 4
%      then [0 0 0 0 1 1 0 0 0 1 0 0 0 0 0] -> [0 0 0 0 1 1 1 1 1 1 0 0 0 0 0]
[rose col]= size(BinaryTrace);
if min(rose, col) ~=1
    %keyboard
    error('BinaryTrace must be a 1 D vector')
end
if (Min0~=round(Min0)) | (Min0 <1)
    error('Min0 must be a positive integer')
end

if rose > col
    BinaryTrace=BinaryTrace';          % Insures the BinaryTrace is a row vector
end
    % We will now move through the trace and look for 1's.  Following eacy
    % 1 that we find we will check whether it is followed by a string of
    % consecutive 0's that are less than Min0 in duration.  If so, we will
    % replace the 0's with 1's.
Frms=length(BinaryTrace);              % Number of frames in BinaryTrace

dumBinaryTrace=[1 BinaryTrace 1];      % Place 1's on both ends of trace
indx1=1;                               % Index of the '1' we are working with
         % Next loop searchs for the next entry of 1
         
while indx1<Frms+1
    
    if dumBinaryTrace(indx1+1)==0
        
         % Here if next entry is a 0
         flagg=0;                      % flagg will be set to 1 if a 1 entry is found
         indxMin=0;                     % Initialize interval length
        while (indxMin<Min0) & (flagg==0)
           
                                       % Here search for index of the next 1: 
                                       % If the index of the next 1 is less than    
                                       % Min0 greater than the present indx1 value
                                       % then we need to change all the intervening
                                       % 0's to 1's
             if dumBinaryTrace(indx1+indxMin+1)==0
                        % Here if next entry is a 0
                 indxMin=indxMin+1;     % Increment interval index
             else
                 flagg=1;               % Found a 1 entry, so set end of 0 interval flagg
             end
             
        end                             % end of searching for a 1 that terminates a 0 interval
              % Here if we find the next 1 following a too short string of 0's OR if we have a string of 0's
              % that is at least as long as Min0
         if indxMin<Min0
             dumBinaryTrace(indx1+1:indx1+1+indxMin-1) =1;        % Interval of 0's was too short,--> replace with 1's
             indx1=indx1+indxMin;
         else
              % Here if the 0's interval was NOT too short --> we still need to find the next 1 
             indx1 = indx1+Min0;        % Interval of 0's was beyond miniimum, so increment indx1 by Min0
             interval0=0;               % length of additional interval of 0's (already min0 in length)
             
            
             while (dumBinaryTrace(indx1+interval0+1)==0) & (indx1+interval0<Frms+1)
                
                                       % Keep going until/unless our
                                       % additional interval reaches  end of the dumBinaryTrace vector
                 interval0=interval0+1; % Increment interval0 b/c next entry is a 0 (zero)
             end
             if indx1+interval0<Frms+1
                 indx1=indx1+interval0;     % Did not reach end of dumBinaryTrace befor encountering a 1
             else
                 indx1=Frms+1;              % Reached end of dumBinaryTrace w/o encountering a 1 entry
             end
                     
         end
         
              
    else
         % Here if verey next entry beyond indx1 is a 1
            indx1=indx1+1;              % Increment index for the current 1 entry
    end
    
        
end

BinaryTrace=dumBinaryTrace(2:2+Frms-1);
pc=BinaryTrace;
                
        
    
