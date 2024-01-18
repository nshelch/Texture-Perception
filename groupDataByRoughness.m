function jointCount = groupDataByRoughness(data, roughnessLabels)

numNeurons = size(data, 1);
numLabels = max(roughnessLabels);
maxDataValue = max(data(:));

jointCount = zeros(numNeurons, numLabels, length(0:maxDataValue));

for nn = 1:numNeurons
    for ll = 1:numLabels
        labelCount = zeros(1, length(0:maxDataValue));
        labelIdx = find(roughnessLabels == ll);
        labelData = squeeze(data(nn, labelIdx, :));
        for dd = 0:maxDataValue
            tmp = (labelData == dd);
            labelCount(dd + 1) = sum(tmp(:));
        end
        jointCount(nn, ll, :) = labelCount;
    end
end

end