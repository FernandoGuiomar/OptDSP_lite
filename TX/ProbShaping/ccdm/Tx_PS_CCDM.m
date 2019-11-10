function [Stx,txSyms,R_CCDM] = Tx_PS_CCDM(C,H,txBits)

% Last Update: 08/01/2019


%% Input Parameters
M = numel(C);
[nPol,nBits] = size(txBits);
nSyms = ceil(nBits/log2(M));

%% Assign Symbol Probability According to Maxwell-Boltzman Distribution
lambda = entropy2lambda(H,C);
symProb = exp(-lambda*abs(C).^2);

%% Initialize CCDM
[symProb,nBitsInfo,symFreq] = ccdm.initialize(symProb,nSyms);
R_CCDM = nBitsInfo/nBits;

%% Encode with Distribution Matcher
[Stx,txSyms] = deal(NaN(nPol,nSyms));
for n = 1:nPol
    i_TX = ccdm.encode(txBits(n,1:nBitsInfo),symFreq).' + 1;
    Stx(n,:) = C(i_TX).';
    txSyms(n,:) = i_TX.'-1;
end

