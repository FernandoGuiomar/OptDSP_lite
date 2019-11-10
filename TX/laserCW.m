function [A,LASER] = laserCW(LASER,Fs,nSamples)

% Last Update: 07/08/2019


%% Input Parser
if ~isfield(LASER,'linewidth')
    LASER.linewidth = 0;
end
if ~isfield(LASER,'RIN_dB')
    LASER.RIN_dB = -inf;
end
if ~isfield(LASER,'phase0')
    LASER.phase0 = 0;
end
if ~isfield(LASER,'P0_dBm')
    LASER.P0_dBm = 30;      % 1 Watt (per polarization)
end

%% Input Parameters
% Laser parameters:
lw = LASER.linewidth;       % laser linewidth [Hz]
RIN_dB = LASER.RIN_dB;      % relative intensity noise [dB/Hz] 
ph0 = LASER.phase0;         % laser initial phase [rad]
P0_dBm = LASER.P0_dBm;      % laser emitted power [dBm]

%% LASER phase noise
phVar = 2*pi*lw/Fs;
phNoise = sqrt(phVar)*randn(1,nSamples);
phNoise = cumsum(phNoise);

%% LASER intensity noise
P0 = db2pow(P0_dBm-30);
intVar = 10^(RIN_dB/10)*Fs*P0^2;                   
intNoise = sqrt(intVar)*randn(1,nSamples);

%% LASER transmitted optical field
A = sqrt(P0 + intNoise) .* exp(1j*(ph0 + phNoise));

%% Output LASER Struct
LASER.phaseVar = phVar;         % phase variance
LASER.phaseNoise = phNoise;     % phase noise [rad]
LASER.RIN_dB = RIN_dB;          % relative intensity noise [dB/Hz] 
LASER.intNoise = intNoise;      % intensity noise [W]
