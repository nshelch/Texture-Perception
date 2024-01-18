load('./Data/dissimData.mat')
numBins = 60;
plotFigure = 0;
binnedDissim = binDissimData(dissimData, numBins, plotFigure); % Bin the dissimilarity scores into 60 bins
pDissim = binnedDissim.dissimMatrixProb;
textIdx = dissimData.textInd;
tau = 1000; % Keep MI to bits/bin

for bb = 2:length(binarizingWindow)
    clc; fprintf('Binarizing Window %i, Snippet Length %i/%i\n', bb, ss, length(binLengths));
    for ss = 1:2
        fprintf('Binarizing Window %i, Spike Count Snippet %i\n', bb, ss);
        spikeJointCount = jointSpikes{bb, ss};
        miJointSpikes(bb, ss, :) = calculateJointMI(spikeJointCount(:, textIdx,:), pDissim, tau);
        fprintf('Binarizing Window %i, First Spike Snippet %i\n', bb, ss);
        firstSpikeJointCount = jointFirstSpike{bb,ss};
        miJointFirstSpike(bb, ss, :) = calculateJointMI(firstSpikeJointCount(:, textIdx,:), pDissim, tau);
    end
    
    % Get the number of snippets was possible given the neural statistic
    isiLoopLength = sum(~(cellfun(@isempty, jointIsi(bb,:))));
    for ss = 1:2
        fprintf('Binarizing Window %i, ISI Snippet %i\n', bb, ss);
        isiJointCount = jointIsi{bb, ss};
        miJointIsi(bb, ss, :) = calculateJointMI(isiJointCount(:, textIdx,:), pDissim, tau);
    end
    
    wordsLoopLength = sum(~(cellfun(@isempty, jointWords(bb,:))));
    for ss = 1:2
        fprintf('Binarizing Window %i, Word Snippet %i\n', bb, ss);
        wordsJointCount = jointWords{bb, ss};
        miJointWords(bb, ss, :) = calculateJointMI(wordsJointCount(:, textIdx,:), pDissim, tau);
    end
    
end

figure('Position', [2000 -70 1000 950])
for bb = 1:length(binarizingWindow)
    miMeansPC = [mean(squeeze(miJointSpikes(bb, 1:2, neuronIds.pc)), 2), ...
        mean(squeeze(miJointFirstSpike(bb, 1:2, neuronIds.pc)), 2), ...
        nanmean(squeeze(miJointWords(bb, 1:2, neuronIds.pc)), 2)];
    
    miStdPC = [std(squeeze(miJointSpikes(bb, 1:2, neuronIds.pc))'); ...
        std(squeeze(miJointFirstSpike(bb, 1:2, neuronIds.pc))'); ...
        nanstd(squeeze(miJointWords(bb, 1:2, neuronIds.pc))')]' ./ sqrt(length(neuronIds.pc));
    
    miMeansSA = [mean(squeeze(miJointSpikes(bb, 1:2, neuronIds.sa)), 2), ...
        mean(squeeze(miJointFirstSpike(bb, 1:2, neuronIds.sa)), 2), ...
        nanmean(squeeze(miJointWords(bb, 1:2, neuronIds.sa)), 2)];
    
    miStdSA = [std(squeeze(miJointSpikes(bb, 1:2, neuronIds.sa))'); ...
        std(squeeze(miJointFirstSpike(bb, 1:2, neuronIds.sa))'); ...
        nanstd(squeeze(miJointWords(bb, 1:2, neuronIds.sa))')]' ./ sqrt(length(neuronIds.sa));
    
    maxYLimInfo = ceil(max(max([miMeansPC + miStdPC, miMeansSA + miStdSA])));
    
    for ss = 1:2
        subplot(4,2,(bb + (bb - 1)) + (ss - 1))
        if (bb == 1 && ss == 2)
        errorbar(1:2, miMeansPC(ss,1:2), miStdPC(ss,1:2), 's-', ...
            'Color', rgb('Orange'), 'MarkerFaceColor', rgb('Orange'), ...
            'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
        hold on
        errorbar(1:2, miMeansSA(ss,1:2), miStdSA(ss,1:2), 's-', ...
            'Color', rgb('ForestGreen'), 'MarkerFaceColor', rgb('ForestGreen'), ...
            'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
        else
            errorbar(1:3, miMeansPC(ss,:), miStdPC(ss,:), 's-', ...
            'Color', rgb('Orange'), 'MarkerFaceColor', rgb('Orange'), ...
            'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
        hold on
        errorbar(1:3, miMeansSA(ss,:), miStdSA(ss,:), 's-', ...
            'Color', rgb('ForestGreen'), 'MarkerFaceColor', rgb('ForestGreen'), ...
            'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
        end
        box off; set(gca, 'XTick', 1:4, 'XTickLabel', {'Spike Count', 'First Spike', 'Word'})
        xlim([0.5 3.5]); ylim([0 .12]);
        set(gca, 'YTick', 0:0.06:.12)
        ylabel('Info [bits]'); title(sprintf('Spike Train %ims', binarizingWindow(bb)))
    end
    
end
th1 = text(1.6, .273, 'Snippet Length 10ms', 'FontWeight', 'Bold', 'FontSize', 12);
th2 = text(6.8, .273, 'Snippet Length 20ms', 'FontWeight', 'Bold', 'FontSize', 12);
saveas(gcf, './Figures/JointMIByNeuronType.png')
