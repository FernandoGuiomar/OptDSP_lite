function signal = symbol2signal(syms,C)
%symbol2signal  Convert constellation symbols into a complex signal
%
%   This function converts an input array of constellation symbols into a
%   complex signal, using the pre-defined IQ mapping.
%
%   INPUTS:
%   syms    :=  array of constellation symbols [nPol x nSyms]
%   C       :=  reference constellation [M x 1]
%               Note that the C vector must be ordered according to the
%               mapping between IQ contellation samples and symbol
%               indices, i.e., C(1) corresponds to symbol #0, C(2) to
%               symbol #1, C(3) to symbol #2, ... C(M) to symbol #M-1
%
%   OUTPUTS:
%   signal  :=  array of complex-valued signal [nPol x nSyms]
%
%
%   Author: Fernando Guiomar
%   Last Update: 13/01/2018

%% Input Parameters
[nSig,nSyms] = size(syms);

%% Signal to Symbol
signal = zeros(nSig,nSyms);
for n = 1:nSig
    signal(n,:) = C(syms(n,:)+1);
end

