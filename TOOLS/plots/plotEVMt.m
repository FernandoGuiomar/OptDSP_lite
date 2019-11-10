function plotEVMt(EVM)

% Last Update: 17/04/2018


%% Input Parser
if ~isfield(EVM,'EVMx_t')
    error('Could not find EVMx_t field in the EVM struct!');
end

%% Input Parameters
nSyms = length(EVM.EVMx_t);
blue = [0 0.2400 0.4310];
red = [0.7300 0.0700 0.1690];

%% Plot EVM Evolution
figure();
hold on;
hPlot = plot(1:nSyms,EVM.EVMx_t);
if isfield(EVM,'EVMy_t')
    hPlot(2) = plot(1:nSyms,EVM.EVMy_t);
end

% Plot Format:
set(hPlot,'Color',blue,'linewidth',1);
if isfield(EVM,'EVMy_t')
    set(hPlot(2),'Color',red);
end

% Axis Properties:
xlabel('Symbol Number','Interpreter','latex','FontSize',11);
ylabel('EVM [\%]','Interpreter','latex','FontSize',11);
xAxis = get(gca,'xaxis');
set(xAxis,'TickLabelInterpreter','latex','FontSize',11);
yAxis = get(gca,'yaxis');
set(yAxis,'TickLabelInterpreter','latex','FontSize',11);
set(gca,'YScale','linear','YMinorGrid','off','Box','on',...
    'PlotBoxAspectRatio',[1 0.5 1]);
axis([1,nSyms,-inf,inf]);

% Gridlines:
grid on;
set(gca,'GridLineStyle','--','XMinorTick','off','XMinorGrid','off');

% Title:
hTitle = title(['\textbf{EVM Evolution (',num2str(EVM.tMem),...
    ' samples of memory)}']);
set(hTitle,'Interpreter','latex','Color',blue);

% Legend:
if isfield(EVM,'EVMy_t')
    hLeg = legend(hPlot,'x-pol','y-pol');
    set(hLeg,'Interpreter','latex','fontsize',9,'Location','NorthWest');
end