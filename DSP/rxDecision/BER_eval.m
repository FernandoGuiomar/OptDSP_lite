function [BER,errPos,BER_sym] = BER_eval(txBits,rxBits,BER_sym_eval,M)

% Last Update: 31/03/2019


%% Input Parser
if nargin < 3 || nargout < 3
    BER_sym_eval = false;
end
if BER_sym_eval
    if nargin < 4
        warning('\nTo calculate the BER per symbol you must parse an additional argument, M (constellation size), to the BER_val function. BER calculation per symbol will be skipped.\n');
        BER_sym_eval = false;
    end
end

%% Input Parameters
nBits = length(txBits);

%% Evaluate BER
errPos = find(xor(txBits,rxBits));
nBitErr = numel(errPos);
BER = nBitErr / nBits;

%% Evaluate BER per Symbol
BER_sym = NaN;
if BER_sym_eval
    txSyms = rectpulse(bit2sym(txBits,log2(M)).',log2(M)).';
    allSyms = unique(txSyms);
    BER_sym = NaN(1,numel(allSyms));
    for n = 1:numel(allSyms)
        thisSym = allSyms(n);
        txBits_sym = txBits(txSyms == thisSym);
        rxBits_sym = rxBits(txSyms == thisSym);
        nBits_sym = length(txBits_sym);
        errPos_sym = find(xor(txBits_sym,rxBits_sym));
        nBitErr_sym = numel(errPos_sym);
        BER_sym(n) = nBitErr_sym/nBits_sym;
    end
end
