function [spikeCount] = getSpikeCount(spikeTrain, snippetLength)
% Outputs the spike counts for each snippet (determined by the snippet length)
% p(x|t) calculated in the calculateMutualInformation fx)

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


if ~(floor(numDataPerRep) == ceil(numDataPerRep))
    error('Current parameters will result in uneven binning.')
end

spikeCount = zeros(numNeurons, numTextures, numDataPerNeuron);
pbar = fprintf('Getting Spike Counts for neuron 0/%i \n', numNeurons); % progress bar

for nn = 1:numNeurons
    fprintf(repmat('\b', 1, pbar))
    pbar = fprintf('Getting Spike Counts for neuron %i/%i \n', nn, numNeurons);
    for tt = 1:numTextures
        
        tmpSpikeCount = cell(1, numReps);
        
        for rr = 1:numReps
            % Reshaping the binarized spike train for easier spike counting
            if numReps > 1
                spikeMatrix = reshape(spikeTrain(nn, tt, rr, :), [snippetLength, numDataPerRep])';
            else
                spikeMatrix = reshape(spikeTrain(nn, tt, :), [snippetLength, numDataPerRep])';
            end

            tmpSpikeCount{rr} = sum(spikeMatrix, 2); % Get the counts for each rep

        end % rep loop

        spikeCount(nn, tt, :) = vertcat(tmpSpikeCount{:}); % Concatenate counts across reps

    end % texture loop
end % neuron loop


end