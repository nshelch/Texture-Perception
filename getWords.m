function [wordCount, wordLabel] = getWords(spikeTrain, snippetLength)

numNeurons = size(spikeTrain, 1);
numTextures = size(spikeTrain, 2);

% If spikeTrain has 4 dims: neurons x textures x reps x spike train
if length(size(spikeTrain)) == 4
    numReps = size(spikeTrain, 3);
    numDataPerRep = size(spikeTrain, 4) / snippetLength;
    numDataPerNeuron = numDataPerRep * numReps;
else % If spikeTrain has 3 dims: neurons x textures x spike train
    numReps = 1;
    numDataPerRep = size(spikeTrain, 3) / snippetLength;
    numDataPerNeuron = numDataPerRep * numReps;
end

if ~(floor(numDataPerNeuron) == ceil(numDataPerNeuron))
    error('Current parameters will result in uneven word binning.')
end

wordCount = zeros(numNeurons, numTextures, numDataPerNeuron);
pbar = fprintf('Getting Word Patterns for neuron 0/%i \n', numNeurons); % progress bar

for nn = 1:numNeurons

    fprintf(repmat('\b', 1, pbar))
    pbar = fprintf('Getting Word Patterns for neuron %i/%i \n', nn, numNeurons);

    for tt = 1:numTextures
        tmpWordCount = cell(1, numReps);

        for rr = 1:numReps
            % Reshaping the binarized spike train for easier spike counting
            if numReps > 1
                spikeMatrix = reshape(spikeTrain(nn, tt, rr, :), [snippetLength, numDataPerRep])';
            else
                spikeMatrix = reshape(spikeTrain(nn, tt, :), [snippetLength, numDataPerRep])';
            end
            tmpWordCount{rr} = bin2dec(num2str(spikeMatrix));

        end % rep loop

        wordCount(nn, tt, :) = vertcat(tmpWordCount{:}); % Concatenate words across reps

    end % texture loop
end % neuron loop

wordLabel = unique(wordCount(:));

end