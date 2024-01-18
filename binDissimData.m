function binnedData = binDissimData(dissimData, numBins, plotFigure)

% dissimData.fullMat = text1 x text2 x subject x rep

maxScore = ceil(max(max(max(max(dissimData.fullMat)))));
minScore = floor(min(min(min(min(dissimData.fullMat)))));

binEdges = linspace(minScore, maxScore, numBins + 1);

zscoreEdges = linspace(-1, 1, numBins + 1);
dissimMatrix = zeros(size(dissimData.fullMat, 1), size(dissimData.fullMat, 1), numBins);
globalCount = zeros(1, numBins);
jointCount = zeros(91, numBins); % 13*12 / 2 + 13 <- since we can do t1 x t1)
if plotFigure
    figure('units','normalized','outerposition',[0 0 1 1]);
end
for ii = 1:size(dissimData.fullMat, 3)
    jointCounter = 1;
    tmp = squeeze(dissimData.fullMat(:, :, ii, :));
    tmpStretched = reshape(tmp, [1, size(tmp, 1) * size(tmp, 2) * size(tmp, 3)]);
    
    if plotFigure
        subplot(10, 2, ii + (ii - 1))
        box off; xlabel('Bins'); ylabel('Probability'); title(sprintf('Subject %i', ii));
        
    end
    tmpHist = histogram(tmpStretched, binEdges, 'Normalization', 'probability'); % Does ignore NaN values
    binnedData.universalBinning(ii, :) = tmpHist.Values;
    
    if plotFigure
        subplot(10, 2, ii + ii)
        box off; xlabel('Zscore Bins'); ylabel('Probability'); title(sprintf('Subject %i', ii));
    end
    
    tmpHist = histogram(normalize(tmpStretched, 'range', [-1 1]), linspace(-1, 1, numBins + 1), 'Normalization', 'probability');
    binnedData.zscoreBinning(ii, :) = tmpHist.Values;
    binnedData.zscore(:, :, ii, :) = reshape(normalize(tmpStretched, 'range', [-1 1]), size(tmp));
    for text1 = 1:size(dissimData.fullMat, 1)
        for text2 = text1:size(dissimData.fullMat, 1)
            dissimMatrix(text1, text2, :) = squeeze(dissimMatrix(text1, text2, :)) + ...
                histcounts(binnedData.zscore(text1, text2, ii, :), zscoreEdges)';
            globalCount = globalCount + histcounts(binnedData.zscore(text1, text2, ii, :), zscoreEdges);
            jointCount(jointCounter, :) = jointCount(jointCounter, :) + histcounts(binnedData.zscore(text1, text2, ii, :), zscoreEdges);
            jointCounter = jointCounter + 1;
        end
    end
end

% Annoying thing to make the lower triangle of the matrix into NaNs
tmp = ones(size(dissimData.fullMat, 1), size(dissimData.fullMat, 1));
tmp = tril(tmp, -1);
tmp(tmp == 1) = NaN;

binnedData.dissimMatrixCounts = dissimMatrix + tmp;
binnedData.dissimMatrixProb = (dissimMatrix ./ repmat(sum(dissimMatrix , 3), [1,1,size(dissimMatrix, 3)])) + tmp;
binnedData.numBins = numBins;
binnedData.zscoreEdges = zscoreEdges;
binnedData.globalCount = globalCount;
binnedData.globalDist = globalCount / sum(globalCount);
binnedData.jointCount = jointCount;
binnedData.jointDist = jointCount ./ repmat(sum(jointCount, 2), [1, numBins]);


if plotFigure
    saveas(gcf, './Figures/DissimDataRange.png')
end

end