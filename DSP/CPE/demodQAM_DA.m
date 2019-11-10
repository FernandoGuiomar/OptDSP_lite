function [Aout,Aout2] = demodQAM_DA(S,txSignal)

% Last Update: 03/07/2016


%% Input Parameters
txSignal = (round(txSignal*1e5)/1e5);
phi = angle(txSignal);

%% Data-Aided Demodulation
Aout = S.*exp(-1j*phi);%./abs(txSignal);

Aout2 = Aout./abs(txSignal);
