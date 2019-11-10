function [Srx,CPE] = CPE_Viterbi_opt(Srx,Stx,nSpS,C,CPE)

% Last Update: 31/03/2019


%% Input Parameters
nTapsMin = CPE.nTaps_min;
nTapsMax = CPE.nTaps_max;

%%
% txSyms = signal2symbol(Stx,C);
% c = sqrt(mean(abs(Srx).^2,2) ./ mean(abs(Stx).^2,2));
% for n = 1:size(Stx,1)
%     Stx(n,:) = Stx(n,:) * c(n);
%     C(:,n) = C(:,n) * c(n);
% end

%% Optimize Number of Taps
options = optimset('MaxFunEvals',1e4,'TolX',5e-1,'TolFun',1e-2);%,...
%     'Display','iter','PlotFcns',@optimplotfval);
[nTaps_opt,opt_FOM] = fminbnd(@(nTaps) CPE_Viterbi_minFOM(Srx,...
    Stx,nSpS,C,CPE,nTaps),nTapsMin,nTapsMax,options);
% [nTaps_opt,opt_FOM] = fminbnd(@(nTaps) CPE_Viterbi_minSER(Srx,...
%     Stx,txSyms,nSpS,C,CPE,nTaps),nTapsMin,nTapsMax,options);

%% Apply Pilot-Based CPE With Optimum Number of Taps
CPE.nTaps(1) = round(nTaps_opt);
[Srx,CPE.phi] = CPE_Viterbi(Srx,Stx,nSpS,C,CPE);

%% Output CPE Parameters
CPE.nTaps_opt = nTaps_opt;
CPE.FOM_error = opt_FOM;

end

%% Aux Functions
function opt_FOM = CPE_Viterbi_minFOM(Srx,Stx,nSpS,C,CPE,nTaps)
    nTaps = round(nTaps);
    CPE.nTaps(1) = nTaps;
    Srx = CPE_Viterbi(Srx,Stx,nSpS,C,CPE);
    var_FOM = zeros(1,size(Srx,1));
    for m = 1:size(Srx,1)
        Scolapsed = QAM_demod(Srx(m,1:nSpS:end),Stx(m,:),'fully-colapsed');
        var_FOM(m) = var(imag(Scolapsed))/var(real(Scolapsed));
    end
    opt_FOM = abs(1 - mean(var_FOM));    
end

function SER = CPE_Viterbi_minSER(Srx,Stx,txSyms,nSpS,C,CPE,nTaps)
    nTaps = round(nTaps);
    CPE.nTaps(1) = nTaps;
    Srx = CPE_Viterbi(Srx,Stx,nSpS,C,CPE);
    rxSyms = signal2symbol(Srx(1:nSpS:end),C);
    SER = sum(txSyms~=rxSyms)/numel(txSyms);
end