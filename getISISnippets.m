function [isiCount] = getISISnippets(spikeTrain, snippetLength)

numNeurons = size(spikeTrain, 1);
numTextures = size(spikeTrain, 2);
numDataPerNeuron = size(spikeTrain, 3) / snippetLength;

if ~(floor(numDataPerNeuron) == ceil(numDataPerNeuron))
    error('Current parameters will result in uneven ISI binning.')
end

isiCount = zeros(numNeurons, numTextures, numDataPerNeuron);

% Initialize hash with 0:snippetLength because those are keys that are
% definitely possible
hashTable = num2cell(0:snippetLength);

pbar = fprintf('Getting ISI Patterns for neuron 0/%i \n', numNeurons); % progress bar

for nn = 1:numNeurons
    
    fprintf(repmat('\b', 1, pbar))
    pbar = fprintf('Getting ISI Patterns for neuron %i/%i \n', nn, numNeurons);
    
    for tt = 1:numTextures
        
        curST = reshape(spikeTrain(nn, tt, :), [snippetLength, numDataPerNeuron])';
        for ii = 1:size(curST, 1)
            spikeIdx = find(curST(ii,:) == 1);
            isiValue = diff(spikeIdx);
            if length(spikeIdx) == 1 % If there is only 1 spike, set the isi to maximum possible isi which is the snippet length
                isiCount(nn, tt, ii) = snippetLength;
            elseif length(isiValue) == 1 % If there are only 2 spikes, the isi is the difference between the two
                isiCount(nn, tt, ii) = isiValue;
            elseif length(isiValue) > 1 % Otherwise, we gotta use the hash table
                hashIdx = NaN;
                for hh = (snippetLength + 1):length(hashTable) % Can ignore the first x hashes which correspond to the previous two cases
                    if all(ismember(isiValue, hashTable{hh}))
                        hashIdx = hh;
                    end
                end
                if isnan(hashIdx) % If that isi pattern doesnt exist, add it to the hash table
                    hashTable{end + 1} = isiValue;
                    hashIdx = length(hashTable); % the pattern is now the last index of the hash table
                end
                isiCount(nn, tt, ii) = hh;
            end
        end
    end
    
end


end