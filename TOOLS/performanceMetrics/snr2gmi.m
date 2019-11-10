function [NGMI,GMI,MI] = snr2gmi(SNR_dB,M,E)
%snr2gmi     Evaluate theorethical MI, GMI and NGMI
%   This function evaluates the theoretical achievable MI, GMI and NGMI 
%   that corresponds to a query SNR and constellation entropy, considering 
%   an AWGN channel. The conversion of SNR into MI, GMI and NGMI is based 
%   on linear interpolation of pre-calculated (simulated) values stored in 
%   look-up tables for each QAM format and constellation entropy. Currently
%   supported QAM formats are:
%   QPSK
%   8QAM (cross QAM)
%   16QAM
%   32QAM (cross QAM)
%   36QAM
%   64QAM
%   100QAM
%   128QAM (cross QAM)
%   144QAM
%   196QAM
%   256QAM
%
%   INPUTS:
%   SNR_dB  :=  signal-to-noise ratio (dB) [1 x nSNR]
%   M       :=  QAM constellation sizes [1 x 1]
%   E       :=  entropy after constellation shaping [1 x 1]
%
%   OUTPUTS:
%   NGMI    :=  normalized generalized mutual information [1 x 1]
%   GMI     :=  generalized mutual information [1 x 1]
%   MI      :=  mutual information [1 x 1]
%
%
%   Examples:
%       [NGMI,GMI,MI] = snr2gmi(8,64,4);
%
%
%   Author: Fernando Guiomar
%   Last Update: 04/07/2019

%% Input Parser
if nargin < 3
    % If no entropy is indicated, then assume uniform modulation:
    E = log2(M);
end

%% Load SNR vs MI Table
fileName = [num2str(M) 'QAM_snr2gmi'];
SNR_vs_GMI = load(fileName);

%% Retrieve SNR, NGMI and Entropy Values
E_LUT = SNR_vs_GMI.entropy;
if numel(E_LUT) > 1
    [SNR_LUT,E_LUT] = meshgrid(SNR_vs_GMI.SNR_dB,E_LUT);
else
    SNR_LUT = SNR_vs_GMI.SNR_dB;
end
NGMI_LUT = SNR_vs_GMI.NGMI;
NGMI_LUT(isnan(NGMI_LUT)) = 1;
NGMI_LUT(isinf(NGMI_LUT)) = 0;

%% Calculate NGMI
% Linear interpolation to find the best-fit NGMI for the query SNR and E:
if numel(E_LUT) > 1
    NGMI = interp2(SNR_LUT,E_LUT,NGMI_LUT,SNR_dB,E,'linear');
else
    NGMI = interp1(SNR_LUT,NGMI_LUT,SNR_dB,'linear',1);
end

%% Calculate GMI
if nargout > 1
    GMI_LUT = SNR_vs_GMI.GMI;
    GMI_LUT(isnan(GMI_LUT)) = E;
    GMI_LUT(isinf(GMI_LUT)) = 0;
    if numel(E_LUT) > 1
        GMI = interp2(SNR_LUT,E_LUT,GMI_LUT,SNR_dB,E,'linear',E);
    else
        GMI = interp1(SNR_LUT,GMI_LUT,SNR_dB,'linear',E);
    end
end

%% Calculate MI
if nargout > 2
    MI_LUT = SNR_vs_GMI.MI;
    MI_LUT(isnan(MI_LUT)) = E;
    MI_LUT(isinf(MI_LUT)) = 0;
    if numel(E_LUT) > 1
        MI = interp2(SNR_LUT,E_LUT,MI_LUT,SNR_dB,E,'linear',E);
    else
        MI = interp1(SNR_LUT,MI_LUT,SNR_dB,'linear',E);
    end
end
