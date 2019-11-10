function [Srx,phi0] = CPE_BPS_Simplified(Srx,Stx,nSpS,C,CPE)

% Last Update: 29/03/2018


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
Lw = CPE.nPhaseSplit;  % number of test phases
phiInt = CPE.angleInterval;                                                 % angle interval
nTaps = CPE.nTaps;                                                          % number of filter taps

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
unwrapFactor = 2*pi/phiInt;

phi0 = zeros(nPol,nSamples);
phi1 = zeros(nPol,nSamples);
phi2 = zeros(nPol,nSamples);
err = zeros(Lw,nSamples);
errV2 = zeros(Lw,nSamples);
Dist = zeros(Lw,nSamples);
DistV2 = zeros(Lw,nSamples);
DistPh = zeros(Lw,nSamples);
angVet = zeros(Lw,nSamples);
angVetA = zeros(Lw,nSamples);
angSplit = zeros(1,Lw);

for n = 1:nPol
    
    err(1:Lw,1:nSamples) = 0;
    errV2(1:Lw,1:nSamples) = 0.5;
    la = phiInt/Lw;
    for k=1:Lw
        angVetA(k,:) = (k-1)*la+la/2;
        angVet(k,:) = (k-1)*la+la/2;
        angSplit(k) = (k-1)*la+la/2;
    end

    for k = 1:nSamples
        [Cref, angIntv, angDiff]  = DC16QAM( C, Srx_CPE(n,k),Lw );       
        Lvar = length(angDiff);      
        angSplit(angIntv) = angDiff;
        
        for r = 1:Lvar
          Xrot = Srx_CPE(n,k)*exp(1j*angDiff(r));
          errV2(angIntv(r),k) = abs(Xrot-Cref(r)).^2;
        end
        
        for r = 1:Lw
          Xrot = Srx_CPE(n,k)*exp(1j*angSplit(r));
          [~,indCref] = min(abs(Cref-Xrot)); 
          Xref = Cref(indCref);
          err(r,k) = abs(Xrot-Xref).^2;
          angVet(r,k) = angSplit(r);
          angVetA(r,k) = min(abs(angle(Xrot)-(angle(Cref))));  
        end
    end
    for k = 1:Lw
        Dist(k,:) = movmean(err(k,:),nTaps);
        DistV2(k,:) = movmean(errV2(k,:),nTaps);
        DistPh(k,:) = movmean(abs(angVetA(k,:)),nTaps);
    end
    
    [~,indv0] = min(Dist);
    [~,indv1] = min(DistV2);
    [~,indv2] = min(DistPh);
    
    for k = 1:nSamples
        phi0(n,k) = angVet(indv0(k),k);
        phi1(n,k) = angVet(indv1(k),k);
        phi2(n,k) = angVet(indv2(k),k);
    end
    
    phi0(n,:) = -unwrap(phi0(n,:)*unwrapFactor)/unwrapFactor;    
    phi1(n,:) = -unwrap(phi1(n,:)*unwrapFactor)/unwrapFactor;
    phi2(n,:) = -unwrap(phi2(n,:)*unwrapFactor)/unwrapFactor;
    phi0(n,:)=movmean(phi0(n,:),nTaps);
    phi1(n,:)=movmean(phi1(n,:),nTaps);
    phi2(n,:)=movmean(phi2(n,:),nTaps);
end
%% Correct Carrier Phase
Srx = Srx.*exp(-1j*rectpulse(phi2',nSpS)');