function [S,LPF] = LPF_apply(S,LPF,Fs,Rs)

% Last Update: 17/05/2019


%% Input Parser
if isfield(LPF,'fc')
    fc = LPF.fc;
elseif ~isfield(LPF,'fc') && isfield(LPF,'fcn')
    fc = LPF.fcn*Fs;
    LPF.fc = fc;
end
if ~isfield(LPF,'f0')
    LPF.f0 = 0;
end

%% Input Parameters
[nPol,nSamples] = size(S);

%% Rx Signal Filtering
switch LPF.type
    case 'user-defined'
        f = (-nSamples/2:nSamples/2-1)*(Fs/nSamples);
        LPF.TF = sqrt(10.^(LPF.TF_dB/10));
        TF = interp1(LPF.f,LPF.TF,f,'linear','extrap');
        if isfield(LPF,'stopband')
            TF(abs(f) > LPF.stopband) = 0;
        end
        for n = 1:nPol
            S(n,:) = ifft(fftshift(TF).*fft(S(n,:)));
        end
        
    case 'user-defined-complex'    
        f = (-nSamples/2:nSamples/2-1)*(Fs/nSamples);
        TF = interp1(LPF.f,LPF.TF,f,'linear','extrap');
        if isfield(LPF,'stopband')
            TF(abs(f) > LPF.stopband) = 0;
        end
        for n = 1:size(S,1)
            S(n,:) = ifft(fftshift(TF).*fft(S(n,:)));
        end
        
    case 'WSS'
        f = (-nSamples/2:nSamples/2-1)*(Fs/nSamples);
        [S,WSS] = WSS_filter(S,f,LPF);
        TF = WSS.Hf;
        
    case 'Butter'
        f = (-nSamples/2:nSamples/2-1)*(Fs/nSamples);
        [B,A] = butter(LPF.order,fc/(Fs/2));
        for n = 1:nPol
            S(n,:) = filter(B,A,S(n,:));
        end
        TF = freqz(B,A,2*pi*f/Fs);
        
    case 'ButterAnalog'
        f = (-nSamples/2:nSamples/2-1)*(Fs/nSamples);
        [B,A] = butter(LPF.order,fc,'s');
        s = 1j*f;
        h = polyval(B,s)./polyval(A,s);
        TF = (h/max(h));
        for n = 1:nPol
            S(n,:) = ifft(fftshift(TF).*fft(S(n,:)));
        end
        
    case 'Bessel'
        f = (-nSamples/2:nSamples/2-1)*(Fs/nSamples);
        [B,A] = besself(LPF.order,fc*2);
        s = 1j*f;
        h = polyval(B,s)./polyval(A,s);
        TF = h/max(h);
        for n = 1:nPol
            S(n,:) = ifft(fftshift(TF).*fft(S(n,:)));
        end
        
    case 'Gaussian'
        TF = superGaussian_transferFunction(fc,LPF.order,LPF.f0,...
            Fs,nSamples);
        for n = 1:nPol
            S(n,:) = ifft(fftshift(TF).*fft(S(n,:)));
        end
        
    case 'Rect'
        f = (-nSamples/2:nSamples/2-1)*(Fs/nSamples);
        TF = zeros(1,nSamples);
        TF((f>-fc) & (f<fc))=1;
        for n = 1:nPol
            S(n,:) = ifft(fftshift(TF).*fft(S(n,:)));
        end
        
    case {'RC','raised-cosine'}
        f = (-nSamples/2:nSamples/2-1)*(Fs/nSamples);
        TF = RC_transferFunction(f,Rs,LPF.rollOff);
        for n = 1:nPol
            S(n,:) = ifft(fftshift(TF).*fft(S(n,:)));
        end
    
    case {'RRC','root-raised-cosine'}
        nSpS_in = Fs/Rs;
        nSpS = round(nSpS_in);
        if abs(nSpS - nSpS_in) > 1e-3
            nSpS = ceil(nSpS_in);
            Fs_out = nSpS * Rs;
            S = applyResample(S,Fs,Fs_out);
        end
        if isfield(LPF,'nTaps')
            nTaps = LPF.nTaps;
        else
            nTaps = 64 * nSpS;
        end
        if isfield(LPF,'implementation')
            implementation = LPF.implementation;
        else
            implementation = 'FFT';
        end
        W = rcosdesign(LPF.rollOff, nTaps/nSpS, nSpS, 'sqrt');
        W = W/sum(W);                                                       % to guarantee unity gain at DC
        if strcmp(implementation,'FFT')
            nSamples = size(S,2);
            zeroEnd = false;
            if mod(nSamples,2)
                S = [S zeros(nPol,1)];
                nSamples = nSamples + 1;
                zeroEnd = true;
            end
            W_f = [zeros(1,(nSamples-nTaps)/2) W ...
                zeros(1,(nSamples-nTaps)/2-1)];
        end
        if strcmp(implementation,'conv')
            for n = 1:nPol
                S(n,:) = conv(S(n,:),W,'same');
            end
        elseif strcmp(implementation,'FFT')
            for n = 1:nPol
                S(n,:) = fftshift(ifft(fft(S(n,:)).*fft(W_f)));
            end
            if zeroEnd
                S = S(:,1:end-1);
            end
        end
        TF = fft(W);
        if abs(nSpS - nSpS_in) > 1e-3
            S = applyResample(S,Fs_out,Fs);
        end
        
    case 'none'
        TF = ones(1,nSamples);
    otherwise
        error('Invalid LPF type!');
end

%% Output LPF Struct
LPF.TF = TF;

