function [Srx_out,Stx_out,Srx_PIL,Stx_PIL,pilot_idx,SYNC] = ...
    pilotSymbols_rmv(Srx,Stx,PILOTS)

% Last Update: 04/11/2019


%% Input Parameters
nPol = size(Stx,1);

%% Synchronize Pilots
[A,B] = rat(PILOTS.rate);
if B-A > 1
    error('Current version of pilot-based CPE only supports rates of (N-1)/N');
end
[tmp,SYNC] = syncSignals_NxN(Stx,upsample(PILOTS.pilotSequence.',B).');
for n = 1:nPol
    pilot_idx{n} = find(tmp(n,:));
    nPilots(n) = numel(pilot_idx{n});
    lastPilot_idx(n) = pilot_idx{n}(end);
end

%% Resolve Different Number of Pilots Per Polarization
if any(nPilots-min(nPilots))
    [~,idx] = max(nPilots);
    lastPilot_idx = lastPilot_idx(idx);
    nPilots = min(nPilots);

    for n = 1:nPol
        pilot_idx{n} = pilot_idx{n}(1:nPilots);
    end

    Srx = Srx(:,1:lastPilot_idx-1);
    Stx = Stx(:,1:lastPilot_idx-1);
end
nSamples = size(Stx,2);

%% Extract Pilot Symbols to Separate Vectors
for n = 1:nPol
    Stx_PIL{n} = Stx(n,pilot_idx{n});
    Srx_PIL{n} = Srx(n,pilot_idx{n});
end

%% Remove Pilot Symbols
for n = 1:nPol
    Stx_out(n,:) = Stx(n,setdiff(1:nSamples,pilot_idx{n}));
    Srx_out(n,:) = Srx(n,setdiff(1:nSamples,pilot_idx{n}));
end

