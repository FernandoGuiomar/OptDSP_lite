function [Sout,phi] = CPE_ML(Sin,Stx,C,CPE)

% Last Update: 02/02/2019


% [1] Xiang Zhou, "An Improved Feed-Forward Carrier Recovery Algorithm for 
% Coherent Receivers With M-QAM Modulation Format", vol.22, no.14, 2010.

%% Input Parser
if ~isfield(CPE,'decision')
    CPE.decision = 'DD';
end

%% Input Parameters
[nPol,nSamples] = size(Sin);
nTaps = CPE.nTaps;

%% Normalize Input Signal
Sin = normSignalPower(Sin,mean(abs(C).^2),true);

%% Reference Signal
switch CPE.decision
    case {'data-aided','dataAided','DA','PN-0'}
        Sref = Stx;
    case {'decision-directed','decisionDirected','DD','decision-feedback','DF'}
        Sref = symbol2signal(signal2symbol(Sin,C),C);
    case {'PN-receiver','PN'}
        Sref = Stx;
        S_DD = symbol2signal(signal2symbol(Sin,C),C);
    otherwise
        error('Invalid CPE sub-method!');
end

%% Maximum Likelihood Phase Estimation
F = Sref.*conj(Sin);
if any(strcmp(CPE.decision,{'PN','PN-receiver','PN-receiver-DD'}))
    F_DD = S_DD.*conj(Sin);
end
switch CPE.convMethod
    case {'sum','vector'}
        H = zeros(nPol,nSamples);
        % ProgressBar Initialization:
        progressbar(['CPE-ML: current sample (',num2str(nSamples-nTaps),' in total)']);
        % Filtering Stage:
        if any(strcmp(CPE.decision,{'PN','PN-receiver','PN-receiver-DD'}))
            for n = ceil(nTaps/2):nSamples-floor(nTaps/2)
                H(:,n) = sum([F(:,n+floor(nTaps/2):-1:n+1) ...
                    F_DD(:,n)...
                    F(:,n-1:-1:n-ceil(nTaps/2)+1)],2);
                % ProgressBar:
                progressbar((n-ceil(nTaps/2)+1)/(nSamples-nTaps+1));
            end
        elseif any(strcmp(CPE.decision,{'PN-receiver-0','PN-0'}))
            for n = ceil(nTaps/2):nSamples-floor(nTaps/2)
                H(:,n) = sum([F(:,n+floor(nTaps/2):-1:n+1) ...
                    F(:,n-1:-1:n-ceil(nTaps/2)+1)],2);
                % ProgressBar:
                progressbar((n-ceil(nTaps/2)+1)/(nSamples-nTaps+1));
            end
        else
            for n = ceil(nTaps/2):nSamples-floor(nTaps/2)
                H(:,n) = sum(F(:,n+floor(nTaps/2):-1:n-ceil(nTaps/2)+1),2);
                % ProgressBar:
                progressbar((n-ceil(nTaps/2)+1)/(nSamples-nTaps+1));
            end
        end
        % Calculate the Phase:
        phi = -atan(imag(H)./real(H));
    case {'filter','conv'}
        H = zeros(nPol,nSamples);
        W = ones(1,nTaps);
        for m = 1:nPol
            H(m,:) = conv(F(m,:),W,'same');
        end
        phi = -atan(imag(H)./real(H));
end

%% Correct Carrier Phase
Sout = Sin.*exp(-1j*phi);

