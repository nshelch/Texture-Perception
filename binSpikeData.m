function spikeTrain = binSpikeData(cData, binSize, timeStart, trialDur)

numNeurons = length(cData.neuron);
numTextures = length(cData.neuron(1).texture);
numReps = length(cData.neuron(1).texture(1).rep);
numData = length(0:binSize:trialDur);

spikeTrain = zeros(numNeurons, numTextures, (numData - 1) * numReps);
for nn = 1:numNeurons
    for tt = 1:numTextures
        tmp = cell(1, numReps);
        for rr = 1:numReps
            
            spikesInMs = cData.neuron(nn).texture(tt).rep{rr} * 1000;
            timeEnd = timeStart + trialDur;
            validSpikes = spikesInMs > timeStart + 1 & spikesInMs < timeEnd;
            spikeTimes = spikesInMs(validSpikes) - timeStart;
            binnedSpikeTrain = histcounts(spikeTimes, 0:binSize:trialDur);
            tmp{rr} = binnedSpikeTrain;
            
        end
        binnedSpikes = cell2mat(tmp);
        binarizedSpikes = binnedSpikes > 1;
        binnedSpikes(binarizedSpikes) = 1;
        spikeTrain(nn, tt, :) = binnedSpikes;
        
    end
end

end

