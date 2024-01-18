roughnessValues = reshape(roughData.roughMean, [1, size(roughData.roughMean, 1) * size(roughData.roughMean, 2)]);

[p,x] = hist(roughnessValues); 
subplot(1,2,1)
plot(x, p/sum(p), 'k'); %PDF
xlabel('Roughness Rating'); ylabel('PDF');
box off
[f,x] = ecdf(roughnessValues); 
subplot(1,2,2)
plot(x, f, 'k'); %CDF
xlabel('Roughness Rating'); ylabel('CDF');
box off
sgtitle('Roughness Scores')
saveas(gcf, './Figures/RoughnessRatingsPDF-CDF.png')

maxEntropy = .5 * log2(2*pi*exp(var(roughnessValues))) + .5;
numBins = 2^maxEntropy;


sidx = 1;
for ss = 1:2
    for ll = 1:3
        subplot(2,3,sidx)
        scatter(miNeural.SpikeCount(ss, ll, :), miNeural.Words(ss, ll, :), ...
            15, 'k', 'filled')
        rf = refline(1,0); rf.Color = rgb('DarkGrey'); rf.LineStyle = '--';
        xlabel('Spike Count'); ylabel('Words');
        title(sprintf('Spike Train Res: %ims \nSnippet Length: %ims', spikeTrainRes(ss), snippetLength(ss,ll)))
        sidx = sidx + 1;
    end
end
sgtitle('Info Based on Roughness')
saveas(gcf, './Figures/TextureInfo.png')

figure;
sidx = 1;
for ss = 1:2
    for ll = 1:3
        subplot(2,3,sidx)
        scatter(miNeural.SpikeCount(ss, ll, :) ./ entNeural.SpikeCount(ss, ll, :), miRoughness.RoughSpikeCount(ss, ll, :) ./ entRoughness.RoughSpikeCount(ss, ll, :), ...
            15, 'k', 'filled')
        rf = refline(1,0); rf.Color = rgb('DarkGrey'); rf.LineStyle = '--';
        xlabel('Info Based on Texture Label [bits/bit]'); ylabel('Info Based on Roughness Score [bits/bit]');
        title(sprintf('Spike Train Res: %ims \nSnippet Length: %ims', spikeTrainRes(ss), snippetLength(ss,ll)))
        sidx = sidx + 1;
    end
end
sgtitle('Texture vs Roughness Info: Spike Count [bits/bit]')
saveas(gcf, './Figures/Roughness_v_Texture_Info_SpikeCount_Bits.png')


%% Info grouped by neuron type and split into texture and roughness
figure;
sidx = 1;
for ss = 1:2
    for ll = 1:3
        
        pcSpikeCountMean = mean(miNeural.SpikeCount(ss, ll, pcIdx));
        pcSpikeCountStd = std(miNeural.SpikeCount(ss, ll, pcIdx)) / sum(pcIdx);
        pcSpikeCountRoughnessMean = mean(miRoughness.RoughSpikeCount(ss, ll, pcIdx));
        pcSpikeCountRoughnessStd = std(miRoughness.RoughSpikeCount(ss, ll, pcIdx)) / sum(pcIdx);
        
        saSpikeCountMean = mean(miNeural.SpikeCount(ss, ll, saIdx));
        saSpikeCountStd = std(miNeural.SpikeCount(ss, ll, saIdx)) / sum(saIdx);
        saSpikeCountRoughnessMean = mean(miRoughness.RoughSpikeCount(ss, ll, saIdx));
        saSpikeCountRoughnessStd = std(miRoughness.RoughSpikeCount(ss, ll, saIdx)) / sum(saIdx);
        
        pcWordsMean = mean(miNeural.Words(ss, ll, pcIdx));
        pcWordsStd = std(miNeural.Words(ss, ll, pcIdx)) / sum(pcIdx);
        pcWordsRoughnessMean = mean(miRoughness.RoughWords(ss, ll, pcIdx));
        pcWordsRoughnessStd = std(miRoughness.RoughWords(ss, ll, pcIdx)) / sum(pcIdx);
        
        saWordsMean = mean(miNeural.Words(ss, ll, saIdx));
        saWordsStd = std(miNeural.Words(ss, ll, saIdx)) / sum(saIdx);
        saWordsRoughnessMean = mean(miRoughness.RoughWords(ss, ll, saIdx));
        saWordsRoughnessStd = std(miRoughness.RoughWords(ss, ll, saIdx)) / sum(saIdx);
        
        subplot(2,3,sidx)
        errorbar([pcSpikeCountMean, pcWordsMean], [pcSpikeCountStd, pcWordsStd], ...
            '-o', 'MarkerSize', 10, 'MarkerEdgeColor', rgb('Orange'), 'MarkerFaceColor', 'w', ...
            'Color', rgb('Orange'), 'LineWidth', 1.5)
        hold on
        errorbar([saSpikeCountMean, saWordsMean], [saSpikeCountStd, saWordsStd], ...
            '-o', 'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', 'w', ...
            'Color', rgb('Green'), 'LineWidth', 1.5)
        
        errorbar([pcSpikeCountRoughnessMean, pcWordsRoughnessMean], [pcSpikeCountRoughnessStd, pcWordsRoughnessStd], ...
            '-o', 'MarkerSize', 10, 'MarkerEdgeColor', rgb('Orange'), 'MarkerFaceColor', rgb('Khaki'), ...
            'Color', rgb('Orange'), 'LineWidth', 1.5)
        errorbar([saSpikeCountRoughnessMean, saWordsRoughnessMean], [saSpikeCountRoughnessStd, saWordsRoughnessStd], ...
            '-o', 'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('LightGreen'), ...
            'Color', rgb('Green'), 'LineWidth', 1.5)
        set(gca, 'XTick', [1,2], 'XTickLabel', {'Spike Count', 'Words'}, 'XLim', [0.5 2.5])
        ylabel('Info [bits')
        title(sprintf('Spike Train Res: %ims \nSnippet Length: %ims', spikeTrainRes(ss), snippetLength(ss,ll)))
        box off
        sidx = sidx + 1;
        
    end
