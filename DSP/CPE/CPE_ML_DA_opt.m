function [Sout,CPE] = CPE_ML_DA_opt(Sin,Stx,C,CPE)
%CPE_ML_DA_opt  Optimized Data-Aided Maximum Likelihood Carrier-Phase
%               Estimation
%   This functions implements a data-aided (DA) maximum likelihood (ML)
%   carrier-phase estimation (CPE) algorithm with optimized number of taps
%   to minimize the non-circularity of the constellation symbols. The
%   number of taps is optimized using the fminbd function to minimize 
%   |1 - FOM|
%
%   INPUTS:
%   Sin     :=  input signal vector [nPol x nSamples]
%   Stx     :=  transmitted signal [nPol x nSyms]
%   C       :=  transmitted constellation [M x 1]
%   CPE     :=  struct with CPE parameters. Required fields:
%               CPE.nTaps_min := minimum number of taps for optimization
%               CPE.nTaps_max := maximum number of taps for optimization
%
%   OUTPUTS:
%   Sout    :=  output signal vector [nPol x nSamples]
%   CPE     :=  struct with CPE parameters. New output fields are:
%               CPE.nTaps_opt := optimum number of taps
%               CPE.phi := vector of estimated phase noise [nPol x nSamples]
%
%
%   [1] Xiang Zhou, "An Improved Feed-Forward Carrier Recovery Algorithm for 
%   Coherent Receivers With M-QAM Modulation Format", vol.22, no.14, 2010.
%
%
%   Author: Fernando Guiomar
%   Last Update: 26/02/2018

%% Input Parameters
[nPol,nSamples] = size(Sin);
H = zeros(nPol,nSamples);
nTapsMin = CPE.nTaps_min;
nTapsMax = CPE.nTaps_max;
CPE.decision = 'DA';
M = numel(C);

%% Normalize Input Signal
Sin = normSignalPower(Sin,mean(abs(C).^2),true);
F = Stx.*conj(Sin);

%% Optimize Number of Taps
% options = optimset('Display','iter');%,'PlotFcns',@optimplotfval);
[nTaps_opt,opt_FOM] = fminbnd(@(nTaps) CPE_ML_DA_minFOM(Sin,Stx,F,...
    M,nTaps,H),nTapsMin,nTapsMax);%,options);

%% Apply ML-DA-CPE With Optimum Number of Taps
nTaps_opt = round(nTaps_opt);
[Sout,CPE.phi] = CPE_ML_DA(Sin,F,nTaps_opt,H);

%% Output CPE Parameters
CPE.nTaps_opt = nTaps_opt;
CPE.FOM_error = opt_FOM;

end


%% Auxiliar Functions for Maximum Likelihood Data-Aided CPE
function [Sout,phi] = CPE_ML_DA(Sin,F,nTaps,H)
    W = ones(1,nTaps);
    for m = 1:size(H,1)
        H(m,:) = conv(F(m,:),W,'same');
    end
    phi = atan(imag(H)./real(H));
    Sout = Sin.*exp(1j*phi);
end

function opt_FOM = CPE_ML_DA_minFOM(Sin,Sref,F,M,nTaps,H)
    nTaps = round(nTaps);
    Sout = CPE_ML_DA(Sin,F,nTaps,H);
    OUT = QAM_varianceAnalyzer(Sout,Sref,M);
    opt_FOM = abs(1 - mean(OUT.var_FOM));
end
