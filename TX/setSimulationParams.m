function PARAM = setSimulationParams(sampRate,nSamples)

% Last Update: 08/08/2019


%% Secondary Parameters
tWindow = nSamples / sampRate;
dt = 1 / sampRate;
df = sampRate / nSamples;
t = (0:nSamples-1)*dt;
f = (-nSamples/2:nSamples/2-1)*(sampRate/nSamples);

%% Set PARAM fields
PARAM.sampRate = sampRate;
PARAM.nSamples = nSamples;
PARAM.tWindow = tWindow;
PARAM.df = df;
PARAM.dt = dt;
PARAM.t = t;
PARAM.f = f;

