function [DECODER] = SC_rxDECODER(DEMAPPER,BIT,FEC,PCS)

% Last Update: 09/11/2019


%% Entrange Message
entranceMsg('BIT DECODER');
tic

%% Input Parser
if nargin == 4
    isPCS = true;
else
    isPCS = false;
end

%% Input Parameters
PCM_FEC = FEC.LDPC_enc.ParityCheckMatrix;
LDPC_blockLength = size(PCM_FEC,2);
nIter_FEC = FEC.nIter;
idx_FEC = FEC.idx;
LLRs = DEMAPPER.LLRs.';
if isPCS
    txBits_afterFEC = BIT.txBits_afterPAS;
else
    txBits_afterFEC = BIT.txBits_afterFEC;
end

%% Rx Decoder
if isPCS
    txBits = DEMAPPER.txBits;
    % Synchronize Bits:
    [txBits,LLRs,idx_FEC,SYNC] = FEC_syncBits(txBits,...
        LLRs,idx_FEC,txBits_afterFEC,LDPC_blockLength);
    % Apply FEC Decoder:
    rxBits_afterFEC = LDPC_decoder(LLRs.',PCM_FEC,idx_FEC,nIter_FEC);
    nBits_afterFEC = length(rxBits_afterFEC);
    % Apply Inverse Distribution Matcher:
    DECODER = PAS_bitReceiver(BIT.txBits,rxBits_afterFEC,PCS);
    
    txBits_afterFEC = txBits(:,setdiff(1:length(txBits),idx_FEC));
    DECODER.txBits_afterFEC = txBits_afterFEC(:,1:nBits_afterFEC);
    DECODER.rxBits_afterFEC = rxBits_afterFEC;
    DECODER.SYNC = SYNC;
else
    rxBits_afterFEC = LDPC_decoder(LLRs.',PCM_FEC,idx_FEC,nIter_FEC);
    nBits_afterFEC = length(rxBits_afterFEC);
    DECODER.txBits_afterFEC = txBits_afterFEC(:,1:nBits_afterFEC);
    DECODER.rxBits_afterFEC = rxBits_afterFEC;
end

%% Elapsed Time
elapsedTime = toc;
myMessages(['Bit Decoder - Elapsed Time: ',...
    num2str(elapsedTime,'%1.4f'),' [s]\n'],1);
