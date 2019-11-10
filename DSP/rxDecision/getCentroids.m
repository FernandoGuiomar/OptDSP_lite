function [centroids,Stx_centroids,sigma2,P_symb,symIdx] = ...
    getCentroids(Srx,Stx,C,debug)

% Last Update: 07/08/2019


%% Input Parser
if nargin < 4
    debug = false;
end

%% Input Parameters
nSamples = size(Srx,2);
Stx_centroids = NaN(1,nSamples);
M = numel(C);
[centroids,sigma2] = deal(NaN(1,M));

%% Synchronize Tx and Rx Signals
x = signal2symbol(Stx,C);
symIdx = bsxfun(@eq,int16(x),(0:M-1).');                                 % indexes of this point
P_symb = sum(squeeze(symIdx),2)/nSamples;

for k = 1:M                                                            % for all transmitted symbols
    Srx_sym = Srx(symIdx(k,:));                                                % get received points relative to i-th TX symbol
    centroids(k) = mean(Srx_sym);                                         % calculate centroid
    Stx_centroids(symIdx(k,:)) = centroids(k);
    sigma2(k) = var(Srx_sym)+eps;                                         % calculate variance (never to zero)
end

%% Debug
if debug
    plot(real(Stx),imag(Stx),'ob');
    hold on;
    plot(real(Stx_centroids),imag(Stx_centroids),'xr');
    legend('Tx Signal','Centroids from Rx Signal',...
        'Location','NorthOutside');
    axis square
end
