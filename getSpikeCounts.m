function [spikeCount] = getSpikeCounts(spikeTrain, snippetLength)

numNeurons = size(spikeTrain, 1);
numTextures = size(spikeTrain, 2);
numDataPerNeuron = size(spikeTrain, 3) / snippetLength;

if ~(floor(numDataPerNeuron) == ceil(numDataPerNeuron))
    error('Current parameters will result in uneven spike count binning.')
end

spikeCount = zeros(numNeurons, numTextures, numDataPerNeuron);
pbar = fprintf('Getting Spike Counts for neuron 0/%i \n', numNeurons); % progress bar

for nn = 1:numNeurons
    fprintf(repmat('\b', 1, pbar))
    pbar = fprintf('Getting Spike Counts for neuron %i/%i \n', nn, numNeurons);
    for tt = 1:numTextures
        spikeCount(nn, tt, :) = sum(reshape(spikeTrain(nn, tt, :), [snippetLength, numDataPerNeuron])', 2);
    end
end


end