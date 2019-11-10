function [bits,BIT] = QAM_PRBSgenerator(BIT,M,nPol,nSyms)

% Last Update: 30/09/2018


%% Input Parser
if ~isfield(BIT,'seed')
    error('You must specify the first polynomial seed for PRBS generation: PRBS.seed');
end
if ~isfield(BIT,'applyBitDelay')
    BIT.applyBitDelay = false;
end
if ~isfield(BIT,'evenLength')
    BIT.evenLength = true;
end

%% Input Parameters
degreePRBS = BIT.degree;                                                    % PRBS degree
evenLength = BIT.evenLength;                                                % flag signaling if the sequence should be of even length (in that case, one 0 must be padded at the end of each PRBS)
applyBitDelay = BIT.applyBitDelay;                                          % flag signaling if bit delay should be applied to the generated/loaded PRBS sequences
seed = BIT.seed;                                                            % seed for the first polynomial utilized for PRBS generation
N = nPol*log2(M);                                                           % number of parallel PRBSs (only if parallel bit to symbol assignment is used)
if isinf(degreePRBS)
    nBits = floor(nSyms / log2(M));
    degreePRBS = floor(log2(nBits));
end

%% Generate PRBS
try
    bitMatrix = PRBS_generator(N,degreePRBS,seed);
catch
    warning('Could not generate the specified PRBS. Proceeding with randi function.');
    rng(seed);
    bitMatrix = randi([0 1],N,2^degreePRBS-1);
end
for n = 1:N
    bit{n} = bitMatrix(n,:);
end

%% Check for Even Length Sequence
if evenLength
    for n = 1:N
        bit{n} = [bit{n} 0];
    end
end

%% Truncate PRBS Sequence
if isfield(BIT,'sequenceLength') ...
        && ~isinf(BIT.sequenceLength)
    for n = 1:N
        bit{n} = bit{n}(:,1:BIT.sequenceLength);
    end
end

%% Adjust the Length of the PRBS to the Number of Simulated Bits
nBitsPRBS = length(bit{1});
if nSyms < nBitsPRBS
    for n = 1:N
        bit{n} = bit{n}(:,1:nSyms);
    end
elseif nSyms > nBitsPRBS
    nRep = floor((nSyms)/nBitsPRBS);
    nTrail = mod(nSyms,nBitsPRBS);
    for n = 1:N
        bit{n} = [repmat(bit{n},1,nRep) bit{n}(:,1:nTrail)];    
    end
end

%% Parallel to Serial Bit Assignment
bits = zeros(nPol,length(bit{1})*N/nPol) + NaN;
for k = 1:N/nPol
    for kk = 1:nPol
        bits(kk,k:N/nPol:end) = bit{(kk-1)*N/nPol+k};
    end
end

%% Apply Fixed Bit Delay to Bit Stream
if applyBitDelay
    if isfield(BIT,'bitDelay') && BIT.bitDelay
        bitDelay = BIT.bitDelay;
    else
        bitDelay = randi(length(bits),1,1);
    end
    bits = circshift(bits, [0 bitDelay]);
end
