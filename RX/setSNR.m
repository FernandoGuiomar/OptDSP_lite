function [S,Pn_Fs,SNR_out,noise] = setSNR(S,SNR,Fs,Rs)

% Last Update: 08/11/2019


%% Input Parser
if isnumeric(SNR)
    SNR_tmp.SNRout_dB = SNR;
    SNR = SNR_tmp;
end
if ~isfield(SNR,'SNRin_dB')
    SNR.SNRin_dB = Inf;
end

%% Input Parameters
[nPol,nSamples] = size(S);
SNRout = 10.^(SNR.SNRout_dB/10);
SNRin = 10^(SNR.SNRin_dB/10);

%% Determine Signal Power
Ps_in = mean(abs(S).^2,2);
if isfield(SNR,'Pin')
    Ps = SNR.Pin;
else
    Ps = Ps_in;
end

%% Determine Noise Power
if isfield(SNR,'Pn')
    Pn_Fs = SNR.Pn;
    if numel(Pn_Fs) == 1
        Pn_Fs = repmat(Pn_Fs,1,nPol);
    end
    Pn_Rs = Pn_Fs*Rs/Fs;
else
    Pn0 = Ps/SNRin;
    Pn_Rs = Ps./SNRout - Pn0;
    Pn_Fs = Pn_Rs*Fs/Rs;
end

%% Generate Noise
% Set random number generator seed:
if isfield(SNR,'noiseSeed')
    rng(SNR.noiseSeed);
else
    rng('shuffle');
    tmp = rng;
    SNR.noiseSeed = tmp.Seed;
end
% Generate noise in the I and Q components:
[noise_I,noise_Q] = deal(zeros(nPol,nSamples));
for n = 1:nPol
    noise_I(n,:) = randn(1,nSamples).*sqrt(Pn_Fs(n)/2);
    noise_Q(n,:) = randn(1,nSamples).*sqrt(Pn_Fs(n)/2);
end
% Create the complex-valued noise:
noise = noise_I + 1j*noise_Q;

%% Add Noise to the Signal
S = S + noise;

%% Calculate Ouput SNR
Pn_Fs = mean(Pn_Fs);
SNR_out = pow2db(mean(Ps_in)/mean(Pn_Rs));
