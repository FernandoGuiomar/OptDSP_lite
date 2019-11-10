function [TX_sync,SYNC] = syncSignals_NxN(RX,TX,SYNC)

% Last Update: 04/11/2019


%% Input Parser
% Check for Sync Method and Debug Flag:
SYNC_method = 'complexField';
debug = false;
avoidSingularity = true;
if nargin == 3
    if isfield(SYNC,'method')
        SYNC_method = SYNC.method;
    end
    if isfield(SYNC,'debug')
        debug = SYNC.debug;
    end
    if isfield(SYNC,'avoidSingularity')
        avoidSingularity = true;
    end
end
SYNC.method = SYNC_method;

%% Input Parameters
nPol = size(RX,1);

%% Test all Synchronization Combinations
polRot = false(1,nPol);
for n = 1:nPol
    for k = 1:nPol
        [tmp{n,k},D(n,k),G(n,k),R(n,k)] = syncSignals(RX(n,:),TX(k,:),SYNC);
    end
end

%% Choose Best Synchronization
% Find maximum synchronization strength among all polarizations:
[idx(1),idx(2)] = find(G == max(G(:)));
TX_sync(idx(1),:) = tmp{idx(1),idx(end)};
syncPoint(idx(1)) = D(idx(1),idx(end));
if ~isempty(diff(idx)) && abs(diff(idx)) > 0
    polRot(idx(1)) = true;
end
% Synchronize the other polarization(s):
if avoidSingularity && nPol == 2
    polRot(idx(2)) = polRot(idx(1));
    idx(1) = mod(idx(1),2) + 1;
    idx(2) = mod(idx(2),2) + 1;
    TX_sync(idx(1),:) = tmp{idx(1),idx(2)};
    syncPoint(idx(1)) = D(idx(1),idx(2));
else
    for n = 1:nPol
        if n ~= idx(1)
            [~,idx_new] = max(G(n,:));
            TX_sync(idx_new,:) = tmp{n,idx_new};
            syncPoint(idx_new) = D(n,idx_new);
            polRot(idx_new) = idx_new~=n;
        end
    end
end

%% Output SYNC Struct
SYNC.syncPoint = syncPoint + 1;
SYNC.G = G;
SYNC.delay = D;
SYNC.rotation = R;
SYNC.polRotation = polRot;

%% Debug plots
if debug
    hold on;
    for n = 1:nPol
        for k = 1:nPol
            xCorrPlot(RX(n,:),TX(k,:),SYNC_method);
            lgdString = ['Tx[',num2str(k),']->Rx[',num2str(n),']'];
            legend(lgdString);
        end
    end
end
