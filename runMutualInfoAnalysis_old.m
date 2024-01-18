saveDataFilename = './Data/mutualInfo_ST1SL5_Variations.mat';

% Params for MI Calculations
startTime = 100; % ms
poiDur = 1800; % Duration of period of interest (poi) in ms
spikeTrainRes = 1; %[1, 2]; % ms
snippetLength = 10; %[5, 8, 10; 8, 10, 20]; % ms
maxBins = 20; % Number of bins to not exceed for word and ISI calculations, based on MATLAB memory limits and my patience
convFactor = 1000; % Conversion factor from bits/bin to bits/sec in MI calculations (1000 keeps the info in units of bits/bin)
miParams.spikeTrainRes = spikeTrainRes;
miParams.snippetLength = snippetLength;

% Toggle different analysis
miAnalysis = 1;
fsAnalysis = 0;
roughnessAnalysis = 0;
plotFigures = 0; % Toggle figure plots
saveJointProb = 0; % Toggle joint count saving

% FS Analysis
if fsAnalysis
    fracErrorThresh = 0.1;
    propDataSampled = [0.5 .75 .8 .9 .95 1];
    numRepsFS = 25;
    miParams.fracErrorThresh = fracErrorThresh;
end

% Load data or make data structure
if exist('./Data/cData.mat', 'file')
    load('./Data/cData.mat')
else
    load('./Data/cdaData.mat')
    cData = formatData(cdaData.fullRun.data);
end

% Load Roughness info
if roughnessAnalysis
    load('./Data/roughnessData.mat')
    miParams.roughEdges = linspace(min(roughData.roughMean), max(roughData.roughMean), 50);
    textureLabels = roughnessLabels(miParams.roughEdges, roughData.roughMean);
    miParams.textureLabels = textureLabels;
end

% Calculating entropy and mutual information
for ss = 1:length(spikeTrainRes)
    for ll = 1:size(snippetLength, 2)
        clc; fprintf('Spike Train Res: %i/%i, Snippet Length %i/%i\n', ss, length(spikeTrainRes), ll, length(snippetLength));
        
        if miAnalysis
            
            numBins = snippetLength(ss, ll) / spikeTrainRes(ss); % Number of bins needed based on the resolution of the spike train
            
            % Bins the data based on the spike train res. and outputs a 3D
            % binarized spike train matrix (neurons x textures x spike train)
            spikeTrain = binSpikeData(cData, spikeTrainRes(ss), startTime, poiDur);
            
            % Mutual Info: Spike Count
            [spikeCount] = getSpikeCounts(spikeTrain, numBins);
            tmpSpikes = calculateMutualInformation(spikeCount, 0:numBins, convFactor);
            miNeural.SpikeCount(ss, ll, :) = tmpSpikes.mutualInfo;
            entNeural.SpikeCount(ss, ll, :) = tmpSpikes.entropy;
            
            % Finite Size Analysis: Spike Count
            if fsAnalysis
                fs.SpikeCount(ss, ll) = finiteSizeAnalysis(spikeCount, numBins, numRepsFS, propDataSampled);
                if fs.SpikeCount(ss, ll).fracError > fracErrorThresh
                    warning('Fractional error for spike count exceeds threshold: %.2f', fs.SpikeCount(ss, ll).fracError);
                end
            end
            
            % Roughness Info: Spike Count 
            if roughnessAnalysis
                roughSpikeCount = groupDataByRoughness(spikeCount, textureLabels);
                tmpRoughSpikes = calculateMutualInformation(roughSpikeCount, NaN, convFactor);
                miNeural.RoughSpikeCount(ss, ll, :) = tmpRoughSpikes.mutualInfo;
                entNeural.RoughSpikeCount(ss, ll, :) = tmpRoughSpikes.entropy;
            end
            
            if numBins < maxBins
                
                % Mutual Info: Words
                [wordCount] = getWords(spikeTrain, numBins);
                maxWord = (2^numBins) - 1;
                tmpWords = calculateMutualInformation(wordCount, 0:maxWord, convFactor);
                miNeural.Words(ss, ll, :) = tmpWords.mutualInfo;
                entNeural.Words(ss, ll, :) = tmpWords.entropy;
                
                % Finite Size Analysis: Words
                if fsAnalysis
                    fs.Words(ss, ll) = finiteSizeAnalysis(wordCount, maxWord, numRepsFS, propDataSampled);
                    if fs.Words(ss, ll).fracError > fracErrorThresh
                        warning('Fractional error for words exceeds threshold: %.2f', fs.Words(ss, ll).fracError);
                    end
                end
                
                % Roughness Info: Words
                if roughnessAnalysis
                    roughWordCount = groupDataByRoughness(wordCount, textureLabels);
                    tmpRoughWords = calculateMutualInformation(roughWordCount, NaN, convFactor);
                    miNeural.RoughWords(ss, ll, :) = tmpRoughWords.mutualInfo;
                    entNeural.RoughWords(ss, ll, :) = tmpRoughWords.entropy;
                end
            end
            
            if saveJointProb
                jointProb.SpikeCount{ss, ll} = tmpSpikes.probOfXGivenTexture;
                try
                    jointProb.Words{ss, ll} = tmpWords.probOfXGivenTexture;
                catch
                    fprint('Too many bins, word info was not calculated');
                end
            end
            
        end
    end
