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
intTimeWindow = 5; %[1, 2, 5, 10, 20, 25, 50, 100]; % Time period (ms) over which a neuron can receive information (integration time)

% Spike Train Params
spikeTrainRes = 1; % Binning resolution of the spike train (ms)
snippetLength = [10, 20, 50, 100]; % ms (NS 1/23/24: May remove later)

stParams.snippetLength = snippetLength; stParams.spikeTrainRes = spikeTrainRes;

% ISI Params
isiRes = 1; % ms
isiCutoff = 120; %ms

isiParams.resolution = isiRes; isiParams.cutoff = isiCutoff;

% Tau Params
isiTau = 1:15; % 1:19
maxTauCount = [19,9,6,4,3,3,2,2,2,1,1,1,1,1,1]; % [9,4,3,2,1,1,1,1,1]; %

isiParams.tau = isiTau; isiParams.maxTauRate = maxTauCount;

%% Processing Loop
% 1/23/24 Notes: Since not doing tip to tail stitching, need to think about
% restructuring the way I organize my data and its impact on these
% calculations --> impacts the getXX functions not
% calculateMutualInformation (since that already takes joint distributions
% as input)

%% ISI calculations using actual spike times (gonna keep it for now but might remove later)
% Get ISI Data
% isiEdges = 0:isiRes:isiCutoff; % 0:1:120
% isiHist = getISIHist(cData, startTime, poiDur, isiRes, isiCutoff);
%
% for ll = 1:length(intTimeWindow) % This should be extended to the outer most loop (since we will do this for all the info calcs)
%     clc; fprintf('ISI Res: %i/%i, ISI Length %i/%i\n',  length(isiRes), ll, length(intTimeWindow));
%
%     isiLimit = find(isiEdges <= intTimeWindow(ll), 1, 'last');
%
%     tmpISI = calculateMutualInformation(isiHist(:,:,1:isiLimit), NaN, convFactor);
%     miNeural.ISI(ll, :) = tmpISI.mutualInfo;
%     entNeural.ISI(ll, :) = tmpISI.entropy;
%     jointNeural.ISI{ll} = tmpISI.jointCount;
%     %         rate.ISI(ll, :, :) =
%     %         [distMetric.ISI.pcDJS(ll, :, :, :), distMetric.ISI.pcRsq(ll, :)] = djsAnalysis(tmpISI.jointCount(find(pcIdx == 1), textIdx, :), humanScores, 0);
%     %         [distMetric.ISI.saDJS(ll, :, :, :), distMetric.ISI.saRsq(ll, :)] = djsAnalysis(tmpISI.jointCount(find(saIdx == 1), textIdx, :), humanScores, 0);
% end

%% Info calculations using binarized spike trains
% TODO: Implement integration time window here

spikeTrain = binSpikeData(cData, startTime, poiDur, spikeTrainRes);

for tt = 1:length(intTimeWindow)

    % Spike Count
    [spikeCount] = getSpikeCount(spikeTrain, intTimeWindow(tt)); % Outputs spike count not p(x|t)

    tmpSpikes = calculateMutualInformation(spikeCount, 0:numBins, convFactor);
    miNeural.SpikeCount(sl, :) = tmpSpikes.mutualInfo;
    entNeural.SpikeCount(sl, :) = tmpSpikes.entropy;
    jointNeural.SpikeCount{sl} = tmpSpikes.jointCount;
    rate.SpikeCount(sl, :, :) = mean(spikeCount, 3);
    %         [distMetric.SpikeCount.pcDJS(sl, :, :, :), distMetric.SpikeCount.pcRsq(sl, :)] = djsAnalysis(tmpSpikes.jointCount(find(pcIdx == 1), textIdx, :), humanScores, 1);
    %         [distMetric.SpikeCount.saDJS(sl, :, :, :), distMetric.SpikeCount.saRsq(sl, :)] = djsAnalysis(tmpSpikes.jointCount(find(saIdx == 1), textIdx, :), humanScores, 0);

    % ISI TODO
    isiEdges = 0:isiRes:isiCutoff; % 0:1:120

    [isiCount] = getISITau(spikeTrain, intTimeWindow(tt));
    tmpISI = calculateMutualInformation(isiCount, NaN, convFactor);
    miNeural.ISI(ll, :) = tmpISI.mutualInfo;
    entNeural.ISI(ll, :) = tmpISI.entropy;
    jointNeural.ISI{ll} = tmpISI.jointCount;


    % Spike Interval Code (was ISI Tau)
    [spikeIntCount] = getISITau(oldSpikeTrain, intTimeWindow(tt));

    tmpTauIsi = calculateMutualInformation(spikeIntCount, 0:maxTauCount(tt), convFactor);
    miNeural.TauIsi(tt, :) = tmpTauIsi.mutualInfo;
    entNeural.TauIsi(tt, :) = tmpTauIsi.entropy;
    jointNeural.TauIsi{tt} = tmpTauIsi.jointCount;
    rate.isiTau(tt, :) = mean(squeeze(mean(spikeIntCount, 2)), 2);

end % integration time window loop

if saveData
    save('./Data/mostRecentCalculation.mat', 'miNeural', 'entNeural', 'jointNeural', 'distMetric', 'stParams', 'isiParams', 'neuronType', 'pcIdx', 'saIdx', 'isiHist', 'spikeTrain')
end