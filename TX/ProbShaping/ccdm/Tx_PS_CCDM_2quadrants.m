function [Stx,txSyms,R_CCDM] = Tx_PS_CCDM_2quadrants(C,lambda,txBits)

% Last Update: 29/11/2018


%% Input Parameters
M = numel(C);
[nPol,nBits] = size(txBits);
nSyms = ceil(nBits/log2(M));

%% Assign Symbol Probability According to Maxwell-Boltzman Distribution
C_2quad = unique(abs(real(C)) + 1j*imag(C));
lambda = entropy2lambda(5.1633,C_2quad);
symProb = exp(-lambda*abs(C_2quad).^2);
symProb = symProb/sum(symProb);

% idx = find(real(C) > 0);
% symProb = symProb(idx);
% symProb = symProb * 2;

% Approximate Symbol Probability:
% [symProb] = PS_approxPDF(symProb,4);

% symProb = rectpulse(symProb,2);

% symProb(33:64) = 1e-3;
% symProb = symProb/sum(symProb);

%% Initialize CCDM
[symProb,nBitsInfo,symFreq] = ccdm.initialize(symProb,nSyms);

%% Allocate Quadrant Bits and Shaped Bits
quadBitsIdx = 1:log2(M):nBits;
shapedBitsIdx = setdiff(1:nBits,quadBitsIdx);
shapedBitsIdx = shapedBitsIdx(1:nBitsInfo);
R_CCDM = (nBitsInfo+numel(quadBitsIdx))/nBits;

%% Encode with Distribution Matcher
[Stx,txSyms] = deal(NaN(nPol,nSyms));
for n = 1:nPol
    i_TX = ccdm.encode(txBits(n,shapedBitsIdx),symFreq).' + 1;
    Stx(n,:) = C_2quad(i_TX).';
    quadBits = txBits(n,quadBitsIdx);
    % Assign Quadrant According to Quadrant Bits:
%     Stx(n,quadBits == 1) = -conj(Stx(n,quadBits == 1));
    txSyms(n,:) = signal2symbol(Stx(n,:),C);
end

