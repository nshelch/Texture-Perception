function [isiCount] = getISIHist(data, startTime, poi, isiRes, isiCutoff)

numNeurons = size(data.neuron, 2);
numTextures = size(data.neuron(1).texture, 2);
numReps = size(data.neuron(1).texture(1).rep, 2);
numBins = isiCutoff / isiRes;

isiCount = zeros(numNeurons, numTextures, numBins);

for nn = 1:numNeurons
    for tt = 1:numTextures
        tmpIsi = cell(1, numReps);
        for rr = 1:numReps
            spikesInMs = data.neuron(nn).texture(tt).rep{rr} * 1000; % Convert to ms
            timeEnd = startTime + poi;
            validSpikesIdx = spikesInMs >= startTime & spikesInMs <= timeEnd; % Get the spikes indices during the poi
            validSpikes = spikesInMs(validSpikesIdx); % Get the spike times during poi
            tmpIsi{rr} = diff(validSpikes); % Get the difference betweem spikes
        end % rep loop
        isiVec = cell2mat(tmpIsi'); 
        isiCount(nn, tt, :) = histcounts(isiVec, 'BinLimits', [0, isiCutoff], 'BinEdges', 0:isiRes:isiCutoff); 
    end % texture loop
end % neuron loop

end