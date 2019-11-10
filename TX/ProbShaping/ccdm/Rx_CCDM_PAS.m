function [rxBits] = Rx_CCDM_PAS(rxBits_afterFEC,PCS)

% Last Update: 29/03/2019


%% Input Parameters
nPol = size(rxBits_afterFEC,1);

idx_sign_perBlock = PCS.idx_sign;
idx_amp_I_perBlock = PCS.idx_amp_I;
idx_amp_Q_perBlock = PCS.idx_amp_Q;
idx_PAS_perBlock = sort([idx_sign_perBlock ...
    idx_amp_I_perBlock idx_amp_Q_perBlock]);
nBits_PAS_perBlock = numel(idx_PAS_perBlock);
[~,idx_sym] = sort(PCS.idx_sym+1);
nBits_info_perDM = PCS.nBits_info_DM;
nBits_info_perBlock = PCS.nBits_info_perBlock;
nBpS_perDM = PCS.nBpS_PAS;
nBpS = 2*nBpS_perDM + 2;
symFreq = PCS.symFreq;
CCDM_blockLength = PCS.blockLength;
nBits_DM_FEC_perBlock = CCDM_blockLength * nBpS;
nBits_afterFEC = length(rxBits_afterFEC);
nBlocks_CCDM = floor(nBits_afterFEC * PCS.rate / nBits_info_perBlock);
nBits = nBlocks_CCDM * nBits_info_perBlock;
rxBits = NaN(nPol,nBits);
nBits_afterFEC = nBlocks_CCDM * nBits_PAS_perBlock;
rxBits_afterFEC = rxBits_afterFEC(:,1:nBits_afterFEC);

%% Put rxBits Back Inside the PAS+FEC Frame
rxBits_DM_FEC = false(nPol,nBits_DM_FEC_perBlock*nBlocks_CCDM);
if nBlocks_CCDM > 1
    idx_PAS_perBlock = repmat(idx_PAS_perBlock,1,nBlocks_CCDM) + ...
        rectpulse([0:nBlocks_CCDM-1]*nBits_DM_FEC_perBlock,nBits_PAS_perBlock);
end
for n = 1:nPol
    rxBits_DM_FEC(n,idx_PAS_perBlock) = rxBits_afterFEC(n,:);
end

%% Decode with Distribution Dematcher
idx_bits_I = 1:2:nBits_info_perDM;
idx_bits_Q = 2:2:nBits_info_perDM;
idx_bits_sign = nBits_info_perDM+1:nBits_info_perBlock;
for n = 1:nPol
    for k = 1:nBlocks_CCDM
        c = (k-1)*nBits_info_perBlock;
        d = (k-1)*nBits_DM_FEC_perBlock;
        
        % Inverse CCDM Over I:
        shapedBits_I = rxBits_DM_FEC(n,idx_amp_I_perBlock + d);
        syms_PAS_I = bit2sym(shapedBits_I,nBpS_perDM);
        idx_I = idx_sym(syms_PAS_I+1)-1;
        rxBits_I = ccdm.decode(idx_I,symFreq,nBits_info_perDM/2);
        rxBits(n,idx_bits_I + c) = rxBits_I;
        
        % Inverse CCDM Over Q:
        shapedBits_Q = rxBits_DM_FEC(n,idx_amp_Q_perBlock + d);
        syms_PAS_Q = bit2sym(shapedBits_Q,nBpS_perDM);
        idx_Q = idx_sym(syms_PAS_Q+1)-1;
        rxBits_Q = ccdm.decode(idx_Q,symFreq,nBits_info_perDM/2);
        rxBits(n,idx_bits_Q + c) = rxBits_Q;
        
        % Retrieve Sign Bits:
        shapedBits_sign = rxBits_DM_FEC(n,idx_sign_perBlock + d);
        rxBits(n,idx_bits_sign + c) = shapedBits_sign;
    end
end


