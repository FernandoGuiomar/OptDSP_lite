function BER = snr2ber(varargin)
%snr2ber    Determine the BER that theoretically corresponds to a given SNR
%   This function evaluates the theoretical BER that corresponds to a given
%   measured SNR over a AWGN channel. The conversion of SNR into BER is
%   based on analytical formulas (approximate or exact) obtained from the
%   literature. Currently supported formats are:
%   mPSK (constant amplitude)
%   mPAM (amplitude modulation only)
%   mQAM (square QAM)
%   mQAM (cross QAM)
%   mQAM (rectangular)
%
%   INPUTS:
%   SNR_dB  :=  signal-to-noise ratio (dB) [nSNR1 x nSNR2]
%   M       :=  QAM constellation size [scalar, or 1 x 2 for rect-QAM]
%   mode_MF :=  modulation format mode:
%                   - 'QAM': m-ary quadrature amplitude modulation;
%                   - 'PSK': m-ary phase-shift keying;
%                   - 'PAM': m-ary pulse amplitude modulation
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
%                   - 'rect (exact)': rectangular m-ary QAM using exact
%                   analytical formulas;
%                   - 'rect (approx)': rectangular m-ary QAM using 
%                   approximate analytical formulas;
%   mode_SNR :=  mode for SNR measured values: 'Es' for energy per symbol
%   (default) and 'Eb' for energy per bit
%
%   Alternatively, snr2ber also accepts M and mode_MF to be parsed as
%   fields of a QAM struct:
%   M = QAM.M;
%   mode_MF = QAM.mode;
%   class_MF = QAM.class;
%
%   OUTPUTS:
%   BER     :=  bit-error-rate [nSNR1 x nSNR2]
%
%
%   Examples:
%       1) With numeric inputs:
%       BER_sqQAM_exact = snr2ber(10:20,64,'QAM','square')
%       BER_sqQAM_approx = snr2ber(10:20,64,'QAM','square (approx)')
%       BER_xQAM = snr2ber(10:20,32,'QAM','cross')
%       BER_rectQAM_exact = snr2ber(10:20,[8 4],'QAM','rect')
%       BER_rectQAM_approx = snr2ber(10:20,[8 4],'QAM','rect (approx)')
%
%       2) With QAM struct:
%       QAM = QAM_config('M',64)
%       BER_64QAM_exact = snr2ber(10:20,QAM)
%
%
%   Author: Fernando Guiomar
%   Last Update: 07/01/2018

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
    if nargin == 5
        mode_SNR = varargin{5};
    end
end
% Default option for mode_SNR:
if ~isfield('mode_SNR','var')
    mode_SNR = 'Es';
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

%% Convert to Linear Scale
SNR = 10.^(SNR_dB/10);

%% Calculate BER
switch mode_MF
    case {'PSK','mPSK'}
        BER = 1/log2(M) * erfc(sqrt(SNR)*sin(pi/M));
    case {'mPAM','PAM'}
        BER = snr2ber_PAM(M,SNR,mode_SNR);
    case {'QAM','mQAM'}
        switch class_MF
            case {'square (exact)','square'}
                BER = snr2ber_squareQAM_exact(M,SNR,mode_SNR);
            case {'square (approx)'}
                BER = snr2ber_squareQAM_approx(M,SNR,mode_SNR);
            case 'cross'
                BER = snr2ber_crossQAM(M,SNR,mode_SNR);
            case {'rect','rect (exact)'}
                BER = snr2ber_rectQAM_exact(M,SNR,mode_SNR);
            case {'rect (approx)'}
                BER = snr2ber_rectQAM_approx(M,SNR,mode_SNR);
        end
    otherwise
        error('Unknown modulation format.');
end
end

%% Auxiliary Functions
function BER = snr2ber_squareQAM_exact(M,SNR,mode_SNR)
    % K. Cho and D. Yoon, "On the General BER Expression of One-
    % and Two-Dimensional Amplitude Modulations," IEEE Trans. on
    % Communications, vol. 50, no. 7, 2002.
    N = log2(sqrt(M));
    Pb = zeros(size(SNR));
    if strcmp(mode_SNR,'Es')
        c = 1;
    elseif strcmp(mode_SNR,'Eb')
        c = log2(M);
    end
    for k = 1:N
        tmp = 0;
        for i = 0 : (1-2^(-k))*sqrt(M)-1
            tmp = tmp + (-1)^floor(i*2^(k-1)/sqrt(M)) * (2^(k-1)-...
                floor(i*2^(k-1)/sqrt(M)+1/2)) * ...
                erfc((2*i+1) * sqrt(3*c*SNR/(2*(M-1))));
        end
        Pb = Pb + 1/sqrt(M) * tmp;
    end
    BER = 1/N * Pb;
