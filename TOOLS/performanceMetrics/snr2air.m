function [AIR] = snr2air(SNR_dB,R_FEC,M,NGMIth)
%snr2air    Evaluate the achievable information rate (AIR) that matches
%           the operating SNR, considering a given FEC rate, NGMI threshold 
%           and a given M-QAM template (ideal PCS is assumed)
%
%   INPUTS:
%   SNR_dB  :=  signal-to-noise ratio (dB) [1 x 1]
%   M       :=  QAM constellation sizes [1 x 1]
%   NGMI    :=  normalized generalized mutual information [1 x 1]
%
%   OUTPUTS:
%   AIR     :=  achievable information rate after constellation shaping [1 x 1]
%
%
%   Examples:
%       [AIR] = snr2air(15,0.9,256);
%
%
%   Author: Fernando Guiomar
%   Last Update: 04/07/2019

%% Input Parser
if nargin < 4
    % if the threshold NGMI is not indicated, then consider an ideal FEC:
    NGMIth = R_FEC;
end
if NGMIth < R_FEC
    error('The threshold NGMI cannot be lower than the FEC rate!');
end

%% Calculate Transmitted Entropy
E = snr2entropy(SNR_dB,NGMIth,M);

%% Calculate Entropy Reserved for FEC
E_FEC = (1-R_FEC)*log2(M);

%% Calculate AIR
AIR = E - E_FEC;
