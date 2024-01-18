function binRes = dissimDataBinningResolution(dissimData, numBins)

binRes = zeros(1, length(numBins));
for ii = 1:length(numBins)
    tmp = binDissimData(dissimData, numBins(ii), 0);
    s = -1 * sum( tmp.globalDist .* log2(tmp.globalDist + eps) + eps);
    binRes(ii) = s;
end

figure('WindowStyle','docked')
plot(numBins, binRes, 'k-', 'LineWidth', 1.5)
hold on
plot(numBins, binRes, 'k.', 'MarkerSize', 15)
xlabel('Number of bins'); ylabel('Entropy')
box off
saveas(gcf, './Figures/DissimilarityBinningRes.png')

end