function [Sout,PS] = pulseShaper(Sin,nSpS,PS)

% Last Update: 31/03/2019


%% Input Parser
[nPol,nSamples] = size(Sin);

%% Select Pulse Shaping Filter
switch PS.type
    case {'Rect','rect','rectangular','none'}
        for n = 1:nPol
            Sout(n,:) = rectpulse(Sin(n,:),nSpS);
        end
    case {'RC','raised-cosine','raisedCos','Nyquist'}
        a = PS.rollOff;
        if isfield(PS,'nTaps')
            nTaps = PS.nTaps;
        else
            nTaps = 64 * nSpS;
        end
        k = -floor(nTaps/2):ceil(nTaps/2)-1;
        tK = k/nSpS;
        W = sinc(tK).*cos(a*pi*tK)./(1-4*a^2*tK.^2);
        W(isinf(W)) = 0;
              
        for n = 1:nPol
            Sout(n,:) = conv(upsample(Sin(n,:),nSpS),W,'same');
        end
        PS.W = W;
        
    case {'RRC','root-raised-cosine'}
        resampleFlag = abs(round(nSpS) - nSpS) > 1e-3;
        if resampleFlag
            nSpS_in = nSpS;
            nSpS = ceil(nSpS);
        end
        if isfield(PS,'nTaps')
            nTaps = PS.nTaps;
        else
            nTaps = 256*nSpS;
        end
        if isfield(PS,'implementation')
            implementation = PS.implementation;
        else
            implementation = 'FFT';
        end
        W = rcosdesign(PS.rollOff, nTaps/nSpS, nSpS, 'sqrt');
        W = W/sum(W);                                                       % to guarantee unity gain at DC
        if strcmp(implementation,'FFT')
            zeroEnd = false;
            if mod(nSamples,2)
                Sin = [Sin zeros(nPol,1)];
                nSamples = nSamples + 1;
                zeroEnd = true;
            end
            W_f = [zeros(1,(nSpS*nSamples-nTaps)/2) W ...
                zeros(1,(nSpS*nSamples-nTaps)/2-1)];
        end
        if strcmp(implementation,'conv')
            for n = 1:nPol
                Sout(n,:) = conv(upsample(Sin(n,:),nSpS),W,'same');
            end
        elseif strcmp(implementation,'FFT')
            for n = 1:nPol
                X = upsample(Sin(n,:),nSpS);
                Sout(n,:) = fftshift(ifft(fft(X).*fft(W_f)));
            end
            if zeroEnd
                Sout = Sout(:,1:end-nSpS);
            end
        end
        if resampleFlag
            Sout = applyResample(Sout,nSpS,nSpS_in);
        end
        PS.W = W;
        
    case 'Gaussian'
        fcn = PS.fcn;
        nTaps = PS.nTaps;
        W = gaussdesign(fcn,nTaps/nSpS,nSpS);
        W = W/max(abs(W));
        for n = 1:nPol
            Sout(n,:) = conv(upsample(Sin(n,:),nSpS),W,'same');
        end
        PS.W = W;
                
    otherwise
        error('Invalid Pulse Shaping Filter!');
end

