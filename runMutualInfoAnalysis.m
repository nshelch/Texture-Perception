% TODO: Basis stats -> look at the data and confirm POI and trial alignment
% makes sense
clear; clc;

% Folder locations (Move this into a startup script)
hostEnv = getenv('computername');
if strcmpi(hostEnv, 'DESKTOP-LEG2SE6')
    pathLoc = 'C:/Users/nshel/Box/BensmaiaLab/';
elseif strcmpi(hostEnv, 'OBA-PC-01')
    pathLoc = 'C:/Users/somlab/Box/BensmaiaLab/';
elseif strcmpi(hostEnv, 'DESKTOP-FB47T9U')
    pathLoc = 'C:/Users/nshelch/Box/BensmaiaLab (Natalya Shelchkova)/';
end

dataLoc = fullfile(pathLoc, 'Texture Perception/Data/');

% Load Data
if exist(fullfile(dataLoc, 'cData.mat'), 'file')
    load(fullfile(dataLoc, 'cData.mat'))
    %     load(fullfile(dataLoc, 'dissimData.mat'))
else
    load(fullfile(dataLoc, 'cdaData.mat'))
    cData = formatData(cdaData.fullRun.data);
end

% Saving files
saveData = 0;
saveDataFilename = './Data/infoCalculations_ISI_SpikeCount_IntervalISI_DistMetrics.mat';

%% Parameters for analysis

% Params for MI Calculations
startTime = 100; % ms
poiDur = 1800; % Duration of period of interest (poi) in ms
convFactor = 1000; % Conversion factor from bits/bin to bits/sec in MI calculations (1000 keeps the info in units of bits/bin)

% Spike Train Params
spikeTrainRes = 1; % Binning resolution of the spike train (ms)
snippetLength = [2:6,8,10]; % ms
stParams.snippetLength = snippetLength; stParams.spikeTrainRes = spikeTrainRes;

%% Analysis start

% Binarize the spike train
spikeTrain = binSpikeData(cData, startTime, poiDur, spikeTrainRes);

for sl = 1:length(snippetLength)

    %%% Spike Count
    [spikeCount] = getSpikeCount(spikeTrain, snippetLength(sl)); % Outputs spike count not p(x|t)
    tmpSpikes = calculateMutualInformation(spikeCount, 0:snippetLength(sl), convFactor);
    
    miNeural.SpikeCount(sl, :) = tmpSpikes.mutualInfo;
    entNeural.SpikeCount(sl, :) = tmpSpikes.entropy;
    jointNeural.SpikeCount{sl} = tmpSpikes.jointCount;
    rate.SpikeCount(sl, :, :) = mean(spikeCount, 3);


    %%% Spike Interval Code (single spikes assigned the same label)
    [spikeIntCount, spikeIntTable] = getSpikeIntervalCount(spikeTrain, snippetLength(sl), 0);
    tmpSpikeInt = calculateMutualInformation(spikeIntCount, unique(spikeIntTable.Label), convFactor);

    miNeural.SpikeInt(sl, :) = tmpSpikeInt.mutualInfo;
    entNeural.SpikeInt(sl, :) = tmpSpikeInt.entropy;
    jointNeural.SpikeInt{sl} = tmpSpikeInt.jointCount;
    rate.SpikeInt(sl, :) = mean(squeeze(mean(spikeIntCount, 2)), 2);


    %%% Spike Interval Code (single spikes assigned different labels)
    [spikeIntCount, spikeIntTable] = getSpikeIntervalCount(spikeTrain, snippetLength(sl), 1);
    tmpSpikeInt = calculateMutualInformation(spikeIntCount, spikeIntTable.Label, convFactor);

    miNeural.SplitSpikeInt(sl, :) = tmpSpikeInt.mutualInfo;
    entNeural.SplitSpikeInt(sl, :) = tmpSpikeInt.entropy;
    jointNeural.SplitSpikeInt{sl} = tmpSpikeInt.jointCount;
    rate.SplitSpikeInt(sl, :) = mean(squeeze(mean(spikeIntCount, 2)), 2);


    %%% Words
    if snippetLength(sl) <= 6 % max snippet length given the amount of data we have
        [wordCount, wordLabels] = getWords(spikeTrain, snippetLength(sl));
        tmpWords = calculateMutualInformation(wordCount, wordLabels, convFactor);

        miNeural.Words(sl, :) = tmpWords.mutualInfo;
        entNeural.Words(sl, :) = tmpWords.entropy;
        jointNeural.Words{sl} = tmpWords.jointCount;
        rate.Words(sl, :) = mean(squeeze(mean(wordCount, 2)), 2);
    else
        miNeural.Words(sl, :) = NaN;
        entNeural.Words(sl, :) = NaN;
        jointNeural.Words{sl} = NaN;
        rate.Words(sl, :) = NaN;
    end

end % snippet length


% 
% if saveData
%     save('./Data/mostRecentCalculation.mat', 'miNeural', 'entNeural', 'jointNeural', 'distMetric', 'stParams', 'isiParams', 'neuronType', 'pcIdx', 'saIdx', 'isiHist', 'spikeTrain')
% end