function [PAPR,PAPR_IQ_mean,PAPR_pol,PAPR_IQ] = getPAPR(S)

% Last Update: 18/05/2017


%% Input Parameters
nPol = size(S,1);

%% Determine PAPR
for n = 1:nPol
    PAPR_pol(n) = max(abs(S(n,:)).^2) / mean(abs(S(n,:)).^2);
    PAPR_IQ(n,1) = max(abs(real(S(n,:))).^2) / mean(abs(real(S(n,:))).^2);
    PAPR_IQ(n,2) = max(abs(imag(S(n,:))).^2) / mean(abs(imag(S(n,:))).^2);
end

%% Average PAPR
PAPR = mean(PAPR_pol);
PAPR_IQ_mean = mean(PAPR_IQ(:));

%% Ouput Values in dB
PAPR = 10*log10(PAPR);
PAPR_IQ_mean = 10*log10(PAPR_IQ_mean);
PAPR_pol = 10*log10(PAPR_pol);
PAPR_IQ = 10*log10(PAPR_IQ);

