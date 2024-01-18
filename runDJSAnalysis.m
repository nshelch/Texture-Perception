load('./Data/dissimData.mat')
load('./Data/neuronIds.mat')
humanScores = dissimData.mat;
textIdx = dissimData.textInd;

for bb = 2:4
    %     ssLength = sum(miWords(bb, :, 1) ~= 0);
    for ss = 3
        tmp = jointSpikes{bb, ss};
        [pcDJS, pcRsq] = djsAnalysis(tmp(neuronIds.pc, textIdx, :), humanScores, 0);
        [saDJS, saRsq] = djsAnalysis(tmp(neuronIds.sa, textIdx, :), humanScores, 0);
        djsSpikesPC(bb, ss, :, :, :) = pcDJS;
        djsSpikesSA(bb, ss, :, :, :) = saDJS;
%         rsqSpikesPC(bb, ss, :) = pcRsq;
%         rsqSpikesSA(bb, ss, :) = saRsq;
        
        tmp = jointFirstSpike{bb, ss};
        [pcDJS, pcRsq] = djsAnalysis(tmp(neuronIds.pc, textIdx, :), humanScores, 0);
        [saDJS, saRsq] = djsAnalysis(tmp(neuronIds.sa, textIdx, :), humanScores, 0);
        djsFirstSpikePC(bb, ss, :, :, :) = pcDJS;
        djsFirstSpikeSA(bb, ss, :, :, :) = saDJS;
%         rsqFirstSpikePC(bb, ss, :) = pcRsq;
%         rsqFirstSpikeSA(bb, ss, :) = saRsq;
           
        tmp = jointIsi{bb, ss};
        [pcDJS, pcRsq] = djsAnalysis(tmp(neuronIds.pc, textIdx, :), humanScores, 0);
        [saDJS, saRsq] = djsAnalysis(tmp(neuronIds.sa, textIdx, :), humanScores, 0);
        djsIsiPC(bb, ss, :, :, :) = pcDJS;
        djsIsiSA(bb, ss, :, :, :) = saDJS;
%         rsqIsiPC(bb, ss, :) = pcRsq;
%         rsqIsiSA(bb, ss, :) = saRsq; 
        
        tmp = jointWords{bb, ss};
        [pcDJS, pcRsq] = djsAnalysis(tmp(neuronIds.pc, textIdx, :), humanScores, 0);
        [saDJS, saRsq] = djsAnalysis(tmp(neuronIds.sa, textIdx, :), humanScores, 0);
        djsWordsPC(bb, ss, :, :, :) = pcDJS;
        djsWordsSA(bb, ss, :, :, :) = saDJS;
%         rsqWordsPC(bb, ss, :) = pcRsq;
%         rsqWordsSA(bb, ss, :) = saRsq;
        
    end
end

%% RSQ as a function of spike time res and snippet length
meanRsqSpikesPC = mean(squeeze(rsqSpikesPC(:, :, :)), 3);
meanRsqFirstSpikePC = mean(squeeze(rsqFirstSpikePC(:, :, :)), 3);
meanRsqIsiPC = mean(squeeze(rsqIsiPC(:, :, :)), 3);
meanRsqWordsPC = mean(squeeze(rsqWordsPC(:, :, :)), 3);

meanRsqSpikesSA = mean(squeeze(rsqSpikesSA(:, :, :)), 3);
meanRsqFirstSpikeSA = mean(squeeze(rsqFirstSpikeSA(:, :, :)), 3);
meanRsqIsiSA = mean(squeeze(rsqIsiSA(:, :, :)), 3);
meanRsqWordsSA = mean(squeeze(rsqWordsSA(:, :, :)), 3);

