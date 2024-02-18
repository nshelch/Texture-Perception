neuronType = {cData.neuron(:).type};
pcIdx = strcmp(neuronType, 'PC'); saIdx = strcmp(neuronType, 'SA');


pcSpikeCountMeans = mean(squeeze(miNeural.SpikeCount(:, pcIdx)), 2);
saSpikeCountMeans = mean(squeeze(miNeural.SpikeCount(:, saIdx)), 2);

pcSpikeCountStd = std(squeeze(miNeural.SpikeCount(:, pcIdx)), 0, 2);
saSpikeCountStd = std(squeeze(miNeural.SpikeCount(:, saIdx)), 0, 2);

pcSpikeIntMeans = mean(squeeze(miNeural.SpikeInt(:, pcIdx)), 2);
saSpikeIntMeans = mean(squeeze(miNeural.SpikeInt(:, saIdx)), 2);

pcSpikeIntStd = std(squeeze(miNeural.SpikeInt(:, pcIdx)), 0, 2);
saSpikeIntStd = std(squeeze(miNeural.SpikeInt(:, saIdx)), 0, 2);

figure('WindowStyle', 'docked')
subplot(2,1,1)
errorbar(snippetLength, pcSpikeCountMeans, pcSpikeCountStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', rgb('DarkOrange'), ...
    'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
hold on
errorbar(snippetLength, saSpikeCountMeans, saSpikeCountStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('Green'), ...
    'Color', rgb('Green'), 'LineWidth', 1.5)
ylabel('Info [bits]')
set(gca, 'XLim', [1.5 10.5], 'XTick', snippetLength, 'FontSize', 12)
box off
% ylim([0 2])
legend({'PC', 'SA'}, 'Location', 'Northwest')
title('Spike Count')


subplot(2,1,2)
errorbar(snippetLength, pcSpikeIntMeans, pcSpikeIntStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', rgb('DarkOrange'), ...
    'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
hold on
errorbar(snippetLength, saSpikeIntMeans, saSpikeIntStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('Green'), ...
    'Color', rgb('Green'), 'LineWidth', 1.5)
ylabel('Info [bits]')
set(gca, 'XLim', [1.5 10.5], 'XTick', snippetLength, 'FontSize', 12)
box off
% ylim([0 2])
legend({'PC', 'SA'}, 'Location', 'Northwest')
title('Spike Interval')
xlabel('Snippet Length [ms]')

% saveas(gcf, './Figures/SpikeCountVsIsi.png')
% export_fig('./Figures/SpikeCountVsIsi.png', '-dpng', '-transparent', '-r300');

%% % Scatter plots
% Size of dot = snippet size

neuronType = {cData.neuron(:).type};
pcIdx = strcmp(neuronType, 'PC'); saIdx = strcmp(neuronType, 'SA');

for sl = 1:length(snippetLength)
    scatter(squeeze(miNeural.SpikeCount(sl, pcIdx)), squeeze(miNeural.SpikeIntCount(sl, pcIdx)), sl, rgb('DarkOrange'), "filled")



end


