function [C] = snr2shannon(SNR_dB)

% Last Update: 09/03/2017


%% Convert SNR [dB] into Capacity [bits/symbol]
C = log2(1+10.^(SNR_dB/10));

