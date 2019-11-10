function scatterPlotColor(S,varargin)
%scatterPlotColor   Draws a scatter plot with a colormap
%   This function draws a scatter plot of a given complex signal using a
%   colormap to highlight the probability density function of the
%   constellation symbols.
%
%   INPUTS:
%   S   := vector with the signal samples [1 x nSymbol]
%
%   OPTIONS:
%   markerSize  := size of the markers in the scatter plot 
%                   [default: 1.5]
%   histRes     := resolution (number of classes) for calculating the 
%                   signal histogram
%                   [default: 400]
%   colorMap    := colormap to use with the scatter plot
%                   [default: jet]
%   backColor   := background color of the scatter plot
%                   [default: 'w']
%   newFig      := flag to indicate if a new figure should be created
%                   [default: true]
%   savePNG     := file path to save the plot as a .png file (uses the
%                   export_fig function)
%                   [default: none]
%
%   EXAMPLES:
%   C = awgn(qammod(randi(64,1,2e5)-1,64),8);
%   scatterPlotColor(C);
%   scatterPlotColor(C,'res',200,'markersize',1,'colormap',hot,'backColor','none');
%   C2 = 1.5*awgn(qammod(randi(4,1,2e5)-1,4),15);
%   scatterPlotColor(C2,'newFig',false,'colormap',gray);
%
%
%   Author: Fernando Guiomar
%   Last Update: 13/04/2019

%% Input Parser
% Default Parameters:
markerSize = 1.5;
histRes = 400;
newFig = true;
cMap = jet;
backColor = 'w';
saveFig = false;
% Get Optional Parameters:
for n = 1:2:nargin-1
    varName = varargin{n};
    varValue = varargin{n+1};
    if contains(varName,'marker','IgnoreCase',true)
        markerSize = varValue;
    end
    if any(contains(varName,{'hist','res'},'IgnoreCase',true))
        histRes = varValue;
    end
    if any(contains(varName,{'newFig'},'IgnoreCase',true))
        newFig = varValue;
    end
    if contains(varName,'colorMap','IgnoreCase',true)
        cMap = varValue;
    end
    if contains(varName,'backColor','IgnoreCase',true)
        backColor = varValue;
    end
    if contains(varName,'savePNG','IgnoreCase',true)
        savePNG = varValue;
        saveFig = true;
    end
end

%% Input Parameters
if size(S,1) > 1
    S = reshape(S,1,numel(S));
end
I = real(S);
Q = imag(S);

%% Calculate Color Histogram
ht = hist3([I',Q'],[histRes histRes]);
normI = floor((I-min(I))/(max(I)-min(I))*0.9999*histRes) + 1;
normQ = floor((Q-min(Q))/(max(Q)-min(Q))*0.9999*histRes) + 1;
IQcolor = zeros(1,length(I));
for m = 1:length(I)
    IQcolor(m) = ht(normI(m),normQ(m));
end
% Calculate colors using chosen colormap:
IQcolor = round(IQcolor/max(IQcolor) * size(cMap,1));
IQcolor(~IQcolor) = 1;
IQcolor = cMap(IQcolor,:);

%% Plot Setup
if newFig
    figure();
end
hold on;

% Scatter plot:
scatter(I,Q,markerSize,IQcolor,'filled');

hold off;
axis image;
axis off;

% set(gcf,'color',backColor,'menubar','none','toolbar','none');

%% Save Figure
if saveFig
    export_fig(savePNG,'-png','-r300','-transparent');
end
