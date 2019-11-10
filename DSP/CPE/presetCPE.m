function [CPE] = presetCPE(varargin)

% Last Update: 31/03/2019


%% Input Parser
nOptionalArgs = length(varargin);
for n=1:2:nOptionalArgs
    varName = varargin{n};
    varValue = varargin{n+1};
    if any(strncmpi(varName,{'method'},4))
        method = varValue;
    elseif any(strncmpi(varName,{'decision'},6))
        decision = varValue;
    elseif any(strncmpi(varName,{'mQAM'},4))
        mQAM = varValue;
    elseif any(strncmpi(varName,{'demodQAM'},5))
        demodQAM = varValue;
    elseif any(strncmpi(varName,{'segChangeDetect','segmentChangeDetect','detectSegmentChange'},10))
        segChangeDetect = varValue;
    elseif any(strcmpi(varName,{'p'}))
        p = varValue;
    elseif any(strncmpi(varName,{'QAM_classes','classesQAM','QAMclasses'},9))
        QAM_classes = varValue;
    elseif any(strcmpi(varName,{'nSpS'}))
        nSpS = varValue;
    elseif any(strcmpi(varName,{'ts0'}))
        ts0 = varValue;
    elseif any(strcmpi(varName,{'nTaps'}))
        nTaps = varValue;
    elseif any(strncmpi(varName,{'debugPlots','plotsDebug'},7))
        debugPlots = varValue;
    elseif any(strncmpi(varName,{'convMethod'},4))
        convMethod = varValue;
    elseif any(strncmpi(varName,{'nTestPhases'},7))
        nTestPhases = varValue;
    elseif any(strncmpi(varName,{'angleInterval'},8))
        angleInterval = varValue;
    elseif any(strncmpi(varName,{'rmvEdgeSamples'},8))
        rmvEdgeSamples = varValue;
    elseif strncmpi(varName,'CPE',3)
        CPE_old = varValue;
    end
end

%% Check for pre-defined CPE
if exist('CPE_old','var')
    CPE = CPE_old;
end

%% Check Method
if ~exist('method','var') && isfield(CPE,'method')
    method = CPE.method;
end
if exist('method','var')
    switch method
        case {'Viterbi','Viterbi&Viterbi','V&V','VV','VV:optimized'}
            CPE.method = method;
            if exist('nTaps','var')
                CPE.nTaps = nTaps;
            elseif ~isfield(CPE,'nTaps')
                CPE.nTaps = 50;
            end
            if exist('segChangeDetect','var')
                CPE.segChangeDetect = segChangeDetect;
            elseif ~isfield(CPE,'segChangeDetect')
                CPE.segChangeDetect = true;
            end
            if exist('rmvEdgeSamples','var')
                CPE.rmvEdgeSamples = rmvEdgeSamples;
            elseif ~isfield(CPE,'rmvEdgeSamples')
                CPE.rmvEdgeSamples = false;
            end
            if exist('convMethod','var')
                CPE.convMethod = convMethod;
            elseif ~isfield(CPE,'convMethod')
                CPE.convMethod = 'filter';
            end
            if exist('mQAM','var')
                CPE.mQAM = mQAM;
            elseif ~isfield(CPE,'mQAM')
                CPE.mQAM = 'QPSK';
            end
            if ~strcmpi(CPE.mQAM,'QPSK')
                if exist('demodQAM','var')
                    CPE.demodQAM = demodQAM;
                elseif ~isfield(CPE,'demodQAM')
                    CPE.demodQAM = 'QPSKpartition';
                end
                if exist('QAM_classes','var')
                    CPE.QAM_classes = QAM_classes;
                elseif ~isfield(CPE,'QAM_classes')
                    CPE.QAM_classes = 'A';
                end
                if exist('p','var')
                    CPE.p = p;
                elseif ~isfield(CPE,'p')
                    CPE.p = 1;
                end
            end
            if exist('debugPlots','var')
                CPE.debugPlots = debugPlots;
            elseif ~isfield(CPE,'debugPlots')
                CPE.debugPlots = {};
            end
            if exist('nSpS','var')
                CPE.nSpS = nSpS;
            end
            if exist('ts0','var')
                CPE.ts0 = ts0;
            elseif ~isfield(CPE,'ts0')
                CPE.ts0 = 1;
            end
        case {'MaximumLikelihood','Maximum-Likelihood','maxLike','ML'}
            CPE.method = method;
            if exist('nTaps','var')
                CPE.nTaps = nTaps;
            elseif ~isfield(CPE,'nTaps')
                CPE.nTaps = 50;
            end
            if exist('rmvEdgeSamples','var')
                CPE.rmvEdgeSamples = rmvEdgeSamples;
            elseif ~isfield(CPE,'rmvEdgeSamples')
                CPE.rmvEdgeSamples = true;
            end
            if exist('decision','var')
                CPE.decision = decision;
            elseif ~isfield(CPE,'decision')
                CPE.decision = 'DD';
            end
            if exist('convMethod','var')
                CPE.convMethod = convMethod;
            elseif ~isfield(CPE,'convMethod')
                CPE.convMethod = 'filter';
            end
        case {'decision-directed','DecisionDirected','DD'}
            CPE.method = method;
            if exist('nTaps','var')
                CPE.nTaps = nTaps;
            elseif ~isfield(CPE,'nTaps')
                CPE.nTaps = 50;
            end
            if exist('rmvEdgeSamples','var')
                CPE.rmvEdgeSamples = rmvEdgeSamples;
            elseif ~isfield(CPE,'rmvEdgeSamples')
                CPE.rmvEdgeSamples = true;
            end
            if exist('ts0','var')
                CPE.ts0 = ts0;
            elseif ~isfield(CPE,'ts0')
                CPE.ts0 = 1;
            end
            if exist('nSpS','var')
                CPE.nSpS = nSpS;
            end
            CPE.convMethod = 'vector';
        case {'blind phase-search','blindPhaseSearch','BPS'}
            CPE.method = method;
            if exist('nTaps','var')
                CPE.nTaps = nTaps;
            elseif ~isfield(CPE,'nTaps')
                CPE.nTaps = 50;
            end
            if exist('rmvEdgeSamples','var')
                CPE.rmvEdgeSamples = rmvEdgeSamples;
            elseif ~isfield(CPE,'rmvEdgeSamples')
                CPE.rmvEdgeSamples = true;
            end
            if exist('nTestPhases','var')
                CPE.nTestPhases = nTestPhases;
            elseif ~isfield(CPE,'nTestPhases')
                CPE.nTestPhases = 32;
            end
            if exist('angleInterval','var')
                CPE.angleInterval = angleInterval;
            elseif ~isfield(CPE,'angleInterval')
                CPE.angleInterval = pi/4;
            end
        case 'phaseRotation'
            CPE.method = method;
    end
elseif ~exist('method','var') && ~exist('presetConfig','var')
    warning('To preset the CPE parameters you must indicate either the CPE method or a CPE preset configuration. Without any of these, all other parameters cannot be assigned. CPE will be now preset to simple QPSK-based Viterbi&Viterbi estimation.');
    CPE.method = 'VV';
    CPE.nTaps = 50;
    CPE.mQAM = 'QPSK';
    CPE.p = 1;
    CPE.segChangeDetect = true;
    CPE.ts0 = 1;
    CPE.convMethod = 'filter';
    CPE.debugPlots = {};
end

