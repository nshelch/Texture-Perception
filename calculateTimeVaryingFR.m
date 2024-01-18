for nn = 1:141
    for tt = 1:59
        tmp = reshape(spikeTrain(nn, tt, :), [1800, 5])';
        for rr = 1:5
            tmp2 = reshape(tmp(rr, :), [20, 1800 / 20]);
            tmpFR(rr, :) = (sum(tmp2) ./ 20) .* 1000;
        end
        firingRatesTV(nn, tt, :) = mean(tmpFR); % convert fr from ms to seconds
    end
end

save('./Data/neuronFiringRatesTV.mat', 'firingRatesTV')