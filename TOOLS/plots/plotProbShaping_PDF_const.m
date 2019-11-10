function [hFig,hBar] = plotProbShaping_PDF_const(varargin)

% Last Update: 08/01/2019


%% Input Parser
% if ~exist('contains','builtin')
%     contains = @(x,y,a,b) any(strfind(x,y));
% end
for n = 1:2:nargin
    varName = varargin{n};
    varValue = varargin{n+1};
    if contains(varName,'const','IgnoreCase',true)
        C = varValue;
    elseif contains(varName,'symbol','IgnoreCase',true)
        syms = varValue;
    elseif contains(varName,'prob','IgnoreCase',true)
        symProb = varValue;
    elseif contains(varName,'bit-rate','IgnoreCase',true)
        Rb = varValue;
    elseif contains(varName,'color','IgnoreCase',true)
        color = varValue;
    elseif contains(varName,'filepath','IgnoreCase',true)
        filePath = varValue;
    elseif contains(varName,'axis','IgnoreCase',true)
        hAxis = varValue;
    elseif contains(varName,'fontsize','IgnoreCase',true)
        fontSize = varValue;
    end
end
% Default Input Parameter Options:
if ~exist('color','var')
    color = [0 0.24 0.431];
end
if ~exist('filePath','var')
    exportFig = false;
else
    exportFig = true;
end
if ~exist('fontSize','var')
    fontSize = 12;
end

%% Define Colors
color1 = color*0.2;
color2 = color;
color_map(:,1) = linspace(color1(1),color2(1),128);
color_map(:,2) = linspace(color1(2),color2(2),128);
color_map(:,3) = linspace(color1(3),color2(3),128);

%% Input Parameters
M = numel(C);
N_I = unique(real(C));
N_Q = unique(imag(C));
ni = numel(N_I);
nq = numel(N_Q);

%% Calculate Symbol Probabilities
if ~exist('symProb','var')
    edges = -0.5:1:M-0.5;
    symProb = histcounts(syms(:),edges,'Normalization','prob').';
end

%% Calculate Constellation Entropy
tmp = log2(symProb);
tmp(isinf(tmp)) = 0;
H = -sum(symProb.*tmp);
symProb = symProb*100;

%% Re-order Constellation
for n = 1:ni
    for k = 1:nq
        idx = find(C == N_I(n) + 1j*N_Q(k));
        if ~isempty(idx)
            P(n,k) = symProb(idx);
        else
            P(n,k) = 0;
        end
    end
end

% Check if there are empty columns / rows:
for n = 1:ni
    if ~any(P(n,:))
        delRow(n) = true;
    else
        delRow(n) = false;
    end
end
for n = 1:ni
    if ~any(P(:,n))
        delCol(n) = true;
    else
        delCol(n) = false;
    end
end
P = P(~delRow,~delCol);
M = numel(P);
ni = sqrt(M);
nq = ni;

%% Plot Constellation PDF
% if ~exist('hAxis','var')
% end
if ~exist('hAxis','var')
    hFig = figure();
    hAxis = gca;
end
hBar = bar3(hAxis,P);
for k = 1:length(hBar)
    zdata = hBar(k).ZData;
    hBar(k).CData = zdata;
    hBar(k).FaceColor = 'interp';
end
colormap(hAxis,color_map)
set(hBar,'EdgeColor','w');
set(hAxis,'GridLineStyle','--','XMinorTick','off','XMinorGrid','off');
xAxis = get(hAxis,'xaxis');
set(xAxis,'TickLabels',repmat({},1,numel(get(xAxis,'TickLabels'))));
yAxis = get(hAxis,'yaxis');
set(yAxis,'TickLabels',repmat({},1,numel(get(yAxis,'TickLabels'))));
zAxis = get(hAxis,'zaxis');
set(zAxis,'TickLabels',repmat({},1,numel(get(yAxis,'TickLabels'))));
% set(zAxis,'TickLabelInterpreter','latex','FontSize',fontSize);
axis(hAxis,[0.5 ni+0.5 0.5 nq+0.5 0 Inf]);
% axis square

% xlabel('In-Phase','Interpreter','latex','FontSize',12);
zlabel(hAxis,'Probability','Interpreter','latex','FontSize',fontSize);

if exist('Rb','var')
    title(hAxis,['PS-',num2str(M),'QAM | ',num2str(Rb*1e-9,'%1.0f'),...
        'G | $H = ',num2str(H,'%1.2f'),'$'],'Interpreter','latex',...
        'FontSize',fontSize);
else
    title(hAxis,['PS-',num2str(M),'QAM | $H = ',num2str(H,'%1.2f'),'$'],...
        'Interpreter','latex','FontSize',fontSize);
end    
set(hAxis.Parent,'Color','w');

%% Export Figure
if exportFig
    export_fig(filePath,'-pdf','-append');
end
% set(gcf,'Position',[559 528 235 207],'PaperPositionMode','auto')