end


function BER = snr2ber_squareQAM_approx(M,SNR,mode_SNR)
    if strcmp(mode_SNR,'Es')
        c = 1;
    elseif strcmp(mode_SNR,'Eb')
        c = log2(M);
    end
    BER = 2/log2(M) * (1-1/sqrt(M)) * erfc(sqrt(3*c*SNR./(2*(M-1))));
end

function BER = snr2ber_crossQAM(M,SNR,mode_SNR)
    % P. K. Vitthaladevuni, M.-S. Alouini and J. C. Kieffer, "Exact
    % BER Computation for Cross QAM Constellations," IEEE Trans. on
    % Wireless Communications, vol. 4, no. 6, 2005. (see eqs. (2),
    % (5) and (40)).
    switch M
        case 8
            N = 3;
            Gp = 10/8;
            B = 1/(3+sqrt(3));
        case 32
            N = 4 - 6/sqrt(2*M);
            Gp = 7/6;
            B = 48/(31*M-32);
        otherwise
            N = 4 - 6/sqrt(2*M);
            Gp = 1 + 1/sqrt(2*M) + 1/(3*M);
            B = 48/(31*M-32);
    end
    if strcmp(mode_SNR,'Es')
        c = 1;
    elseif strcmp(mode_SNR,'Eb')
        c = log2(M);
    end
    BER = Gp * N/log2(M) * 1/2 * erfc(sqrt(B*c*SNR));
end


function BER = snr2ber_PAM(M,SNR,mode_SNR)
    N = log2(M);
    if strcmp(mode_SNR,'Es')
        c = 1;
    elseif strcmp(mode_SNR,'Eb')
        c = N;
    end
    for k = 1:N
        Pb = zeros(size(SNR));
        tmp = 0;
        for i = 0 : (1-2^(-k))*M-1
            tmp = tmp + (-1)^floor(i*2^(k-1)/M) * (2^(k-1)-...
                floor(i*2^(k-1)/M+1/2)) * ...
                erfc((2*i+1) * sqrt(3*c*SNR/(M^2-1)));
        end
        Pb = Pb + 1/M * tmp;
    end
    BER = 1/N * Pb;
end


function BER = snr2ber_rectQAM_exact(M,SNR,mode_SNR)
    % Calculate exact BER for Square-QAM, Cross-QAM, and 1D-PAM:
    I = M(1);
    J = M(2);
    if strcmp(mode_SNR,'Es')
        c = 1;
    elseif strcmp(mode_SNR,'Eb')
        c = log2(I*J);
    end
    % Calculate over 1st Dimension:
    Pb_I = zeros(size(SNR));
    for k = 1:log2(I)
        tmp = 0;
        for i = 0 : (1-2^(-k))*I-1
            tmp = tmp + (-1)^floor(i*2^(k-1)/I) * (2^(k-1)-...
                floor(i*2^(k-1)/I+1/2)) * ...
                erfc((2*i+1) * sqrt(3*c*SNR/(I^2+J^2-2)));
        end
        Pb_I = Pb_I + 1/I * tmp;
    end
    % Calculate over 1st Dimension:
    Pb_J = zeros(size(SNR));
    for k = 1:log2(J)
        tmp = 0;
        for i = 0 : (1-2^(-k))*J-1
            tmp = tmp + (-1)^floor(i*2^(k-1)/J) * (2^(k-1)-...
                floor(i*2^(k-1)/J+1/2)) * ...
                erfc((2*i+1) * sqrt(3*c*SNR/(I^2+J^2-2)));
        end
        Pb_J = Pb_J + 1/J * tmp;
    end
    BER = 1/log2(I*J) * (Pb_I + Pb_J);
end


function BER = snr2ber_rectQAM_approx(M,SNR,mode_SNR)
    % Calculate approximate BER for Square-QAM, Cross-QAM, and 1D-PAM:
    I = M(1);
    J = M(2);

    if strcmp(mode_SNR,'Es')
        c = 1;
    elseif strcmp(mode_SNR,'Eb')
        c = log2(I*J);
    end
    BER = 1/log2(I*J) * ((I-1)/I + (J-1)/J) * ...
        erfc(sqrt(3*c*SNR / (I^2+J^2-2)));                    
end
