function [spikeIntCount] = getSpikeIntervalCount(spikeTrain, snippetLength)

numNeurons = size(spikeTrain, 1);
numTextures = size(spikeTrain, 2);
numReps = size(spikeTrain, 3);
numDataPerRep = size(spikeTrain, 4) / snippetLength;
numDataPerNeuron = numDataPerRep * numReps;

if ~(floor(numDataPerRep) == ceil(numDataPerRep))
    error('Current parameters will result in uneven binning.')
end

spikeIntCount = cell(numNeurons, numTextures, numDataPerNeuron);
spikeIntTable = zeros(numNeurons, numTextures, numDataPerNeuron, length(0:(snippetLength - 1))); % In this case, each row is the spike interval (starting at 0)

pbar = fprintf('Getting Spike Interval Count for neuron 0/%i \n', numNeurons); % progress bar

curBinIdx = 1; % counter for which data bin we are in (since reps are no longer stitched together, avoiding confusion with how to mix the rr and ii labels.
for nn = 1:numNeurons
    for tt = 1:numTextures
        for rr = 1:numReps
            fprintf(repmat('\b', 1, pbar))
            pbar = fprintf('Getting Spike Interval Count for Neuron: %i/%i Texture: %i Rep: %i\n', nn, numNeurons, tt, rr);
            
            spikeMatrix = reshape(spikeTrain(nn, tt, rr, :), [snippetLength, numDataPerRep])';
            
            % These steps might be vectorizable but lets not for now
            
            for ii = 1:numDataPerRep
                spikeIdx = find(spikeMatrix(ii, :)); % Find the spike idx
                spikeIntValue = diff(spikeIdx); % Get the difference for the spike interval code
                
                % Spike Interval Conditions
                if isempty(spikeIdx) % no spikes
                    spikeIntCount(nn, tt, curBinIdx) = {0};
                    %                     spikeIntTable(nn, tt, curBinIdx, 1) = 1;
                    
                elseif length(spikeIdx) == 1 % 1 spike only -> treating it as though its a 0 spike interval
                    spikeIntCount(nn, tt, curBinIdx) = {0};
                    %                     spikeIntTable(nn, tt, curBinIdx, 1) = 1;
                    
                elseif ~isempty(spikeIntValue) % two spikes or more
                    spikeIntCount(nn, tt, curBinIdx) = {spikeIntValue};
                    %                     spikeIntTable(nn, tt, curBinIdx, :) = histcounts(spikeIntValue,  'BinEdges', -.5:snippetLength); % replaces the below lines of code
                    %                     for ss = 1:length(spikeIntValue) % Count the number of times each spike interval occurs
                    %                         spikeIntTable(nn, tt, curBinIdx, spikeIntValue(ss) + 1) = sum(spikeIntValue == spikeIntValue(ss));
                    %                     end
                end
                curBinIdx = curBinIdx + 1;
            end % bin loop
        end % rep loop
    end % texture loop
end % neuron loop


end