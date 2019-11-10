function [Srx,phi] = CPE_BPS(Srx,Stx,nSpS,C,CPE)

% Last Update: 01/04/2019


%% Input Parser
if ~isfield(CPE,'decision')
    CPE.decision = 'DD';
end
if any(strcmp(CPE.decision,{'DA','data-aided','genie-aided'}))
    dataAided = true;
else
    dataAided = false;
end

%% Input Parameters
[nPol,nSamples] = size(Srx);
B = CPE.nTestPhases;                                                        % number of test phases
phiInt = CPE.angleInterval;                                                 % angle interval
nTaps = CPE.nTaps;                                                          % number of filter taps
applyUnwrap = true;
if isfield(CPE,'applyUnwrap')
    applyUnwrap = false;
end

%% If Signal is Oversampled, Perform Downsampling
Srx_CPE = Srx;
if nSpS > 1
    nSamples = nSamples/nSpS;
    if isfield(CPE,'ts0')
        Srx_CPE = Srx(:,CPE.ts0:nSpS:end);
    else
        Srx_CPE = Srx(:,1:nSpS:end);
    end
end

%% Apply Blind Phase Search
phi = zeros(nPol,nSamples);
d = zeros(B+1,nSamples);
unwrapFactor = 2*pi/phiInt;
for n = 1:nPol
    if dataAided
        Sref = Stx(n,:);
    end
    for b = 0:B
        phiTest = (b/B-1/2)*phiInt;
        Srot = Srx_CPE(n,:).*exp(1j*phiTest);
        if ~dataAided
            Sref = symbol2signal(signal2symbol(Srot,C),C);
        end
        err = abs(Srot-Sref).^2;
        d(b+1,:) = movmean(err,nTaps);
    end
    [~,ind] = min(d);
    phi(n,:) = -((ind-1)/B-1/2)*phiInt;
    if applyUnwrap
        phi(n,:) = unwrap(phi(n,:)*unwrapFactor)/unwrapFactor;
    end
end

%% Correct Carrier Phase
Srx = Srx.*exp(-1j*rectpulse(phi',nSpS)');
