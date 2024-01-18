function [mi] = calculateJointMI(data, pDissim, tau)

numNeurons = size(data, 1);
numTextures = size(data, 2);
numData = size(data, 3);
numDissimData = size(pDissim, 3);

binToSecConversion = 1000 / tau;

ijPairs = numTextures * (numTextures - 1) / 2;
mi = zeros(1, numNeurons);

pbar = fprintf('Calculating Joint Mutual Information for neuron 0/%i \n', numNeurons); % progress bar

for nn = 1:numNeurons
    fprintf(repmat('\b', 1, pbar))
    pbar = fprintf('Calculating Joint Mutual Information for neuron %i/%i \n', nn, numNeurons);
    
    pJoint = squeeze(data(nn, :, :));
    pdij = zeros(numDissimData, numData * numData);
    for text1 = 1:numTextures - 1
        for text2 = text1 + 1:numTextures
            pij = reshape(pJoint(text1, :)' * pJoint(text2, :), [1, numData * numData]);
            dij = squeeze(pDissim(text1, text2, :));
            pdij = pdij + ((dij * pij) * (1/ijPairs));
        end
    end
    mi(nn) = sum(sum(pdij .* log2(pdij ./ (sum(pdij, 2) * sum(pdij, 1) + eps) + eps))) * binToSecConversion;
    if mi(nn) < 0 && ~(mi(nn) > -1e-10)
        error('Mutual information is negative')
    end
end

end