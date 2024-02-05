function info = calculateMutualInformation(data, binValues, tau)

% data: 3D matrix of neurons x labels x binned data
%                           OR
% data: 3D matrix of neurons x labels x joint count
% binValues: the range of possible values in the bins (if data contains
% joint count, then binValues is NaN)
% tau: time resolution of the bins -> used to convert from bits/bin to
% bits/second

numNeurons = size(data, 1); 
numTextures = size(data, 2);

if ~isnan(binValues)
    numBins = length(binValues);
else
    numBins = size(data, 3);
end

info.convertBinsToSeconds = (1000 / tau); % conversion factor to transform info from bits/bin to bits/second

% Get label info/entropy
info.probTexture = 1/numTextures; % P(t)
info.entropyTexture = log2(numTextures) * info.convertBinsToSeconds; % bits/second

% Set up joint and global counters
jointCount = zeros(numNeurons, numTextures, numBins);
probOfXGivenTexture = zeros(numNeurons, numTextures, numBins);

pbar = fprintf('Calculating Mutual Information for neuron 0/%i \n', numNeurons); % progress bar

for nn = 1:numNeurons
    countOfEachBin = sparse(zeros(1, numBins)); % across texture count
    
    % Calculating mutual entropy per neuron but across textures
    fprintf(repmat('\b', 1, pbar))
    pbar = fprintf('Calculating Mutual Information for neuron %i/%i \n', nn, numNeurons);
    
    for tt = 1:numTextures
        % parfor(tt = 1:length(textures), 2) % Useful if calculations are
        % going slowly
        
        % Get the binned data/joint counts from each neuron
        tmp = squeeze(data(nn, tt, :));
        
        % Get p(x|t) for each neuron
        if ~isnan(binValues) % if the data is binned
            [probOfX, xCount] = calculateProbOfX(tmp, binValues);
        else % if the data is the joint count
            probOfX = tmp / sum(tmp + eps);
            xCount = tmp';
        end
        
        probOfXGivenTexture(nn, tt, :) = probOfX; % p(x|t)
        countOfEachBin = countOfEachBin + xCount;
        jointCount(nn, tt, :) = xCount;
    end
    
    % Get the probability distribution for the neural statistic
    info.prob(nn, :) = countOfEachBin/sum(countOfEachBin); % P(x)
    info.entropy(nn) = calculateEntropy(info.prob(nn, :)) * info.convertBinsToSeconds; % S(x)
    
    % Get the mutual info using the joint probability distribution
    mi = calculateMutualInfoUsingJointCount(squeeze(jointCount(nn, :, :))) * info.convertBinsToSeconds;
    
    if (mi < 0 && ~(mi > -1e-10))
        error('Mutual information is negative')
    end

    info.mutualInfo(nn) = mi;
    
end

info.probOfXGivenTexture = probOfXGivenTexture;
info.jointCount = jointCount;
info.binValues = binValues;

end

function [probOfX, countOfX] = calculateProbOfX(x, binValues)

countOfX = zeros(1, length(binValues));

% Get a matrix of the words which actually occurred
uniqueX = unique(x);

% Get the indices of these words so you don't have to search through the
% entire vector
binIdx = find(ismember(binValues', uniqueX) == 1);

for ii = 1:length(binIdx)
    numX = sum(ismember(x, uniqueX(ii)));
    countOfX(binIdx(ii)) = numX;
end

probOfX = countOfX / sum(countOfX);

end

function s = calculateEntropy(probX)

tmp = -1 * (probX .* log2(probX + eps));
s = sum(tmp);

end

function mi = calculateMutualInfoUsingJointCount(jointCount)

% MI = SUM_i SUM_j [ P(X,Y) * log2( P(X,Y) / P(X) * P(Y) ) ]

pJoint = jointCount / sum(jointCount(:)); % Get the joint distribution
px = sum(pJoint, 2);
py = sum(pJoint, 1);
logTerm = log2(pJoint./((px * py) + eps) + eps);
mi = sum(sum(pJoint .* logTerm));

end