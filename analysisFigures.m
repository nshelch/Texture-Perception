%%%%%%% Figures %%%%%%%%%%%%
neuronType = {cData.neuron(:).type};
pcIdx = strcmp(neuronType, 'PC'); saIdx = strcmp(neuronType, 'SA');

%% PC/SA Spike Count Histogram per Texture

spikeCountRate = zeros(141, numel(stParams.snippetLength));
spikeCountTextureRate = zeros([size(isiHist, 1,2), numel(stParams.snippetLength)]);
for nn = 1:141
    for ii = 1:numel(stParams.snippetLength)
        tau = 0:stParams.snippetLength(ii);
        for tt = 1:59
            curSpikeCountDist{tt} = repelem(tau, squeeze(jointNeural.SpikeCount{ii}(nn, tt, :))');
            spikeCountTextureRate(nn, tt, ii) = mean(curSpikeCountDist{tt});
        end
        if ~isempty(curSpikeCountDist)
            spikeCountRate(nn, ii) = mean(cell2mat(curSpikeCountDist));
        end
    end
end

pcId = find(pcIdx == 1); saId = find(saIdx == 1);
for ii = 1:numel(stParams.snippetLength)
    for nn = pcId
        if ismember(nn, pcId)
            neuronColor = rgb('DarkOrange');
        elseif ismember(nn, saId)
            neuronColor = rgb('Green');
        else
            neuronColor = rgb('DarkGrey');
        end
        if stParams.snippetLength(ii) > 20
            tau = 0:stParams.snippetLength(ii);
        end
        figure('units','normalized','outerposition',[0 0 1 1])
        for tt = 1:59
            if stParams.snippetLength(ii) > 20
                curSpikeCountDist = repelem(tau, squeeze(jointNeural.SpikeCount{ii}(nn, tt, :))');
                subplot(10,6,tt)
                histogram(curSpikeCountDist, 'BinEdges', -0.5:1:stParams.snippetLength(ii) + .5, ...
                    'Normalization', 'probability', 'FaceColor', neuronColor)   
            else
                subplot(10,6,tt)
                histogram('BinEdges', -0.5:1:stParams.snippetLength(ii) + .5, 'BinCounts', squeeze(jointNeural.SpikeCount{ii}(nn, tt, :)), ...
                    'Normalization', 'probability', 'FaceColor', neuronColor)
            end
            hold on
            stem(spikeCountRate(nn, ii), .5, 'kv', 'LineWidth', 1.5, 'MarkerFaceColor', 'k')
            stem(spikeCountTextureRate(nn, tt, ii), .4, 's', 'LineWidth', 1.5, ...
                'Color', rgb('Crimson'), 'MarkerFaceColor', rgb('Crimson'))
            ylim([0, 1]); box off
            set(gca, 'FontSize', 10)
        end
        sgtitle(sprintf('Neuron %i, Snippet Length %ims', nn, stParams.snippetLength(ii)));
        saveas(gcf, sprintf('./Figures/PC%i_SpikeCountHist_%imsWindow.png', nn, stParams.snippetLength(ii)))
    end
end

%% SA/PC Spike Count vs ISI
scIdx = find(snippetLength == 10);
pcSpikeCountMeans = mean(squeeze(miNeural.SpikeCount( scIdx, pcIdx)));
saSpikeCountMeans = mean(squeeze(miNeural.SpikeCount( scIdx, saIdx)));

pcSpikeCountStd = std(squeeze(miNeural.SpikeCount( scIdx, pcIdx)), 0, 1);
saSpikeCountStd = std(squeeze(miNeural.SpikeCount( scIdx, saIdx)), 0, 1);

isiIdx = find(isiParams.isiTimeWindow == 10);
pcIsiMeans = mean(squeeze(miNeural.ISI( isiIdx, pcIdx)), 1);
saIsiMeans = mean(squeeze(miNeural.ISI( isiIdx, saIdx)), 1);

pcIsiStd = std(squeeze(miNeural.ISI( isiIdx, pcIdx)));
saIsiStd = std(squeeze(miNeural.ISI( isiIdx, saIdx)));

figure('WindowStyle', 'docked')
errorbar([pcSpikeCountMeans, pcIsiMeans], [pcSpikeCountStd, pcIsiStd], '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', rgb('DarkOrange'), ...
    'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
hold on
errorbar([saSpikeCountMeans, saIsiMeans], [saSpikeCountStd, saIsiStd], '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('Green'), ...
    'Color', rgb('Green'), 'LineWidth', 1.5)
ylabel('Info [bits]')
set(gca, 'XLim', [0.5 2.5], 'XTick', 1:2, 'XTickLabel', {'Spike Count', 'ISI (\tau \leq 10 ms)'}, 'FontSize', 15)
box off
ylim([0 2])
legend({'PC', 'SA'}, 'Location', 'Northwest')
saveas(gcf, './Figures/SpikeCountVsIsi.png')
export_fig('./Figures/SpikeCountVsIsi.png', '-dpng', '-transparent', '-r300');

%% PC/SA Spike Count vs ISI and DJS Individual Neurons
    figure('WindowStyle', 'docked')
for nn = pcId
    subplot(1,2,1)
    plot(stParams.snippetLength, miNeural.SpikeCount(1,:, nn), '--o', ...
        'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', 'w', ...
        'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
    hold on
    plot(stParams.snippetLength, miNeural.ISI(1,isiWindows, nn), '-o', ...
        'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', rgb('DarkOrange'), ...
        'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
    ylabel('Info [bits]'); xlabel('Snippet Length [ms]')
    set(gca, 'XLim', [0 110], 'FontSize', 15)
    box off
    ylim([0 2])
    title(sprintf('PC %i', nn))
    legend({'Spike Count', 'ISI'}, 'Location', 'NorthWest')
    hold off
    subplot(1,2,2)
    plot(stParams.snippetLength, distMetric.SpikeCount.pcRsq(:, pcId == nn), '--o', ...
        'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', 'w', ...
        'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
    hold on
    plot(stParams.snippetLength, distMetric.ISI.pcRsq(isiWindows, pcId == nn), '-o', ...
        'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', rgb('DarkOrange'), ...
        'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
    ylabel('R^2 [perceptual distance]'); xlabel('Snippet Length [ms]')
    set(gca, 'XLim', [0 110], 'FontSize', 15)
    box off
    ylim([0 .75])
    title(sprintf('PC %i', nn))    
    saveas(gcf, sprintf('./Figures/PC%i_InfoDjsMetrics.png', nn))
    hold off
end

%% PC/SA Info as ISI Length Increases

miNeural.ISI(isnan(miNeural.ISI)) = 0; entNeural.ISI(isnan(entNeural.ISI)) = 0;
pcMeans = mean(squeeze(miNeural.ISI(:, pcIdx)), 2);
saMeans = mean(squeeze(miNeural.ISI(:, saIdx)), 2);

pcStd = std(squeeze(miNeural.ISI(:, pcIdx)), 0, 2);
saStd = std(squeeze(miNeural.ISI(:, saIdx)), 0, 2);

figure('WindowStyle', 'docked');
errorbar(isiParams.isiTimeWindow, pcMeans, pcStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Orange'), 'MarkerFaceColor', rgb('Orange'), ...
    'Color', rgb('Orange'), 'LineWidth', 1.5)
hold on
errorbar(isiParams.isiTimeWindow, saMeans, saStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('Green'), ...
    'Color', rgb('Green'), 'LineWidth', 1.5)
xlabel('ISI Limit [ms]'); ylabel('Info [bits]')
% title(sprintf('ISI Resolution %i ms', isiRes(ss)))
ylim([-0.5 3])
box off
set(gca, 'FontSize', 15)
legend({'PC', 'SA'}, 'Location', 'NorthWest')

saveas(gcf, './Figures/IsiResolutionInfo_bits.png')
export_fig('./Figures/IsiResolutionInfo_bits.png', '-dpng', '-transparent', '-r300');

%% PC/SA Info as ISI Length Increases (Normalized by Entropy)
pcMeans = mean(squeeze(miNeural.ISI(:, pcIdx)) ./ (squeeze(entNeural.ISI(:, pcIdx)) + eps), 2);
saMeans = mean(squeeze(miNeural.ISI(:, saIdx)) ./ (squeeze(entNeural.ISI(:, saIdx)) + eps), 2);

pcStd = std(squeeze(miNeural.ISI(:, pcIdx)) ./ squeeze(entNeural.ISI(:, pcIdx) + eps), 0, 2);
saStd = std(squeeze(miNeural.ISI(:, saIdx)) ./ squeeze(entNeural.ISI(:, saIdx) + eps), 0, 2);

isiWindow = 2:numel(isiParams.isiTimeWindow);
figure('WindowStyle', 'docked');
errorbar(isiParams.isiTimeWindow(isiWindow), pcMeans(isiWindow), pcStd(isiWindow), '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Orange'), 'MarkerFaceColor', rgb('Orange'), ...
    'Color', rgb('Orange'), 'LineWidth', 1.5)
hold on
errorbar(isiParams.isiTimeWindow(isiWindow), saMeans(isiWindow), saStd(isiWindow), '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('Green'), ...
    'Color', rgb('Green'), 'LineWidth', 1.5)
xlabel('ISI Limit [ms]'); ylabel('Info [bits/bit]')
box off
set(gca, 'FontSize', 15)
legend({'PC', 'SA'}, 'Location', 'Northeast')
saveas(gcf, './Figures/IsiResolutionInfo_bitsPerBit.png')
export_fig('./Figures/IsiResolutionInfo_bitsPerBit.png', '-dpng', '-transparent', '-r300');

%% PC/SA Info as ISI Length Increases (Normalized by Spikes)

spikeRate = zeros([141, numel(jointNeural.SpikeCount)]);
for nn = 1:size(isiHist, 1)
    for ii = 1:numel(snippetLength)
        tau = 0:snippetLength(ii);
        for tt = 1:size(isiHist, 2)
            curSpikeCountDist{tt} = repelem(tau, squeeze(jointNeural.SpikeCount{ii}(nn, tt, :)));
        end
        if ~isempty(curSpikeCountDist)
            spikeRate(nn, ii) = mean(cell2mat(curSpikeCountDist)); % +1 since the first column is ISI = 0;
            spikeRateStd(nn, ii) = std(cell2mat(curSpikeCountDist));
        end
    end
end

isiWindow = ismember(isiParams.isiTimeWindow, snippetLength);

pcMeans = mean(squeeze(miNeural.ISI( isiWindow, pcIdx)) ./ spikeRate(pcIdx, :)');
saMeans = mean(squeeze(miNeural.ISI( isiWindow, saIdx)) ./ spikeRate(saIdx, :)');

pcStd = std(squeeze(miNeural.ISI( isiWindow, pcIdx)) ./ spikeRateStd(pcIdx, :)');
saStd = std(squeeze(miNeural.ISI( isiWindow, saIdx)) ./ spikeRateStd(saIdx, :)');

isiWindow = 2:numel(isiParams.isiTimeWindow);
figure('WindowStyle', 'docked');
errorbar(isiParams.isiTimeWindow(isiWindow), pcMeans(isiWindow), pcStd(isiWindow), '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Orange'), 'MarkerFaceColor', rgb('Orange'), ...
    'Color', rgb('Orange'), 'LineWidth', 1.5)
hold on
errorbar(isiParams.isiTimeWindow(isiWindow), saMeans(isiWindow), saStd(isiWindow), '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('Green'), ...
    'Color', rgb('Green'), 'LineWidth', 1.5)
xlabel('ISI Limit [ms]'); ylabel('Info [bits/spike]')
box off
set(gca, 'FontSize', 15)
legend({'PC', 'SA'}, 'Location', 'Northeast')
saveas(gcf, './Figures/IsiResolutionInfo_bitsPerSpike.png')
export_fig('./Figures/IsiResolutionInfo_bitsPerTau.png', '-dpng', '-transparent', '-r300');

%% PC/SA ISI Histogram per Texture

isiRate = zeros(141, numel(isiParams.isiTimeWindow));
isiTextureRate = zeros([size(isiHist, 1,2), numel(isiParams.isiTimeWindow)]);
for nn = 1:size(isiHist, 1)
    for ii = 1:numel(isiParams.isiTimeWindow)
        tau = 0:isiParams.isiTimeWindow(ii);
        for tt = 1:size(isiHist, 2)
            curIsiDist{tt} = repelem(tau, squeeze(isiHist(nn, tt, 1:isiParams.isiTimeWindow(ii) + 1))');
            isiTextureRate(nn, tt, ii) = mean(curIsiDist{tt});
        end
        if ~isempty(curIsiDist)
            isiRate(nn, ii) = mean(cell2mat(curIsiDist));
        end
    end
end

pcId = find(pcIdx == 1); saId = find(saIdx == 1);
for ii = 4:numel(isiParams.isiTimeWindow)
    for nn = pcId
        if ismember(nn, pcId)
            neuronColor = rgb('DarkOrange');
        elseif ismember(nn, saId)
            neuronColor = rgb('Green');
        else
            neuronColor = rgb('DarkGrey');
        end
        figure('units','normalized','outerposition',[0 0 1 1])
         if isiParams.isiTimeWindow(ii) > 20
            tau = 0:isiParams.isiTimeWindow(ii);
        end
        for tt = 1:59
            if isiParams.isiTimeWindow(ii)  > 20
                curIsiDist = repelem(tau, squeeze(isiHist(nn, tt, 1:isiParams.isiTimeWindow(ii) + 1))');
                subplot(10,6,tt)
                histogram(curIsiDist, 'BinEdges', -0.5:1:isiParams.isiTimeWindow(ii) + .5, ...
                    'Normalization', 'probability', 'FaceColor', 'w', 'EdgeColor', rgb('DarkOrange'))
            else
                subplot(10,6,tt)
                histogram('BinEdges', -0.5:1:isiParams.isiTimeWindow(ii) + .5, 'BinCounts', squeeze(isiHist(nn, tt, 1:isiParams.isiTimeWindow(ii) + 1)), ...
                    'Normalization', 'probability', 'FaceColor', neuronColor)
            end
            hold on
            stem(isiRate(nn, ii), .75, 'kv', 'LineWidth', 1.5, 'MarkerFaceColor', 'k')
            stem(isiTextureRate(nn, tt, ii), .6, 's', 'LineWidth', 1.5, ...
                'Color', rgb('Crimson'), 'MarkerFaceColor', rgb('Crimson'))
            ylim([0, 1]); box off
            %             ylabel('Probability'); xlabel('ISI [ms]')
            set(gca, 'FontSize', 10)
            %             title(sprintf('Texture %i', tt))
        end
        sgtitle(sprintf('Neuron %i, ISI Window %ims', nn, isiParams.isiTimeWindow(ii)));
        saveas(gcf, sprintf('./Figures/PC%i_ISIHist_%imsWindow.png', nn, isiParams.isiTimeWindow(ii)))
    end
end

%% PC/SA ISI vs Spike Count Histogram per Texture

isiWindows = [4,5,7,8];
for ii = 1:3
    spikeTimeIdx = ii;
    isiTimeIdx = isiWindows(ii);
            figure('units','normalized','outerposition',[0 0 1 1])
    for nn = pcId
        tau = 0:stParams.snippetLength(spikeTimeIdx);
        for tt = 1:59
            
            subplot(10,6,tt)
            curSpikeCountDist = repelem(tau, squeeze(jointNeural.SpikeCount{spikeTimeIdx}(nn, tt, :))');
            histogram(curSpikeCountDist, 'BinEdges', -0.5:1:stParams.snippetLength(spikeTimeIdx) + .5, ...
                'Normalization', 'probability', 'FaceColor', rgb('Gold')) % DodgerBlue
            hold on
            stem(spikeCountRate(nn, spikeTimeIdx), .5, 'v', 'Color', rgb('Goldenrod'), 'LineWidth', 1.5, ...
                'MarkerFaceColor', rgb('Goldenrod'), 'MarkerEdgeColor', 'none', 'MarkerSize', 5) %DarkBlue
            stem(spikeCountTextureRate(nn, tt, spikeTimeIdx), .4, 's', 'Color', rgb('Gold'), 'LineWidth', 1.5, ...
                'MarkerFaceColor', rgb('Gold'), 'MarkerEdgeColor', 'none', 'MarkerSize', 5) %DodgerBlue
            
            curIsiDist = repelem(tau, squeeze(isiHist(nn, tt, 1:isiParams.isiTimeWindow(isiTimeIdx) + 1))');
            histogram(curIsiDist, 'BinEdges', -0.5:1:isiParams.isiTimeWindow(isiTimeIdx) + .5, ...
                'Normalization', 'probability', 'FaceColor', rgb('Orange'), 'FaceAlpha', 0.5) %ForestGreen
            
            stem(isiRate(nn, isiTimeIdx), .5, 'v',  'Color', rgb('Chocolate'), 'LineWidth', 1.5, ...
                'MarkerFaceColor', rgb('Chocolate'), 'MarkerEdgeColor', 'none', 'MarkerSize', 5) %DarkGreen
            stem(isiTextureRate(nn, tt, isiTimeIdx), .4, 's',  'Color', rgb('Orange'), 'LineWidth', 1.5, ...
                'MarkerFaceColor', rgb('Orange'), 'MarkerEdgeColor', 'none', 'MarkerSize', 5) %ForestGreen
            
            ylim([0, 1]); xlim([0 50]); box off
            set(gca, 'FontSize', 10)
            hold off
        end
        sgtitle(sprintf('Neuron %i, Snippet Length %ims', nn, stParams.snippetLength(spikeTimeIdx)));
        saveas(gcf, sprintf('./Figures/PC%i_SpikeCountHist_%imsWindow.png', nn, stParams.snippetLength(spikeTimeIdx)))
    end
end

%% PC/SA ISI Histogram
isiNeuronHist = squeeze(sum(isiHist, 2));
figure('WindowStyle', 'docked');
histogram('BinCounts', squeeze(sum(isiNeuronHist(pcIdx, :))), 'BinEdges', 0:1:120, ...
    'Normalization', 'probability', 'DisplayStyle', 'stairs', ...
    'EdgeColor', rgb('DarkOrange'), 'LineWidth', 1.5)
hold on
histogram('BinCounts', squeeze(sum(isiNeuronHist(saIdx, :))), 'BinEdges', 0:1:120, ...
    'Normalization', 'probability', 'DisplayStyle', 'stairs', ...
    'EdgeColor', rgb('Green'), 'LineWidth', 1.5)
xlabel('ISI [ms]'); ylabel('Probability')
box off
set(gca, 'FontSize', 15)
legend({'PC', 'SA'}, 'Location', 'Northeast')
saveas(gcf, './Figures/IsiDistributionNeruonTypes.png')
export_fig('./Figures/IsiDistributionNeruonTypes.png', '-dpng', '-transparent', '-r300');

%% PC/SA Tau Rate

figure('WindowStyle', 'docked');
plot(maxTauCount, '--', 'Color', 'k', 'LineWidth', 1.5)
hold on
plot(mean(squeeze(rate.isiTau(1, 2, :, pcIdx)), 2), '-', 'Color', rgb('Orange'), 'LineWidth', 1.5)
plot(mean(squeeze(rate.isiTau(1, 2, :, saIdx)), 2), '-', 'Color', rgb('Green'), 'LineWidth', 1.5)
ylabel('\tau Rate [Counts per Snippet]')
xlabel('\tau [ms]')
legend({'Max Rate', 'PC Obs.', 'SA Obs.'}, 'Location', 'Northeast')
box off
set(gca, 'Fontsize', 15)
saveas(gcf, './Figures/rate.isiTau.png')
export_fig('./Figures/rate.isiTau.png', '-dpng', '-transparent', '-r300');

figure('WindowStyle', 'docked');
plot(mean(squeeze(rate.isiTau(1, 2, :, pcIdx)), 2), '-', 'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
hold on
plot(mean(squeeze(rate.isiTau(1, 2, :, saIdx)), 2), '-', 'Color', rgb('Green'), 'LineWidth', 1.5)
ylabel('\tau Rate [Counts per Snippet]')
xlabel('\tau [ms]')
legend({'PC', 'SA'}, 'Location', 'Northeast')
box off
set(gca, 'Fontsize', 15)
saveas(gcf, './Figures/ISITauRateZoomed.png')
export_fig('./Figures/ISITauRateZoomed.png', '-dpng', '-transparent', '-r300');

%% PC/SA Broken up by ISI Tau
figure('WindowStyle', 'docked');
for tt = 1:length(isiTau)
    pcMeans = mean(squeeze(miNeural.TauIsi( 2, :, pcIdx)), 2);
    saMeans = mean(squeeze(miNeural.TauIsi( 2, :, saIdx)), 2);
    
    pcStd = std(squeeze(miNeural.TauIsi( 2, :, pcIdx)), 0, 2);
    saStd = std(squeeze(miNeural.TauIsi( 2, :, saIdx)), 0, 2);
    
    errorbar(isiTau, pcMeans, pcStd, '-o', ...
        'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', rgb('DarkOrange'), ...
        'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
    hold on
    errorbar(isiTau, saMeans, saStd, '-o', ...
        'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('Green'), ...
        'Color', rgb('Green'), 'LineWidth', 1.5)
    xlabel('Interval Code \tau [ms]'); ylabel('Info [bits]')
    %     title(sprintf('ISI Resolution %i ms', isiRes(ss)))
    box off
    %     set(gca, 'XLim', [0.5 9.5], 'XTick', 1:10)
    set(gca, 'FontSize', 15)
    %     set(gcf, 'Color', 'none')
    legend({'PC', 'SA'}, 'Location', 'Northeast')
end

saveas(gcf, './Figures/InfoISITau_20msSnippet.png')
export_fig('./Figures/InfoISITau_20msSnippet.png', '-dpng', '-transparent', '-r300');

%% ISI vs Spike Count Info Snippet Length
pcIsiMeans = mean(squeeze(miNeural.ISI(1, :, pcIdx)), 2);
saIsiMeans = mean(squeeze(miNeural.ISI(1, :, saIdx)), 2);

pcIsiStd = std(squeeze(miNeural.ISI(1, :, pcIdx)), 0, 2);
saIsiStd = std(squeeze(miNeural.ISI(1, :, saIdx)), 0, 2);

pcSpikeCountMeans = mean(squeeze(miNeural.SpikeCount(1, :, pcIdx)), 2);
saSpikeCountMeans = mean(squeeze(miNeural.SpikeCount(1, :, saIdx)), 2);

pcSpikeCountStd = std(squeeze(miNeural.SpikeCount(1, :, pcIdx)), 0, 2);
saSpikeCountStd = std(squeeze(miNeural.SpikeCount(1, :, saIdx)), 0, 2);

figure('WindowStyle', 'docked');
subplot(2,1,1)
errorbar(isiParams.isiTimeWindow, pcIsiMeans, pcIsiStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', rgb('DarkOrange'), ...
    'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
hold on
errorbar(stParams.snippetLength, pcSpikeCountMeans, pcSpikeCountStd, '--o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('DarkOrange'), 'MarkerFaceColor', 'w', ...
    'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
box off; xlabel('Snippet Length [ms]'); ylabel('Info [bits]');
legend({'PC ISI', 'PC Spike Count'}, 'Location', 'Northwest')
set(gca, 'FontSize', 15)

subplot(2,1,2)
errorbar(isiParams.isiTimeWindow, saIsiMeans, saIsiStd, '-o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('Green'), ...
    'Color', rgb('Green'), 'LineWidth', 1.5)
hold on
errorbar(stParams.snippetLength, saSpikeCountMeans, saSpikeCountStd, '--o', ...
    'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', 'w', ...
    'Color', rgb('Green'), 'LineWidth', 1.5)
box off; xlabel('Snippet Length [ms]'); ylabel('Info [bits]');
legend({'SA ISI', 'SA Spike Count'}, 'Location', 'Northwest')
set(gca, 'FontSize', 15)
saveas(gcf, './Figures/InfoIsiSpikeCount_FunctionOfSL.png')
export_fig('./Figures/InfoIsiSpikeCount_FunctionOfSL.png', '-dpng', '-transparent', '-r300');

%% DJS Scatter Neural vs Human


load(fullfile(dataLoc, 'dissimData.mat'))

humanScores = dissimData.mat;
textIdx = dissimData.textInd;

humanDissim = reshape(humanScores, [1, size(humanScores, 1) * size(humanScores, 2)]);

% ISI
ll = 8;
pcNeuron = find(distMetric.ISI.pcRsq(ll, :) == max(distMetric.ISI.pcRsq(ll, :)));
saNeuron = find(distMetric.ISI.saRsq(ll, :) == max(distMetric.ISI.saRsq(ll, :)));
neuralDissimPC = reshape(distMetric.ISI.pcDJS(ll, pcNeuron, :, :), size(humanDissim));
neuralDissimSA = reshape(distMetric.ISI.saDJS(ll, saNeuron, :, :), size(humanDissim));
[regLinePC, ~] = calculateLinearRegression(humanDissim(~isnan(neuralDissimPC)), neuralDissimPC(~isnan(neuralDissimPC)), 1);
[regLineSA, ~] = calculateLinearRegression(humanDissim(~isnan(neuralDissimSA)), neuralDissimSA(~isnan(neuralDissimSA)), 1);

figure('WindowStyle', 'docked')
scatter(humanDissim, neuralDissimPC, 10, rgb('DarkOrange'), 'filled')
hold on
scatter(humanDissim, neuralDissimSA, 10, rgb('Green'), 'filled')
% plot line of best fit
plot(humanDissim(~isnan(neuralDissimPC)), regLinePC, '-', 'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
plot(humanDissim(~isnan(neuralDissimSA)), regLineSA, '-', 'Color', rgb('Green'), 'LineWidth', 1.5)

xlabel('Human Dissimilarity'); ylabel('Neural Dissimilarity [D_{JS} (ISI)]')
title(sprintf('Snippet Length %i ms', isiParams.isiTimeWindow(ll)))

export_fig('./Figures/ISIDJS_SnippetLength100ms.png', '-dpng', '-transparent', '-r300');

% Spike Count
ll = 4;
neuralDissimPC = reshape(distMetric.SpikeCount.pcDJS(ll, pcNeuron, :, :), size(humanDissim));
neuralDissimSA = reshape(distMetric.SpikeCount.saDJS(ll, saNeuron, :, :), size(humanDissim));
[regLinePC, ~] = calculateLinearRegression(humanDissim(~isnan(neuralDissimPC)), neuralDissimPC(~isnan(neuralDissimPC)), 1);
[regLineSA, ~] = calculateLinearRegression(humanDissim(~isnan(neuralDissimSA)), neuralDissimSA(~isnan(neuralDissimSA)), 1);

figure('WindowStyle', 'docked')
scatter(humanDissim, neuralDissimPC, 10, rgb('DarkOrange'), 'filled')
hold on
scatter(humanDissim, neuralDissimSA, 10, rgb('Green'), 'filled')
% plot line of best fit
plot(humanDissim(~isnan(neuralDissimPC)), regLinePC, '-', 'Color', rgb('DarkOrange'), 'LineWidth', 1.5)
plot(humanDissim(~isnan(neuralDissimSA)), regLineSA, '-', 'Color', rgb('Green'), 'LineWidth', 1.5)

xlabel('Human Dissimilarity'); ylabel('Neural Dissimilarity [D_{JS} (Spike Count)]')
title(sprintf('Snippet Length %i ms', snippetLength(ll)))
export_fig('./Figures/SpikeCountDJS_SnippetLength100ms.png', '-dpng', '-transparent', '-r300');

%% DJS Plots ISI
isiOfInterest = [10, 20, 50, 100];
[~,isiIdx] = intersect(isiParams.isiTimeWindow, isiOfInterest, 'stable');
bwValues{1} = [distMetric.ISI.pcRsq(isiIdx, :)'; NaN(13, 4)];
bwValues{2} = distMetric.ISI.saRsq(isiIdx, :)';
figure('WindowStyle', 'docked');
boxplotGroup(bwValues, 'PrimaryLabels', {'PC', 'SA'}, ...
    'SecondaryLabels', {'10 ms', '20 ms', '50 ms', '100 ms'}, ...
    'Colors', [rgb('DarkOrange'); rgb('Green'); rgb('White')], ...
    'GroupLabelType', 'Vertical')
boxplotGroup(bwValues, 'PrimaryLabels', {'PC', 'SA'}, ...
    'SecondaryLabels', {'10 ms', '20 ms', '50 ms', '100 ms'}, ...
    'Colors', [rgb('DarkOrange'); rgb('Green'); rgb('White')], ...
    'GroupLabelType', 'Vertical', 'BoxStyle', 'filled')
box off
ylabel('R^2');
ylim([ -0.05 0.75])
set(gca, 'FontSize', 13)
title('ISI')
saveas(gcf, './Figures/CorrelationISI.png')
export_fig('./Figures/CorrelationISI.png', '-dpng', '-transparent', '-r300');

%% DJS Plots Spike Count
bwValues{1} = [distMetric.SpikeCount.pcRsq'; NaN(13, 4)];
bwValues{2} = distMetric.SpikeCount.saRsq';
figure('WindowStyle', 'docked');
boxplotGroup(bwValues, 'PrimaryLabels', {'PC', 'SA'}, ...
    'SecondaryLabels', {'10 ms', '20 ms', '50 ms', '100 ms'}, ...
    'Colors', [rgb('DarkOrange'); rgb('Green'); rgb('White')], ...
    'GroupLabelType', 'Vertical')
boxplotGroup(bwValues, 'PrimaryLabels', {'PC', 'SA'}, ...
    'SecondaryLabels', {'10 ms', '20 ms', '50 ms', '100 ms'}, ...
    'Colors', [rgb('DarkOrange'); rgb('Green'); rgb('White')], ...
    'GroupLabelType', 'Vertical', 'BoxStyle', 'filled')
box off
ylabel('R^2');
ylim([ -0.05 0.75])
set(gca, 'FontSize', 13)
title('Spike Count')
saveas(gcf, './Figures/CorrelationSpikeCount.png')
export_fig('./Figures/CorrelationSpikeCount.png', '-dpng', '-transparent', '-r300');

%% Human Dissim Matrix

figure('WindowStyle', 'docked')
tmp = triu(humanScores);
tmp(tmp == 0) = NaN;
h = imagesc(tmp);
textNames = cData.textureNames(textIdx);
set(gca, 'YTick', 1:length(textNames), 'YTickLabel', textNames, ...
    'XTick', 1:length(textNames), 'XTickLabel', textNames)
xtickangle(-45)
cbar = colorbar; axis square;
set(h, 'AlphaData', ~isnan(tmp))
caxis([0 2]); colormap(turbo);
cbar.Ticks = 0:.5:2;
cbar.FontSize = 15;
ylabel(cbar, 'Dissimilarity Rating', 'FontSize', 15)
set(gca, 'FontSize', 12)
export_fig('./Figures/HumanDissimHeatmap.png', '-dpng', '-transparent', '-r300');

%% Histogram Differences in Texture

nn = 8;
textureRef = 1;
textureComp = [2, 21, 27];
timeMax = 10;
binIdx = find(isiEdges == timeMax);
figure('WindowStyle', 'docked');
for tt = 1:length(textureComp)
    subplot(3, 1, tt)
    histogram('BinCounts', squeeze(isiHist(nn, textureRef, 1:binIdx)), 'BinEdges', isiEdges(1:binIdx + 1), ...
        'Normalization', 'probability', 'FaceColor', rgb('MediumVioletRed'), ...
        'FaceAlpha', 0.5, 'EdgeColor', rgb('MediumVioletRed'), 'LineWidth', 1.5)
    hold on
    histogram('BinCounts', squeeze(isiHist(nn, textureComp(tt), 1:binIdx)), 'BinEdges', isiEdges(1:binIdx + 1), ...
        'Normalization', 'probability', 'FaceColor', rgb('DodgerBlue'), ...
        'FaceAlpha', 0.5, 'EdgeColor', rgb('DodgerBlue'), 'LineWidth', 1.5)
    xlabel('ISI Distribution [ms]'); ylabel('Probability')
    box off
    set(gca, 'FontSize', 13, 'XTick', 0.5:timeMax + 0.5, ...
        'XTickLabel', {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11','12','13','14','15','16','17','18','19','20'}, ...
        'YLim', [0 .75], 'YTick', 0:.25:1)
    legend([cData.textureNames(textureRef), cData.textureNames(textureComp(tt))], 'Location', 'Northeast')
end
sgtitle('ISI', 'FontWeight', 'bold', 'FontSize', 15)
export_fig('./Figures/ISIDifferencesTexture.png', '-dpng', '-transparent', '-r300');


binIdx = find(snippetLength == timeMax);
figure('WindowStyle', 'docked');
for tt = 1:length(textureComp)
    subplot(3, 1, tt)
    histogram('BinCounts', squeeze(jointNeural.SpikeCount{binIdx}(nn, textureRef, :)), 'BinEdges', 0:timeMax + 1, ...
        'Normalization', 'probability', 'FaceColor', rgb('MediumVioletRed'), ...
        'FaceAlpha', 0.5, 'EdgeColor', rgb('MediumVioletRed'), 'LineWidth', 1.5)
    hold on
    histogram('BinCounts', squeeze(jointNeural.SpikeCount{binIdx}(nn, textureComp(tt), :)), 'BinEdges', 0:timeMax + 1, ...
        'Normalization', 'probability', 'FaceColor', rgb('DodgerBlue'), ...
        'FaceAlpha', 0.5, 'EdgeColor', rgb('DodgerBlue'), 'LineWidth', 1.5)
    xlabel('Spike Count per Snippet [ms]'); ylabel('Probability')
    box off
    set(gca, 'FontSize', 13, 'XTick', 0.5:timeMax + 0.5, ...
        'XTickLabel', {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11','12','13','14','15','16','17','18','19','20'}, ...
        'YLim', [0 .75], 'YTick', 0:.25:1)
    legend([cData.textureNames(textureRef), cData.textureNames(textureComp(tt))], 'Location', 'Northeast')
end
sgtitle('Spike Count', 'FontWeight', 'bold', 'FontSize', 15)
export_fig('./Figures/SpikeCountDifferencesTexture.png', '-dpng', '-transparent', '-r300');