function [SNR_dB] = shannon2snr(C)

% Last Update: 09/03/2017


%% Convert Capacity [bits/symbol] into SNR [dB]
SNR_dB = 10*log10(2.^C - 1);
