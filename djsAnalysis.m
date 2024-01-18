function [djsMatrix, rsq] = djsAnalysis(neuralJointDist, humanScores, plotFigure)

djsMatrix = NaN(size(neuralJointDist, 1), size(humanScores, 1), size(humanScores, 1));
humanScores(1:size(humanScores, 1) + 1:end) = NaN(1, size(humanScores, 1)); % Set the diagonal to NaN

numNeurons = size(neuralJointDist, 1);
rsq = NaN(1, numNeurons);
numPlots = ceil(sqrt(numNeurons)); % Figure out the number of subplot rows/cols

if plotFigure
    figure('units','normalized','outerposition',[0 0 1 1]);
end
for nn = 1:size(neuralJointDist, 1)
    if plotFigure
        s(nn) = subplot(numPlots, numPlots, nn);
    end
    for text1 = 1:size(humanScores, 1)
        for text2 = 1:size(humanScores, 1)
            if text1 ~= text2
                djsMatrix(nn, text1, text2) = JSDiv(squeeze(neuralJointDist(nn, text1, :))', squeeze(neuralJointDist(nn, text2, :))');
            end
        end
    end
    x = reshape(humanScores, [1, size(humanScores, 1) * size(humanScores, 2)]);
    y = reshape(djsMatrix(nn, :, :), [1, size(djsMatrix, 2) * size(djsMatrix, 3)]);
    % Remove NaNs for analysis
    [regLine, rsq(nn)] = calculateLinearRegression(x(~isnan(x)), y(~isnan(y)), 1);
    
    if plotFigure
        scatter(x, y, 'k.', 'MarkerFaceColor', 'k')
        hold on
        % plot line of best fit
        plot(x(~isnan(x)), regLine, 'r-', 'LineWidth', 2)
        title(sprintf('N%i, R^2 = %.2f', nn, rsq(nn)))
        xlabel('HDR'); ylabel('D_{JS}')
        xlim([.4 2])
    end
end

if plotFigure
    % Reformat subplots so it looks pretty
    reformatFigure(s, numPlots, numNeurons)
end

end

function [regLine, rsq] = calculateLinearRegression(x, y, polyTerm)
% Performs a basic linear regression and calculates the line of best fit,
% and the r^2 term based on https://www.mathworks.com/help/matlab/data_analysis/linear-regression.html

% Get the coefficients for the line of best fit

p = polyfit(x, y, polyTerm);

% Get the line of best fit
regLine = polyval(p, x);

% Calculate the R^2
yResid = y - regLine;
ssResid = sum(yResid .^ 2);
ssTotal = (length(y)-1) * var(y);
rsq = 1 - ssResid/ssTotal;

end

function reformatFigure(subplotHandle, numPlots, numNeurons)

if numPlots == 4 % PC Neurons
    set(subplotHandle(:), 'FontSize', 10)
    pos1Diff = .245;
    pos2Diff = 0.33;
    pos1 = .04; pos2 = .715; pos3 = .2; pos4 = .25;
    subplotHandle(1).Position = [pos1, pos2, pos3, pos4];
%     figName = './Figures/DjsHumanSimilarity_PCNeurons.png';
    
elseif numPlots == 5 % SA Neurons
    set(subplotHandle(:), 'FontSize', 8)
    pos1Diff = .19;
    pos2Diff = 0.2;
    pos1 = .05; pos2 = .835; pos3 = .14; pos4 = .14;
    subplotHandle(1).Position = [pos1, pos2, pos3, pos4];
%     figName = './Figures/DjsHumanSimilarity_SANeurons.png';
    
elseif numPlots == 12 % All Neurons
    pos1Diff = .08;
    pos2Diff = 0.082;
    set(subplotHandle(:), 'FontSize', 7)
    pos1 = .04; pos2 = .935; pos3 = .05; pos4 = .032;
    subplotHandle(1).Position = [pos1, pos2, pos3, pos4];
%     figName = './Figures/DjsHumanSimilarity_AllNeurons.png';
else
    warning('Number of subplots not accounted for :o')
end

% Actually do the formatting
for rr = 1:numPlots:numPlots^2
    if rr == 1
        curPos2 = subplotHandle(1).Position(2);
    elseif rr <= numNeurons
        curPos2 = subplotHandle(rr - numPlots).Position(2) - pos2Diff;
        subplotHandle(rr).Position = [pos1, curPos2, pos3, pos4];
    end
    for cc = 1:numPlots - 1
        if rr + cc <= numNeurons
            subplotHandle(rr + cc).Position = [subplotHandle(rr + cc - 1).Position(1) + pos1Diff, curPos2, pos3, pos4];
        end
    end
end

% saveas(gcf, figName)

end