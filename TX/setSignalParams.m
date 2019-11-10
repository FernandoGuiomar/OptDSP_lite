function SIG = setSignalParams(varargin)

% Last Update: 08/01/2019


%% Input Parameters
if nargin <= 3
    SIG = varargin{1};
    symRate = SIG.symRate;
    if isfield(SIG,'nBpS')
        nBpS = SIG.nBpS;
    end
    if isfield(SIG,'nPol')
        nPol = SIG.nPol;
    end
    if isfield(SIG,'rollOff')
        rollOff = SIG.rollOff;
    end
    if nargin == 2
        PARAM = varargin{2};
        sampRate = PARAM.sampRate;
        nSamples = PARAM.nSamples;
    elseif nargin == 3
        sampRate = varargin{2};
        nSamples = varargin{3};
    end
else
    for n = 1:2:nargin
        varName = varargin{n};
        varValue = varargin{n+1};
        switch varName
            case {'symRate','symbol-rate'}
                symRate = varValue;
            case {'M'}
                SIG.M = varValue;
            case {'nBpS'}
                nBpS = varValue;
            case {'nPol'}
                nPol = varValue;
            case {'roll-off'}
                rollOff = varValue;
            case {'sampRate'}
                sampRate = varValue;
            case {'nSamples'}
                nSamples = varValue;
            case {'nSpS'}
                nSpS = varValue;
            case {'nSyms'}
                nSyms = varValue;
            case 'encoding'
                SIG.encoding = varValue;
            case 'modulation'
                SIG.modulation = varValue;
        end
    end
end
if ~isfield(SIG,'M')
    error('You must specify the constellation size, M');
end
if ~exist('nBpS','var')
    nBpS = log2(SIG.M);
end
if ~exist('nPol','var')
    nPol = 2;
end
if ~exist('rollOff','var')
    rollOff = 0.05;
end
if ~isfield(SIG,'encoding')
    SIG.encoding = 'normal';
end
if ~isfield(SIG,'modulation')
    SIG.modulation = 'QAM';
end
if ~exist('sampRate','var')
    if exist('nSpS','var')
        SIG.nSpS = nSpS;
        sampRate = nSpS * symRate;
    end
end
if ~exist('nSamples','var')
    if exist('nSyms','var')
        SIG.nSyms = nSyms;
        if exist('sampRate','var')
            nSamples = sampRate/symRate * nSyms;
        end
    end
end

%% Secondary Parameters
bitRate = symRate * nBpS * nPol;
tSym = 1/symRate;
tBit = nPol/bitRate;

%% Signal Parameters that Depend on the Simulation Parameters
if exist('sampRate','var') && exist('nSamples','var')
    SIG.nSpS = sampRate / symRate;
%     SIG.nSpB = sampRate / (symRate * nBpS);
    SIG.nSyms = nSamples / SIG.nSpS;
    SIG.nBits = SIG.nSyms * nBpS;
end

%% Set QAM fields
SIG.symRate = symRate;
SIG.bitRate = bitRate;
SIG.nBpS = nBpS;
SIG.nPol = nPol;
SIG.tSym = tSym;
SIG.tBit = tBit;
SIG.rollOff = rollOff;

