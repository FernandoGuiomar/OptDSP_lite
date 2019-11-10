function [phi,w,A_VV] = VV_phaseEstimation(Ain,nTaps,convMethod,MSG)

% Last Update: 02/04/2019


%% Input Parser
if nargin < 3
    convMethod = 'conv';
end
if nargin < 4
    MSG = [];
end

%% Input Parameters
ni = ceil(nTaps/2);
nf = floor(nTaps/2);
nSamples = length(Ain);
[A_VV,phi,w] = deal(zeros(1,nSamples));

%% Perform Phase Average
switch convMethod
    case {'mean','vector'}
        % ProgressBar Initialization:
        progressbar(['Viterbi-Viterbi ',MSG,': current sample (',...
            num2str(nSamples-nTaps),' in total)']);
        for n = ni:nSamples-nf
            A = Ain(n+nf:-1:n-ni+1);
            w(n) = sum(A~=0);
            A_VV(n) = mean(A(A~=0));
            if w(n)
                A_VV(n) = mean(A(A~=0));
                phi(n) = atan2(imag(A_VV(n)),real(A_VV(n)));
            else
                phi(n) = phi(n-1);
            end
            progressbar((n-ceil(nTaps/2)+1)/(nSamples-nTaps+1));
        end
    case {'conv','filter'}
        A_VV = movmean(Ain,nTaps);
        phi = atan2(imag(A_VV),real(A_VV));
    otherwise
        error('Unsupported convolution method for CPE');
end

