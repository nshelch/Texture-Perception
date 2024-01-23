function spikeTrain = binSpikeData(data, startTime, poi, binRes)

numNeurons = size(data.neuron, 2);
numTextures = size(data.neuron(1).texture, 2);
numReps = size(data.neuron(1).texture(1).rep, 2);
numData = length(0:binRes:poi);

spikeTrain = zeros(numNeurons, numTextures, numReps, numData - 1);
for nn = 1:numNeurons
    for tt = 1:numTextures
        for rr = 1:numReps
            
            spikesInMs = data.neuron(nn).texture(tt).rep{rr} * 1000;
            timeEnd = startTime + poi;
            validSpikes = spikesInMs >= startTime & spikesInMs <= timeEnd;
            spikeTimes = spikesInMs(validSpikes) - startTime; % Align to 0
            binnedSpikeTrain = histcounts(spikeTimes, 0:binRes:poi); % Bin the spike times 

            % Binarize the data (CHECK THIS WAS DONE CORRECTLY (SINCE I
            % MOVED SHIT SO QUICKLY BEFORE THE MEETING)
            binarizedSpikes = binnedSpikeTrain > 1;
            binnedSpikeTrain(binarizedSpikes) = 1;
            spikeTrain(nn, tt, rr, :) = binnedSpikeTrain;

            
        end % rep loop
        
    end % texture loop
end % neuron loop

end

