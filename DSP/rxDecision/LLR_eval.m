function [LLRs] = LLR_eval(Srx,N0,C,symProb)
%LLR_eval   Calculate the log-likelihood ratio (LLR) for soft-decision
%   This function evaluates the LLRs in the soft-decision of a received
%   signal, Srx, according to a reference transmitted constellation,
%   C,assuming circularly symmetric Gaussian noise statistics with variance
%   N0. 
%   This function also supports non-uniform modulation (probabilistic
%   shaping) in which the constellation points have different probabilities
%   of occurrence. 
%
%   INPUTS:
%   Srx     := received signal [1 x nSyms]
%   N0      := noise variance of Srx [1 x 1]
%   C       := reference constellation points [M x 1]
%   symProb := symbol probabilities of each constellation point [M x 1]
%
%   Note that Srx and C must be properly scaled (e.g. normalizing their
%   average power or minimizing their MMSE).
%
%   OUTPUTS:
%   LLRs    := vector of LLRs corresponding to each received sample 
%               [1 x nSyms]
%
%   Some auxiliary variables:
%   Xk_b: subset of constellation points that contain a bit "b" (0/1) in 
%           position k (out of nBpS bit positions)
%   Pk_b: symbol probabilities that correspond to each constellation point 
%           of subset Xk_b
%
%
%   Author: Fernando Guiomar
%   Last Update: 23/02/2019

%% Input Parameters
nSyms = size(Srx,2);
M = numel(C);
nBpS = log2(M);
bitMap = dec2bin(0:M-1,nBpS);
if nargin < 4
    symProb = ones(1,M);
end

%% Calculate LLRs
LLRs = NaN(nSyms*nBpS,1);
for n = 1:nBpS
    % Get Subsets Xk_b and Pk_b:
    idx = bitMap(:,n)=='0';
    Xk_0 = C(idx);
    Pk_0 = symProb(idx);
    idx = bitMap(:,n)=='1';
    Xk_1 = C(idx);
    Pk_1 = symProb(idx);
    % Calculate Numerator and Demominator of the Likelihood Ratio:
    A = zeros(1,nSyms);
    for k = 1:numel(Xk_0)
        A = A + exp(-abs(Srx-Xk_0(k)).^2/N0)*Pk_0(k);
    end
    B = zeros(1,nSyms);
    for k = 1:numel(Xk_1)
        B = B + exp(-abs(Srx-Xk_1(k)).^2/N0)*Pk_1(k);
    end
    % Calculate the Log-Likelihood Ratio:
    LLRs(n:nBpS:end) = -log(B./A);
end
