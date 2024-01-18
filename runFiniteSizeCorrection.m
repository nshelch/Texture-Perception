function [info, badNeurons] = runFiniteSizeCorrection(data, frac, numReps, fracErrThresh)

% Runs calc_info_P_joint.m written by Stephanie Palmer and calculates the
% info using the joint probability distribution between x and y, and
% applies a finite size correction if needed. Furthermore, it implements a
% threshold which returns a suggestion of which neurons should be excluded
% from analysis based on their fractional errors.
%
% data: a struct containing the following
%   data.x -> a vector containing the values used to calculate the prob.
%           dist. p(x) (must be greater than 0)
%   data.y -> a vector containing the values used to calculate the prob.
%           dist. p(y) (must be greater than 0). data.x and data.y should be matched in that the first value
%           of data.x should correspond to the label associated in the first index
%           of data.y
%   data.xRange -> the maximum value that data.x could have (the function
%           calc_info_P_joint.m assumes that the data.x values will range from 1 ->
%           data.xRange
%   data.yRange -> the maximum value that data.y could have (the function
%           calc_info_P_joint.m assumes that the data.y values will range from 1 ->
%           data.yRange
% frac: the fraction of data used for the bootstraps i.e. [1 0.9 0.8 .75 0.5]
% numReps: number of times each fraction should be bootstrapped (ideal is
%   between 10 - 50)
% fracErrThresh: the cutoff for the fractional error, i.e. any neurons
%   which have a fractional error greater than this threshold should be
%   excluded from analysis
%
% TODO: Rewrite the info_calc_P_joint.m code to be more intuitive 
%       Make varargout work (right now it returns the minimum info needed
%       to run the bootstrap code)



badNeurons = [];

for nn = 1:size(data.x, 1)

[info.fsCorrected(nn), err_50(nn), info.fracError(nn), ...
    info.fsCorrectedShuffle(nn), err_50Shuffle(nn), info.fracErrorShuffle(nn), ...
    fs_samples{nn}, fs_samplesShuffle{nn}, jointDist{nn}, jointDistShuffle{nn}] = ...
    calc_info_P_joint(data.x(nn, :) + 1, data.y(nn), data.xRange, data.yRange, frac, numReps);

if info.fracError(nn) > fracErrThresh
    badNeurons = [badNeurons, nn];
end

end



end