function [TF] = RC_transferFunction(f,Rs,a)

% Last Update: 07/07/2019


%% Calculate Passing and Decaying Bands
passBand = abs(f)<=(1-a)*Rs/2;
decayBand = abs(f)>(1-a)*Rs/2 & abs(f)<=(1+a)*Rs/2;

%% Apply RC Transfer Function
TF = zeros(size(f));
TF(passBand) = 1;
TF(decayBand) = 0.5*(1+cos(pi/(a*Rs)*(abs(f(decayBand))-(1-a)*Rs/2)));
