function [txBits_demap,LLRs,idx_FEC,SYNC] = FEC_syncBits(txBits_demap,...
    LLRs,idx_FEC,txBits_afterPAS,LDPC_blockLength)

% Last Update: 09/11/2019


%% Expand TX Bits Reference to the Length of LLRs
TX = txBits_afterPAS*2-1;
nTX = length(TX);
RX = sign(LLRs);
nRX = length(RX);
nBlocks = floor(nRX/nTX);
remSamples = nRX - nBlocks*nTX;
TX = [repmat(TX,1,nBlocks) TX(:,1:remSamples)];

%% Find Sync Point
SYNC.method = 'complexField';
% SYNC.debug = true;
SYNC.minDelay = 0;
SYNC.maxDelay = nTX;
[~,SYNC] = SC_syncTxRx(TX,RX,1,SYNC);

%% Truncate LLRs and txBits to start in the first full FEC frame
delay = SYNC.syncPoint - 1;
nBlocksDelay = floor(delay/LDPC_blockLength);
remDelay = delay - nBlocksDelay*LDPC_blockLength;
syncPoint = (nBlocksDelay+1)*LDPC_blockLength - remDelay + 1;
LLRs = LLRs(:,syncPoint:end);
txBits_demap = txBits_demap(:,syncPoint:end);

nBits_perBlock = length(txBits_afterPAS);
nBlocks = floor(length(LLRs)/nBits_perBlock);
nTail = mod(length(LLRs),nBits_perBlock);
idx_FEC_all = [];
for n = 1:nBlocks
    idx_FEC_all = [idx_FEC_all idx_FEC + (n-1)*nBits_perBlock];
end
idx_FEC = [idx_FEC_all idx_FEC(idx_FEC<=nTail) + nBlocks*nBits_perBlock];
