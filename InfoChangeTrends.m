%% Loading data
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
    load(fullfile(dataLoc, 'InfoData_2024_2_15.mat'))
end

%%

neuronType = {cData.neuron(:).type};
pcIdx = strcmp(neuronType, 'PC'); saIdx = strcmp(neuronType, 'SA');
snippetLength = [2:6,8,10]; % ms

% Toggle conversion of info from bits/bin to bits/bit or bits/spike
infoUnitBits = 1;
infoUnitSpikes = 0;

% Plot params
pcColor = rgb('DarkOrange');
saColor = rgb('Green');

spikeCountColor = rgb('MediumVioletRed');
spikeIntColor = rgb('DeepSkyBlue');
wordColor = rgb('SpringGreen');

%% Change in info due to snippet length

pcData = diff(squeeze(miNeural.SpikeCount(:, pcIdx)) ./ snippetLength');

pcDeltaWords = mean(pcData, 2);
pcDeltaWordsStd = std(pcData, 0, 2);

figure('WindowStyle', 'docked')
subplot(2,1,1)
errorbar(pcDeltaWords, pcDeltaWordsStd, '--o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', pcColor, 'MarkerFaceColor', rgb('White'), ...
    'Color', pcColor, 'LineWidth', 1.5)
hold on
% errorbar(snippetLength, pcSpikeIntMeans, pcSpikeIntStd, '-o', ...
%     'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', rgb('DarkOrange'), ...
%     'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
% 
% ylabel('Info [bits/bit]')
% set(gca, 'XLim', [1.5 10.5], 'XTick', snippetLength, 'FontSize', 12)
% box off
% % ylim([0 2])
% legend({'PC Split', 'PC'}, 'Location', 'Northwest')
% title('PC Spike Interval Count')





%% Change in info due to label