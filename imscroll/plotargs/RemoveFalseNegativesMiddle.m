function pc=RemoveFalseNegativesMiddle(BinaryTrace,Min0)
%
% function RemoveFalseNegativesMiddle(BinaryTrace,Min0)
% 
% ****Operates on ONLY the middle of the input trace 'BinaryTrace'
% i.e. does not operate on the first and last intervals of 'BinaryTrace'
%
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
    flaggrose=1;                       % BinaryTrace input as column vector
else
    flaggrose=0;                       % BinaryTrace input as row vector
    BinaryTrace=BinaryTrace';          % Insures the BinaryTrace is a column vector
end
    % We will now move through the trace and look for 1's.  Following eacy
    % 1 that we find we will check whether it is followed by a string of
    % consecutive 0's that are less than Min0 in duration.  If so, we will
    % replace the 0's with 1's.

lengthBinary=length(BinaryTrace);       % Length of the input BinaryTrace
dumBinary=[BinaryTrace  [1:lengthBinary]'  BinaryTrace];   % [(0/1)    (frm#)   (0/1)]  
                                        % Above necessary to use the Find_Landings_Beginning_End() function
dumdat=Find_Landings_Beginning_End(dumBinary); 
midBinaryTrace=BinaryTrace(dumdat.BeginningIndex+1:dumdat.EndingIndex-1);
             %midBinaryTrace = (N x 1) consisting of the middle of the binary trace
             % i.e. the binary trace other than the first and last intervals
            % Now remove 0 intervals whose frame length is shorter than Min0
if length(midBinaryTrace>Min0)
                % Above test is necessary b/c sometimes the entire trace is
                % the first+last interval, so there is no midBinaryTrace
    midBinaryTrace=RemoveFalseNegatives(midBinaryTrace,Min0);
            % lengthBinary =Length of the trace
            % Now replace the BinaryTrace (binary trace) with one that
            % has had the short 0 intervals removed (other than the first
            % and last intervals of the trace)
    BinaryTrace=[BinaryTrace(1:dumdat.BeginningIndex) ; midBinaryTrace' ; BinaryTrace(dumdat.EndingIndex:lengthBinary)]; 
end
    % At this point BinaryTrace is a column vector (with middle section
    % having had all the short 0 intervals removed)
if flaggrose ==0
    % Here if BinaryTrace was input as a row vector
    BinaryTrace=BinaryTrace';   % Change BinaryTrace into a row vector
end
pc=BinaryTrace;
