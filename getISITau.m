function [tauCounts] = getISITau(spikeTrain, snippetLength, tau)

numNeurons = size(spikeTrain, 1);
numTextures = size(spikeTrain, 2);
numDataPerNeuron = size(spikeTrain, 3) / snippetLength;

if ~(floor(numDataPerNeuron) == ceil(numDataPerNeuron))
    error('Current parameters will result in uneven ISI binning.')
end

tauCounts = zeros(numNeurons, numTextures, numDataPerNeuron);

pbar = fprintf('Getting ISI Patterns for neuron 0/%i \n', numNeurons); % progress bar

for nn = 1:numNeurons
    
    fprintf(repmat('\b', 1, pbar))
    pbar = fprintf('Getting ISI Patterns for neuron %i/%i \n', nn, numNeurons);
    
    for tt = 1:numTextures
        
        curST = reshape(spikeTrain(nn, tt, :), [snippetLength, numDataPerNeuron])';
        
        for ii = 1:size(curST, 1)
            spikeIdx = find(curST(ii,:) == 1);
            isiValue = diff(spikeIdx);
            if ~isempty(isiValue) && length(isiValue) > 1
                tauCounts(nn,tt,ii) = sum(isiValue == tau); % Subtracting 1 because the count includes the initial spike????
            end
        end
    end % texture loop
    
end % neuron loop


end