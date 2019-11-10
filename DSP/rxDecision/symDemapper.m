function [DEMAPPER,Stx] = symDemapper(Srx,Stx,C,DEMAPPER)
%symDemapper     Demaps symbols and bits from transmitted and received signals
%   This function synchronizes the transmitted and received signals and 
%   applies symbol decoding and bit decoding. 
%
%   INPUTS:
%       Srx := received signal [nPol x nSamples]
%       Stx := transmitted signal [nPol x nSamples]
%       C   := array with the reference transmitted constellation [M x 1]
%       DEMAPPER := struct of demapper parameters, including the following
%           optional fields:
%           - normMethod := string identifying the method for decision.
%               Supported methods include:
%               - 'avgPower': normalizes Srx to the average power of Stx
%               - 'MMSE': normalizes Srx to minimize the MMSE of Srx-Stx
%               - 'minSER': normalizes Srx to minimize the SER after
%                   decoding (uses the fminbnd function)
%           - decoding := string identifying the demapper decoding method.
%               Currently supported methods include:
%               - 'normal': normal non-differential decoding;
%               - 'diff-quad': differential quadrand decoding.
%
%   OUTPUTS:
%       DEMAPPER := struct of decoder outputs, including the following
%       fields:
%           - txSyms := array of decoded transmitted symbols [nPol x nSyms]
%           - rxSyms := array of decoded received symbols [nPol x nSyms]
%           - txBits := array of decoded transmitted bits [nPol x nBits]
%           - rxBits := array of decoded received bits [nPol x nBits]
%           - scaleFactor := scale factor utilized for the decision grid
%           - C := reference constellation utilized for minimum Euclidean
%               distance decision
%           - SYNC := struct with synchronization parameters between Tx and
%           Rx signals
%
%
%   Author: Fernando Guiomar
%   Last Update: 17/07/2019

%% Input Parser
global PROG;
useGPU = PROG.useGPU;
% Check if input signal is valid. If not, return an error:
if any(any(isnan(Srx),2)) || ~all(sum(Srx,2))
    error('Error in Symbol Decoder: input signal is not valid!');
end
normMethod = 'MMSE';
use_centroids = false;
decoding = 'normal';
calc_LLR = true;
M = numel(C);
nBpS = log2(M);
applySYNC = false;
SYNC.method = 'complexField';
SYNC.debug = false;
normalizeTX = true;
getSymsRX = true;
if nargin == 4
    if isfield(DEMAPPER,'decoding')
        decoding = DEMAPPER.decoding;
    end
    if isfield(DEMAPPER,'normMethod')
        normMethod = DEMAPPER.normMethod;
    end
    if isfield(DEMAPPER,'use_centroids')
        use_centroids = DEMAPPER.use_centroids;
    end
    if isfield(DEMAPPER,'calc_LLR')
        calc_LLR = DEMAPPER.calc_LLR;
    end
    if isfield(DEMAPPER,'SYNC')
        if isfield(DEMAPPER.SYNC,'apply')
            applySYNC = DEMAPPER.SYNC.apply;
        end
        if isfield(DEMAPPER.SYNC,'method')
            SYNC.method = DEMAPPER.SYNC.method;
        end
        if isfield(DEMAPPER.SYNC,'debug')
            SYNC.debug = DEMAPPER.SYNC.debug;
        end
    end
    if isfield(DEMAPPER,'normalizeTX')
        normalizeTX = DEMAPPER.normalizeTX;
    end
    if isfield(DEMAPPER,'getSymsRX')
        getSymsRX = DEMAPPER.getSymsRX;
    end
end
nPol = size(Srx,1);
if size(C,2) == 1
    C = repmat(C,1,nPol);
end

%% Synchronize Tx with Rx Signal
if applySYNC
    [Stx,SYNC] = syncSignals_NxN(Srx,Stx,SYNC);
end

%% Normalize Stx to the Constellation Reference
if normalizeTX
    for n = 1:nPol
        C_u = (uniquetol(real(C(:,n)),1e-6) + ...
            1j*uniquetol(imag(C(:,n)),1e-6)).';
        Stx_u = uniquetol(real(Stx(n,:)),1e-6) + ...
            1j*uniquetol(imag(Stx(n,:)),1e-6);
        if numel(C_u) > numel(Stx_u)
            Stx_u = Stx_u(abs(Stx_u) == min(abs(Stx_u)));
            C_u = C_u(abs(C_u) == min(abs(C_u)));
        end
        fun = @(h) (h*Stx_u-C_u)*(h*Stx_u-C_u)';
        scaleFactor = fminsearch(fun,1);
        Stx(n,:) = Stx(n,:) * scaleFactor;
    end
