function [lambda,H] = ProbShaping_getLambda(nBpS_gross,M_PS,OH_FEC)

% Last Update: 07/04/2017


%% Input Parser
if nargin < 3
    OH_FEC = 0.2;
end

%% Get Lambda
nBpS_net = nBpS_gross / (1 + OH_FEC);
H = nBpS_net + log2(M_PS)*(1-1/(1 + OH_FEC));
if H == log2(M_PS)
    lambda = 0;
else
    lambda = entropy2lambda(H,M_PS);
end
