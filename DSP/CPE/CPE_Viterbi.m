function [Aout,phi] = CPE_Viterbi(Srx,Stx,nSpS,C,CPE)

% Last Update: 02/04/2019


%% Input Parser
if ~isfield(CPE,'p')
    CPE.p = 1;
end

%% Input Parameters
nTaps = CPE.nTaps;
CPE.nTaps = max(nTaps);
[nPol,nSamples] = size(Srx);
M = numel(C);

%% If Signal is Oversampled, Perform Downsampling
A_CPE = Srx(:,1:nSpS:end);

%% Viterbi & Viterbi Phase Estimation
[Ap,bnd] = deal(cell(1,nPol));
[phi,Ademod] = deal(zeros(size(A_CPE)));
for n = 1:nPol
    % mQAM Demodulation:
    switch CPE.decision
        case {'DA','data-aided'}
            Ademod(n,:) = demodQAM_DA(A_CPE(n,:),Stx(n,:));
        case 'data-aided (4th-power)'
            Ademod(n,:) = demodQAM_4thPower_DA(A_CPE(n,:),Stx(n,:),M);
        case {'DD','decision-directed'}
            Ademod(n,:) = demodQAM_DD(A_CPE(n,:),C);
        case {'DD (4th-power)','decision-directed (4th-power)'}
            Ademod(n,:) = demodQAM_4thPower_DD(A_CPE(n,:),C);            
        case 'QPSKpartition'
            % Ring Partitioning of QAM Constellation:
            [Ap{n},bnd{n}] = ringPartitionQAM(A_CPE(n,:),Stx(n,:),C);
            % Class Partitioning of QAM Constellation:
            Aclass(n) = classPartitionQAM(Ap{n},M,CPE.QAM_classes);
            % 4th-Power Demodulation:
            A4thPower(n) = demodQAM_4thPower(Aclass(n),M,CPE.p);
            % Sample Selection:
            if M == 8
                Ademod(n,:) = A4thPower(n).A1 + A4thPower(n).B1;
            else
                Ademod(n,:) = CPE_sampleSelection_mQAM(A4thPower(n),...
                    CPE.nTaps,CPE.convMethod);
            end
        case 'nthPower'
            Ademod(n,:) = demodQAM_nthPower(A_CPE(n,:),M);
        otherwise
            Aclass(n).A = A_CPE(n,:);
            % 4th-Power Demodulation:
            A4thPower(n) = demodQAM_4thPower(Aclass(n),M,CPE.p);
            Ademod(n,:) = A4thPower(n).A1;
    end
    % V&V Phase Estimation:
    if numel(nTaps) == 2
        % Phase Estimation with Larger Number of Taps:
        CPE.nTaps = max(nTaps);
        phi1(n,:) = VV_phaseEstimation(Ademod(n,:),CPE.nTaps,...
            CPE.convMethod,'[all QAM classes]');
        % Unwrap Phase:
        phi1(n,:) = unwrapPhase(phi1(n,:),CPE.decision);
        % Phase Estimation with Shorter Number of Taps:
        CPE.nTaps = min(nTaps);
        phi2(n,:) = VV_phaseEstimation(Ademod(n,:),CPE.nTaps,...
            CPE.convMethod,'[all QAM classes]');
        % Unwrap Phase:
        phi2(n,:) = unwrapPhase(phi2(n,:),CPE.decision);
        % Cycle-Slip Correction:
        phi(n,:) = VV_dualStage_CS_removal(phi1(n,:),phi2(n,:));
    else
        % Phase Estimation:
        phi(n,:) = VV_phaseEstimation(Ademod(n,:),CPE.nTaps,...
            CPE.convMethod,'[all QAM classes]');        
        % Unwrap Phase:
        phi(n,:) = unwrapPhase(phi(n,:),CPE.decision);
    end
end

%% Correct Carrier Phase
if nSpS > 1
    Aout = Srx.*exp(-1j*rectpulse(phi',nSpS)');
else
    Aout = Srx.*exp(-1j*phi);
end

%% Debug Plots
if isfield(CPE,'debugPlots')
    for m = 1:length(CPE.debugPlots)
        debugPlot = CPE.debugPlots{m};
        if any(strncmpi(debugPlot,{'ringPartition','all'},3))
            ringPartitionPlot(A_CPE,Ap,bnd);
        end
        if any(strcmpi(debugPlot,{'demodQAM','all'}))
            demodQAMplot(A4thPower);
        end
        if any(strncmpi(debugPlot,{'phase','all'},3))
            phaseCPEplot(phi,phi);
        end
        if any(strcmpi(debugPlot,{'demodQAM_motion','all'}))
            A = Ademod(1,:);
            A(A==0) = NaN;
            plotSpecs.blockSize = CPE.nTaps;
            plotSpecs.advanceBlock = ceil(CPE.nTaps/4);
            scatterPlotMotion(A,plotSpecs);
        end
    end
end
