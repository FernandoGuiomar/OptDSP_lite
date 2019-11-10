function [Aout,PARAM] = applyResample(Ain,Fs_in,Fs_out)

% Last Update: 11/04/2017


%% Input Parameters
K = Fs_out/Fs_in;
nSignals = size(Ain,1);

%% Resample
[n1,n2] = rat(K,1e-8);
if (n1 ~= n2)
    % Resample:
    for n = 1:nSignals
        Aout(n,:) = resample(Ain(n,:),n1,n2);
    end
else
    Aout = Ain;
end

%% Update PARAM Struct
PARAM = setSimulationParams(Fs_out,length(Aout));

