function [Stx,txSyms,PCS] = Tx_PS_CCDM_PAS(C,M,H_DM,R_FEC,PCS,txBits)
%Tx_PS_CCDM_PAS     Apply the Probabilistic Amplitude Shaping (PAS) scheme
%
%   This function applies the PAS scheme using the Constant Composition 
%   Distribution Matcher (CCDM) together with an SD-FEC based on DVBS2 LPDC. 
%
%   INPUTS:
%   C       := constellation symbols of the PCS template [M x 1]
%   M       := size of the PCS template [1 x 1]
%   H_DM    := entropy requested to the distribution matcher [1 x 1]
%   R_FEC   := FEC rate [1 x 1]
%   PCS     := PCS struct with the following mandatory fields:
%               - PCS.blockLength: request block-length of each DM
%   txBits  := transmitted bit-stream [1 x nBits]
%
%   OUTPUTS:
%   Stx     := transmitted constellation symbols after PAS [1 x nSyms]
%   txSyms  := transmitted symbols indices [1 x nSyms]
%   PCS     := PCS struct with the following output fields:
%               - PCS.nBlocks_DM: total number of DM blocks
%               - PCS.idx_sign: indices for sign bit positions
%               - PCS.idx_amp_I: indices for in-phase amplitude bit
%                   positions
%               - PCS.idx_amp_Q: indices for quadrature amplitude bit
%                   positions
%               - PCS.idx_sym: ordering of the symbols within the
%                   constellation space, C
%               - PCS.symFreq: frequency (number of occurrences) of each
%                   symbol
%               - PCS.nBits_info_DM: number of information bits per DM
%                   block
%               - PCS.nBits_info_perBlock: number of information bits
%                   contained within each DM block + information sign bits
%               - PCS.nBits_info_total: total number of information bits
%                   contained in all DM blocks (PCS.nBlocks_DM *
%                   PCS.nBits_info_perBlock)
%               - PCS.nBpS_PAS: number of bits per symbol at the output of
%                   each DM (I and Q separately)
%               - PCS.shapedBits: stream of shaped bits after PAS
%               - PCS.rate_CCDM: rate of the CCDM
%               - PCS.rate: total rate of the PAS scheme
%               - PCS.FEC.rate: rate of the FEC
%               - PCS.FEC.LPDC_enc: object with the LPDC encoder properties
%               - PCS.FEC.idx: indices of the FEC parity bits
%
%
%   Author: Fernando Guiomar
%   Last Update: 25/04/2019

%% Input Parameters
nBpS = log2(M);
nBpS_PAS = (nBpS-2)/2;
[nPol,nBits_info] = size(txBits);
H_FEC = (1-R_FEC) * nBpS;
% H_PAS_sign = 2 - H_FEC;
% H_PAS = H_DM + H_PAS_sign;
% R_PAS = H_DM / (nBpS-2);
H_DM_I = H_DM/2;
CCDM_blockLength = PCS.blockLength;

%% Initialize LDPC Encoder
parityCheckMatrix = dvbs2ldpc(R_FEC);
LDPC_enc = comm.LDPCEncoder(parityCheckMatrix);
[nRows,nCols] = size(LDPC_enc.ParityCheckMatrix);
LDPC_blockLength = nCols - nRows;

%% Assign Symbol Probability According to Maxwell-Boltzman Distribution
C_I = unique(abs(real(C)));
lambda = entropy2lambda(H_DM_I,C_I);
symProb = exp(-lambda*abs(C_I).^2);
symProb = symProb/sum(symProb);

%% Find Correct Ordering of Symbols
if numel(C) ~= M
    C = qammod(0:M-1,M,'gray').';
    C_I = unique(abs(real(C)));
end
for n = 1:numel(C_I)
    bit = sym2bit(find(real(C) == C_I(n))-1,nBpS);
    idx_sym(n) = bit2sym(bit(1,2:nBpS_PAS+1),nBpS_PAS);
