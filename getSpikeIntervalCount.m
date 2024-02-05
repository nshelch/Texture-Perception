function [spikeIntCount] = getSpikeIntervalCount(spikeTrain, intTime)

numNeurons = size(spikeTrain, 1);
numTextures = size(spikeTrain, 2);
numReps = size(spikeTrain, 3);
numDataPerRep = size(spikeTrain, 4) / intTime;
numDataPerNeuron = numDataPerRep * numReps;

if ~(floor(numDataPerRep) == ceil(numDataPerRep))
    error('Current parameters will result in uneven binning.')
end

spikeIntCount = cell(numNeurons, numTextures, numDataPerNeuron);
tmpspikeIntCount = zeros(numNeurons, numTextures, numDataPerNeuron, length(0:intTime)); % In this case, each row is the ISI interval (starting at 0) 

pbar = fprintf('Getting Spike Interval Count for neuron 0/%i \n', numNeurons); % progress bar

curBinIdx = 1; % counter for which data bin we are in (since reps are no longer stitched together, avoiding confusion with how to mix the rr and ii labels.
for nn = 1:numNeurons
    fprintf(repmat('\b', 1, pbar))
    pbar = fprintf('Getting Spike Interval Count for neuron %i/%i \n', nn, numNeurons);
    for tt = 1:numTextures
        for rr = 1:numReps
            spikeMatrix = reshape(spikeTrain(nn, tt, rr, :), [intTime, numDataPerRep])';
            
            % These steps might be vectorizable but lets not for now
            for ii = 1:numDataPerRep
                spikeIdx = find(spikeMatrix(curBinIdx, :)); % Find the spike idx
%                 spikeIntValue = diff(spikeIdx); % Get the difference for the spike interval code 
                spikeIntValue = diff([0, spikeIdx]); % Get the difference for the spike interval code (assumes there is a spike right before the bins)
               
                % Spike Interval Conditions
                if isempty(spikeIdx) % no spikes
                    spikeIntCount(nn, tt, curBinIdx) = {0};
                    tmpspikeIntCount(nn, tt, curBinIdx, 1) = 1;

                elseif length(spikeIdx) == 1 % 1 spike only
                    spikeIntCount(nn, tt, curBinIdx) = {spikeIdx};
                    tmpspikeIntCount(nn, tt, curBinIdx, spikeIdx + 1) = 1; % We add 1 to spikeIdx since we have a 0 ISI slot

                elseif ~isempty(spikeIntValue) && length(spikeIntValue) > 1 % two spikes or more
                    spikeIntCount(nn, tt, curBinIdx) = {spikeIntValue};
                    for ss = 1:length(spikeIntValue) % Count the number of times each spike interval occurs
                        tmpspikeIntCount(nn, tt, curBinIdx, spikeIntValue(ss) + 1) = sum(spikeIntValue == spikeIntValue(ss));
                    end
                end
                curBinIdx = curBinIdx + 1;
                
            end % bin loop
        end % rep loop
    end % texture loop
end % neuron loop


end