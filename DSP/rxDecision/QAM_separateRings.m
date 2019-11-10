function [Sout,R] = QAM_separateRings(Sin,txSignal)

% Last Update: 14/07/2016


%% Input Parameters
txSignal    = (round(txSignal*1e5)/1e5);
R           = unique(abs(txSignal));

%% Remove Phase Modulation
Sin = Sin .* exp(-1j*angle(txSignal));

%% Separate QAM Symbols
for n = 1:numel(R)
    Sout{n} = Sin(abs(txSignal)==R(n));
end

