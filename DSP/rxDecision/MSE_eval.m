function MSE = MSE_eval(Sin,Sref)

% Last Update: 01/09/2017

MSE = mean((Sin-Sref).^2);

