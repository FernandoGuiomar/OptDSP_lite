function [rxBits,nBlocks] = LDPC_decoder(LLRs,PCM_FEC,idx_FEC,nIter_FEC)

% Last Update: 09/11/2019


%% Input Parameters
[nBits,nPol] = size(LLRs);

%% Initialize LDPC Decoder
ldpcDec = comm.LDPCDecoder(PCM_FEC,'MaximumIterationCount',nIter_FEC);
[OH_blockLength,LDPC_blockLength] = size(PCM_FEC);
nBlocks = floor(nBits / LDPC_blockLength);
PL_blockLength = LDPC_blockLength - OH_blockLength;

%% Isolate FEC Overhead and Payload
OH = LLRs(idx_FEC,:);
PL = LLRs(setdiff(1:nBits,idx_FEC),:);

%% Apply LDPC Decoder
upd = textprogressbar(nBlocks,'updatestep',1,...
    'startmsg','Applying LDPC Decoding... ',...
    'endmsg','Done!','showactualnum',true);
for k = 1:nBlocks
    idx_PL = (k-1)*PL_blockLength+1:k*PL_blockLength;
    idx_OH = (k-1)*OH_blockLength+1:k*OH_blockLength;
    for n = 1:nPol
        theseLLRs = [PL(idx_PL,n); OH(idx_OH,n)];
        rxBits(idx_PL,n) = ldpcDec(theseLLRs);    
    end
    upd(k);
end
rxBits = rxBits.';
