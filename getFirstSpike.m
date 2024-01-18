function [firstSpikeCount] = getFirstSpike(spikeTrain, snippetLength)

numNeurons = size(spikeTrain, 1);
numTextures = size(spikeTrain, 2);
numDataPerNeuron = size(spikeTrain, 3) / snippetLength;

% Check to make sure spike train is split evenly
if ~(floor(numDataPerNeuron) == ceil(numDataPerNeuron))
    error('Current parameters will result in uneven first spike binning.')
end

firstSpikeCount = zeros(numNeurons, numTextures, numDataPerNeuron);
pbar = fprintf('Getting First Spike Values for neuron 0/%i \n', numNeurons); % progress bar

for nn = 1:numNeurons
    
    fprintf(repmat('\b', 1, pbar))
    pbar = fprintf('Getting First Spike Values for neuron %i/%i \n', nn, numNeurons);
    
    for tt = 1:numTextures        
        curST = reshape(spikeTrain(nn, tt, :), [snippetLength, numDataPerNeuron])';
        for ii = 1:size(curST, 1)
            firstSpikeIdx = find(curST(ii,:) == 1, 1);
            if ~isempty(firstSpikeIdx) % If there was a spike anywhere in the snippet
                firstSpikeCount(nn, tt, ii) = firstSpikeIdx;
            end
        end
    end
    
end



end