function spikeTrain = binSpikeData(data, startTime, poi, binRes)

numNeurons = size(data.neuron, 2);
numTextures = size(data.neuron(1).texture, 2);
numReps = size(data.neuron(1).texture(1).rep, 2);
numData = length(0:binRes:poi);

spikeTrain = zeros(numNeurons, numTextures, numReps, numData - 1);
for nn = 1:numNeurons
    for tt = 1:numTextures
        for rr = 1:numReps
            % Get the spikes that occurred during the period of interest
            % and align them to 0
            spikesInMs = data.neuron(nn).texture(tt).rep{rr} * 1000; % Convert to ms
            timeEnd = startTime + poi;
            validSpikes = spikesInMs >= startTime & spikesInMs <= timeEnd;
            spikeTimes = spikesInMs(validSpikes) - startTime; % Align to 0
            binnedSpikeTrain = histcounts(spikeTimes, 0:binRes:poi); % Bin the spike times 

            % Binarize the data
            multSpikeIdx = binnedSpikeTrain > 1; % Find the indices where more than one spike landed in a bin
            binarizedSpikeTrain = binnedSpikeTrain; % Copy the binned data
            binarizedSpikeTrain(multSpikeIdx) = 1; % Set bins with  multiple spikes equal to 1
            
            spikeTrain(nn, tt, rr, :) = binarizedSpikeTrain;
        end % rep loop
    end % texture loop
end % neuron loop

end

