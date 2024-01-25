function [spikeIntCount] = getSpikeIntervalCount(spikeTrain, intTime)

numNeurons = size(spikeTrain, 1);
numTextures = size(spikeTrain, 2);
numReps = size(spikeTrain, 3);
numDataPerRep = size(spikeTrain, 4) / intTime;
numDataPerNeuron = numDataPerRep * numReps;

if ~(floor(numDataPerRep) == ceil(numDataPerRep))
    error('Current parameters will result in uneven binning.')
end

spikeIntCount = zeros(numNeurons, numTextures, numDataPerNeuron);

pbar = fprintf('Getting Spike Interval Count for neuron 0/%i \n', numNeurons); % progress bar

for nn = 1:numNeurons
    fprintf(repmat('\b', 1, pbar))
    pbar = fprintf('Getting Spike Interval Count for neuron %i/%i \n', nn, numNeurons);
    for tt = 1:numTextures
        for rr = 1:numReps
            spikeMatrix = reshape(spikeTrain(nn, tt, rr, :), [intTime, numDataPerRep])';
            for ii = 1:numDataPerRep
                spikeIdx = find(spikeMatrix(ii, :));
                spikeIntValue = diff(spikeIdx);
                if ~isempty(spikeIntValue) && length(spikeIntValue) > 1
                    spikeIntCount(nn, tt, ii) = sum(spikeIntValue == tau);
                end
            end

        end % rep loop
    end % texture loop
end % neuron loop


end