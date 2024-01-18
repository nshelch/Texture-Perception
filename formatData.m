function cData = formatData(data)

[numNeurons, numTextures, numReps] = size(data);

load('./Data/pRegCoeff.mat');
subcell_high = pRegCoeff > .8;
PCs = find(subcell_high(1,:));
RAs = find(subcell_high(2,:));
SAs = find(subcell_high(3,:));

for nn = 1:numNeurons
    if ismember(nn, PCs)
        cData.neuron(nn).type = 'PC';
    elseif ismember(nn, SAs)
        cData.neuron(nn).type = 'SA';
    elseif ismember(nn, RAs)
        cData.neuron(nn).type = 'RA';
    end
    
    for tt = 1:numTextures
        for rr = 1:numReps
            cData.neuron(nn).texture(tt).rep{rr} = data{nn, tt, rr};
        end
    end
end

% save('./Data/cData.mat', 'cData')

end