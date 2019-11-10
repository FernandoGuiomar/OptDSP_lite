function [Stx,txSyms,txBits,FEC] = LDPC_encoder_QAM(txBits,FEC,C)

% Last Update: 09/11/2019


%% Input Parameters
[nPol,nBits] = size(txBits);
nBpS = log2(numel(C));
R_FEC = FEC.rate;

%% Initialize LDPC Encoder
parityCheckMatrix = dvbs2ldpc(R_FEC);
LDPC_enc = comm.LDPCEncoder(parityCheckMatrix);
[nRows,nCols] = size(LDPC_enc.ParityCheckMatrix);
LDPC_blockLength = nCols - nRows;
LDPC_nBlocks = nBits/LDPC_blockLength;

%% Truncate txBits to Guarantee Integer Number of Symbols
flag = true;
while flag
    LDPC_nBlocks = nBits/LDPC_blockLength;
    nSyms = nBits/nBpS;
    if LDPC_nBlocks - floor(LDPC_nBlocks) < 1e-6 && ... 
        nSyms - floor(nSyms) < 1e-6
        flag = false;
    else
        nBits = nBits - 1;
    end
end
txBits = txBits(:,1:nBits);

%% Apply LDPC Encoder
idx_FEC = [];
for k = 1:LDPC_nBlocks
    idx_block = (k-1)*LDPC_blockLength+1:k*LDPC_blockLength;
    idx_enc = (k-1)*nCols+1:k*nCols;
    for n = 1:nPol
        encBits(n,idx_enc) = LDPC_enc(txBits(n,idx_block)')';
    end
    idx_FEC = [idx_FEC idx_enc(LDPC_blockLength+1:end)];
end

%% Convert Bits to Symbols
txSyms = bit2sym(encBits,nBpS);

%% Convert Symbols to Transmitted Signal
Stx = symbol2signal(txSyms,C);

%% Output Parameters
FEC.LDPC_enc = LDPC_enc;
FEC.idx = idx_FEC;
