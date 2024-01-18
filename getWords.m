function [wordCount] = getWords(spikeTrain, lengthWords)

numNeurons = size(spikeTrain, 1);
numTextures = size(spikeTrain, 2);
numDataPerNeuron = size(spikeTrain, 3) / lengthWords;

if ~(floor(numDataPerNeuron) == ceil(numDataPerNeuron))
    error('Current parameters will result in uneven word binning.')
end

wordCount = zeros(numNeurons, numTextures, numDataPerNeuron);
pbar = fprintf('Getting Word Patterns for neuron 0/%i \n', numNeurons); % progress bar

for nn = 1:numNeurons
    
    fprintf(repmat('\b', 1, pbar))
    pbar = fprintf('Getting Word Patterns for neuron %i/%i \n', nn, numNeurons);
    
    for tt = 1:numTextures        
        tmp = reshape(spikeTrain(nn, tt, :), [lengthWords, numDataPerNeuron])';
        wordCount(nn, tt, :) = bin2dec(num2str(tmp));
    end
    
end


end