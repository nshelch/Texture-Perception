function textureLabels = roughnessLabels(labelEdges, roughnessScores)

textureLabels = NaN(1, length(roughnessScores));

for rr = 1:length(roughnessScores)
    textureLabels(rr) = find(histcounts(roughnessScores(rr), labelEdges) == 1);
end

end