end

%% Transmitted Symbols
txSyms = signal2symbol(Stx,C,[],useGPU);

%% Calculate Centroids of Rx Signal
if use_centroids
    for n = 1:nPol
        [centroids,Stx(n,:)] = getCentroids(Srx(n,:),Stx(n,:),C(:,n));
        C(:,n) = centroids.';
    end
end

%% Normalize Rx Signal
switch normMethod
    case 'avgPower'
        c = sqrt(mean(abs(Srx).^2,2) ./ mean(abs(Stx).^2,2));
    case 'MMSE'
        for n = 1:nPol
            fun = @(h) (h*Stx(n,:)-Srx(n,:))*(h*Stx(n,:)-Srx(n,:))';
            c(n) = fminsearch(fun,1);
        end
    case 'minSER'
        c0 = sqrt(mean(abs(Srx).^2,2) ./ mean(abs(Stx).^2,2));
%         options = optimset('Display','iter','PlotFcns',@optimplotfval);
        options = [];
        for n = 1:nPol
            c1(n) = fminsearch(@(h) getSER(Srx(n,:) / c0(n),...
                txSyms(n,:),h*C(:,n),useGPU),1,options);
            c(n) = c0(n) * c1(n);
        end
    otherwise
        c = ones(1,nPol);
end
for n = 1:nPol
    Stx(n,:) = Stx(n,:) * c(n);
    C(:,n) = C(:,n) * c(n);
end

%% Demap Rx Symbols
if getSymsRX
    rxSyms = signal2symbol(Srx,C,[],useGPU);
end

%% Calculate Noise Variance
if exist('DEMAPPER','var') && isfield(DEMAPPER,'N0')
    N0 = DEMAPPER.N0;
else
    N0 = getN0_MMSE(Stx,Srx);
end
Prx = var(Srx.');
N0 = N0 .* Prx;
SNR_dB = pow2db(Prx) - pow2db(N0);

%% Calculate LLRs
% for n = 1:nPol
%     qamDemod = comm.GeneralQAMDemodulator('BitOutput',true,...
%         'DecisionMethod',decisionMethod,...
%         'VarianceSource','Input port','Constellation',double(C(:,n)));
%     LLRs(:,n) = qamDemod(Srx(n,:).',N0(n));
% end

%% Calculate LLRs
if calc_LLR
    for n = 1:nPol
        % Calculate Symbol Probability:
        symProb = histcounts(txSyms(n,:),-0.5:1:M-0.5,'Normalization','prob').';
        % Calculate LLRs:
        LLRs(:,n) = LLR_eval(Srx(n,:),N0(n),C(:,n),symProb);
    end
end

%% Transmitted and Received Bits
if strcmp(decoding,'diff-quad')
    DEMAPPER.txBits = syms2bits_diffQuad(txSyms,nBpS);
    txSyms = bit2sym(DEMAPPER.txBits,nBpS);
    if getSymsRX
        DEMAPPER.rxBits = syms2bits_diffQuad(rxSyms,nBpS);
        rxSyms = bit2sym(DEMAPPER.rxBits,nBpS);
    end
else
    if ~mod(nBpS,1)
        DEMAPPER.txBits = sym2bit(txSyms,nBpS);
        if getSymsRX
            DEMAPPER.rxBits = sym2bit(rxSyms,nBpS);
        end
    else
        DEMAPPER.txBits = NaN;
        DEMAPPER.rxBits = NaN;
    end
end

%% Remove NaNs from LLRs (may happen when SNR is too high)
if calc_LLR
    if isnan(LLRs)
        LLRs(isnan(LLRs)) = -(DEMAPPER.txBits(isnan(LLRs))*2-1)*Inf;
    end
end

%% Output Demapper Struct
DEMAPPER.SYNC = SYNC;
DEMAPPER.txSyms = txSyms;
if getSymsRX
    DEMAPPER.rxSyms = rxSyms;
end
DEMAPPER.C = C;
DEMAPPER.scaleFactor = c;
if calc_LLR
    DEMAPPER.LLRs = LLRs;
end
DEMAPPER.N0 = N0;

end
%% Helper Functions
function SER = getSER(Srx,txSyms,C,useGPU)
    symsRx = signal2symbol(Srx,C,[],useGPU);
    SER = sum(symsRx~=txSyms)./numel(txSyms);
end

function xd = differential_decoding(x)
quad = sign(real(x))+1j*sign(imag(x));                                     % find quadrant of RX symbols
xd = x.*[quad(2:end,:);(1+1j)*ones(1,size(x,2))].*conj(quad).^2*(1+1j)/4;  % differentially-decode RX symbols
end