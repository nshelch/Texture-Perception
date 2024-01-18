function [shuffledSpikeTrain] = shuffleSpikeTrain(numSpikesData, trialDur)

numNeurons = size(numSpikesData, 1);
numTextures = size(numSpikesData, 2);

shuffledSpikeTrain = zeros(numNeurons, numTextures, trialDur);

for nn = 1:numNeurons
    for tt = 1:numTextures
        numSpikes = numSpikesData(nn, tt);
        spikeTimes = randperm(trialDur, numSpikes);
        shuffledSpikeTrain(nn, tt, spikeTimes) = 1;  
    end
end

end