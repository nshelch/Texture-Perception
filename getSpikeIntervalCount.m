function [spikeIntCount, spikeIntTable] = getSpikeIntervalCount(spikeTrain, snippetLength, splitSingleSpikes)
% TODO: Check that the first bin in the spike int pattern only get
% triggered by the single spike condition


numNeurons = size(spikeTrain, 1);
numTextures = size(spikeTrain, 2);

if length(size(spikeTrain)) == 4
    numReps = size(spikeTrain, 3);
    numDataPerRep = size(spikeTrain, 4) / snippetLength;
    numDataPerNeuron = numDataPerRep * numReps;
else
    numReps = 1;
    numDataPerRep = size(spikeTrain, 3) / snippetLength;
    numDataPerNeuron = numDataPerRep * numReps;
end

if ~(floor(numDataPerRep) == ceil(numDataPerRep))
    error('Current parameters will result in uneven binning.')
end

% Matrix containing the spike interval label for each snippet
spikeIntCount = zeros(numNeurons, numTextures, numDataPerNeuron);

%% Spike Int Table

% Table containing the spike interval patterns and labels
spikeIntTable = table();
spikeIntTable.Label(1) = 0; % First label is 0 spikes in a snippet (the most common and makes the 0 label intuitive)
spikeIntTable.SpikeIntPattern(1, :) = zeros(1, snippetLength); % First pattern is 0 spikes in a snippet

% If we don't want to seperate the different single spike labels, we
% initiate the second one so we don't have to guess which label will be the
% single spike one (maybe unneeded but I can clean this up later)
if ~splitSingleSpikes
    tmpTable.Label = 1; % a single spike occuring anywhere in the snippet
    tmpTable.SpikeIntPattern = [1, zeros(1, snippetLength - 1)]; % the first number indicates the location of the first spike
    spikeIntTable = [spikeIntTable; struct2table(tmpTable)]; % append the tmp table
end

%% Main loop
pbar = fprintf('Getting Spike Interval Count for neuron 0/%i \n', numNeurons); % progress bar
for nn = 1:numNeurons
    fprintf(repmat('\b', 1, pbar))
    pbar = fprintf('Getting Spike Interval Count for Neuron: %i/%i\n', nn, numNeurons);
    for tt = 1:numTextures
        curBinIdx = 1; % counter for which data bin we are in (since reps are no longer stitched together, avoiding confusion with how to mix the rr and ii labels.

        for rr = 1:numReps

            if numReps > 1
                spikeMatrix = reshape(spikeTrain(nn, tt, rr, :), [snippetLength, numDataPerRep])';
            else
                spikeMatrix = reshape(spikeTrain(nn, tt, :), [snippetLength, numDataPerRep])';
            end

            % These steps might be vectorizable but lets not for now
            for ii = 1:numDataPerRep
                spikeIdx = find(spikeMatrix(ii, :)); % Find the spike idx
                spikeIntValue = diff(spikeIdx); % Get the difference for the spike interval code

                % Spike Interval Conditions
                if length(spikeIdx) == 1 % One spike regardless of where it is
                    tmpPattern = [spikeIdx, zeros(1, snippetLength - 1)]; % Records the location of the first spike

                    % Update the table
                    if ~ismember(tmpPattern, spikeIntTable.SpikeIntPattern, 'rows') % Add a new spike int pattern
                        if splitSingleSpikes
                            tmpTable.Label = spikeIntTable.Label(end) + 1;
                        else
                            tmpTable.Label = 1;
                        end
                        tmpTable.SpikeIntPattern = tmpPattern;
                        spikeIntTable = [spikeIntTable; struct2table(tmpTable)]; % append the tmp table
                    end
                    [~, patternIdx] = ismember(tmpPattern, spikeIntTable.SpikeIntPattern, 'rows');
                    spikeIntCount(nn, tt, curBinIdx) =  spikeIntTable.Label(patternIdx);

                elseif ~isempty(spikeIntValue) % two spikes or more

                    tmpPattern = histcounts(spikeIntValue,  'BinEdges', -.5:snippetLength); % Counts the spike intervals to create a 'spike interval gram' aka the label

                    % Update the table
                    if ~ismember(tmpPattern, spikeIntTable.SpikeIntPattern, 'rows') % Add a new spike int pattern
                        tmpTable.Label = spikeIntTable.Label(end) + 1;
                        tmpTable.SpikeIntPattern = tmpPattern;
                        spikeIntTable = [spikeIntTable; struct2table(tmpTable)]; % append the tmp table
                    end
                    [~, patternIdx] = ismember(tmpPattern, spikeIntTable.SpikeIntPattern, 'rows');
                    spikeIntCount(nn, tt, curBinIdx) =  spikeIntTable.Label(patternIdx);
                end % spike interval conditions

                curBinIdx = curBinIdx + 1;

            end % bin loop
        end % rep loop
    end % texture loop
end % neuron loop


end