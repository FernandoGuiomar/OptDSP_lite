function [Sout,I,Q] = QAM_separateSymbols(Sin,txSignal)

% Last Update: 05/07/2016


%% Input Parameters
txSignal = (round(txSignal*1e5)/1e5);
I = unique(real(txSignal));
Q = unique(imag(txSignal));

Sin = Sin .* exp(-1j*angle(txSignal));% - abs(txSignal);
% Sin = Sin .* exp(-1j*angle(txSignal))./abs(txSignal);

%% Separate QAM Symbols
for n = 1:numel(I)
    for k = 1:numel(Q)
        Sout{n,k} = Sin(real(txSignal)==I(n) & imag(txSignal)==Q(k));
    end
end

