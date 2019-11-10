function Q = Qfactor(BER)

% Last Update: 21/03/2014

Q = 20*log10(sqrt(2)*erfcinv(2*BER));

% References:
% [1] C. Zhu et al, "Training-Aided PDM 64-QAM Transmission with Enhanced 
% Fiber Nonlinearity Tolerance", in Proc. OFC'14, paper M2A.7, 2014.

