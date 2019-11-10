function [Srx,CPE] = CPE_pilotBased_opt(Srx,Stx,nSpS,CPE)

% Last Update: 04/11/2019


%% Input Parameters
nTapsMin = 1;
nTapsMax = 201;
debug = false;
if isfield(CPE,'nTaps_min')
    nTapsMin = CPE.nTaps_min;
end
if isfield(CPE,'nTaps_max')
    nTapsMax = CPE.nTaps_max;
end
if isfield(CPE,'debug')
    debug = CPE.debug;
end
nSamples = size(Stx,2);

%% If Signal is Oversampled, Perform Downsampling
ts0 = 1;
if isfield(CPE,'ts0')
    ts0 = CPE.ts0;
end
Srx_tmp = Srx(:,ts0:nSpS:end);

%% Synchronize and Extract Pilots
[~,~,Srx_PIL,Stx_PIL,pilot_idx] = pilotSymbols_rmv(Srx_tmp,Stx,CPE.PILOTS);

%% Optimize Number of Taps
if debug
    options = optimset('MaxFunEvals',1e4,'TolX',5e-1,'TolFun',1e-2,...
        'Display','iter','PlotFcns',@optimplotfval);
else
    options = optimset('MaxFunEvals',1e4,'TolX',5e-1,'TolFun',1e-2);
end
[nTaps_opt,opt_FOM] = fminbnd(@(nTaps) CPE_pilotBased_minFOM(...
    Srx_tmp,Stx,Srx_PIL,Stx_PIL,pilot_idx,nTaps,nSamples),...
    nTapsMin,nTapsMax,options);

%% Apply Pilot-Based CPE With Optimum Number of Taps
CPE.nTaps = round(nTaps_opt);
[Srx,CPE.phi] = CPE_pilotBased(Srx,Stx,nSpS,CPE);

%% Output CPE Parameters
CPE.nTaps_opt = nTaps_opt;
CPE.FOM_error = opt_FOM;

end

%% Aux Functions
function opt_FOM = CPE_pilotBased_minFOM(Srx,Stx,Srx_PIL,Stx_PIL,...
    pilot_idx,nTaps,nSamples)
    
    % Input Parameters:
    nTaps = round(nTaps);
    nPol = size(Srx,1);
    % Calculate Phase Using Pilots:
    phi = zeros(nPol,nSamples);
    for n = 1:nPol
        F = Stx_PIL{n} .* conj(Srx_PIL{n});
        % Apply Moving Average to Average Out Noise:
        H = movmean(F,nTaps,2);
        % Unwrap the Phase:
        phi_CPE = unwrap(atan2(imag(H),real(H)),[],2);
        % Interpolate:
        phi(n,:) = interp1(pilot_idx{n},phi_CPE,1:nSamples,...
            'linear','extrap');
    end
    % Compensate Phase Noise:
    Srx = Srx.*exp(1j*phi);
   
    % Calculate Residual Phase Noise in the Compensate Signal:
    var_FOM = zeros(1,size(Srx,1));
    for m = 1:size(Srx,1)
        Scolapsed = QAM_demod(Srx(m,:),Stx(m,:),'fully-colapsed');
        var_FOM(m) = var(imag(Scolapsed))/var(real(Scolapsed));
    end
    opt_FOM = abs(1 - mean(var_FOM));    
end