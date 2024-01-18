clear; close all; clc;
load('./Data/numSpikes.mat')

% MI Params
spikeTrainRes = [1, 2]; % ms
snippetLength = [5, 8, 10; 8, 10, 20]; % ms
startTime = 0; % Start at 0 since its Poisson data
poiDur = 1800; % ms
convFactor = 1000; % Conversion factor from bits/bin to bits/sec in MI calculations (1000 keeps the info in units of bits/bin)
slidingWindow = 0;
maxBins = 20;

% Poisson Neuron Params
numReps = 50;
tdelta = 1; % ms
tref = 1; % ms
trialDuration = 1800; % ms
numRuns = 100; % Number of times to do the Poisson generation

for rr = 1:numRuns
    %     pbar = fprintf('Generating Poisson data for neuron %i\n', 0);
    %     for nn = 1:141
    %         fprintf(repmat('\b', 1, pbar))
    %         pbar = fprintf('Generating Poisson data for neuron %i\n', nn);
    %         for tt = 1:59
    %             [~, spikeTimes] = poissonNeuronModel(firingRates(nn, tt), tdelta, trialDuration, numReps);
    %             cPoiss.neuron(nn).texture(tt).rep = spikeTimes; %cellfun(@(z) z(:) + 0.1, spikeTimes, 'UniformOutput', false);  % Since POI starts at 0.1 seconds
    %         end
    %     end
    
    for ss = 1:length(spikeTrainRes)
        
        spikeTrainPoiss = shuffleSpikeTrain(squeeze(numSpikes(ss, :, :)), poiDur);
        
        % Bins the data based on the spike train res. and outputs a 3D
        % binarized spike train matrix (neurons x textures x spike train)
%         spikeTrainPoiss = binSpikeData(cPoiss, spikeTrainRes(ss), startTime, poiDur);
       
        for ll = 1:length(snippetLength)
            clc; fprintf('Bootstrap: %i, Spike Train Res: %i/%i, Snippet Length %i/%i\n', rr, ss, length(spikeTrainRes), ll, length(snippetLength));
            
            numBins = snippetLength(ss, ll) / spikeTrainRes(ss); % Number of bins needed based on the resolution of the spike train
            
            % Spike Count
            [spikeCountPoiss] = getSpikeCounts(spikeTrainPoiss, numBins);
            fanoFactor(ss, ll, rr, :, :) = calculateFanoFactor(spikeCountPoiss);
            tmpSpikes = calculateMutualInformation(spikeCountPoiss, 0:numBins, convFactor);
            miPoiss.SpikeCount(ss, ll, rr, :) = tmpSpikes.mutualInfo;
            entPoiss.SpikeCount(ss, ll, rr, :) = tmpSpikes.entropy;
            
            % First Spike
%             [firstSpikeCountPoiss] = getFirstSpike(spikeTrainPoiss, numBins);
%             tmpFirstSpike = calculateMutualInformation(firstSpikeCountPoiss, 0:numBins, convFactor);
%             miPoiss.FirstSpike(ss, ll, rr, :) = tmpFirstSpike.mutualInfo;
%             entPoiss.FirstSpike(ss, ll, rr, :) = tmpFirstSpike.entropy;
%             
            if numBins < maxBins
                % Words
                [wordCountPoiss] = getWords(spikeTrainPoiss, numBins);
                tmpWords = calculateMutualInformation(wordCountPoiss, unique(wordCountPoiss), convFactor);
                miPoiss.Words(ss, ll, rr, :) = tmpWords.mutualInfo;
                entPoiss.Words(ss, ll, rr, :) = tmpWords.entropy;
            end
            
            
        end
    end
end

poissParams.spikeTrainRes = spikeTrainRes;
poissParams.snippetLength = snippetLength;

save(sprintf('./Data/miPoiss%iReps%iRuns_ST1_2_shuffledData.mat', numReps, numRuns), 'miPoiss', 'entPoiss', 'spikeTrainPoiss', 'fanoFactor');

%% Scatter Plot Info
figure;
sidx = 1;
for ss = 1:length(spikeTrainRes)
    for ll = 1:size(snippetLength, 2)
        subplot(length(spikeTrainRes), size(snippetLength, 2), sidx)
        scatter(squeeze(mean(miPoiss.SpikeCount(ss, ll, :, :))), squeeze(mean(miPoiss.Words(ss, ll, :, :))), ...
            15, 'k', 'filled')
        rf = refline(1,0); rf.Color = rgb('DarkGrey'); rf.LineWidth = 1; rf.LineStyle = '--';
        xlabel('Spike Count Info')
        ylabel('Word Info')
        title(sprintf('Spike Train Res: %ims \nSnippet Length: %ims', spikeTrainRes(ss), snippetLength(ss, ll))) 
        sidx = sidx + 1;
    end
end

%% Fano Factor Plot
avgAcrossRepsFF = squeeze(mean(fanoFactor, 3));
avgAcrossTexturesFF = squeeze(mean(avgAcrossRepsFF, 4));
figure;
plot(squeeze(avgAcrossTexturesFF(ss, ll, :)))