end
        legend({'PC Texture', 'SA Texture', 'PC Roughness', 'SA Roughness'}, 'Location', 'Best')

%         plot([pcSpikeCountMean, pcWordsMean], [pcSpikeCountRoughnessMean, pcWordsRoughnessMean], 'Color', rgb('Orange'), 'LineWidth', 1.5)
%         hold on
%         errorbar(pcSpikeCountMean, pcSpikeCountRoughnessMean, pcSpikeCountStd, 'horizontal', ...
%             'o', 'MarkerSize', 10, 'MarkerEdgeColor', rgb('Orange'), 'MarkerFaceColor', 'w', ...
%             'Color', rgb('Orange'), 'LineWidth', 1.5)
%         errorbar(pcSpikeCountMean, pcSpikeCountRoughnessMean, pcSpikeCountRoughnessStd, ...
%             'o', 'MarkerSize', 10, 'MarkerEdgeColor', rgb('Orange'), 'MarkerFaceColor', 'w', ...
%             'Color', rgb('Orange'), 'LineWidth', 1.5)
%         errorbar(pcWordsMean, pcWordsRoughnessMean, pcWordsStd, 'horizontal', ...
%             'o', 'MarkerSize', 10, 'MarkerEdgeColor', rgb('Orange'), 'MarkerFaceColor',  rgb('Orange'), ...
%             'Color', rgb('Orange'), 'LineWidth', 1.5)
%         errorbar(pcWordsMean, pcWordsRoughnessMean, pcWordsRoughnessStd, ...
%             'o', 'MarkerSize', 10, 'MarkerEdgeColor', rgb('Orange'), 'MarkerFaceColor',  rgb('Orange'), ...
%             'Color', rgb('Orange'), 'LineWidth', 1.5)
%
%         plot([saSpikeCountMean, saWordsMean], [saSpikeCountRoughnessMean, saWordsRoughnessMean], 'Color', rgb('Green'), 'LineWidth', 1.5)
%         errorbar(saSpikeCountMean, saSpikeCountRoughnessMean, saSpikeCountStd, 'horizontal', ...
%             'o', 'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', 'w', ...
%             'Color', rgb('Green'), 'LineWidth', 1.5)
%         errorbar(saSpikeCountMean, saSpikeCountRoughnessMean, saSpikeCountRoughnessStd, ...
%             'o', 'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', 'w', ...
%             'Color', rgb('Green'), 'LineWidth', 1.5)
%         errorbar(saWordsMean, saWordsRoughnessMean, saWordsStd, 'horizontal', ...
%             'o', 'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor',  rgb('Green'), ...
%             'Color', rgb('Green'), 'LineWidth', 1.5)
%         errorbar(saWordsMean, saWordsRoughnessMean, saWordsRoughnessStd, ...
%             'o', 'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor',  rgb('Green'), ...
%             'Color', rgb('Green'), 'LineWidth', 1.5)
%         xlabel('Texture Info'); ylabel('Roughness Info');
%         title(sprintf('Spike Train Res: %ims \nSnippet Length: %ims', spikeTrainRes(ss), snippetLength(ss,ll)))
%
%         rf = refline(1,0); rf.Color = rgb('DarkGrey'); rf.LineStyle = '--'; rf.LineWidth = 1.5;
