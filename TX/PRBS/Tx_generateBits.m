function [txBits] = Tx_generateBits(nSyms,M,nPol,BIT)

% Last Update: 03/10/2018


%% Set Default Bit Source
if nargin < 4 || ~isfield(BIT,'source')
    BIT.source = 'randi';
end

%% Generate Tx Bits
nBits = floor(nSyms*log2(M));
txBits = NaN(nPol,nBits);
switch BIT.source
    case 'randi'
        if isfield(BIT,'seed')
            rng(BIT.seed);
        end
        for n = 1:nPol
            txBits(n,:) = randi(2,1,nBits)-1;
        end
    case 'PRBS'
        for n = 1:nPol
            prbs = PRBS_generator(1,nextpow2(nBits),BIT.seed+n-1);
            txBits(n,:) = prbs(1:nBits);
        end
    case 'PRBS-QAM'
        txBits = QAM_PRBSgenerator(BIT,M,nPol,nSyms);
end
txBits = logical(txBits);
