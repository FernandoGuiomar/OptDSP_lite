function [SNR_dB] = ber2snr(varargin)
%ber2snr    Determine the SNR that theoreticaly corresponds to a given BER
%   This function evaluates the theoretical SNR that corresponds to a given
%   measured BER over a AWGN channel. The conversion of BER into SNR is
%   based on analytical formulas (approximate) obtained from the
%   literature. Currently supported formats are:
%   mPSK (constant amplitude)
%   mQAM (square QAM)
%   mQAM (cross QAM)
%
%   INPUTS:
%   BER     :=  bit-error rate [1 x nBER]
%   M       :=  QAM constellation size [1 x 1]
%   mode_MF :=  modulation format mode:
%                   - 'mPSK': m-ary phase-shift keying;
%                   - 'mQAM': m-ary quadrature amplitude modulation
%   class_MF :=  modulation format class (only for QAM mode):
%                   - 'square-QAM': square m-ary QAM using approximate 
%                   analytical formula;
%                   - 'cross-QAM': cross m-ary QAM using approximate 
%                   analytical formulas , as published in:
%                   https://doi.org/10.1109/TWC.2005.857997
%                   (see eqs. (2), (5) and (40)).
%
%   Alternatively, snr2ber also accepts M and mode_MF to be parsed as
%   fields of a QAM struct:
%   M = QAM.M;
%   mode_MF = QAM.mode;
%   class_MF = QAM.class;
%
%   OUTPUTS:
%   SNR_dB  :=  signal-to-noise ratio (considering energy per symbol, Es)
%               (dB) [1 x nBER]
%   Examples:
%       1) With numeric inputs:
%       SNR_64QAM = ber2snr(1e-3:1e-3:1e-2,64,'QAM','square')
%       SNR_32QAM = ber2snr(1e-3:1e-3:1e-2,32,'QAM','cross')
%
%       2) With QAM struct:
%       QAM = QAM_config('M',64)
%       SNR_64QAM = ber2snr(1e-3:1e-3:1e-2,QAM)
%       QAM = QAM_config('M',32,'modulation','QAM','class','cross')
%       SNR_32QAM = ber2snr(1e-3:1e-3:1e-2,QAM)
%
%
%   Author: Fernando Guiomar
%   Last Update: 07/01/2018

%% Input Parser
if nargin < 2
    error('At least two input arguments are required for the ber2snr function.');
end
% Get BER:
BER = varargin{1};
% Get Constellation Size, M, and Modulation Format Mode, mode_MF::
if isstruct(varargin{2})
    MF = varargin{2};
    M = MF.M;
    if isfield(MF,'mode')
        mode_MF = MF.mode;
    end
    if isfield(MF,'class')
        class_MF = MF.class;
        if strcmp(class_MF,'rect')
            M = MF.M_rect;
        end
    end
elseif isnumeric(varargin{2})
    M = varargin{2};
    if nargin >= 3
        mode_MF = varargin{3};
    end
    if nargin >= 4
        class_MF = varargin{4};
    end
end
% Default option for mode_MF:
if ~exist('mode_MF','var')
    mode_MF = 'QAM';
end
% Default option for class_MF:
if ~exist('class_MF','var')
    if numel(M) == 1
        if mod(sqrt(M),1) == 0
            class_MF = 'square';
        elseif mod(log2(M),1) == 0
            class_MF = 'cross';
        end
    elseif numel(M) == 2
        class_MF = 'rect';
    end
end
% Allow only for integer number of bits per symbol:
if mod(log2(M),1) > 0
    error('The ber2snr function is only compatible with QAM constellation of size 2^n, for any integer n. The parsed constellation size, %d, does not fulfill this condition. Please consider changing the constellation size.',M);
end

%% Calculate SNR from BER
SNR = zeros(1,numel(BER));
switch mode_MF
    case {'PSK','mPSK'}
        SNR = (erfcinv(log2(M)*BER)/(sin(pi/M))).^2;
    case {'QAM','mQAM'}
        switch class_MF
            case 'square'
                SNR = 2*(M-1)/3*...
                    erfcinv((BER*log2(M))/(2*(1-1/sqrt(M)))).^2;
            case 'cross'
                SNR = ber2snr_crossQAM(M,BER);
        end
end

%% Convert to SNR into dB
SNR_dB = 10*log10(SNR);

end

%% Auxiliary Functions
function SNR = ber2snr_crossQAM(M,BER)
    % P. K. Vitthaladevuni, M.-S. Alouini and J. C. Kieffer, "Exact
    % BER Computation for Cross QAM Constellations," IEEE Trans. on
    % Wireless Communications, vol. 4, no. 6, 2005. (see eqs. (2),
    % (5) and (40)).
    switch M
        case 8
            N = 3;
            Gp = 10/8;
            B = 3 + sqrt(3);
        case 32
            N = 4 - 6/sqrt(2*M);
            Gp = 7/6;
            B = (31*M-32)/48;
        otherwise
            N = 4 - 6/sqrt(2*M);
            Gp = 1 + 1/sqrt(2*M) + 1/(3*M);
            B = (31*M-32)/48;
    end
    SNR = B*erfcinv((BER*log2(M)*2)/(Gp*N)).^2;        
end