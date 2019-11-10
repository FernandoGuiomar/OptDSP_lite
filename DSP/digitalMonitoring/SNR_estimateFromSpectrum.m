function [SNR_dB,Ps,Pn] = SNR_estimateFromSpectrum(PSD,Fs,Rs,rollOff,...
    fNoise,fCenter,debugPlots)
%SNR_estimateFromSpectrum   Estimate the SNR (in dB) from received spectrum
%   This function estimates the signal-to-noise ratio (SNR) from a given
%   received signal spectrum. It performs integration of the signal power
%   and noise power over user-specified bandwidths (through trapezoidal
%   integration, using the trapz function).
%
%   INPUTS:
%   PSD := power spectral density estimate of the signal (W/Hz)
%          [1 x nSamples]
%          Note: the PSD of the signal can be obtained e.g. by using the
%          pwelch function:
%               PSD = pwelch(Srx,1e3,[],[],Fs,'centered','psd');
%   Fs := sampling frequency (Hz) [scalar]
%         - alternative: if a vector is parsed, Fs will instead be
%         interpreted as being the frequency vector, f
%   Rs := symbol-rate (Baud) [scalar]
%   rollOff := RC/RRC roll-off factor [scalar]
%   fNoise := relative or absolute (Hz) noise frequency bins for noise power
%             estimation [nNoiseBins,2]
%             - example: [-0.9 -0.7; 0.7 0.9] (relative freq.) or 
%             [-30e9 -25e9; 25e9 30e9] (absolute freq.)
%             - default: [-0.9 -0.8; 0.8 0.9]
%   fCenter := central frequency of the signal (Hz) [scalar]
%              - default: 0 Hz
%   debugPlots := flag to activate/disable debug plots [boolean]
%                 - default: false
%   
%   OUTPUTS:
%   Ps := measured signal power (W)
%   Pn := measured noise power (W)
%
%
%   Author: Fernando Guiomar
%   Last Update: 02/11/2019

%% Input Parser
nSamples = size(PSD,2);
if numel(Fs) == 1
    f = (-nSamples/2:nSamples/2-1)*(Fs/nSamples);
else
    f = Fs;
    Fs = (max(f) - min(f));
end
if nargin < 6
    fCenter = 0;
end
if nargin < 5
    fNoise = [-0.9 -0.8; 0.8 0.9]*Fs/2 + fCenter;
else
    if max(fNoise) <= 1
        fNoise = fNoise*Fs/2 + fCenter;
    end
end
if nargin < 7
    debugPlots = false;
end

%% Input Parameters
nNoiseBins = size(fNoise,1);
sigBW = Rs*(1+rollOff);
if any(abs(fNoise)<=sigBW/2)
    warning('Noise bins overlap with the signal bandwidth. SNR estimation is probably wrong!');
end

%% Calculate Signal+Noise Power per Subcarrier
[~,indSig(1)] = min(abs(f-fCenter+sigBW/2));
[~,indSig(2)] = min(abs(f-fCenter-sigBW/2));
Psn_BW = abs(f(indSig(2)) - f(indSig(1)));
Psn_SCM = trapz(f(indSig(1):indSig(2)),PSD(indSig(1):indSig(2)))*...
    sigBW/Psn_BW;

%% Calculate Noise Power
[Pn_BW,Pn_bins] = deal(NaN(1,nNoiseBins));
indNoise = NaN(nNoiseBins,2);
for n = 1:nNoiseBins
    [~,indNoise(n,1)] = min(abs(f-fNoise(n,1)));
    [~,indNoise(n,2)] = min(abs(f-fNoise(n,2)));
    Pn_BW(n) = abs(f(indNoise(n,2)) - f(indNoise(n,1)));
    Pn_bins(n) = trapz(f(indNoise(n,1):indNoise(n,2)),...
        PSD(indNoise(n,1):indNoise(n,2)));
end
% Convert Pn into the symbol-rate bandwidth (for SNR calculation):
Pn = sum(Pn_bins)/sum(Pn_BW)*Rs;

%% Calculate SNR
Ps = Psn_SCM - Pn;
SNR_dB = 10*log10(Ps/Pn);

%% Debug Plots
if debugPlots
    blue = [0 0.2400 0.4310];
    red = [0.7300 0.0700 0.1690];
    
    if Fs > 1e12
        units = 'THz';
        f = f*1e-12;
        Fs = Fs*1e-12;
    elseif Fs > 1e9
        units = 'GHz';
        f = f*1e-9;
        Fs = Fs*1e-9;
    elseif Fs > 1e6
        units = 'MHz';
        f = f*1e-6;
        Fs = Fs*1e-6;
    elseif Fs > 1e3
        units = 'KHz';
        f = f*1e-3;
        Fs = Fs*1e-3;
    else
        units = 'Hz';
    end
    
    PSD = PSD/max(PSD);
    figure();
    hPlot1 = plot(f,10*log10(PSD));
    hold on;
    for n = 1:nNoiseBins
        ind = indNoise(n,1):indNoise(n,2);
        hPlot2(n) = plot(f(ind'),10*log10(PSD(ind')));
    end
    
    ind = indSig(1):indSig(2);
    hPlot3 = plot(f(ind'),10*log10(PSD(ind')));

    % Plot Format:
    set(hPlot1,'Color',blue);
    set(hPlot2,'Color',red,'LineStyle',':',...
        'LineWidth',1.5);
    set(hPlot3,'Color',[0 0 0],'LineStyle','--','LineWidth',1.5);

    % Axis Properties:
    xlabel(['$f$ [' units ']'],'Interpreter','latex','FontSize',11);
    ylabel('Normalized PSD [dB]','Interpreter','latex','FontSize',11);
    xAxis = get(gca,'xaxis');
    set(xAxis,'TickLabelInterpreter','latex','FontSize',11);
    yAxis = get(gca,'yaxis');
    set(yAxis,'TickLabelInterpreter','latex','FontSize',11);

    % Gridlines:
    grid on;
    set(gca,'GridLineStyle','--','XMinorTick','off','XMinorGrid','off');
    axis tight;

    % Legend:
    hLeg = legend([hPlot1,hPlot2(1),hPlot3],...
        'Full Spectrum','Noise Power','Signal Power');
    set(hLeg,'Interpreter','latex','fontsize',9,'Location','NorthWest');
    
    % Annotations:
    hText = text(f(end)-0.02*Fs,-1,['SNR = ' ...
        num2str(SNR_dB,'%1.1f') ' dB']);
    set(hText,'HorizontalAlignment','right','Color',blue,...
        'VerticalAlignment','top','Interpreter','latex','FontSize',12,...
        'BackgroundColor','w','EdgeColor',blue,'Margin',2);
    
end
