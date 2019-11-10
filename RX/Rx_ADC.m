function [Srx,ADC,Fs] = Rx_ADC(Srx,ADC,Fs,Rs)

% Last Update: 09/10/2019


%% Introduce Rx Skew
if isfield(ADC,'SKEW')
    Srx = DAC_IQskew(Srx,Fs,ADC.SKEW);
end

%% Low-Pass Filtering
if isfield(ADC,'LPF')
    if nargin == 3
        Srx = LPF_apply(Srx,ADC.LPF,Fs);
    elseif nargin == 4
        Srx = LPF_apply(Srx,ADC.LPF,Fs,Rs);
    end
end

%% Resample to ADC Sampling Rate
if isfield(ADC,'RESAMP')
    if isfield(ADC.RESAMP,'sampRate')
        Fs_ADC = ADC.RESAMP.sampRate;
    elseif isfield(ADC.RESAMP,'nSpS') && nargin==4
        Fs_ADC = ADC.RESAMP.nSpS * Rs;
    end
    Srx = applyResample(Srx,Fs,Fs_ADC);
    Fs = Fs_ADC;
end

%% Apply Clipping
if isfield(ADC,'clipping')
    Srx = DAC_applyClipping(Srx,ADC.clipping);
end

%% Set Maximum PAPR
if isfield(ADC,'maxPAPR_dB') && ~isinf(ADC.maxPAPR_dB)
    [Srx,ADC.clip_I,ADC.clip_Q] = DAC_setMaxPAPR(Srx,ADC.maxPAPR_dB);
end

%% Quantization
if isfield(ADC,'ENOB') && ~isinf(ADC.ENOB)
    Srx = setENOB(Srx,ADC.ENOB);
elseif isfield(ADC,'nBits') && ~isinf(ADC.nBits)
    Srx = quantizeSignal(Srx,ADC.nBits);
end

