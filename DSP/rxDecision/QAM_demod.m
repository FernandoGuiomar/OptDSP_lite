function [Sout] = QAM_demod(Sin,txSignal,option)

% Last Update: 14/07/2016


%% Input Parser
if ~exist('option','var')
    option = 'fully-colapsed';
end

%% Input Parameters
switch option
    case 'fully-colapsed',
        txSignal = (round(txSignal*1e5)/1e5);
        % Sout = Sin.*conj(txSignal);
        Sout = Sin .* exp(-1j*angle(txSignal))./abs(txSignal) - 1;
    case 'separate-symbols',
        Sout = QAM_separateSymbols(Sin,txSignal);
    case 'separate-rings',
        Sout = QAM_separateRings(Sin,txSignal);
end

