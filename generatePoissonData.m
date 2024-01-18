% load('./Data/neuronFiringRates.mat')

numTrials = 100;
tau = 0.001; % seconds
tref = 1; % ms
trialDuration = 1.8; % seconds

for nn = 1:141
    fprintf('Generating Poisson data for neuron %i\n', nn);
    for tt = 1:59
        [~, spikeTimes] = poissonNeuronModel(firingRates(nn,tt), tau, trialDuration, numTrials, 'refractory', tref);
        cPoissNS.neuron(nn).texture(tt).rep = spikeTimes; % Since poi starts at 0.1 seconds    
    end
end