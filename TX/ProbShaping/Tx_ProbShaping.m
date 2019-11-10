function [Stx,txSyms,QAM] = Tx_ProbShaping(txBits,QAM,SIG,R_FEC)

% Last Update: 15/10/2019


%% Input Parser
% Set Default Shaping Method:
if ~isfield(QAM,'PCS') || ~isfield(QAM.PCS,'method')
    QAM.PCS.method = 'CCDM';
end
% Set Default FEC Rate:
if nargin < 4 || isempty(R_FEC)
    R_FEC = 1;
end

%% Impact of FEC on the PAS Scheme
nBpS = SIG.nBpS;
C = QAM.IQmap;
M_PS = numel(C);
flag = false;
if mod(log2(M_PS),1)
    M_PS = 2^nextpow2(M_PS);
    if mod(sqrt(M_PS),1)
        M_PS = 2^nextpow2(M_PS+1);
    end
    flag = true;
end
H_quad = (1-R_FEC)*log2(M_PS);
R_FEC_min = (log2(M_PS) - 2) / log2(M_PS);
if H_quad > 2
    error(['PAS scheme requires to allocate FEC bits to quadrant ',...
        'positions, whose maximum entropy is 2 bits/symbol. ',...
        'With the requested FEC rate of ',num2str(R_FEC,'%1.2f'),...
        ', the required entropy for FEC bits is ',...
        num2str(H_quad,'%1.2f'),', which exceeds the 2 bits/sym limit!',...
        ' Consider increasing the FEC rate. The minimum FEC rate '...
        'allowed for this system is (log2(M)-2)/log2(M)',...
        num2str(R_FEC_min,'%1.4f'),'.']);
end
H_PAS = nBpS * R_FEC + H_quad;
H_DM = H_PAS - 2;
H_PS = nBpS * R_FEC;

%% Apply Distribution Matcher
[Stx,txSyms,QAM.R_CCDM] = Tx_PS_CCDM(C,H_PAS,txBits);

%%
if flag
    QAM.M = M_PS;
    QAM.IQmap = qammod(0:M_PS-1,M_PS,'gray').';
    txSyms = signal2symbol(Stx,QAM.IQmap);
    nBpS = log2(M_PS);
    bMap = false(M_PS,nBpS);
    for n = 0:M_PS-1
        [~,e] = log2(n);
        bMap(n+1,:) = rem(floor(n * pow2(1-max(e,nBpS):0)),2);
    end
    QAM.sym2bitMap = bMap;
    QAM.nBpS = log2(M_PS);
end

%% Set QAM Parameters
QAM.maxConstPower = max(abs(Stx).^2);
QAM.meanConstPower = mean(abs(Stx).^2);
QAM.maxConstPower = max(abs(Stx).^2);
edges = -0.5:1:QAM.M-0.5;
QAM.symProb = histcounts(txSyms(:),edges,'Normalization','prob').';
tmp = log2(QAM.symProb);
tmp(isinf(tmp)) = 0;
QAM.entropy = -sum(QAM.symProb.*tmp);

%% Debug
% RGB = fancyColors;
% plotProbShaping_PDF_const('const',QAM.IQmap,...
%     'symbols',txSyms(:),'color',RGB.itred);
% plotConstMap(QAM.IQmap,QAM.sym2bitMap,QAM.symProb);