end

%% Find CCDM Block Length That Allows a Correct PAS Indexation
flag = true;
while flag
    nBits_CCDM = CCDM_blockLength * nBpS;
    CCDM_nBlocks_perLDPC = nCols/nBits_CCDM;
    nBits_CCDM = nCols/CCDM_nBlocks_perLDPC;
    if CCDM_nBlocks_perLDPC - floor(CCDM_nBlocks_perLDPC) < 1e-6 && ...
            nBits_CCDM - floor(nBits_CCDM) < 1e-6
        flag = false;
    else
        CCDM_blockLength = CCDM_blockLength - 1;
    end
    if CCDM_blockLength < 1
        error('Could not find a valid CCDM block length that allows for correct indexation of the PAS scheme!');
    end
end

%% Initialize CCDM
[~,nBits_info_I,symFreq] = ccdm.initialize(symProb,CCDM_blockLength);
nBits_info_DM = 2*nBits_info_I;

nBits_PAS_amp = nBits_CCDM * (nBpS-2)/nBpS;
nBits_PAS_I = nBits_PAS_amp/2;
nBits_sign = nBits_CCDM - nBits_PAS_amp;
nBits_FEC = round(nBits_sign * H_FEC/2);
nBits_PAS_sign = nBits_sign - nBits_FEC;
nBits_PAS = nBits_PAS_amp + nBits_PAS_sign;
nBits_info_perBlock = nBits_info_DM + nBits_PAS_sign;

CCDM_nBlocks = floor(nBits_info/nBits_info_perBlock);
LDPC_nBlocks = floor(CCDM_nBlocks / CCDM_nBlocks_perLDPC);
CCDM_nBlocks = LDPC_nBlocks * CCDM_nBlocks_perLDPC;
nBits_PAS_info = CCDM_nBlocks * nBits_info_perBlock;
nBits_withFEC = LDPC_nBlocks * nCols;
% nBits_afterPAS_noFEC = LDPC_nBlocks * LDPC_blockLength;

%% Truncate Tx Bits to Fit Inside CCDM_nBlocks_perLDPC * LDPC_nBlocks
txBits = txBits(:,1:nBits_PAS_info);

%% Place FEC Parity Bits in Quadrant Positions
% Identify quadrant bits:
idx_quad = [1:nBpS:nBits_CCDM nBpS/2+1:nBpS:nBits_CCDM];
idx_quad = sort(idx_quad);
% Identify amplitude bits:
idx_PAS_amp = setdiff(1:nBits_CCDM,idx_quad);
idx_I = repmat(1:nBpS_PAS,1,nBits_PAS_I/nBpS_PAS) + ...
    rectpulse(0:2*nBpS_PAS:2*(nBits_PAS_I-1),nBpS_PAS);
idx_Q = setdiff(1:nBits_PAS_amp,idx_I);

idx_PAS_amp_I = idx_PAS_amp(idx_I);
idx_PAS_amp_Q = idx_PAS_amp(idx_Q);
% Distribute FEC parity bits evenly over the available sign bits:
[a,b] = rat(H_FEC/2);
idx_PAS_sign = cumsum(histcounts(1:b,a));
nBins_sign = numel(idx_PAS_sign);
nRep = floor(nBits_PAS_sign / nBins_sign);
idx_PAS_sign = repmat(idx_PAS_sign,1,nRep) + ...
    rectpulse(0:b:nRep*b-1,nBins_sign);
tail = cumsum(histcounts(1:b,a)) + nRep*b;
nTail = nBits_PAS_sign - numel(idx_PAS_sign);
idx_PAS_sign = [idx_PAS_sign tail(1:nTail)];
idx_PAS_sign = idx_quad(idx_PAS_sign);

