function lambda = entropy2lambda(H,C)
%entropy2lambda     Convert entropy values to required shaping parameter,
%                   lambda using a pre-stored look-up table (LUT)
%   This function performs the conversion of query entropy points, H, into
%   the correspondent shaping parameter, lambda, required by probabilistic
%   shaping. The probability distribution function is assumed to be 
%   exp(-lambda*abs(C).^2).
%
%   INPUTS:
%       H := entropy values [1 x nEntropy]
%       M := size of the QAM constellation [scalar]
%
%   OUTPUTS:
%       lambda := shaping parameter [1 x nEntropy]
%
%
%   Examples:
%       lambda = entropy2lambda(3.5:0.1:4,64);
%
%
% Authors: Fernando Guiomar
% Last Update: 23/10/2017

%% Optimize lambda to Achieve Desired Entropy
options = optimset('MaxFunEvals',1e4,'TolX',1e-4,'TolFun',1e-4,...
    'Display','none','PlotFcns',[]);
[lambda,err] = fminsearch(@(lambda) fitMaxwellBoltzman(lambda,C,H),...
    0,options);

end

%% Maxwell-Boltzman Fitting Function
function err = fitMaxwellBoltzman(lambda,C,H)
    symProb = exp(-lambda*abs(C).^2);
    symProb = symProb/sum(symProb);
    entropy = -sum(symProb.*log2(symProb));    
    err = abs(H-entropy);
end
