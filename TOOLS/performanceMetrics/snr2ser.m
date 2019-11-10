function SER = snr2ser(varargin)
%snr2ber    Determine the SER that theoretically corresponds to a given SNR
%   This function evaluates the theoretical SER that corresponds to a given
%   measured SNR over a AWGN channel. The conversion of SNR into SER is
%   based on analytical formulas (approximate or exact) obtained from the
%   literature. Currently supported formats are:
%   mPSK (constant amplitude)
%   mPAM (amplitude modulation only)
%   mQAM (square QAM)
%   mQAM (cross QAM)
%   rectangular mQAM
%
%   INPUTS:
%   SNR_dB  :=  signal-to-noise ratio (dB) [nSNR1 x nSNR2]
%   M       :=  QAM constellation size [scalar, or 1 x 2 for rect-QAM]
%   mode_MF :=  modulation format mode:
%                   - 'QAM': m-ary quadrature amplitude modulation;
%                   - 'PSK': m-ary phase-shift keying;
%   class_MF :=  modulation format class (only for QAM mode):
%                   - 'square (approx)': square m-ary QAM using 
%                   approximate analytical formula;
%                   - 'square (exact)': square m-ary QAM using exact
%                   analyical formulas, as published in:
%                   https://doi.org/10.1109/TCOMM.2002.800818
%                   - 'cross': cross m-ary QAM using approximate 
%                   analytical formulas , as published in:
%                   https://doi.org/10.1109/TWC.2005.857997
%                   (see eqs. (2), (5) and (40)).
%                   - 'rect (approx)': rectangular m-ary QAM using 
%                   approximate analytical formulas;
%
%   Alternatively, snr2ser also accepts M and mode_MF to be parsed as
%   fields of a QAM struct:
%   M = QAM.M;
%   mode_MF = QAM.mode;
%   class_MF = QAM.class;
%
%   OUTPUTS:
%   SER     :=  bit-error-rate [nSNR1 x nSNR2]
%
%
%   Examples:
%       1) With numeric inputs:
%       SER_sqQAM_exact = snr2ser(10:20,64,'QAM','square')
%       SER_sqQAM_approx = snr2ser(10:20,64,'QAM','square (approx)')
%       SER_xQAM = snr2ser(10:20,32,'QAM','cross')
%       SER_rectQAM_approx = snr2ser(10:20,[8 4],'QAM','rect (approx)')
%
%       2) With QAM struct:
%       QAM = QAM_config('M',64)
%       SER_64QAM_exact = snr2ser(10:20,QAM)
%
%
%   Author: Fernando Guiomar
%   Last Update: 07/01/2019

%% Input Parser
if nargin < 2
    error('At least two input arguments are required for the ber2snr function.');
end
% Get SNR:
SNR_dB = varargin{1};
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

%% Convert to Linear Scale
SNR = 10.^(SNR_dB/10);

%% Calculate SER
switch mode_MF
    case {'PSK','mPSK'}
        SER = erfc(sqrt(SNR)*sin(pi/M));
    case {'QAM','mQAM'}
        switch class_MF
            case {'square (exact)','square'}
                if isfield(MF,'symProb')
                    P = MF.symProb;
                else
                    P = repmat(1/M,M,1);
                end
                C = MF.IQmap;
                SER = snr2ser_squareQAM_exact(C,P,SNR);
            case {'square (approx)'}
                SER = 2 * (1-1/sqrt(M)) * erfc(sqrt(3*SNR./(2*(M-1))));
            case {'cross', 'cross (approx)'}
                SER = snr2ser_crossQAM(M,SNR);
            case {'rect','rect (approx)'}
                I = M(1);
                J = M(2);
                SER = ((I-1)/I + (J-1)/J) * ...
                    erfc(sqrt(3*SNR / (I^2+J^2-2)));
        end
    otherwise
        error('Unknown modulation format.');
end
end

%% Auxiliary Functions:
function SER = snr2ser_squareQAM_exact(C,P,SNR)
    M = numel(C);
    A = mean(P.*abs(C).^2);
    B = mean(1/M.*abs(C).^2);
    PS_SNRgain = B/A;
    SNR = SNR*PS_SNRgain;

    idx_corner = abs(C) == max(abs(C));
    P_corner = P(idx_corner);
    idx_edge = (abs(real(C)) == max(abs(real(C)))) | ...
        (abs(imag(C)) == max(abs(imag(C))));
    idx_inside = ~idx_edge;
    P_inside = P(idx_inside);
    idx_other = idx_edge & ~idx_corner;
    P_other = P(idx_other);
    A = erfc(sqrt(3*SNR./(2*(M-1))));
    SER_corner = A - 1/4*A.^2;
    SER_inside = 2*A - A.^2;
    SER_other = 3/2*A - 1/2*A.^2;
    SER = sum(P_corner)*SER_corner + ...
        sum(P_inside)*SER_inside + sum(P_other)*SER_other;
end


function SER = snr2ser_crossQAM(M,SNR)
    % P. K. Vitthaladevuni, M.-S. Alouini and J. C. Kieffer, "Exact
    % BER Computation for Cross QAM Constellations," IEEE Trans. on
    % Wireless Communications, vol. 4, no. 6, 2005. (see eqs. (2),
    % (5) and (40)).
    switch M
        case 8
            N = 3;
            B = 1/(3+sqrt(3));
        case 32
            N = 4 - 6/sqrt(2*M);
            B = 48/(31*M-32);
        otherwise
            N = 4 - 6/sqrt(2*M);
            B = 48/(31*M-32);
    end
    SER = N/2 * erfc(sqrt(B*SNR));
end