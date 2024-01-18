function [spikeTrain, spikeTimes] = poissonNeuronModel(fr0, delta, trialDur, numTrials, varargin)

% fr0 -> the firing rate of this neuron in spikes/second
% delta -> resolution at which we want to get the spiking data (how long is
%   each bin)
% trialDur -> duration of the trial
% numTrials -> number of trials to simulate

numBins = trialDur / delta; % number of time bins in the trial
spikeTrain = zeros(numTrials, numBins);
spikeTimes = cell(1, numTrials);
deltaSec = delta/1000; % transform delta from ms to s
timeVec = 0:deltaSec:trialDur; % time vector for the trial

if ~isempty(varargin)
    if strcmp(varargin(1), 'refractory')
        modelType = 'refractory';
        tref = varargin{2}; % refractory period in ms
    elseif strcmp(varargin(1), 'time-varying')
        modelType = 'time-varying';
        timeVecFR = varargin{2}; % time that corresponds to each firing rate
    elseif strcmp(varargin(1), 'time-varying refractory')
        modelType = 'time-varying refractory';
        tref = varargin{2}; % refractory period in ms
        timeVecFR = varargin{3}; % time that corresponds to each firing rate
        pastFRIdx = 0;
    end
else
    modelType = 'default'; % assumes no refractory period
end

for tt = 1:numTrials
    fr = fr0; % initial value of r
    for nn = 1:numBins
        pSpike = rand; % pick a random number between 0 and 1
        
        % Different Poisson Models
        switch modelType
            case 'default'
                if deltaSec*fr0 > pSpike
                    spikeTrain(tt, nn) = 1;
                end
                
            case 'refractory'
                if fr < fr0
                    dr = (fr0 - fr) / tref;
                    fr = fr + dr;
                else % in the case that r is greater than r0
                    fr = fr0;
                end
                
                if deltaSec*fr > pSpike
                    spikeTrain(tt, nn) = 1;
                    fr = 0;
                end
                
            case 'time-varying'
                frIdx = find(timeVec(nn) >= timeVecFR);
                fr = fr0(frIdx(end));
                if deltaSec*fr > pSpike
                    spikeTrain(tt, nn) = 1;
                end
                
            case 'time-varying refractory'
                frIdx = find(timeVec(nn) >= timeVecFR);
                if pastFRIdx ~= frIdx(end)
                    fr = r0(frIdx(end));
                    r = fr;
                    pastFRIdx = frIdx(end);
                end
                
                % Refractory component
                if r < fr
                    dr = (fr - r) / tref;
                    r = r + dr;
                else % in the case that r is greater than r0
                    r = fr;
                end
                
                %  Check if spike happens
                if deltaSec*r > pSpike
                    spikeTrain(tt, nn) = 1;
                    r = 0;
                end
        end
    end
    spikeTimes{tt} = timeVec(spikeTrain(tt,:) == 1);
end
end

