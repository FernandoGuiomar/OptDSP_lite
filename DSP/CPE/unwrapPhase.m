function [phi] = unwrapPhase(phi,demodQAM)

% Last Update: 19/02/2018


%% Unwrap Phase
switch demodQAM
    case {'QPSKpartition','data-aided (4th-power)',...
            'decision-directed (4th-power)','QPSK'}
        phi = unwrap(phi)/4-pi/4;
    case {'DA','data-aided','decision-directed'}
        phi = unwrap(phi);
    case 'nthPower'
        c = 2*pi/(pi-4*atan(1/3));
        phi = unwrap(phi)/(4*c);
    case 'recenter'
        phi = unwrap(phi)/4;
end
