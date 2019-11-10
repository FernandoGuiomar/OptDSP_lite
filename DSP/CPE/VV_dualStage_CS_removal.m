function [phi,csCorrection] = VV_dualStage_CS_removal(phi1,phi2)

% Last Update: 02/07/2016


%% Input Parameters
deltaPhi = phi1 - phi2;
csCorrection = round(deltaPhi/(pi/2))*pi/2;
phi = phi2 + csCorrection;

