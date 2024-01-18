
function roughData = GetNewRoughData()

filepath            = './Data/NewRoughnessFiles/';
formatStringHeader  = '%s%s%s%s%s%s%s%s';
formatString        = '%d%d%d%d%d%d%d%f';
    
files = dir([filepath '*rsp*']); % rsp data files

N = size(files,1);
fileList = cell(N,1);

nText       = 60;
nRep        = 2;
allRough = nan(N,nText,nRep);

allNames = cell(N,1);

for i=1:N
    file = strtrim(files(i).name);
    fileList{i} = file;
    
    allNames{i} = file([9 10]);
    
    fid                 = fopen([filepath file], 'rt');
    headers             = textscan(fid, formatStringHeader, 1);
    data                = textscan(fid, formatString);
    fclose(fid);
    
    posInd = find(cellfun(@(x)strcmp(x, 'PositionOnDrum'), headers));
    tList = data{posInd};
    
    roughInd    = find(cellfun(@(x)strcmp(x, 'Response'), headers));
    thisRough   = data{roughInd};
    repInd      = find(cellfun(@(x)strcmp(x, 'RepNum'), headers));
    thisRep     = data{repInd};
    for j = 1:size(thisRough)
        allRough(i,tList(j), thisRep(j)) = thisRough(j);
    end
end

names = unique(allNames);
nNames = length(names);

sortRough = nan(nNames, 6, nText);


for nameInd=1:nNames
    indList = find(strcmp(allNames, names(nameInd)));
    index = 0;
    for runInd = 1:length(indList)
        for repInd=1:2
            index = index + 1;
            sortRough(nameInd, index, :) = allRough(indList(runInd), :, repInd);
        end
    end
end

N = size(sortRough); 
allNormRough = sortRough ./ repmat( nanmean(nanmean(sortRough,3),2), [1 N(2:3)]);
normRough = squeeze(nanmean(allNormRough,2))';

useInd              = [1:22 24:60];

textureNames        = cda1201_GetCalibrationData()';

roughData.roughMean = nanmean(normRough(useInd, :), 2);
roughData.roughStd  = nanstd( normRough(useInd, :), [], 2);
roughData.roughN    = sum(~isnan(normRough(useInd, :)), 2);
roughData.allData   = normRough(useInd,:);

roughData.textureNames  = textureNames(useInd);
                            

end

