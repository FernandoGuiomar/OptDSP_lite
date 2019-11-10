function [Srx,CPE] = CPE_BPS_DD_opt(Srx,Stx,nSpS,C,CPE)

% Last Update: 09/11/2019


%% Input Parameters
nTapsMin = CPE.nTaps_min;
nTapsMax = CPE.nTaps_max;
CPE.decision = 'DD';

%% Optimize Number of Taps
options = optimset('MaxFunEvals',1e4,'TolX',5e-1,'TolFun',1e-2);%,...
%     'Display','iter','PlotFcns',@optimplotfval);
[nTaps_opt,opt_FOM] = fminbnd(@(nTaps) BPS_DD_minFOM(Srx,Stx,nSpS,...
    C,CPE,nTaps),nTapsMin,nTapsMax,options);

%% Apply ML-DA-CPE With Optimum Number of Taps
CPE.nTaps = round(nTaps_opt);
[Srx,CPE.phi] = CPE_BPS(Srx,[],nSpS,C,CPE);

%% Output CPE Parameters
CPE.nTaps_opt = nTaps_opt;
CPE.FOM_error = opt_FOM;

end

%% Auxiliar Functions
function opt_FOM = BPS_DD_minFOM(Srx,Stx,nSpS,C,CPE,nTaps)
    nTaps = round(nTaps);
    CPE.nTaps = nTaps;
    Srx = CPE_BPS(Srx,[],nSpS,C,CPE);
    var_FOM = zeros(1,size(Srx,1));
    for m = 1:size(Srx,1)
        Scolapsed = QAM_demod(Srx(m,1:nSpS:end),Stx(m,:),'fully-colapsed');
        var_FOM(m) = var(imag(Scolapsed))/var(real(Scolapsed));
    end
    opt_FOM = abs(1 - mean(var_FOM));    
end

function SERxy = BPS_DD_minSER(Sin,Stx,nSpS,C,CPE,nTaps)
    nTaps = round(nTaps);
    CPE.nTaps = nTaps;
    Srx = CPE_BPS(Sin,[],nSpS,C,CPE);
    
    DEMAPPER.normMethod = 'MMSE';
    DEMAPPER.decoding = 'diff-quad';
    DEMAP = symDemapper(Srx,Stx,C,DEMAPPER);
    
    SER = SER_eval(DEMAP.txSyms,DEMAP.rxSyms);
    SERxy = SER.SERxy;
end

