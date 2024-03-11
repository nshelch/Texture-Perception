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

figure('WindowStyle', 'docked')
subplot(2,1,1); hold on;

pcData = diff(squeeze(miNeural.SpikeCount(:, pcIdx)) ./ snippetLength');
pcMean = mean(pcData, 2);
pcStd = std(pcData, 0, 2);

errorbar(pcMean, pcStd, 'o-', ...
    'MarkerSize', 10, 'MarkerEdgeColor', spikeCountColor, 'MarkerFaceColor', spikeCountColor, ...
    'Color', spikeCountColor, 'LineWidth', 1.5)

pcData = diff(squeeze(miNeural.SpikeInt(:, pcIdx)) ./ snippetLength');
pcMean = mean(pcData, 2);
pcStd = std(pcData, 0, 2);

errorbar(pcMean, pcStd, 'o-', ...
    'MarkerSize', 10, 'MarkerEdgeColor', spikeIntColor, 'MarkerFaceColor', spikeIntColor, ...
    'Color', spikeIntColor, 'LineWidth', 1.5)

pcData = diff(squeeze(miNeural.Words(:, pcIdx)) ./ snippetLength');
pcMean = mean(pcData, 2);
pcStd = std(pcData, 0, 2);

errorbar(pcMean, pcStd, 'o-', ...
    'MarkerSize', 10, 'MarkerEdgeColor', wordColor, 'MarkerFaceColor', wordColor, ...
    'Color', wordColor, 'LineWidth', 1.5)

ylabel('\DeltaInfo [bits/bit]')
xTickLabel = {'2 \rightarrow 3', '3 \rightarrow 4', '4 \rightarrow 5', '5 \rightarrow 6', '6 \rightarrow 8', '8 \rightarrow 10'};
set(gca, 'XLim', [0.5 6.5], 'XTick', 1:6, 'XTickLabel', xTickLabel, 'FontSize', 12)
box off
text(.75, .00225, ColorText({'Spike Count', 'Spike Int.', 'Words'}, [spikeCountColor; spikeIntColor; wordColor]), ...
    'FontSize', 12, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top')
title('PC Neurons')

subplot(2,1,2); hold on;

saData = diff(squeeze(miNeural.SpikeCount(:, saIdx)) ./ snippetLength');
saMean = mean(saData, 2);
saStd = std(saData, 0, 2);

errorbar(mean(saData, 2), std(saData, 0, 2), 'o-', ...
    'MarkerSize', 10, 'MarkerEdgeColor', spikeCountColor, 'MarkerFaceColor', spikeCountColor, ...
    'Color', spikeCountColor, 'LineWidth', 1.5)


saData = diff(squeeze(miNeural.SpikeInt(:, saIdx)) ./ snippetLength');
saMean = mean(saData, 2);
saStd = std(saData, 0, 2);

errorbar(saMean, saStd, 'o-', ...
    'MarkerSize', 10, 'MarkerEdgeColor', spikeIntColor, 'MarkerFaceColor', spikeIntColor, ...
    'Color', spikeIntColor, 'LineWidth', 1.5)

saData = diff(squeeze(miNeural.Words(:, saIdx)) ./ snippetLength');
saMean = mean(saData, 2);
saStd = std(saData, 0, 2);

errorbar(saMean, saStd, 'o-', ...
    'MarkerSize', 10, 'MarkerEdgeColor', wordColor, 'MarkerFaceColor', wordColor, ...
    'Color', wordColor, 'LineWidth', 1.5)

ylabel('\DeltaInfo [bits/bit]')
xlabel('Snippet Length [ms]')
xTickLabel = {'2 \rightarrow 3', '3 \rightarrow 4', '4 \rightarrow 5', '5 \rightarrow 6', '6 \rightarrow 8', '8 \rightarrow 10'};
set(gca, 'XLim', [0.5 6.5], 'XTick', 1:6, 'XTickLabel', xTickLabel, 'FontSize', 12)
box off
text(.75, .00095, ColorText({'Spike Count', 'Spike Int.', 'Words'}, [spikeCountColor; spikeIntColor; wordColor]), ...
    'FontSize', 12, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top')
title('SA Neurons')

%% Change in info due to label

figure('WindowStyle', 'docked')
subplot(3,1,1); hold on;

pcData = diff(squeeze(miNeural.SpikeCount(:, pcIdx)) ./ snippetLength');
pcMean = mean(pcData, 2);
pcStd = std(pcData, 0, 2);

errorbar(pcMean, pcStd, 'o-', ...
    'MarkerSize', 10, 'MarkerEdgeColor', pcColor, 'MarkerFaceColor', pcColor, ...
    'Color', pcColor, 'LineWidth', 1.5)

saData = diff(squeeze(miNeural.SpikeCount(:, saIdx)) ./ snippetLength');
saMean = mean(saData, 2);
saStd = std(saData, 0, 2);

errorbar(mean(saData, 2), std(saData, 0, 2), 'o-', ...
    'MarkerSize', 10, 'MarkerEdgeColor', spikeCountColor, 'MarkerFaceColor', spikeCountColor, ...
    'Color', spikeCountColor, 'LineWidth', 1.5)

ylabel('\DeltaInfo [bits/bit]')
xTickLabel = {'2 \rightarrow 3', '3 \rightarrow 4', '4 \rightarrow 5', '5 \rightarrow 6', '6 \rightarrow 8', '8 \rightarrow 10'};
set(gca, 'XLim', [0.5 6.5], 'XTick', 1:6, 'XTickLabel', xTickLabel, 'FontSize', 12)
box off
text(.75, .00225, ColorText({'Spike Count', 'Spike Int.', 'Words'}, [spikeCountColor; spikeIntColor; wordColor]), ...
    'FontSize', 12, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top')
title('PC Neurons')

subplot(3,1,2); hold on;

pcData = diff(squeeze(miNeural.SpikeInt(:, pcIdx)) ./ snippetLength');
pcMean = mean(pcData, 2);
pcStd = std(pcData, 0, 2);

errorbar(pcMean, pcStd, 'o-', ...
    'MarkerSize', 10, 'MarkerEdgeColor', spikeIntColor, 'MarkerFaceColor', spikeIntColor, ...
    'Color', spikeIntColor, 'LineWidth', 1.5)


saData = diff(squeeze(miNeural.SpikeInt(:, saIdx)) ./ snippetLength');
saMean = mean(saData, 2);
saStd = std(saData, 0, 2);

errorbar(saMean, saStd, 'o-', ...
    'MarkerSize', 10, 'MarkerEdgeColor', spikeIntColor, 'MarkerFaceColor', spikeIntColor, ...
    'Color', spikeIntColor, 'LineWidth', 1.5)

subplot(3,1,3); hold on;


pcData = diff(squeeze(miNeural.SpikeInt(:, pcIdx)) ./ snippetLength');
pcMean = mean(pcData, 2);
pcStd = std(pcData, 0, 2);

errorbar(pcMean, pcStd, 'o-', ...
    'MarkerSize', 10, 'MarkerEdgeColor', spikeIntColor, 'MarkerFaceColor', spikeIntColor, ...
    'Color', spikeIntColor, 'LineWidth', 1.5)

saData = diff(squeeze(miNeural.Words(:, saIdx)) ./ snippetLength');
saMean = mean(saData, 2);
saStd = std(saData, 0, 2);

errorbar(saMean, saStd, 'o-', ...
    'MarkerSize', 10, 'MarkerEdgeColor', wordColor, 'MarkerFaceColor', wordColor, ...
    'Color', wordColor, 'LineWidth', 1.5)

ylabel('\DeltaInfo [bits/bit]')
xlabel('Snippet Length [ms]')
xTickLabel = {'2 \rightarrow 3', '3 \rightarrow 4', '4 \rightarrow 5', '5 \rightarrow 6', '6 \rightarrow 8', '8 \rightarrow 10'};
set(gca, 'XLim', [0.5 6.5], 'XTick', 1:6, 'XTickLabel', xTickLabel, 'FontSize', 12)
box off
text(.75, .00095, ColorText({'Spike Count', 'Spike Int.', 'Words'}, [spikeCountColor; spikeIntColor; wordColor]), ...
    'FontSize', 12, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top')
title('SA Neurons')