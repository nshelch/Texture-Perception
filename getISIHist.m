function [isiCount] = getISI(data, startTime, poi, isiRes, isiCutoff)

numNeurons = size(data.neuron, 2);
numTextures = size(data.neuron(1).texture, 2);
numReps = size(data.neuron(1).texture(1), 2);
numBins = isiCutoff / isiRes;

isiCount = zeros(numNeurons, numTextures, numBins);

for nn = 1:numNeurons
    for tt = 1:numTextures
        tmp = cell(1, numReps);
        for rr = 1:numReps
            tmpdata = data.neuron(nn).texture(tt).rep{rr};
            tmp{rr} = diff(tmpdata(tmpdata >= startTime/1000 & tmpdata <= (startTime + poi)/1000));
        end
        isiVec = cell2mat(tmp') * 1000; % Convert to ms
        isiCount(nn, tt, :) = histcounts(isiVec, 'BinLimits', [0, isiCutoff], 'BinEdges', 0:isiRes:isiCutoff); 
    end
end

end