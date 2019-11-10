function [SNR_dB] = gmi2snr(GMI,M,E)
%ngmi2snr   Evaluate the theoretical SNR that corresponds to given
%           measured GMI, constellation template for probabilistic
%           shaping (M) and signal entropy (E)
%
%   INPUTS:
%   GMI     :=  generalized mutual information [1 x 1]
%   M       :=  QAM constellation sizes [1 x 1]
%   E       :=  entropy after constellation shaping [1 x 1]
%
%   OUTPUTS:
%   SNR_dB  :=  signal-to-noise ratio (dB) [1 x 1]
%
%
%   Examples:
%       [SNR_dB] = gmi2snr(5.2,256,6);
%
%
%   Author: Fernando Guiomar
%   Last Update: 04/07/2019

%% Input Parser
if nargin < 3
    % If no entropy is indicated, then assume uniform modulation:
    E = log2(M);
end

%% Load SNR vs GMI Table
fileName = [num2str(M) 'QAM_snr2gmi'];
SNR_vs_GMI = load(fileName);
E_LUT = SNR_vs_GMI.entropy;
SNR_LUT = SNR_vs_GMI.SNR_dB;
GMI_LUT = SNR_vs_GMI.GMI;

%% Find Closest Entropy Values in the LUT
[minErr,idx] = min(abs(E_LUT-E));
if minErr > 0
    idx = idx-1:idx+1;
end
E_LUT = E_LUT(idx);

%% Interpolate Over GMI for Each Trial Entropy
thisSNR_dB = NaN(1,numel(idx));
for n = 1:numel(idx)
    thisGMI = GMI_LUT(idx(n),:);
    idxNaN = isnan(thisGMI);
    thisGMI = thisGMI(~idxNaN);
    thisSNR = SNR_LUT(~idxNaN);
    [thisGMI,idxUnique] = unique(thisGMI);
    thisSNR = thisSNR(idxUnique);
    thisSNR_dB(n) = interp1(thisGMI,thisSNR,GMI,'linear'); 
end

%% Interpolate Over Entropy
if numel(idx) > 1
    SNR_dB = interp1(E_LUT,thisSNR_dB,E,'linear');
else
    SNR_dB = thisSNR_dB;
end
