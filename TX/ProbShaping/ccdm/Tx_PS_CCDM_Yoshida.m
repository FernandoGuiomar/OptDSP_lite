function [Stx,txSyms,R_CCDM] = Tx_PS_CCDM_Yoshida(C,txBits)

% Last Update: 29/11/2018


%% Input Parameters
M = numel(C);
[nPol,nBits] = size(txBits);
nSyms = ceil(nBits/log2(M));

%% Assign Symbol Probability According to Maxwell-Boltzman Distribution
C_I = unique(abs(real(C)));
% C_I2 = C_I;
C_I2 = C_I(1:2:end);
lambda = entropy2lambda(1.583333,C_I2);
symProb = exp(-lambda*abs(C_I2).^2);
symProb = symProb/sum(symProb);

H = entropy_eval(symProb);

% idx = find(real(C) > 0);
% symProb = symProb(idx);
% symProb = symProb * 2;
% symProb(33:64) = 0;

%% Initialize CCDM
[symProb,nBitsInfo,symFreq] = ccdm.initialize(symProb,nSyms);

%% Allocate Quadrant Bits and Shaped Bits
% quadBitsIdx = 1:log2(M):nBits;
quadBitsIdx = [1:log2(M):nBits 2:log2(M):nBits];
quadBitsIdx = sort(quadBitsIdx);

LSB_I_idx = log2(M)-1:log2(M):nBits;
LSB_Q_idx = log2(M):log2(M):nBits;

shapedBits_idx = setdiff(1:nBits,quadBitsIdx);
shapedBits_idx = shapedBits_idx(1:nBitsInfo*2);

shapedBitsI_idx = shapedBits_idx(1:2:end);
shapedBitsQ_idx = shapedBits_idx(2:2:end);

%% Encode with Distribution Matcher
[Stx,txSyms] = deal(NaN(nPol,nSyms));
for n = 1:nPol
    idx_I = ccdm.encode(txBits(n,shapedBitsI_idx),symFreq).' + 1;
    idx_Q = ccdm.encode(txBits(n,shapedBitsQ_idx),symFreq).' + 1;
    
    idx_I = idx_I*2;
    idx_Q = idx_Q*2;
%     
    LSB_I_bits = txBits(n,LSB_I_idx);
    idx_I(LSB_I_bits==1) = idx_I(LSB_I_bits==1)-1;
    LSB_Q_bits = txBits(n,LSB_Q_idx);
    idx_Q(LSB_Q_bits==1) = idx_Q(LSB_Q_bits==1)-1;
    
    Stx(n,:) = C_I(idx_I).' + 1j*C_I(idx_Q).';
    quadBits = txBits(n,quadBitsIdx);
    quadSyms = bit2sym(quadBits,2);
    % Assign Quadrant According to Quadrant Bits:
    Stx(n,quadSyms == 1) = -conj(Stx(n,quadSyms == 1));
    Stx(n,quadSyms == 2) = -Stx(n,quadSyms == 2);
    Stx(n,quadSyms == 3) = conj(Stx(n,quadSyms == 3));
    txSyms(n,:) = signal2symbol(Stx(n,:),C);
end


R_CCDM = (numel(shapedBitsI_idx) + numel(shapedBitsQ_idx)) / (numel(Stx)*4);
