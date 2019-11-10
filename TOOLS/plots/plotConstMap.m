function [hFig,hPlot,hText] = plotConstMap(IQmap,sym2bitMap,symProb)

% Last Update: 02/10/2018


%% Input Parameters
M = numel(IQmap);
if nargin < 3
    symProb = repmat(1/M,1,M);
end

%% Define Colormap
hFig = figure();
color_map = colormap('hot');
color_map = color_map(8:40,:);

%% Plot
for n = 1:M
    IQ = IQmap(n);
    hPlot(n) = plot(IQ,'xb');
    hold on;
    idx = ceil(symProb(n)/max(symProb)*size(color_map,1));
    if idx
        thisColor = color_map(idx,:);
        set(hPlot(n),'LineWidth',3,'MarkerSize',12,'color',thisColor);
    else
        set(hPlot(n),'visible',false);
    end
    bits = sym2bitMap(n,:);
    bitString = num2str(bits);
    bitString(bitString==' ') = '';
    hText(n) = text(real(IQ),imag(IQ)-0.05,...
        ['\textbf{' bitString '}']);
end
set(hText,'HorizontalAlignment','center','VerticalAlignment','top',...
    'Interpreter','latex','fontsize',8);

%% Plot QAM Grid
I = sort(unique(real(IQmap)));
Q = sort(unique(imag(IQmap)));
minI = I(1)+(I(1)-I(2))/2;
maxI = I(end)-(I(1)-I(2))/2;
minQ = Q(1)+(Q(1)-Q(2))/2;
maxQ = Q(end)-(Q(1)-Q(2))/2;
for m = 1:length(I)-1
    meanI = (I(m)+I(m+1))/2;
    meanQ = (Q(m)+Q(m+1))/2;
    hLine = line(rectpulse(meanQ,2),[minI maxI]);
    set(hLine,'Color','k','LineStyle','--','LineWidth',1);
    hLine = line([minQ maxQ],rectpulse(meanI,2));
    set(hLine,'Color','k','LineStyle','--','LineWidth',1);
end

axis image;
axis square
axis off;
