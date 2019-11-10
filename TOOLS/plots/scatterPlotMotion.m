function scatterPlotMotion(y,varargin)

% Last Update: 13/04/2019


%% Input Parser
y = y(:);
% Default Parameters:
blockSize = 5e3;
advanceBlock = 1e2;
plotPause = 0.1;
newFig = true;
markerSize = 5;
markerColor = 'k';
% Get Optional Parameters:
for n = 1:2:nargin-1
    varName = varargin{n};
    varValue = varargin{n+1};
    if contains(varName,'marker','IgnoreCase',true)
        markerSize = varValue;
    end
    if contains(varName,'markerColor','IgnoreCase',true)
        markerColor = varValue;
    end
    if contains(varName,'newFig','IgnoreCase',true)
        newFig = varValue;
    end
    if contains(varName,'blockSize','IgnoreCase',true)
        blockSize = varValue;
    end
    if contains(varName,'advanceBlock','IgnoreCase',true)
        advanceBlock = varValue;
    end
    if contains(varName,'plotPause','IgnoreCase',true)
        plotPause = varValue;
    end
end

%% Plot Setup
nSamples = length(y);
nPlots = nSamples - blockSize + 1;
maxIQ = max([max(real(y)) max(imag(y))]);
if newFig
    figure();
end
upd = textprogressbar(nPlots,'startmsg','running scatterPlotMotion...',...
    'endmsg','done!','showactualnum',true,'updatestep',1);
for m = 1:nPlots
    ni = (m-1)*advanceBlock+1;
    nf = (m-1)*advanceBlock+blockSize;

    % plot signal constellation:
    I = real(y(ni:nf));
    Q = imag(y(ni:nf));
    hPlot = plot(I,Q,'.');
    set(hPlot,'MarkerSize',markerSize,'color',markerColor);
    axis([-maxIQ maxIQ -maxIQ maxIQ]);
    pause(plotPause);
    upd(m);
end

