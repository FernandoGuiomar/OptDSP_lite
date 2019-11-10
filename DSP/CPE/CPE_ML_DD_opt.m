function [Sout,CPE] = CPE_ML_DD_opt(Srx,Stx,C,CPE)
%CPE_ML_DD_opt  Optimized Decision-Directed Maximum Likelihood
%               Carrier-Phase Estimation
%
%   This function implements a decision-directed (DD) maximum likelihood
%   (ML) carrier-phase estimation (CPE) algorithm with optimized number of
%   taps to minimize the symbol error-rate (SER). The number of taps is
%   optimized using the fminbnd function to minimize the SER. 
% 
%   INPUTS:
%   Srx     :=  input signal vector [nPol x nSamples]
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
% [1] Xiang Zhou, "An Improved Feed-Forward Carrier Recovery Algorithm for 
% Coherent Receivers With M-QAM Modulation Format", vol.22, no.14, 2010.
%
%
%   Author: Fernando Guiomar
%   Last Update: 02/05/2019

global SER_CPE nTaps_CPE

%% Input Parameters
[nPol,nSamples] = size(Srx);
H = zeros(nPol,nSamples);
nTapsMin = CPE.nTaps_min;
nTapsMax = CPE.nTaps_max;
CPE.decision = 'DD';
nTaps_CPE = [];
SER_CPE = [];

%% Obtain Transmitted Symbols
C = C * sqrt(mean(abs(Stx(1,:)).^2)/mean(abs(C).^2)); 
txSyms = signal2symbol(Stx,C);

%% Obtain Reference Signal for DD-CPE
C = C * sqrt(mean(abs(Srx(1,:)).^2)/mean(abs(C).^2)); 
Sref = symbol2signal(signal2symbol(Srx,C),C);
F = Sref.*conj(Srx);

%% Optimize Number of Taps
options = optimset('Display','iter','PlotFcns',@optimplotfval);
[nTaps_opt] = fminbnd(@(nTaps) CPE_ML_DD_minBER(Srx,txSyms,F,...
    C,nTaps,H),nTapsMin,nTapsMax);%,options);

%% Apply ML-DA-CPE With Optimum Number of Taps
nTaps_opt = round(nTaps_opt);
[Sout,CPE.phi] = CPE_ML_DD(Srx,F,nTaps_opt,H);

%% Output CPE Parameters
[nTaps_CPE,idx] = unique(nTaps_CPE);
SER_CPE = SER_CPE(idx);
CPE.nTaps_opt = nTaps_opt;
CPE.SER_iter = SER_CPE;
CPE.nTaps_iter = nTaps_CPE;

end


%% Auxiliar Functions
function [Sout,phi] = CPE_ML_DD(Sin,F,nTaps,H)
    W = ones(1,nTaps);
    for m = 1:size(H,1)
        H(m,:) = conv(F(m,:),W,'same');
    end
    phi = atan(imag(H)./real(H));
    Sout = Sin.*exp(1j*phi);
end

function SERxy = CPE_ML_DD_minBER(Sin,txSyms,F,C,nTaps,H)
    global SER_CPE nTaps_CPE
    nTaps = round(nTaps);
    Sout = CPE_ML_DD(Sin,F,nTaps,H);
    
    rxSyms = signal2symbol(Sout,C);
    for n = 1:size(txSyms,1)
        SER(n) = SER_eval(txSyms,rxSyms);
    end
    SERxy = mean(SER);
    
    SER_CPE = [SER_CPE SERxy];
    nTaps_CPE = [nTaps_CPE nTaps];
end
