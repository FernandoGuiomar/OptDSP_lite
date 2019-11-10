function [Stx,DAC,PARAM] = Tx_DAC(Stx,DAC,Fs)

% Last Update: 09/10/2019


%% Resample to DAC Sampling Rate
if isfield(DAC,'RESAMP')
    [Stx,PARAM] = applyResample(Stx,Fs,DAC.RESAMP.sampRate);
end

%% Introduce Tx Skew
if isfield(DAC,'SKEW') && isfield(DAC.SKEW,'delay_ps')
    Stx = DAC_IQskew(Stx,Fs,DAC.SKEW.delay_ps);
end

%% Insert Clock Timing Offset
if isfield(DAC,'CLOCK') && isfield(DAC.CLOCK,'offset')
    [Stx,DAC.CLOCK] = DAC_clockOffset(Stx,Fs,DAC.CLOCK);
end

%% Insert Clock Timing Jitter
if isfield(DAC,'CLOCK')
    [Stx,DAC.CLOCK] = DAC_clockJitter(Stx,Fs,DAC.CLOCK);
end

%% Apply Clipping
if isfield(DAC,'clipping')
    Stx = DAC_applyClipping(Stx,DAC.clipping);
end

%% Set Maximum PAPR
if isfield(DAC,'maxPAPR_dB') && ~isinf(DAC.maxPAPR_dB)
    [Stx,DAC.clip_I,DAC.clip_Q] = DAC_setMaxPAPR(Stx,DAC.maxPAPR_dB);
end

%% Quantization
if isfield(DAC,'ENOB') && ~isinf(DAC.ENOB)
    Stx = setENOB(Stx,DAC.ENOB);
elseif isfield(DAC,'nBits') && ~isinf(DAC.nBits)
    Stx = quantizeSignal(Stx,DAC.nBits);
end

%% Low-Pass Filtering
if isfield(DAC,'LPF')
    Stx = LPF_apply(Stx,DAC.LPF,Fs);
end

%% Normalization
if isfield(DAC,'NORM')
    Stx = normalizeIQ(Stx,DAC.NORM.range,DAC.NORM.mode);
end
