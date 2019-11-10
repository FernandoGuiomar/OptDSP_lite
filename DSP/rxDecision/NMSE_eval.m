function NMSE = NMSE_eval(Sin,Sref)

% Last Update: 29/06/2018

NMSE = mean(abs(Sin(:)-Sref(:)).^2)/mean(abs(Sin(:).^2));