%% Encode with Distribution Matcher
shapedBits = NaN(nPol,nBits_withFEC);
idx_bits_I = 1:2:2*nBits_info_I;
idx_bits_Q = 2:2:2*nBits_info_I;
idx_bits_sign = 2*nBits_info_I+1:nBits_info_perBlock;
for n = 1:nPol
    for k = 1:CCDM_nBlocks
        c = (k-1)*nBits_info_perBlock;
        d = (k-1)*nBits_CCDM;
        
        % Apply PAS over I:
        idx_I = ccdm.encode(txBits(n,idx_bits_I + c),symFreq).' + 1;
        syms_PAS_I = idx_sym(idx_I);
        bits_PAS_I = sym2bit(syms_PAS_I,nBpS_PAS);
        shapedBits(n,idx_PAS_amp_I + d) = bits_PAS_I;

        % Apply PAS over Q:
        idx_Q = ccdm.encode(txBits(n,idx_bits_Q + c),symFreq).' + 1;
        syms_PAS_Q = idx_sym(idx_Q);
        bits_PAS_Q = sym2bit(syms_PAS_Q,nBpS_PAS);
        shapedBits(n,idx_PAS_amp_Q + d) = bits_PAS_Q;

        % Assign PAS over sign:
        shapedBits(n,idx_PAS_sign + d) = txBits(n,idx_bits_sign + c);
    end
end

%% Apply LDPC Encoder
% Group all payload bits (PAS over amplitude and sign):
idx_PAS_perBlock = sort([idx_PAS_amp idx_PAS_sign]);
idx_PAS = repmat(idx_PAS_perBlock,1,CCDM_nBlocks) + ...
    rectpulse([0:CCDM_nBlocks-1]*nBits_CCDM,nBits_PAS);
idx_PAS = idx_PAS(idx_PAS<=nBits_withFEC);

% Identify FEC parity bits:
idx_FEC = setdiff(1:nBits_withFEC,idx_PAS);

for n = 1:nPol
    bits_PL = shapedBits(n,:);
    bits_PL = bits_PL(~isnan(bits_PL));
    for k = 1:LDPC_nBlocks
        idx_block = (k-1)*LDPC_blockLength+1:k*LDPC_blockLength;
        idx_enc = (k-1)*nCols+1:k*nCols;
        idx_OH1 = (k-1)*nRows+1:k*nRows;
        idx_OH2 = k*nCols-nRows+1:k*nCols;
        encBits(n,idx_enc) = LDPC_enc(bits_PL(1,idx_block)')';
        bits_OH(n,idx_OH1) = encBits(n,idx_OH2);
    end
    shapedBits(n,idx_FEC) = bits_OH(n,:);
end

%% Convert Shaped Bits Into Symbols
shapedBits = logical(shapedBits);
txSyms = bit2sym(shapedBits,nBpS);

%% Generate the QAM Constellation
Stx = symbol2signal(txSyms,C);

%% Evaluate the CCDM Rate
nBitsOut = CCDM_blockLength*(log2(M)-2);
R_CCDM = nBits_info_DM / nBitsOut;
R_PAS = nBits_info_perBlock/nBits_CCDM;

%% PAS Outputs
PCS.nBlocks_DM = CCDM_nBlocks;
PCS.blockLength = CCDM_blockLength;
PCS.idx_sign = idx_PAS_sign;
PCS.idx_amp_I = idx_PAS_amp_I;
PCS.idx_amp_Q = idx_PAS_amp_Q;
PCS.idx_sym = idx_sym;
PCS.symFreq = symFreq;
PCS.nBits_info_DM = nBits_info_DM;
PCS.nBits_info_perBlock = nBits_info_perBlock;
PCS.nBits_info_total = nBits_PAS_info;
PCS.nBpS_PAS = nBpS_PAS;
PCS.shapedBits = shapedBits;
PCS.rate_CCDM = R_CCDM;
PCS.rate = R_PAS;

PCS.FEC.rate = R_FEC;
PCS.FEC.LDPC_enc = LDPC_enc;
PCS.FEC.idx = idx_FEC;

