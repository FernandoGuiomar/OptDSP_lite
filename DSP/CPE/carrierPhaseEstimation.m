function [Srx,CPE] = carrierPhaseEstimation(Srx,Stx,CPE,C,nSpS)

% Last Update: 09/11/2019


%% Input Parser
CPE = presetCPE('CPE',CPE);
if nargin < 5
    nSpS = 1;
end

%% Check if a Preset Phase Compensation is Available
if isfield(CPE,'phi')
    Srx = Srx.*exp(-1j*rectpulse(CPE.phi',nSpS)');
end

%% Normalize Constellation to the Signal Power
if nargin >= 4
    C = C * sqrt(mean(abs(Srx(1,:)).^2)/mean(abs(C).^2)); 
end

%% Select and Apply CPE Method
switch CPE.method
    case {'pilot-based'}
        [Srx,CPE.phi] = CPE_pilotBased(Srx,Stx,nSpS,CPE);
    case {'pilot-based:optimized'}
        [Srx,CPE] = CPE_pilotBased_opt(Srx,Stx,nSpS,CPE);
    case {'Viterbi','Viterbi&Viterbi','V&V','VV'}
        [Srx,CPE.phi] = CPE_Viterbi(Srx,Stx,nSpS,C,CPE);
    case {'VV:optimized'}
        [Srx,CPE] = CPE_Viterbi_opt(Srx,Stx,nSpS,C,CPE);
    case {'MaximumLikelihood','Maximum-Likelihood','maxLike','ML','MLPE'}
        [Srx,CPE.phi] = CPE_ML(Srx,Stx,C,CPE);
    case {'DA-ML:optimized'}
        [Srx,CPE] = CPE_ML_DA_opt(Srx,Stx,C,CPE);
    case {'DD-ML:optimized'}
        [Srx,CPE] = CPE_ML_DD_opt(Srx,Stx,C,CPE);
    case {'PN','PN receiver'}
        [Srx,CPE.phi] = CPE_PN_receiver(Srx,Stx,C,CPE);
    case {'decision-directed','DecisionDirected','DD'}
        [Srx,CPE.phi] = CPE_decisionDirected(Srx,nSpS,C,CPE);
    case {'blind phase-search','blindPhaseSearch','BPS'}
        [Srx,CPE.phi] = CPE_BPS(Srx,Stx,nSpS,C,CPE);
    case {'DD-BPS:optimized','BPS:optimized'}
        [Srx,CPE] = CPE_BPS_DD_opt(Srx,Stx,nSpS,C,CPE);
    case {'BPS_Simp'}
        [Srx,CPE.phi] = CPE_BPS_Simplified(Srx,Stx,nSpS,C,CPE);
        %[Srx,CPE.phi] = CPE_BPS_ModV0(Srx,Stx,nSpS,C,CPE);
    case 'phaseRotation'
        [Srx,CPE.phi] = CPE_phaseRotation(Srx,C,CPE);
    case 'none'
        CPE.phi = 0;
    otherwise
        error('Unsupported CPE method!');
end
