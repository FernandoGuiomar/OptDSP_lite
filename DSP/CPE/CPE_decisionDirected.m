function [Aout,phi] = CPE_decisionDirected(Ain,nSpS,C,CPE)

% Last Update: 26/02/2018


%% Input Parameters
[nPol,nSamples] = size(Ain);
nTaps = CPE.nTaps;
ts0 = CPE.ts0;

%% Apply Decision-Directed CPE
phi = zeros(nPol,nSamples/nSpS);
Aout = Ain;
for n = 1:nPol
    % ProgressBar Initialization:
    progBarText = ['Decision-Directed CPE (',char('w'+n),...
        '-pol): current sample ('];
    progressbar([progBarText,num2str(nSamples-nTaps),' in total)']);
    W = zeros(1,nTaps);
    k = 1;
    for m = ts0:nSpS:nSamples
        ind = m-nSpS+1:m;
        if k > 1
            Aout(n,ind) = Ain(n,ind).*exp(-1j*phi(n,k-1));
        else
            Aout(n,ind) = Ain(n,ind);
        end
        if isnan(Aout(n,m))
            Aout(n,ind) = 0;
        end
        Adec = symbol2signal(signal2symbol(Aout(n,m),C),C);
        error = angle(Aout(n,m)) - angle(Adec);
        W(mod(k-1,nTaps)+1) = error;
        phi(n,k) = mean(W);
        progressbar(m/nSamples);
        k = k+1;
    end
end


