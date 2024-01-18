clear; close all; clc; 

if exist('./Data/cData.mat', 'file')
    load('./Data/cData.mat')
else
    load('./Data/cdaData.mat')
    cData = formatData(cdaData.fullRun.data);
end

% Params for MI Calculations
startTime = 100; % ms
poiDur = 1800; % Duration of period of interest (poi) in ms
spikeTrainRes = 2; %[1, 2, 5, 10]; % ms
snippetLength = [6 8]; %[10, 20, 30, 40, 50, 100]; % ms
maxBins = 20; % Number of bins to not exceed for word and ISI calculations, based on MATLAB memory limits and my patience
slidingWindow = 0;

convFactor = 1000; % Conversion factor from bits/bin to bits/sec in MI calculations (1000 keeps the info in units of bits/bin)

for ss = 1:length(spikeTrainRes)
    for ll = 1:length(snippetLength)
        clc; fprintf('Spike Train Res: %i/%i, Snippet Length %i/%i\n', ss, length(spikeTrainRes), ll, length(snippetLength));
        
        numBins = snippetLength(ll) / spikeTrainRes(ss); % Number of bins needed based on the resolution of the spike train
        
        % Bins the data based on the spike train res. and outputs a 3D
        % binarized spike train matrix (neurons x textures x spike train)
        spikeTrain = binSpikeData(cData, spikeTrainRes(ss), startTime, poiDur);
        
        % Spike Count
        [spikeCount] = getSpikeCounts(spikeTrain, numBins, slidingWindow);
        [firstSpikeCount] = getFirstSpike(spikeTrain, numBins, slidingWindow);
        [wordCount] = getWords(spikeTrain, numBins, slidingWindow);
        
        for nn = 1:141
            spikeCountX = reshape(squeeze(spikeCount(nn,:,:)), [1, size(squeeze(spikeCount(nn,:,:)), 1) * size(squeeze(spikeCount(nn,:,:)), 2)]);
            spikeCountY = reshape(repmat((1:59)', [1, size(squeeze(spikeCount(nn,:,:)), 2)]), [1, size(squeeze(spikeCount(nn,:,:)), 1) * size(squeeze(spikeCount(nn,:,:)), 2)]);
            
            [infoSpikeCount(ss, ll).fs_corr(nn), infoSpikeCount(ss, ll).err_50(nn), infoSpikeCount(ss, ll).err_frac(nn), ...
                infoSpikeCount_shuffled(ss, ll).fs_corr(nn), infoSpikeCount_shuffled(ss, ll).err_50(nn), infoSpikeCount_shuffled(ss, ll).err_frac(nn), ...
                infoSpikeCount(ss, ll).fs_samples{nn}, infoSpikeCount_shuffled(ss, ll).fs_samples{nn}, ...
                infoSpikeCount(ss,ll).joint{nn}, infoSpikeCount_shuffled(ss,ll).joint{nn}] = calc_info_P_joint(spikeCountX + 1, spikeCountY, numBins + 1, 59, [1 0.9 0.8 .75 0.5], 25);
            
            
            firstSpikeX = reshape(squeeze(firstSpikeCount(nn,:,:)), [1, size(squeeze(firstSpikeCount(nn,:,:)), 1) * size(squeeze(firstSpikeCount(nn,:,:)), 2)]);
            firstSpikeY = reshape(repmat((1:59)', [1, size(squeeze(firstSpikeCount(nn,:,:)), 2)]), [1, size(squeeze(firstSpikeCount(nn,:,:)), 1) * size(squeeze(firstSpikeCount(nn,:,:)), 2)]);
            
            [infoFirstSpike(ss, ll).fs_corr(nn), infoFirstSpike(ss, ll).err_50(nn), infoFirstSpike(ss, ll).err_frac(nn), ...
                infoFirstSpike_shuffled(ss, ll).fs_corr(nn), infoFirstSpike_shuffled(ss, ll).err_50(nn), infoFirstSpike_shuffled(ss, ll).err_frac(nn), ...
                infoFirstSpike(ss, ll).fs_samples{nn}, infoFirstSpike_shuffled(ss, ll).fs_samples{nn}, ...
                infoFirstSpike(ss,ll).joint{nn}, infoFirstSpike_shuffled(ss,ll).joint{nn}] = calc_info_P_joint(firstSpikeX + 1, firstSpikeY, numBins + 1, 59, [1 0.9 0.8 .75 0.5], 25);
            
            wordX = reshape(squeeze(wordCount(nn,:,:)), [1, size(squeeze(wordCount(nn,:,:)), 1) * size(squeeze(wordCount(nn,:,:)), 2)]);
            wordY = reshape(repmat((1:59)', [1, size(squeeze(wordCount(nn,:,:)), 2)]), [1, size(squeeze(wordCount(nn,:,:)), 1) * size(squeeze(wordCount(nn,:,:)), 2)]);
            
            [infoWord(ss, ll).fs_corr(nn), infoWord(ss, ll).err_50(nn), infoWord(ss, ll).err_frac(nn), ...
                infoWord_shuffled(ss, ll).fs_corr(nn), infoWord_shuffled(ss, ll).err_50(nn), infoWord_shuffled(ss, ll).err_frac(nn), ...
                infoWord(ss, ll).fs_samples{nn}, infoWord_shuffled(ss, ll).fs_samples{nn}, ...
                infoWord(ss,ll).joint{nn}, infoWord_shuffled(ss,ll).joint{nn}] = calc_info_P_joint(wordX + 1, wordY, 2^numBins + 1, 59, [1 0.9 0.8 .75 0.5], 25);
        end
    end
end

save('./Data/FS_Info.mat', 'infoFirstSpike', 'infoFirstSpike_shuffled', 'infoSpikeCount', 'infoSpikeCount_shuffled', 'infoWord', 'infoWord_shuffled')
