function QAM = QAM_config(varargin)
%QAM_config     Configure QAM struct based on a selected format 
%   This functions configures a struct with QAM properties based on the
%   specified modulation format. Currently supported formats are:
%   QPSK/4QAM (square)
%   8QAM (cross)
%   16QAM (square)
%   32QAM (cross)
%   36QAM (square)
%   64QAM (square)
%   128QAM (cross)
%   256QAM (square)
%   512QAM (cross)
%   1024QAM (square)
%
%   INPUTS:
%   modFormat   :=  modulation format string. It must contain the 'mQAM'
%                   string in it (e.g. 'QPSK','4QAM','8QAM','1024QAM') and
%                   it may also contain a string to indicate the use of
%                   dual-polarization (either 'DP' or 'PM')
%   encoding    :=  method for symbol encoding
%                   - 'normal': normal encoding (non-differential) (defaul)
%                   - 'diff-quad': differential quadrant encoding
%
%   OUTPUTS:
%   QAM         :=  struct with QAM parameters
%
%
%   Examples:
%       QAM = QAM_config('1024QAM')
%       QAM = QAM_config('PM-QPSK')
%       QAM = QAM_config('DP-4QAM')
%       QAM = QAM_config('PM-32QAM')
%
%       scatterplot(QAM.IQmap);
%
%
%   Author: Fernando Guiomar
%   Last Update: 10/04/2019

%% Input Parser
% Default parameter values:
nPol = 2;
encoding = 'normal';
modulation = 'QAM';
class = [];
symbolOrder = 'gray';
% Assignment of input parameters:
if nargin == 1
    SIG = varargin{1};
    M = SIG.M;
    if isfield(SIG,'nPol')
        nPol = SIG.nPol;
    end
    if isfield(SIG,'encoding')
        encoding = SIG.encoding;
    end
    if isfield(SIG,'modulation')
        modulation = SIG.modulation;
    end
    if isfield(SIG,'class')
        class = SIG.class;
    end
    if isfield(SIG,'symbolOrder')
        symbolOrder = SIG.symbolOrder;
    end
else
    for n = 1:2:nargin
        varName = varargin{n};
        varValue = varargin{n+1};
        if strcmpi(varName,'M')
            M = varValue;
        elseif strcmpi(varName,'nPol')
            nPol = varValue;
        elseif strcmpi(varName,'encoding')
            encoding = varValue;
        elseif strcmpi(varName,'modulation')
            modulation = varValue;
        elseif strcmpi(varName,'class')
            class = varValue;
        elseif strcmpi(varName,'symbolOrder')
            symbolOrder = varValue;
        end
    end
end

if strcmp(modulation,'QAM') && isempty(class)
    if mod(sqrt(M),1) == 0
        class = 'square';
    else
        class = 'cross';
    end
end

%% Assign Constellation
try
    symbolMap = 0:M-1;
    switch modulation
        case 'QAM'
            if M == 8
                if strcmp(class,'cross')
                    error('Cannot generate cross-8QAM with qammod.');
                elseif isempty(class)
                    class = 'rect';
                    M_rect = [2 4];
                end
            end
            const = qammod(symbolMap,M,symbolOrder);
        case 'PAM'
            const = pammod(symbolMap,M,pi/2,symbolOrder);
        case 'PSK'
            const = pskmod(symbolMap,M,0,symbolOrder);
    end
catch
    % Load QAM Constellation:
    MF_ID = [num2str(M) modulation '_' class];
    [const,symbolMap] = QAM_loadConstellation(MF_ID);
end

%% Configure Modulation Format Parameters
% Determine all radii in the constellation:
radius = unique(abs(const));
radius = sort(radius/max(radius),2,'descend');
modFormat = [num2str(M) modulation];
% If there are two polarization, change modulation format ID accordingly:
if nPol == 2
    modFormat = ['PM-' modFormat];
end

%% Determine Constellation Mapping
% Symbol mapping and indices:
symbolInd = zeros(1,M);
for n = 0:M-1
    symbolInd(n+1) = find(symbolMap==n);
end
IQmap = const(symbolInd).';
% Mapping symbols to bits:
if mod(log2(M),1) == 0
    sym2bitMap = false(M,log2(M));
    for n = 0:M-1
        [~,e] = log2(n);
        sym2bitMap(n+1,:) = rem(floor(n * pow2(1-max(e,log2(M)):0)),2);
    end
end
% LSB bit map for differential encoding:
if strcmp(encoding,'diff-quad')
    QAM.LSB_bitMap = NaN(M,log2(M)-2);
end
% Calculate average and maximum constellation powers:
S_meanP = mean(abs(IQmap).^2);
S_maxP = max(abs(IQmap).^2);

%% Output QAM Struct
QAM.modFormat = modFormat;                                                  % modulation format
QAM.mode = modulation;                                                      % modulation type (QAM, PAM, PSK)
if strcmp(QAM.mode,'QAM')
    QAM.class = class;                                                      % QAM class (square, cross, rect)
    if strcmp(QAM.class,'rect')
        QAM.M_rect = M_rect;
    end
end
QAM.M = M;                                                                  % constellation number of symbols
QAM.nBpS = log2(M);                                                         % number of bits per symbol
QAM.entropy = log2(M);
QAM.radius = radius;                                                        % constellation radius
QAM.nPol = nPol;                                                            % number of polarization components
QAM.meanConstPower = S_meanP;                                               % mean constellation power
QAM.maxConstPower = S_maxP;                                                 % mean constellation power
QAM.IQmap = IQmap;                                                          % mapping between constellation symbols and IQ
if exist('sym2bitMap','var')
    QAM.sym2bitMap = sym2bitMap;                                            % map symbols to bits
end
QAM.encoding = encoding;
