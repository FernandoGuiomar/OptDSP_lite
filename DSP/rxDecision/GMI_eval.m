function [GMI,NGMI] = GMI_eval(Srx,txBits,C,N0,symProb,useGPU)
%GMI_eval   Estimate the generalized mutual information (GMI) in AWGN
%           channels
%   This function evaluates the GMI from the received signal and the
%   transmitted bits, considering AWGN channel statistics.
%   This function also supports non-uniform modulation (probabilistic
%   shaping) in which the constellation points have different probabilities
%   of occurrence. 
%
%   INPUTS:
%   Srx     := received signal [1 x nSyms]
%   txBits  := vector of transmitted bits [1 x nBits]
%   C       := reference constellation points [M x 1]
%   N0      := noise variance of Srx [1 x 1]
%   symProb := symbol probabilities of each constellation point [M x 1]
%   useGPU  := flag to decide whether to use or not GPU-based processing
%
%   Note that Srx and C must be properly scaled (e.g. normalizing their
%   average power or minimizing their MMSE).
%
%   OUTPUTS:
%   GMI     := average generalized mutual information [1 x 1]
%   NGMI    := normalized generalized mutual information [1 x 1]
%
%
%   Author: Fernando Guiomar
%   Last Update: 04/06/2019

%% Cast to Single (for increased speed)
% Srx = single(Srx);
% C = single(C);
% N0 = single(N0);
% if nargin >= 5
%     symProb = single(symProb);
% else
%     symProb = single(ones(1,numel(C)));
% end

%% Transfer Variable to GPU
if nargin < 6
    useGPU = false;
end
if nargin < 5
    symProb = repmat(1/numel(C),numel(C),1);
end
if useGPU
    Srx = gpuArray(Srx);
    C = gpuArray(C);
    N0 = gpuArray(N0);
    symProb = gpuArray(symProb);
    txBits = gpuArray(txBits);
end

%% Input Parameters
nSyms = size(Srx,2);
M = numel(C);
nBpS = log2(M);
bMap = false(M,nBpS);
for n = 0:M-1
    [~,e] = log2(n);
    bMap(n+1,:) = rem(floor(n * pow2(1-max(e,nBpS):0)),2);
end

%% Evaluate Channel Transition Probability
C = exp(-abs(Srx-C).^2/N0).*repmat(symProb,1,numel(Srx));
B = sum(C,1);

%% Calculate LLRs
Z = zeros(1,nSyms);
if useGPU
    Z = gpuArray(Z);
end
for n = 1:nBpS
    idx = bMap(:,n)==txBits(n:nBpS:n+(nSyms-1)*nBpS);
    Z = Z + log2(B./(sum(C .* idx)));
end
G = mean(Z);

%% Evaluate GMI
Hx = entropy_eval(symProb);
GMI = Hx - G;

%% Normalized GMI
NGMI = 1 - (Hx-GMI)/nBpS;

%% Gather Variables from GPU
if useGPU
    GMI = gather(GMI);
    NGMI = gather(NGMI);
end
