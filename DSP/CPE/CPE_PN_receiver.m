function [Sout,phi] = CPE_PN_receiver(Sin,Stx,C,CPE)

% Last Update: 19/02/2018


% [1] Tobias Fehenberger et al, "Compensation of XPM Interference by Blind 
%Tracking of the Nonlinear Phase in WDM Systems with QAM Input", in Proc.
%ECOC 2015, paper ID: 0361, 2015.

%% Input Parameters
[nPol,nSamples] = size(Sin);
nTaps = CPE.nTaps;

%% Normalize Input Signal
Sin = normalizeSignal(Sin,mean(abs(C).^2),'joint');

%% Reference Signal
switch CPE.decision
    case {'data-aided','dataAided','DA'}
        Sref = Stx;
    case {'decision-directed','decisionDirected','DD','decision-feedback','DF'}
        Sref = symbol2signal(signal2symbol(Sin,C),C);
    otherwise
        error('Invalid CPE sub-method!');
end

%% Maximum Likelihood Phase Estimation
F = Sref.*conj(Sin);
switch CPE.convMethod
    case {'sum','vector'}
        H = ones(nPol,nSamples);
        % ProgressBar Initialization:
        progressbar(['CPE-PN receiver: current sample (',num2str(nSamples-nTaps),' in total)']);
        % Filtering Stage:
        for n = nTaps+1:nSamples
            H(:,n) = sum(F(:,n-1:-1:n-nTaps),2);
            % ProgressBar:
            progressbar((n-nTaps+1)/(nSamples-nTaps+1));
        end
        % Calculate the Phase:
        phi = atan(imag(H)./real(H));
    case {'filter','conv'}
        H = zeros(nPol,nSamples);
        W = ones(1,nTaps);
        % Filtering Stage:
        for m = 1:nPol
            H(m,:) = conv(F(m,:),W,'same');
        end
        % Calculate the Phase:
        phi = atan(imag(H)./real(H));
        
end

%% Correct Carrier Phase
Sout = Sin.*exp(1j*phi);

