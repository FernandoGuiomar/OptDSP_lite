function [B_sync,delay,peakGain,rot] = syncSignals(A,B,SYNC)

% Last Update: 08/11/2019


%% Input Parser
showPlots = false;
maxDelay = Inf;
minDelay = -Inf;
evalDelay = true;
if ~exist('SYNC','var')
    SYNC.method = 'complexField';
else
    if ~isfield(SYNC,'method')
        SYNC.method = 'complexField';
    end
end
if isfield(SYNC,'presetDelay')
    delay = SYNC.presetDelay;
    evalDelay = false;
end
if isfield(SYNC,'maxDelay')
    maxDelay = SYNC.maxDelay;
end
if isfield(SYNC,'minDelay')
    minDelay = SYNC.minDelay;
end
if ~isfield(SYNC,'nPeakIgnore')
    SYNC.nPeakIgnore = 0;
end
if isfield(SYNC,'debug')
    showPlots = SYNC.debug;
end

%% Input Parameters
N_A = length(A);
N_B = length(B);
if N_A > N_B
    A = A(1:N_B);
end

%% Calculate Cross Correlation Between A and B
if evalDelay
    if strcmp(SYNC.method,'abs')
        [AB,lags] = xcorr(abs(A) - mean(abs(A)),abs(B) - mean(abs(B)));
    else
        [AB,lags] = xcorr(A,B);
    end
    AB = AB(lags < maxDelay);
    lags = lags(lags < maxDelay);

    AB = AB(lags > minDelay);
    lags = lags(lags > minDelay);
end

%% Calculate SyncPoint
if evalDelay
    meanAB = mean(abs(AB));
    [maxAB,maxABind] = max(abs(AB));
    % Ignore N first correlation peaks, if applicable:
    for n = 1:SYNC.nPeakIgnore
        AB(max(1,maxABind-10):min(numel(AB),maxABind+10)) = 0;
        [maxAB,maxABind] = max(abs(AB));
    end
    peakGain = 10*log10(maxAB/meanAB);
    delay = lags(maxABind);
end

%% Synchronize B relatively to A
if delay >= 0
    Bhead = B(end-delay+1:end);
    Btail = B(1:mod(N_A-delay,N_B));
    B_sync = [Bhead repmat(B,1,floor((N_A-delay)/N_B)) Btail];
else
    Bhead = B(abs(delay)+1:end);
    Btail = B(1:mod(N_A-length(Bhead),N_B));
    B_sync = [Bhead repmat(B,1,ceil((N_A-abs(delay))/N_B)) Btail];
end

%% Truncate B if lenght(B)>length(A)
if length(B_sync) > N_A
    B_sync = B_sync(1:N_A);
end

%% Find Rotation
if exist('maxABind','var')
    if abs(imag(AB(maxABind))) > abs(real(AB(maxABind)))
        if imag(AB(maxABind)) < 0
            rot = -pi/2;
        else
            rot = pi/2;
        end
    else
        if real(AB(maxABind))<0
            rot = -pi;
        else
            rot = 0;
        end
    end
else
    rot = 0;
end
B_sync = B_sync*exp(1j*rot);

%% Debug
if showPlots && evalDelay
    red = [0.73 0.07 0.169];
    blue = [0.0 0.24 0.431];

    hFig = figure();
    
    AB = AB/max(abs(AB));
    y = 10*log10(abs(AB));
    yMax = 1;

    hPlot(1) = plot(lags,y);
    hold on;
    hPlot(2) = plot(delay,y(lags==delay),'rx');

    % Plot Formatting:
    set(hPlot(1),'color',blue,'marker','none','LineStyle','-',...
        'LineWidth',0.5);
    set(hPlot(2),'color',red,'marker','o','LineStyle',':',...
        'MarkerSize',6,'LineWidth',1.5,'MarkerFaceColor','w');
    
    % Axis Formatting:
    xlabel('Sample Index','Interpreter','latex','FontSize',11);
    ylabel('Correlation Strength [dB]','Interpreter','latex','FontSize',11);
    xAxis = get(gca,'xaxis');
    set(xAxis,'TickLabelInterpreter','latex','FontSize',12);
    yAxis = get(gca,'yaxis');
    set(yAxis,'TickLabelInterpreter','latex','FontSize',12);
    set(gca,'PlotBoxAspectRatio',[1 0.6 1],'Box','on');

    xText = delay/2;
    yText = -1;
    txtString = ['$\,\,$delay$=',num2str(delay) '\,\,$'];
    hText = text(xText,yText,txtString);
    
    set(hText,'HorizontalAlignment','center','Interpreter','latex',...
        'BackgroundColor','w','margin',0.1,'edgecolor',blue);
    set(gca,'YLim',[yMax-20 yMax],'XLim',[lags(1),lags(end)]);
    
    % Gridlines:
    grid on;
    set(gca,'GridLineStyle','--');
end