end

% Setting the instances in which entropy and mutual info couldn't be
% calculated to NaNs so it's not misleading
miNeural.Words(miNeural.Words == 0) = NaN; entNeural.Words(entNeural.Words == 0) = NaN;

% Get the neuron types
neuronType = {cData.neuron(:).type};
pcIdx = strcmp(neuronType, 'PC'); saIdx = strcmp(neuronType, 'SA');

% Saving stuff
if saveJointProb
    save('./Data/jointProb.mat', 'jointProb', '-v7.3') % v7.3 allows matlab to save files bigger than 2GB
end
save(saveDataFilename, 'miNeural', 'entNeural', 'miParams', 'neuronType', 'pcIdx', 'saIdx')

if plotFigures
    % Check for the existence of a Figures folder
    if ~exist('./Figures/', 'dir')
        mkdir('./Figures/')
    end
    
    %% Fractional Error as a Function of Spike Train Resolution and Snippet Length
    fsVar = fieldnames(fs);
    colorVec = parula(5); %[rgb('LightSeaGreen'); rgb('DarkSlateGray')];
    fracError.SpikeCount = reshape([fs.SpikeCount.fracError], [length(spikeTrainRes), length(snippetLength)]);
    fracError.Words = reshape([fs.Words.fracError], [length(spikeTrainRes), length(snippetLength)]);
    
    figure('WindowStyle', 'docked')
    for ss = 1:length(spikeTrainRes)
        for vv = 1:length(fsVar) % Loop through spike count, words, etc.
            subplot(1,2,vv)
            plot(snippetLength(ss,:), fracError.(fsVar{vv})(ss, :), 's-', ...
                'Color',  colorVec(ss,:), 'MarkerFaceColor', colorVec(ss,:), ...
                'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
            hold on
            box off; axis([0 max(snippetLength(:)) + 5 0 .5]);
            xlabel('Snippet Length [ms]'); ylabel('Fractional Error'); title(fsVar{vv})
        end
    end
    subplot(1,2,1)
    plot([0, max(snippetLength(:)) + 5], [fracErrorThresh, fracErrorThresh], ...
        'k--', 'LineWidth', 1.5)
    subplot(1,2,2)
    plot([0, max(snippetLength(:)) + 5], [fracErrorThresh, fracErrorThresh], ...
        'k--', 'LineWidth', 1.5)
    
    legend({'1ms', '2ms', 'Threshold'}, 'Location', 'SouthEast')
    saveas(gcf, './Figures/FracErrorVsSnippetLength.png')
    
    %% Entropy as a Function of Spike Train Resolution and Snippet Length
    entVar = fieldnames(entNeural);
    colorVec = parula(5); %[rgb('LightSeaGreen'); rgb('DarkSlateGray')];
    figure('WindowStyle', 'docked')
    for ss = 1:length(spikeTrainRes)
        for vv = 1:length(entVar) % Loop through spike count, words, etc.
            subplot(1,5,vv)
            meanEntropy = mean(squeeze(entNeural.(entVar{vv})(ss,:,:)), 2);
            plot(snippetLength(ss,:), meanEntropy, 's-', ...
                'Color',  colorVec(ss,:), 'MarkerFaceColor', colorVec(ss,:), ...
                'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
            hold on
            box off; axis([0 max(snippetLength(:)) + 5 0 5]);
            xlabel('Snippet Length [ms]'); ylabel('Entropy [bits]'); title(entVar{vv})
        end
    end
    
    legend({'1ms', '2ms'}, 'Location', 'SouthEast')
    saveas(gcf, './Figures/EntropyVsSnippetLength.png')
    
    %% MI as a function of spike train res and snippet length
    miVar = fieldnames(miNeural);
    colorVec = [rgb('LightSeaGreen'); rgb('DarkSlateGray')];
    figure('WindowStyle', 'docked')
    for ss = 1:length(spikeTrainRes)
        for vv = 1:length(miVar)
            subplot(1, 2, vv)
            meanInfo = mean(squeeze(miNeural.(miVar{vv})(ss,:,:)), 2);
            plot(snippetLength(ss, :), meanInfo, 's-', ...
                'Color',  colorVec(ss,:), 'MarkerFaceColor', colorVec(ss,:), ...
                'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
            hold on
            box off; axis([0 max(snippetLength(:)) + 5 0 .5]);
            xlabel('Snippet Length [ms]'); ylabel('Info [bits]'); title(miVar{vv})
        end
    end
    legend({'1ms', '2ms'}, 'Location', 'SouthEast')
    
    saveas(gcf, './Figures/InfoVsSnippetLength.png')
    
    %% Efficiency of Information
    % Efficiency of information is basically a way of seeing if the info is
    % increasing because the entropy is increasing, or are the neurons
    % actually encoding more information. This is like a super lamen's
    % explanation and definitely missing some subtleties, but its the
    % general gist of it
    
    miVar = fieldnames(miNeural);
    colorVec = [rgb('LightSeaGreen'); rgb('DarkSlateGray')];
    figure('WindowStyle', 'docked')
    for ss = 1:length(spikeTrainRes)
        for vv = 1:length(miVar)
            subplot(1,2,vv)
            meanInfo = mean(squeeze(miNeural.(miVar{vv})(ss,:,:)), 2);
            meanEntropy = mean(squeeze(entNeural.(miVar{vv})(ss,:,:)), 2);
            eff = mean(meanInfo ./  meanEntropy, 2);
            plot(snippetLength(ss,:), eff, 's-', ...
                'Color',  colorVec(ss,:), 'MarkerFaceColor', colorVec(ss,:), ...
                'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
            hold on
            box off; axis([0 max(snippetLength(:)) + 5 0 0.1])
            xlabel('Snippet Length [ms]'); ylabel('Info [bits/bit]'); title(miVar{vv})
        end
    end
    sgtitle('Efficiency of Information')
    legend({'1ms', '2ms'}, 'Location', 'SouthEast')
    
    saveas(gcf, './Figures/InfoEfficiencyVsSnippetLength.png')
    
    %% Entropy as a Function of Neuron Type and Snippet Length
    
    entVar = fieldnames(entNeural);
    neuronIds = {'PC', 'SA'};
    neuronColors = [rgb('Orange'); rgb('Green')];
    for ss = 1:length(spikeTrainRes)
        figure('WindowStyle', 'docked')
        sgtitle(sprintf('Spike Train Resolution %i ms', spikeTrainRes(ss)))
        for vv = 1:length(entVar)
            subplot(1,2,vv)
            for nn = 1:length(neuronIds)
                neuronIdx = strcmp(neuronType, neuronIds{nn});
                meanNeuronEntropy = mean(squeeze(entNeural.(entVar{vv})(ss,:,neuronIdx)), 2);
                plot(snippetLength(ss,:), meanNeuronEntropy, 's-', ...
                    'Color',  neuronColors(nn,:), 'MarkerFaceColor', neuronColors(nn,:), ...
                    'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
                hold on
            end
            box off;
            xlabel('Snippet Length [ms]'); ylabel('Entropy [bits]'); title(entVar{vv})
            set(gca, 'XLim', [0 max(snippetLength(ss, :)) + 5], 'YLim', [0 7], 'YTick', 0:1:7)
        end
        
        legend(neuronIds, 'Location', 'SouthEast')
        saveas(gcf, sprintf('./Figures/EntropyVsSnippetLengthByNeuronType_SpikeTrainRes%ims.png', spikeTrainRes(ss)))
    end
    
    %% Mutual Info as a Function of Neuron Type and Snippet Length
    
    miVar = fieldnames(mi);
    neuronIds = {'PC', 'SA'};
    neuronColors = [rgb('Orange'); rgb('Green')];
    for ss = 1:length(spikeTrainRes)
        figure('WindowStyle', 'docked')
        sgtitle(sprintf('Spike Train Resolution %i ms', spikeTrainRes(ss)))
        for vv = 1:length(miVar)
            subplot(1,2,vv)
            for nn = 1:length(neuronIds)
                neuronIdx = strcmp(neuronType, neuronIds{nn});
                meanNeuronInfo = mean(squeeze(miNeural.(miVar{vv})(ss,:,neuronIdx)), 2);
                plot(snippetLength(ss, :), meanNeuronInfo, 's-', ...
                    'Color',  neuronColors(nn,:), 'MarkerFaceColor', neuronColors(nn,:), ...
                    'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
                hold on
            end
            box off;
            xlabel('Snippet Length [ms]'); ylabel('Info [bits]'); title(miVar{vv})
            set(gca, 'XLim', [0 max(snippetLength(ss, :)) + 5], 'YLim', [0 1])
        end
        
        legend(neuronIds, 'Location', 'NorthEast')
        saveas(gcf, sprintf('./Figures/MutualInfoVsSnippetLengthByNeuronType_SpikeTrainRes%ims.png', spikeTrainRes(ss)))
    end
    
    %% Mutual Info as a Function of Neuron Type
    
    miVar = fieldnames(miNeural);
    neuronIds = {'PC', 'SA'};
    neuronColors = [rgb('Orange'); rgb('Green')];
    for ss = 1:length(spikeTrainRes)
        figure('WindowStyle', 'docked')
        sgtitle(sprintf('Spike Train Resolution %i ms', spikeTrainRes(ss)))
        yLimValues = [0.5 1.25];
        for ll = 1:length(snippetLength)
            subplot(length(snippetLength),1,ll)
            for nn = 1:length(neuronIds)
                neuronIdx = strcmp(neuronType, neuronIds{nn});
                for vv = 1:length(miVar)
                    miMean(vv) = mean(squeeze(miNeural.(miVar{vv})(ss, ll, neuronIdx)));
                    miStd(vv) = std(squeeze(miNeural.(miVar{vv})(ss, ll, neuronIdx)));
                    miSem(vv) = miStd(vv) ./ sqrt(length(sum(neuronIdx)));
                    
                end
                errorbar(1:length(miVar), miMean, miSem, 's-', ...
                    'Color', neuronColors(nn,:), 'MarkerFaceColor', neuronColors(nn,:), ...
                    'LineWidth', 1.5, 'MarkerEdgeColor', 'none')
                hold on
                
            end
            box off;
            ylabel('Info [bits]'); title(sprintf('Snippet Length %i ms', snippetLength(ss, ll)));
            set(gca, 'YLim', [0, yLimValues(ss)], 'XLim', [0.5 2.5], 'XTick', 1:2, 'XTickLabels', miVar)
        end
        legend(neuronIds, 'Location', 'NorthWest', 'NumColumns', 1)
        
        saveas(gcf, sprintf('./Figures/MutualInfoNeuronType_SpikeTrainRes%ims.png', spikeTrainRes(ss)))
    end
    
    
    
    pcSpikeCountMeans = squeeze(mean(miNeural.SpikeCount(:,:, pcIdx), 3));
saSpikeCountMeans = squeeze(mean(miNeural.SpikeCount(:,:, saIdx), 3));
pcSpikeCountStd = squeeze(std(miNeural.SpikeCount(:,:, pcIdx), 0, 3)) ./ sum(pcIdx);
saSpikeCountStd = squeeze(std(miNeural.SpikeCount(:,:, saIdx), 0, 3)) ./ sum(saIdx);
pcWordsMeans = squeeze(mean(miNeural.Words(:,:, pcIdx), 3));
saWordsMeans = squeeze(mean(miNeural.Words(:,:, saIdx), 3));
pcWordsStd = squeeze(std(miNeural.Words(:,:, pcIdx), 0, 3)) ./ sum(pcIdx);
saWordsStd = squeeze(std(miNeural.Words(:,:, saIdx), 0, 3)) ./ sum(saIdx);

figure;
for ss = 1:5
    subplot(5,1,ss)
    errorbar([pcSpikeCountMeans(ss), pcWordsMeans(ss)], [pcSpikeCountStd(ss), pcWordsStd(ss)], ...
        '-o', 'MarkerSize', 10, 'MarkerEdgeColor', rgb('Orange'), 'MarkerFaceColor', rgb('Orange'), ...
        'Color', rgb('Orange'), 'LineWidth', 1.5)
    hold on
    errorbar([saSpikeCountMeans(ss), saWordsMeans(ss)], [saSpikeCountStd(ss), saWordsStd(ss)], ...
        '-o', 'MarkerSize', 10, 'MarkerEdgeColor', rgb('Green'), 'MarkerFaceColor', rgb('Green'), ...
        'Color', rgb('Green'), 'LineWidth', 1.5)
    set(gca, 'XTick', 1:2, 'XTickLabel', {'Spike Count', 'Words'})
    xlim([0.5 2.5]); box off;
    title(sprintf('Spike Train Res: %ims \nSnippet Length: %ims', spikeTrainRes(ss), snippetLength(ss)))
    ylabel('Info [bits]')
end
saveas(gcf, './Figures/InfoByNeuronTypes_ST1SL10_Variations.png')


    
end