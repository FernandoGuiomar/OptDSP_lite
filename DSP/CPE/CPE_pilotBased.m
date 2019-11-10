function [Srx,phi] = CPE_pilotBased(Srx,Stx,nSpS,CPE)

% Last Update: 04/11/2019


%% Input Parameters
[nPol,nSamples] = size(Srx);
nTaps = CPE.nTaps;

%% If Signal is Oversampled, Perform Downsampling
ts0 = 1;
if isfield(CPE,'ts0')
    ts0 = CPE.ts0;
end
Srx_tmp = Srx(:,ts0:nSpS:end);

%% Synchronize and Extract Pilots
[~,~,Srx_PIL,Stx_PIL,pilot_idx] = pilotSymbols_rmv(Srx_tmp,Stx,CPE.PILOTS);

%% Calculate Phase Using Pilots
phi = zeros(nPol,nSamples/nSpS);
for n = 1:nPol
    F = Stx_PIL{n} .* conj(Srx_PIL{n});
    % Apply Moving Average to Average Out Noise:
    H = movmean(F,nTaps,2);
    % Unwrap the Phase:
    phi_CPE = unwrap(atan2(imag(H),real(H)),[],2);
    % Interpolate:
    phi(n,:) = interp1(pilot_idx{n},phi_CPE,1:nSamples/nSpS,...
        'linear','extrap');
end

%% Correct Carrier Phase
phi = rectpulse(phi',nSpS)';
Srx = Srx.*exp(1j*phi);
