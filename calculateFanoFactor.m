function [ff] = calculateFanoFactor(data)

numNeurons = size(data, 1);
numTextures = size(data, 2);
ff = zeros(numNeurons, numTextures);

for nn = 1:numNeurons
    for tt = 1:numTextures
        tmp = data(nn, tt, :);
        ff(nn, tt) = var(tmp) / mean(tmp);
        if (mean(tmp) == var(tmp)) && mean(tmp) == 0
           ff(nn, tt) = 1; 
        end
    end
end

end