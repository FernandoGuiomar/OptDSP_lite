function [N0,c] = getN0_MMSE(Stx,Srx)
%getN0_MMSE     Estimate the noise variance using a MMSE criterion
%   This function evaluates the noise variance of a received signal with
%   noise, Srx, by calculating its MMSE with respect to the noiseless
%   transmitted signal, Stx. In order to minimize the MMSE between Stx and
%   Srx, this function utilizes the fminsearch optimization algorithm.
%
%   INPUTS:
%   Stx     := transmitted signal [nPol x nSamples]
%   Srx     := received signal [nPol x nSamples]
%
%   Note that Stx and Srx must be priorly synchronized before being parsed
%   to this function.
%
%   OUTPUTS:
%   N0      := estimated noise variance [1 x nPol]
%   c       := optimized scale factor between Srx and Stx [1 x nPol]
%
%
%   Author: Fernando Guiomar
%   Last Update: 27/02/2019

%% Input Parameters
nPol = size(Stx,1);

%% Calculate Added Noise over Srx
[c,N0] = deal(NaN(1,nPol));
options = optimset('TolX',1e-6,'TolFun',1e-6,'MaxIter',1e3);
for n = 1:nPol
    Stx(n,:) = Stx(n,:)/sqrt(mean(abs(Stx(n,:)).^2));                       % normalize such that var(Stx)=1
    Srx(n,:) = Srx(n,:)/sqrt(mean(abs(Srx(n,:)).^2));                       % normalize such that var(Srx)=1
    fun = @(h) (h*Stx(n,:)-Srx(n,:))*(h*Stx(n,:)-Srx(n,:))';
    c(n) = fminsearch(fun,1,options);
    N0(n) = (1-c(n)^2)/c(n)^2;
end
