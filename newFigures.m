
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

neuronType = {cData.neuron(:).type};
pcIdx = strcmp(neuronType, 'PC'); saIdx = strcmp(neuronType, 'SA');

%% Info in bits/bin
pcData = squeeze(miNeural.SpikeCount(:, pcIdx));
pcSpikeCountMeans = mean(pcData, 2);
pcSpikeCountStd = std(pcData, 0, 2);

saData = squeeze(miNeural.SpikeCount(:, saIdx));
saSpikeCountMeans = mean(saData, 2);
saSpikeCountStd = std(saData, 0, 2);

figure('WindowStyle', 'docked')
subplot(3,1,1)
errorbar(snippetLength, pcSpikeCountMeans, pcSpikeCountStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', rgb('DarkOrange'), ...
    'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
hold on
errorbar(snippetLength, saSpikeCountMeans, saSpikeCountStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('Green'), ...
    'Color', rgb('Green'), 'LineWidth', 1.5)
ylabel('Info [bits/bin]')
set(gca, 'XLim', [1.5 10.5], 'XTick', snippetLength, 'FontSize', 12)
box off
ylim([0 .225])
legend({'PC', 'SA'}, 'Location', 'Northwest')
title('Spike Count')

pcData = squeeze(miNeural.SplitSpikeInt(:, pcIdx));
pcSpikeIntSplitMeans = mean(pcData, 2);
pcSpikeIntSplitStd = std(pcData, 0, 2);

saData = squeeze(miNeural.SplitSpikeInt(:, saIdx));
saSpikeIntSplitMeans = mean(saData, 2);
saSpikeIntSplitStd = std(saData, 0, 2);

subplot(3,1,2)
errorbar(snippetLength, pcSpikeIntSplitMeans, pcSpikeIntSplitStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', rgb('DarkOrange'), ...
    'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
hold on
errorbar(snippetLength, saSpikeIntSplitMeans, saSpikeIntSplitStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('Green'), ...
    'Color', rgb('Green'), 'LineWidth', 1.5)
ylabel('Info [bits/bin]')
set(gca, 'XLim', [1.5 10.5], 'XTick', snippetLength, 'FontSize', 12)
box off
ylim([0 .225])
legend({'PC', 'SA'}, 'Location', 'Northwest')
title('Split Spike Interval')

pcData = squeeze(miNeural.Words(:, pcIdx));
pcWordMeans = mean(pcData, 2);
pcWordStd = std(pcData, 0, 2);

saData = squeeze(miNeural.Words(:, saIdx));
saWordMeans = mean(saData, 2);
saWordStd = std(saData, 0, 2);

subplot(3,1,3)
errorbar(snippetLength, pcWordMeans, pcWordStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', rgb('DarkOrange'), ...
    'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
hold on
errorbar(snippetLength, saWordMeans, saWordStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('Green'), ...
    'Color', rgb('Green'), 'LineWidth', 1.5)
ylabel('Info [bits/bin]')
set(gca, 'XLim', [1.5 10.5], 'XTick', snippetLength, 'FontSize', 12)
box off
ylim([0 .225])
legend({'PC', 'SA'}, 'Location', 'Northwest')
title('Words')
xlabel('Snippet Length [ms]')

%% Info in bits/bit - grouped by info measure

pcData = squeeze(miNeural.SpikeCount(:, pcIdx)) ./ snippetLength';
pcSpikeCountMeans = mean(pcData, 2);
pcSpikeCountStd = std(pcData, 0, 2);

saData = squeeze(miNeural.SpikeCount(:, saIdx)) ./ snippetLength';
saSpikeCountMeans = mean(saData, 2);
saSpikeCountStd = std(saData, 0, 2);

figure('WindowStyle', 'docked')
subplot(3,1,1)
errorbar(snippetLength, pcSpikeCountMeans, pcSpikeCountStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', rgb('DarkOrange'), ...
    'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
hold on
errorbar(snippetLength, saSpikeCountMeans, saSpikeCountStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('Green'), ...
    'Color', rgb('Green'), 'LineWidth', 1.5)
ylabel('Info [bits/bit]')
set(gca, 'XLim', [1.5 10.5], 'XTick', snippetLength, 'FontSize', 12)
box off
ylim([0 .025])
legend({'PC', 'SA'}, 'Location', 'Northwest')
title('Spike Count')

pcData = squeeze(miNeural.SplitSpikeInt(:, pcIdx)) ./ snippetLength';
pcSpikeIntSplitMeans = mean(pcData, 2);
pcSpikeIntSplitStd = std(pcData, 0, 2);

saData = squeeze(miNeural.SplitSpikeInt(:, saIdx)) ./ snippetLength';
saSpikeIntSplitMeans = mean(saData, 2);
saSpikeIntSplitStd = std(saData, 0, 2);

subplot(3,1,2)
errorbar(snippetLength, pcSpikeIntSplitMeans, pcSpikeIntSplitStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', rgb('DarkOrange'), ...
    'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
hold on
errorbar(snippetLength, saSpikeIntSplitMeans, saSpikeIntSplitStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('Green'), ...
    'Color', rgb('Green'), 'LineWidth', 1.5)
ylabel('Info [bits/bit]')
set(gca, 'XLim', [1.5 10.5], 'XTick', snippetLength, 'FontSize', 12)
box off
ylim([0 .025])
legend({'PC', 'SA'}, 'Location', 'Northwest')
title('Split Spike Interval')

pcData = squeeze(miNeural.Words(:, pcIdx)) ./ snippetLength';
pcWordMeans = mean(pcData, 2);
pcWordStd = std(pcData, 0, 2);

saData = squeeze(miNeural.Words(:, saIdx)) ./ snippetLength';
saWordMeans = mean(saData, 2);
saWordStd = std(saData, 0, 2);

subplot(3,1,3)
errorbar(snippetLength, pcWordMeans, pcWordStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', rgb('DarkOrange'), ...
    'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
hold on
errorbar(snippetLength, saWordMeans, saWordStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('Green'), ...
    'Color', rgb('Green'), 'LineWidth', 1.5)
ylabel('Info [bits/bit]')
set(gca, 'XLim', [1.5 10.5], 'XTick', snippetLength, 'FontSize', 12)
box off
ylim([0 .025])
legend({'PC', 'SA'}, 'Location', 'Northwest')
title('Words')
xlabel('Snippet Length [ms]')


%% Info in bits/bit - grouped by neuron

spikeCountColor = rgb('MediumVioletRed');
spikeIntColor = rgb('DeepSkyBlue');
wordColor = rgb('SpringGreen');

pcData = squeeze(miNeural.SpikeCount(:, pcIdx)) ./ snippetLength';
pcSpikeCountMeans = mean(pcData, 2);
pcSpikeCountStd = std(pcData, 0, 2);

pcData = squeeze(miNeural.SplitSpikeInt(:, pcIdx)) ./ snippetLength';
pcSpikeIntSplitMeans = mean(pcData, 2);
pcSpikeIntSplitStd = std(pcData, 0, 2);

pcData = squeeze(miNeural.Words(:, pcIdx)) ./ snippetLength';
pcWordMeans = mean(pcData, 2);
pcWordStd = std(pcData, 0, 2);

figure('WindowStyle', 'docked')
subplot(2,1,1)
errorbar(snippetLength, pcSpikeCountMeans, pcSpikeCountStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', spikeCountColor, 'MarkerFaceColor', spikeCountColor, ...
    'Color', spikeCountColor, 'LineWidth', 1.5)
hold on

errorbar(snippetLength, pcSpikeIntSplitMeans, pcSpikeIntSplitStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', spikeIntColor, 'MarkerFaceColor', spikeIntColor, ...
    'Color', spikeIntColor, 'LineWidth', 1.5)

errorbar(snippetLength, pcWordMeans, pcWordStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', wordColor, 'MarkerFaceColor', wordColor, ...
    'Color', wordColor, 'LineWidth', 1.5)

ylabel('Info [bits/bit]')
set(gca, 'XLim', [1.5 10.5], 'XTick', snippetLength, 'FontSize', 12)
box off
ylim([0 .025])
legend({'Spike Count', 'Spike Interval', 'Words'}, 'Location', 'Northwest')
title('PC Neurons')

saData = squeeze(miNeural.SpikeCount(:, saIdx)) ./ snippetLength';
saSpikeCountMeans = mean(saData, 2);
saSpikeCountStd = std(saData, 0, 2);

saData = squeeze(miNeural.SplitSpikeInt(:, saIdx)) ./ snippetLength';
saSpikeIntSplitMeans = mean(saData, 2);
saSpikeIntSplitStd = std(saData, 0, 2);

saData = squeeze(miNeural.Words(:, saIdx)) ./ snippetLength';
saWordMeans = mean(saData, 2);
saWordStd = std(saData, 0, 2);

subplot(2,1,2)
errorbar(snippetLength, saSpikeCountMeans, saSpikeCountStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', spikeCountColor, 'MarkerFaceColor', spikeCountColor, ...
    'Color', spikeCountColor, 'LineWidth', 1.5)
hold on

errorbar(snippetLength, saSpikeIntSplitMeans, saSpikeIntSplitStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', spikeIntColor, 'MarkerFaceColor', spikeIntColor, ...
    'Color', spikeIntColor, 'LineWidth', 1.5)

errorbar(snippetLength, saWordMeans, saWordStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', wordColor, 'MarkerFaceColor', wordColor, ...
    'Color', wordColor, 'LineWidth', 1.5)

ylabel('Info [bits/bit]')
set(gca, 'XLim', [1.5 10.5], 'XTick', snippetLength, 'FontSize', 12)
box off
ylim([0 .025])
% legend({'Spike Count', 'Spike Interval', 'Words'}, 'Location', 'Northwest')
title('SA Neurons')


%% Splitting single spike labels

pcSpikeIntSplitMeans = mean(squeeze(miNeural.SplitSpikeInt(:, pcIdx)), 2);
pcSpikeIntMeans = mean(squeeze(miNeural.SpikeInt(:, pcIdx)), 2);

pcSpikeIntStd = std(squeeze(miNeural.SpikeInt(:, pcIdx)), 0, 2);
pcSpikeIntSplitStd = std(squeeze(miNeural.SplitSpikeInt(:, pcIdx)), 0, 2);

figure('WindowStyle', 'docked')
subplot(2,1,1)
errorbar(snippetLength, pcSpikeIntSplitMeans, pcSpikeIntSplitStd, '--o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', rgb('White'), ...
    'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
hold on
errorbar(snippetLength, pcSpikeIntMeans, pcSpikeIntStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', rgb('DarkOrange'), ...
    'Color', rgb('DarkOrange'), 'LineWidth', 1.5)

ylabel('Info [bits/bin]')
set(gca, 'XLim', [1.5 10.5], 'XTick', snippetLength, 'FontSize', 12)
box off
% ylim([0 2])
legend({'PC Split', 'PC'}, 'Location', 'Northwest')
title('PC Spike Interval Count')

saSpikeIntSplitMeans = mean(squeeze(miNeural.SplitSpikeInt(:, saIdx)), 2);
saSpikeIntMeans = mean(squeeze(miNeural.SpikeInt(:, saIdx)), 2);

saSpikeIntStd = std(squeeze(miNeural.SpikeInt(:, saIdx)), 0, 2);
saSpikeIntSplitStd = std(squeeze(miNeural.SplitSpikeInt(:, saIdx)), 0, 2);

subplot(2,1,2)
errorbar(snippetLength, saSpikeIntSplitMeans, saSpikeIntSplitStd, '--o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('White'), ...
    'Color', rgb('Green'), 'LineWidth', 1.5)
hold on
errorbar(snippetLength, saSpikeIntMeans, saSpikeIntStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('Green'), ...
    'Color', rgb('Green'), 'LineWidth', 1.5)
ylabel('Info [bits/bin]')
set(gca, 'XLim', [1.5 10.5], 'XTick', snippetLength, 'FontSize', 12)
box off
% ylim([0 2])
legend({'SA Split', 'SA'}, 'Location', 'Northwest')
title('SA Spike Interval Count')
xlabel('Snippet Length [ms]')

%% Splitting single spike labels (bits/bit)

pcData = squeeze(miNeural.SplitSpikeInt(:, pcIdx)) ./ snippetLength';
pcSpikeIntSplitMeans = mean(pcData, 2);
pcSpikeIntSplitStd = std(pcData, 0, 2);

pcData = squeeze(miNeural.SpikeInt(:, pcIdx)) ./ snippetLength';
pcSpikeIntMeans = mean(pcData, 2);
pcSpikeIntStd = std(pcData, 0, 2);

figure('WindowStyle', 'docked')
subplot(2,1,1)
errorbar(snippetLength, pcSpikeIntSplitMeans, pcSpikeIntSplitStd, '--o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', rgb('White'), ...
    'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
hold on
errorbar(snippetLength, pcSpikeIntMeans, pcSpikeIntStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', rgb('DarkOrange'), ...
    'Color', rgb('DarkOrange'), 'LineWidth', 1.5)

ylabel('Info [bits/bit]')
set(gca, 'XLim', [1.5 10.5], 'XTick', snippetLength, 'FontSize', 12)
box off
% ylim([0 2])
legend({'PC Split', 'PC'}, 'Location', 'Northwest')
title('PC Spike Interval Count')

saData = squeeze(miNeural.SplitSpikeInt(:, saIdx)) ./ snippetLength';
saSpikeIntSplitMeans = mean(saData, 2);
saSpikeIntSplitStd = std(saData, 0, 2);

saData = squeeze(miNeural.SpikeInt(:, saIdx)) ./ snippetLength';
saSpikeIntMeans = mean(saData, 2);
saSpikeIntStd = std(saData, 0, 2);

subplot(2,1,2)
errorbar(snippetLength, saSpikeIntSplitMeans, saSpikeIntSplitStd, '--o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('White'), ...
    'Color', rgb('Green'), 'LineWidth', 1.5)
hold on
errorbar(snippetLength, saSpikeIntMeans, saSpikeIntStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('Green'), ...
    'Color', rgb('Green'), 'LineWidth', 1.5)
ylabel('Info [bits/bit]')
set(gca, 'XLim', [1.5 10.5], 'XTick', snippetLength, 'FontSize', 12)
box off
% ylim([0 2])
legend({'SA Split', 'SA'}, 'Location', 'Northwest')
title('SA Spike Interval Count')
xlabel('Snippet Length [ms]')

%% % Scatter plots
% Size of dot = snippet size

neuronType = {cData.neuron(:).type};
pcIdx = strcmp(neuronType, 'PC'); saIdx = strcmp(neuronType, 'SA');
snippetLength = [2:6,8,10]; % ms

pcColor = rgb('DarkOrange');
saColor = rgb('Green');

for sl = 1:length(snippetLength)
    scatter(squeeze(miNeural.SpikeCount(sl, pcIdx)), squeeze(miNeural.SpikeInt(sl, pcIdx)), snippetLength(sl), pcColor, "filled")
    hold on
    scatter(squeeze(miNeural.SpikeCount(sl, saIdx)), squeeze(miNeural.SpikeInt(sl, saIdx)), snippetLength(sl), saColor, "filled")
end


