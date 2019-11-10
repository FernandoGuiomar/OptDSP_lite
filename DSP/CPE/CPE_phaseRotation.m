function [Aout,phi] = CPE_phaseRotation(Ain,C,CPE)

% Last Update: 02/02/2019


%% Input Parameters
[nPol,nSamples] = size(Ain);
phi = zeros(nPol,1);
nRadius = numel(unique(abs(C)));

%% Input Parser
if nRadius ~= 1
    if ~isfield(CPE,'QAM_classes')
        CPE.QAM_classes = 'A';
    end
    if ~isfield(CPE,'p')
        CPE.p = 1;
    end
    if ~isfield(CPE,'demodQAM')
        CPE.demodQAM = 'QPSKpartition';
    end
end

%% Fixed Phase Rotation
for n = 1:nPol
    if nRadius ~= 1
        Ap = ringPartitionQAM(Ain(n,:),C);
        M = numel(C);
        A = classPartitionQAM(Ap,M,CPE.QAM_classes);
        A = demodQAM_4thPower(A,M,CPE.p);
        A = A.A1(~isnan(A.A1));
    else
        A = Ain(n,:).^4;
    end
    A = mean(A);
    phi(n) = atan2(imag(A),real(A));
    phi(n) = unwrap(phi(n)')'/4-pi/4;
end

%% Correct Carrier Phase
Aout = zeros(nPol,nSamples);
for n = 1:nPol
    Aout(n,:) = Ain(n,:)*exp(-1j*phi(n));
end
