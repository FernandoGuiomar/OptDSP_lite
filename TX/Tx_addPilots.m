function [Stx,PILOTS] = Tx_addPilots(Stx,PILOTS,C)

% Last Update: 31/03/2019


%% Input Parser
if isfield(PILOTS,'option')
    pilotOption = PILOTS.option;
else
    pilotOption = 'meanQPSK';
end

%% Input Parameters
[nPol,nSyms] = size(Stx);
pilotRate = PILOTS.rate;
meanP = mean(abs(Stx(:)).^2);

%% Calculate Symbol Indices for Tx Pilots and Payload
[A,B] = rat(pilotRate);
idx_pilots = A+1:B;
nAB = floor(nSyms/A);
nPilots = numel(idx_pilots);
idx_pilots = repmat(idx_pilots,1,nAB) + ...
    B*(rectpulse(1:nAB,nPilots) - 1);
nPilots = numel(idx_pilots);
nSyms_withPilots = nSyms + nPilots;
idx_payload = setdiff(1:nSyms_withPilots,idx_pilots);
idx_pilots = repmat(idx_pilots,nPol,1);
idx_payload = repmat(idx_payload,nPol,1);

%% Generate Pilot Symbols
switch pilotOption
    case 'outerQPSK'
        C_pilot = C(abs(C) == max(abs(C)));
    case 'innerQPSK'
        C_pilot = C(abs(C) == min(abs(C)));
    case 'meanQPSK'
        C_pilot = C(abs(C) == max(abs(C)));
        C_pilot = C_pilot * sqrt(meanP) / ...
            sqrt(mean(abs(C_pilot).^2));
    case 'customQPSK'
        C_pilot = C(abs(C) == max(abs(C)));
        C_pilot = C_pilot * sqrt(meanP) / ...
            sqrt(mean(abs(C_pilot).^2)) * PILOTS.scaleFactor;
end
C_pilot = C_pilot.';
Stx_pilot = C_pilot(randi(numel(C_pilot),[nPol nPilots]));

%% Add Pilot Symbols to the Transmitted Signal
Stx_pilots = NaN(nPol,nSyms_withPilots);
for n = 1:nPol
    Stx_pilots(n,idx_pilots(n,:)) = Stx_pilot(n,:);
    Stx_pilots(n,idx_payload(n,:)) = Stx(n,:);
end
Stx = Stx_pilots;

%% Assign PILOTS Parameters
PILOTS.pilotSequence = Stx_pilot;
PILOTS.idx = idx_pilots;

