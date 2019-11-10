function [Stx,txSyms,R_CCDM] = Tx_PS_CCDM_1quadrant(C,H,txBits)

% Last Update: 09/01/2019


%% Input Parameters
M = numel(C);
[nPol,nBits] = size(txBits);
nSyms = ceil(nBits/log2(M));

%% Assign Symbol Probability According to Maxwell-Boltzman Distribution
C_1quad = unique(abs(real(C)) + 1j*abs(imag(C)));
lambda = entropy2lambda(H,C_1quad);
symProb = exp(-lambda*abs(C_1quad).^2);
symProb = symProb/sum(symProb);

%% Initialize CCDM
[symProb,nBitsInfo,symFreq] = ccdm.initialize(symProb,nSyms);

%% Allocate Quadrant Bits and Shaped Bits
quadBitsIdx = [1:log2(M):nBits 2:log2(M):nBits];
quadBitsIdx = sort(quadBitsIdx);
shapedBitsIdx = setdiff(1:nBits,quadBitsIdx);
shapedBitsIdx = shapedBitsIdx(1:nBitsInfo);
R_CCDM = (nBitsInfo+numel(quadBitsIdx))/nBits;

%% Encode with Distribution Matcher
[Stx,txSyms] = deal(NaN(nPol,nSyms));
for n = 1:nPol
    i_TX = ccdm.encode(txBits(n,1:shapedBitsIdx),symFreq).' + 1;
    Stx(n,:) = C_1quad(i_TX).';
    quadBits = txBits(n,quadBitsIdx);
    quadSyms = bit2sym(quadBits,2);
    % Assign Quadrant According to Quadrant Bits:
    Stx(n,quadSyms == 1) = -conj(Stx(n,quadSyms == 1));
    Stx(n,quadSyms == 2) = -Stx(n,quadSyms == 2);
    Stx(n,quadSyms == 3) = conj(Stx(n,quadSyms == 3));
    txSyms(n,:) = signal2symbol(Stx(n,:),C);
end

