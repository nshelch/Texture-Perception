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
snippetLength = [2:5]; %[2, 5, 10, 20, 50, 100]; % ms
stParams.snippetLength = snippetLength; stParams.spikeTrainRes = spikeTrainRes;

%% Processing Loop
% 1/23/24 Notes: Since not doing tip to tail stitching, need to think about
% restructuring the way I organize my data and its impact on these
% calculations --> impacts the getXX functions not
% calculateMutualInformation (since that already takes joint distributions
% as input)

% Info calculations using binarized spike trains

% spikeTrain = binSpikeData(cData, startTime, poiDur, spikeTrainRes);
% 
% for tt = 1:length(snippetLength)
%     % Spike Count
%     [spikeCount] = getSpikeCount(spikeTrain, snippetLength(tt)); % Outputs spike count not p(x|t)
% 
%     tmpSpikes = calculateMutualInformation(spikeCount, 0:snippetLength(tt), convFactor);
%     miNeural.SpikeCount(tt, :) = tmpSpikes.mutualInfo;
%     entNeural.SpikeCount(tt, :) = tmpSpikes.entropy;
%     jointNeural.SpikeCount{tt} = tmpSpikes.jointCount;
%     rate.SpikeCount(tt, :, :) = mean(spikeCount, 3);
%     %         [distMetric.SpikeCount.pcDJS(sl, :, :, :), distMetric.SpikeCount.pcRsq(sl, :)] = djsAnalysis(tmpSpikes.jointCount(find(pcIdx == 1), textIdx, :), humanScores, 1);
%     %         [distMetric.SpikeCount.saDJS(sl, :, :, :), distMetric.SpikeCount.saRsq(sl, :)] = djsAnalysis(tmpSpikes.jointCount(find(saIdx == 1), textIdx, :), humanScores, 0);
% end

for tt = 1:length(snippetLength)
    % Spike Interval Code (was ISI Tau)
    [spikeIntCount] = getSpikeIntervalCount(spikeTrain, snippetLength(tt));
    tmpSpikeInt = calculateMutualInformation(spikeIntCount, NaN, convFactor);
    miSpikeInt(tt, :) = tmpSpikeInt.mutualInfo;
    entSpikeInt(tt, :) = tmpSpikeInt.entropy;
    jointSpikeInt{tt} = tmpSpikeInt.jointCount;
    rateSpikeInt(tt, :) = mean(squeeze(mean(spikeIntCount, 2)), 2);
end % integration time window loop
% 
% if saveData
%     save('./Data/mostRecentCalculation.mat', 'miNeural', 'entNeural', 'jointNeural', 'distMetric', 'stParams', 'isiParams', 'neuronType', 'pcIdx', 'saIdx', 'isiHist', 'spikeTrain')
% end