colorVecPC = [rgb('Gold'); rgb('Orange'); rgb('Chocolate'); rgb('Brown')];
colorVecSA = [rgb('LightGreen'); rgb('ForestGreen'); rgb('Green'); rgb('DarkGreen')];
figure('WindowStyle', 'docked')
subplot(2,2,1)
for bb = 1:length(binarizingWindow)
    plot(snippetTimes, meanRsqSpikesPC(bb,:), 's-', ...
        'Color',  colorVecPC(bb,:), 'MarkerFaceColor', colorVecPC(bb,:), ...
        'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
    hold on
    plot(snippetTimes, meanRsqSpikesSA(bb,:), 's-', ...
        'Color',  colorVecSA(bb,:), 'MarkerFaceColor', colorVecSA(bb,:), ...
        'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
    box off
    xlabel('Snippet Length [ms]'); ylabel('R^2'); title('Spike Count')
end
ylim([0 0.5]);

subplot(2,2,2)
for bb = 1:length(binarizingWindow)
    plot(snippetTimes, meanRsqFirstSpikePC(bb,:), 's-', ...
        'Color',  colorVecPC(bb,:), 'MarkerFaceColor', colorVecPC(bb,:), ...
        'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
    hold on
    plot(snippetTimes, meanRsqFirstSpikeSA(bb,:), 's-', ...
        'Color',  colorVecSA(bb,:), 'MarkerFaceColor', colorVecSA(bb,:), ...
        'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
    box off
    xlabel('Snippet Length [ms]'); ylabel('R^2'); title('First Spike')
end

meanRsqIsiPC(meanRsqIsiPC == 0) = NaN;
meanRsqIsiSA(meanRsqIsiSA == 0) = NaN;
subplot(2,2,3)
for bb = 1:length(binarizingWindow)
    plot(snippetTimes, meanRsqIsiPC(bb,:), 's-', ...
        'Color',  colorVecPC(bb,:), 'MarkerFaceColor', colorVecPC(bb,:), ...
        'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
    hold on
    plot(snippetTimes, meanRsqIsiSA(bb,:), 's-', ...
        'Color',  colorVecSA(bb,:), 'MarkerFaceColor', colorVecSA(bb,:), ...
        'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
    box off
    xlabel('Snippet Length [ms]'); ylabel('R^2'); title('ISI')
end

meanRsqWordsPC(meanRsqIsiPC == 0) = NaN;
meanRsqWordsSA(meanRsqIsiSA == 0) = NaN;
subplot(2,2,4)
for bb = 1:length(binarizingWindow)
    plot(snippetTimes, meanRsqWordsPC(bb,:), 's-', ...
        'Color',  colorVecPC(bb,:), 'MarkerFaceColor', colorVecPC(bb,:), ...
        'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
    hold on
    box off
    xlabel('Snippet Length [ms]'); ylabel('R^2'); title('Spike Count')
end
for bb = 1:length(binarizingWindow)
    plot(snippetTimes, meanRsqWordsSA(bb,:), 's-', ...
        'Color',  colorVecSA(bb,:), 'MarkerFaceColor', colorVecSA(bb,:), ...
        'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
    hold on
    box off
    xlabel('Snippet Length [ms]'); ylabel('R^2'); title('Words')
end
xlim([0 100]); ylim([0 0.5]);
legend({'PC 1ms', 'PC 2ms', 'PC 5ms', 'PC 10ms', 'SA 1ms', 'SA 2ms', 'SA 5ms', 'SA 10ms'}, ...
    'NumColumns', 2, 'Location', 'NorthEast')
saveas(gcf, './Figures/DJSRSQByNeuronType.png')

%% RSQ as a function of neuron type

figure('Position', [2000 -70 1000 950])
for bb = 1:length(binarizingWindow)
    
    meanRsqPC = [mean(squeeze(rsqSpikesPC(bb, :, :)), 2), ...
        mean(squeeze(rsqFirstSpikePC(bb, :, :)), 2), ...
        nanmean(squeeze(rsqIsiPC(bb, :, :)), 2), ...
        nanmean(squeeze(rsqWordsPC(bb, :, :)), 2)];
    
    semRsqPC = [std(squeeze(rsqSpikesPC(bb, :, :))'); ...
        std(squeeze(rsqFirstSpikePC(bb, :, :))'); ...
        nanstd(squeeze(rsqIsiPC(bb, :, :))'); ...
        nanstd(squeeze(rsqWordsPC(bb, :, :))')]' ./ sqrt(length(neuronIds.pc));
    
    meanRsqSA = [mean(squeeze(rsqSpikesSA(bb, :, :)), 2), ...
        mean(squeeze(rsqFirstSpikeSA(bb, :, :)), 2), ...
        nanmean(squeeze(rsqIsiSA(bb, :, :)), 2), ...
        nanmean(squeeze(rsqWordsSA(bb, :, :)), 2)];
    
    semRsqSA = [std(squeeze(rsqSpikesSA(bb, :, :))'); ...
        std(squeeze(rsqFirstSpikeSA(bb, :, :))'); ...
        nanstd(squeeze(rsqIsiSA(bb, :, :))'); ...
        nanstd(squeeze(rsqWordsSA(bb, :, :))')]' ./ sqrt(length(neuronIds.sa));
    
    maxYLimInfo = 0.5; %ceil(max(max([miMeansPC + miStdPC, miMeansSA + miStdSA])));
    
    for ss = 1:2
        subplot(4,2,(bb + (bb - 1)) + (ss - 1))
        errorbar(1:4, meanRsqPC(ss,:), semRsqPC(ss,:), 's-', ...
            'Color', rgb('Orange'), 'MarkerFaceColor', rgb('Orange'), ...
            'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
        hold on
        errorbar(1:4, meanRsqSA(ss,:), semRsqSA(ss,:), 's-', ...
            'Color', rgb('ForestGreen'), 'MarkerFaceColor', rgb('ForestGreen'), ...
            'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
        box off; set(gca, 'XTick', 1:4, 'XTickLabel', {'Spike Count', 'First Spike', 'ISI', 'Word'})
        xlim([0.5 4.5]); ylim([0 maxYLimInfo]);
        ylabel('R^2'); title(sprintf('Spike Train Resolution %ims', binarizingWindow(bb)))
    end
    
end
th1 = text(-3.7, 2.73, 'Snippet Length 10ms', 'FontWeight', 'Bold', 'FontSize', 12);
th2 = text(1.6, 2.73, 'Snippet Length 20ms', 'FontWeight', 'Bold', 'FontSize', 12);