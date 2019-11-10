function [Aout] = demodQAM_DD(S,C)

% Last Update: 02/02/2018


%% Input Parser
txSignal = symbol2signal(signal2symbol(S,C),C);
phi = angle(txSignal);

%% Data-Aided Demodulation
Aout = S.*exp(-1j*phi);

