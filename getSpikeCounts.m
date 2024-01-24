function [spikeCount] = getSpikeCounts(spikeTrain, intTime)
% TODO: rename intTime to better represent what it actually means
% TODO: Should I have this output p(x|t) instead of spike counts (with
% p(x|t) calculated in the calculateMutualInformation fx)
% Outputs the spike counts (determined by the integration window [intTime])

numNeurons = size(spikeTrain, 1);
numTextures = size(spikeTrain, 2);
numReps = size(spikeTrain, 3);
numDataPerNeuron = size(spikeTrain, 4) / intTime;

if ~(floor(numDataPerNeuron) == ceil(numDataPerNeuron))
    error('Current parameters will result in uneven spike count binning.')
end

spikeCount = zeros(numNeurons, numTextures, numDataPerNeuron);
pbar = fprintf('Getting Spike Counts for neuron 0/%i \n', numNeurons); % progress bar

for nn = 1:numNeurons
    fprintf(repmat('\b', 1, pbar))
    pbar = fprintf('Getting Spike Counts for neuron %i/%i \n', nn, numNeurons);
    for tt = 1:numTextures
        tmpSpikeCount = cell(1, numReps);
        for rr = 1:numReps
            % Reshaping the binarized spike train for easier spike counting
            spikeMatrix = reshape(spikeTrain(nn, tt, rr, :), [intTime, numDataPerNeuron])';
            tmpSpikeCount{rr} = sum(spikeMatrix, 2);
        end % rep loop
        spikeCount(nn, tt, :) = vertcat(tmpSpikeCount{:});
    end % texture loop
end % neuron loop


end