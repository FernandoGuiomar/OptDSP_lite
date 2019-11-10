function [EVM,EVM_sym,EVM_t] = EVM_eval(Srx,Stx,options)

% Last Update: 30/03/2019


%% Input Parser
tMem = 0;
calc_EVM_per_sym = false;
if nargin >= 3
    if isfield(options,'tMem')
        tMem = options.tMem;
    end
    if isfield(options,'calc_EVM_per_sym')
        calc_EVM_per_sym = options.calc_EVM_per_sym;
    end
end

%% Calculate Average EVM
EVM = sqrt(sum((abs(Srx-Stx).^2)) ./ sum(abs(Stx).^2)) * 100;

%% Calculate EVM per Symbol
EVM_sym = NaN;
if calc_EVM_per_sym
    allSyms = unique(Stx);
    % Calculate EVM per Symbol:
    EVM_sym = NaN(1,numel(allSyms));
    for n = 1:numel(allSyms)
        thisSym = allSyms(n);
        symRx = Srx(Stx == thisSym);
        symTx = Stx(Stx == thisSym);
        EVM_sym(n) = sqrt(mean(abs(symRx - symTx).^2)./mean(abs(Stx).^2));
    end
    EVM_sym = EVM_sym * 100;
end

%% Evaluate EVM Evolution in Time, with Averaging Memory
EVM_t = NaN;
if tMem
    EVM_t = sqrt(movmean(abs(Srx-Stx).^2./abs(Stx).^2,tMem)) * 100;
end
