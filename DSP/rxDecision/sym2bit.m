function [bits] = sym2bit(syms,nBpS)
%sym2bit    Convert QAM symbols into bits
%   This function converts a stream of input QAM symbols into the
%   corresponding stream of bits, applying the defined symbol-to-bit
%   mapping.
%
%   INPUTS:
%   syms :=  input QAM symbols [nPol x nSyms]
%   nBpS :=  number of bits per symbol [1 x 1]
%
%   OUTPUTS:
%   bits :=  array of bits [nPol x nBpS*nSyms]
%
%
%   Author: Fernando Guiomar
%   Last Update: 02/10/2018


%% Input Params
[nPol,nSyms] = size(syms);
M = 2^nBpS;

%% Transform Symbols into Bits
bits = false(nPol,log2(M)*nSyms);
for m = 1:nPol
    b = fliplr(de2bi(syms(m,:),log2(M)));
    bits(m,:) = reshape(b',1,numel(b));
end

