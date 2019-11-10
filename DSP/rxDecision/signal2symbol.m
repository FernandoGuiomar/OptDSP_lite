function syms = signal2symbol(sig,C,normPower,useGPU)
%signal2symbol  Convert a complex signal into constellation symbols
%
%   This function converts an input complex signal into the corresponding
%   constellation symbols, employing minimum distance detection. 
%
%   INPUTS:
%   sig         :=  input complex signal at 1 sample/symbol [nPol x nSyms]
%   C           :=  reference constellation [M x nPol]
%                   Note that the C vector must be ordered according to the
%                   mapping between IQ contellation samples and symbol
%                   indices, i.e., C(1) corresponds to symbol #0, C(2) to
%                   symbol #1, C(3) to symbol #2, ... C(M) to symbol #M-1
%   normPower   :=  factor for normalizing the power of the reference 
%                   constellation, C [1 x nPol]
%   useGPU      :=  flag to decide whether to use or not GPU-based processing
%
%   OUTPUTS:
%   syms    :=  array of contellation symbols [nPol x nSyms]
%               The symbols are in the range 0 ... M-1, where M is the
%               constellation size
%   
%
%   Author: Fernando Guiomar
%   Last Update: 04/06/2019

%% Input Parameters
[nPol,nSyms] = size(sig);
if size(C,2) == 1
    C = repmat(C,1,nPol);
end
if nargin < 4
    useGPU = false;
end

%% Normalize Signal
if nargin == 3 && ~isempty(normPower)
    if numel(normPower) == 1
        normPower = repmat(normPower,1,nPol);
    end
    for n = 1:nPol
        C(:,n) = C(:,n)*sqrt(normPower(n))/sqrt(mean(abs(C(:,n)).^2));
    end
end

%% Symbol Decoder
syms = zeros(nPol,nSyms)-1;
for n = 1:nPol
    thisC = single(C(:,n));
    thisSig = single(sig(n,:));
    if useGPU
        thisSig = gpuArray(thisSig);
        thisC = gpuArray(thisC);
    end
    err = abs(thisSig - thisC);
%     err = abs(bsxfun(@minus,thisSig,thisC));
    [~,ind] = min(err);
    if useGPU
        ind = gather(ind);
    end
    syms(n,:) = ind - 1;
end
