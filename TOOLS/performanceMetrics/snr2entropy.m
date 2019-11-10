function [E] = snr2entropy(SNR_dB,NGMI,M)
%snr2entropy    Evaluate the transmitted entropy that matches
%               the operating SNR, considering a given NGMI threshold and a
%               given M-QAM template (ideal PCS is assumed)
%
%   INPUTS:
%   SNR_dB  :=  signal-to-noise ratio (dB) [1 x 1]
%   M       :=  QAM constellation sizes [1 x 1]
%   NGMI    :=  normalized generalized mutual information [1 x 1]
%
%   OUTPUTS:
%   E       :=  transmitted entropy [1 x 1]
%
%
%   Examples:
%       [E] = snr2entropy(15,0.9,256);
%
%
%   Author: Fernando Guiomar
%   Last Update: 04/07/2019

%% Find Best SNR using fminsearch
options = optimset('MaxFunEvals',1e4,'TolX',1e-2,'TolFun',1e-2,...
    'Display','none','PlotFcns',[]);
% E = fminsearch(@(E) snr2gmi_err(SNR_dB,M,E,NGMI),log2(M)-1,options);
E = fminbnd(@(E) snr2gmi_err(SNR_dB,M,E,NGMI),1,log2(M),options);

end

%% Aux Function
function [err] = snr2gmi_err(SNR_dB,M,E,nGMI_query)
    nGMI = snr2gmi(SNR_dB,M,E);
    err = abs(nGMI-nGMI_query);
end
