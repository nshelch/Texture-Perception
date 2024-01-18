function fs = finiteSizeAnalysis(data, maxDataValue, numReps, propDataSampled)
% data: neuron x texture x data matrix
% pRange: possible values for the neural statistic
% numReps: the number of times you want to sample each proportion of data
% propDataSampled: The proportion of data you want to sample

numNeurons = size(data, 1);
numTextures = size(data, 2);
numData = size(data, 3); % total number of data points
numSamples = round(propDataSampled * numData);


for ss = 1:length(propDataSampled)
    fprintf('Prop. of data being sampled %.2f \n', propDataSampled(ss));
    pbar = fprintf('Rep: %i/%i \n', 0, numReps);
    
    for rr = 1:numReps
        fprintf(repmat('\b', 1, pbar))
        pbar = fprintf('Rep: %i/%i \n', rr, numReps);
        
        for nn = 1:numNeurons
            sampledData = zeros(numTextures, numSamples(ss));
            jointCount = zeros(numTextures, maxDataValue + 1);
%             jointCount = zeros(numTextures, maxDataValue + 1);
            for tt = 1:numTextures
                sampledData(tt, :) = datasample(data(nn, tt, :), numSamples(ss));
                jointCount(tt, :) = histcounts(sampledData(tt, :), -.5:maxDataValue + .5); % check this since pRange indicates edges!!!!!
                
                %                 for ii = 0:maxDataValue
                %                     jointCount(tt, ii + 1) = sum(sampledData(tt, :) == ii);
                %                 end
            end
        end
        
        pJoint = jointCount / sum(jointCount(:)); % Get the joint distribution
        px = sum(pJoint, 2);
        py = sum(pJoint, 1);
        logTerm = log2(pJoint./((px * py) + eps) + eps);
        fs.sampledInfo(ss, rr) = sum(sum(pJoint .* logTerm));
        
    end
    
    fs.sampledMean(ss) = mean(fs.sampledInfo(ss, :));
    fs.sampledStd(ss) = std(fs.sampledInfo(ss, :));
end


% Calculate fractional error
p = polyfit(1 ./ numSamples, fs.sampledMean, 1);
infoEst = polyval(p, [0, 1 ./ numSamples, 1 / 200]);
infoAtInf = polyval(p, 0);
infoAllData = fs.sampledMean(propDataSampled == 1);
fs.fracError = (infoAllData / infoAtInf) - 1;

figure('WindowStyle', 'docked');
plot([0, 1 ./ numSamples, 1/200], infoEst, 'k--', 'LineWidth', 1.5)
hold on
errorbar(1 ./ numSamples, fs.sampledMean, fs.sampledStd, ...
    'ok', 'LineStyle', 'none', 'LineWidth', 2, ...
    'MarkerFaceColor', 'w', 'MarkerSize', 7)
ylabel('Info [bits]'); xlabel('1 / # Data');
box off
title('Finite Size Analysis')

% saveFig = input('Do you want to save this figure (y/n)? ', 's');
% if strcmpi(saveFig, 'y')
%     figName = input('Filepath/name for the figure: ', 's');
%     saveas(gcf, figName)
% end

end