function scatterPlot(y,varargin)

% Last Update: 08/10/2019


%% Input Parser
% Detect number and type of inputs:
if ~iscell(y)
    nPol = size(y,1);
    yCell = cell(1,nPol);
    for n = 1:nPol
        yCell{n} = y(n,:);
    end
    y = yCell;
end
nPol = length(y);

% Default Parameters:
markerSig = '.';
markerSizeSig = 2;
markerColorSig = [0.0 0.24 0.431];
markerError = '.';
markerSizeError = 2;
markerColorError = [0.73 0.07 0.169];
markerConst = 'o';
markerSizeConst = 8;
markerColorConst = [0.9 0.9 0.9];
showIdealConst = true;
showDecisionGrid = true;

for n = 1:2:nargin-1
    varName = varargin{n};
    varValue = varargin{n+1};
    if contains(varName,'res','IgnoreCase',true)
        RES = varValue;
    elseif contains(varName,'BER','IgnoreCase',true)
        BER = varValue;
    elseif contains(varName,'EVM','IgnoreCase',true)
        EVM = varValue;
    elseif contains(varName,'axis','IgnoreCase',true)
        hAxis = varValue;
    elseif contains(varName,'marker:sig','IgnoreCase',true)
        markerSig = varValue;
    elseif contains(varName,'markersize:sig','IgnoreCase',true)
        markerSizeSig = varValue;
    elseif contains(varName,'markercolor:sig','IgnoreCase',true)
        markerColorSig = varValue;
    elseif contains(varName,'marker:error','IgnoreCase',true)
        markerError = varValue;
    elseif contains(varName,'markersize:error','IgnoreCase',true)
        markerSizeError = varValue;
    elseif contains(varName,'markercolor:error','IgnoreCase',true)
        markerColorError = varValue;
    elseif contains(varName,'marker:const','IgnoreCase',true)
        markerConst = varValue;
    elseif contains(varName,'markersize:const','IgnoreCase',true)
        markerSizeConst = varValue;
    elseif contains(varName,'markercolor:const','IgnoreCase',true)
        markerColorConst = varValue;
    elseif contains(varName,'showIdealConst','IgnoreCase',true)
        showIdealConst = varValue;
    elseif contains(varName,'showDecisionGrid','IgnoreCase',true)
        showDecisionGrid = varValue;
    elseif contains(varName,'const','IgnoreCase',true)
        C = varValue;
    end
end

% Check for ideal constellation:
if exist('C','var')
    if size(C,2) == 1
        C = repmat(C,1,nPol);
    end
    M = numel(C)/nPol;
end

% Check for new figure flag:
if ~exist('hAxis','var')
    newFig = true;
else
    newFig = false;
end
if newFig
    hFig = figure();
    hAxis = gca;
    set(hFig,'NumberTitle','off');
end

%% Plot Setup
maxIQ = 0;
hSubAxis = hAxis;
for n = 1:nPol
    if newFig && nPol > 1
        hSubAxis(n) = subplot(1,nPol,n);
        hAxis = hSubAxis(n);
    end
    % plot signal constellation:
    I = real(y{n});
    Q = imag(y{n});
    maxIQ = max([I Q maxIQ]);
    hPlot = plot(hAxis,I,Q,'.k');
    hold(hAxis,'on');
    set(hPlot,'MarkerSize',markerSizeSig,'Marker',markerSig,...
        'Color',markerColorSig,'LineStyle','none');
    % plot errorSyms (if any):
    if exist('RES','var') && isfield(RES,'SER')
        if n == 1
            try
                errorSyms = y{n}(RES.SER.errPosX);
            catch
                errorSyms = y{n}(RES.SER.errPosX{1});
            end
        else
            try
                errorSyms = y{n}(RES.SER.errPosY);
            catch
                errorSyms = y{n}(RES.SER.errPosY{1});
            end                
        end
        I = real(errorSyms);
        Q = imag(errorSyms);
        hPlot = plot(hAxis,I,Q);
        set(hPlot,'MarkerSize',markerSizeError,'Marker',markerError,...
            'Color',markerColorError,'LineStyle','none');
    end
    % plot ideal constellation/decision grid:
    if exist('C','var') & ~isempty(C) & ~isnan(C)
        I = real(C(:,n));
        Q = imag(C(:,n));
        % plot ideal constellation:
        if showIdealConst
            hPlot = plot(hAxis,I,Q);
            set(hPlot,'MarkerSize',markerSizeConst,'Marker',markerConst,...
                'Color',markerColorConst,'LineStyle','none');
        end
        % plot decision grid:
        if showDecisionGrid
            I = sort(unique(I));
            Q = sort(unique(Q));
            if numel(I) <= sqrt(M) && numel(Q) <= sqrt(M)
                for m = 1:length(I)-1
                    meanI = (I(m) + I(m+1))/2;
                    meanQ = (Q(m) + Q(m+1))/2;
                    minQ = min(Q) - max(diff(Q))/2;
                    maxQ = max(Q) + max(diff(Q))/2;
                    minI = min(I) - max(diff(I))/2;
                    maxI = max(I) + max(diff(I))/2;
                    hLine = line(hAxis,rectpulse(meanQ,2),[minQ maxQ]);
                    set(hLine,'Color','k','LineStyle','--','LineWidth',1.5);
                    hLine = line(hAxis,[minI maxI],rectpulse(meanI,2));
                    set(hLine,'Color','k','LineStyle','--','LineWidth',1.5);
                end
            end
        end
    end
    axis(hAxis,'square');
    axis(hAxis,[-maxIQ maxIQ -maxIQ maxIQ]);
    axis(hAxis,'off');
end
hold(hAxis,'off');

%% Annotations on the Figure
[isBER,isSER,isEVM,isGMI] = deal(false);
if newFig
    for n = 1:nPol
        [str_BER{n},str_SER{n},str_Q{n},str_EVM{n},str_GMI{n},str_SNR{n}] = deal([]);
        if (exist('RES','var') && isfield(RES,'BER')) || exist('BER','var')
            isBER = true;
            if n == 1
                if exist('BER','var')
                    BERx = BER(1);
                else
                    BERx = RES.BER.BERx;
                end
                str_BER{n} = ['BER = ' num2str(BERx,'%1.2e')];
                str_Q{n} = ['Q = ' num2str(Qfactor(BERx),'%1.2f') ' dB'];
            elseif n == 2
                if exist('BER','var')
                    BERy = BER(2);
                else
                    BERy = RES.BER.BERy;
                end
                str_BER{n} = ['BER = ' num2str(BERy,'%1.2e')];
                str_Q{n} = ['Q = ' num2str(Qfactor(BERy),'%1.2f') ' dB'];
            end
        end
%         if nargin >= 2 && isfield(RES,'SER')
%             isSER = true;
%             if n == 1
%                 str_SER{n} = ['SER = ' num2str(RES.SER.SERx,'%1.2e')];
%             elseif n == 2
%                 str_SER{n} = ['SER = ' num2str(RES.SER.SERy,'%1.2e')];
%             end
%         end
        if (exist('RES','var') && isfield(RES,'EVM')) || exist('EVM','var')
            isEVM = true;
            if n == 1
                if exist('EVM','var')
                    EVMx = EVM(1);
                else
                    EVMx = RES.EVM.EVMx;
                end
                str_EVM{n} = ['EVM = ' num2str(EVMx,'%1.2f') '\%'];
                str_SNR{n} = ['SNR = ' num2str(-20*log10(EVMx/100),'%1.2f') ' dB'];
            elseif n == 2
                if exist('EVM','var')
                    EVMy = EVM(2);
                else
                    EVMy = RES.EVM.EVMy;
                end
                str_EVM{n} = ['EVM = ' num2str(EVMy,'%1.2f') '\%'];
                str_SNR{n} = ['SNR = ' num2str(-20*log10(EVMy/100),'%1.2f') ' dB'];
            end
        end
        if exist('RES','var') && isfield(RES,'GMI')
            isGMI = true;
            if n == 1
                str_GMI{n} = ['GMI = ' num2str(RES.GMI.GMIx,'%1.2f')];
                str_NGMI{n} = ['NGMI = ' num2str(RES.GMI.NGMIx,'%1.2f')];
            elseif n == 2
                str_GMI{n} = ['GMI = ' num2str(RES.GMI.GMIy,'%1.2f')];
                str_NGMI{n} = ['NGMI = ' num2str(RES.GMI.NGMIy,'%1.2f')];
            end
        end
        if n == 1
            str_pol = ['\fontsize{14}{0}\selectfont\makebox[4in][c]{\textbf{x-pol}}'];
        elseif n == 2
            str_pol = ['\fontsize{14}{0}\selectfont\makebox[4in][c]{\textbf{y-pol}}'];
        end
        strTitle{1} = str_pol;
        k = 2;
        if isBER
            strTitle{k} = ['\makebox[4in][c]{' str_BER{n} ' $|$ ' ...
                str_Q{n} '}'];
            k = k + 1;
        end
        if isEVM
            strTitle{k} = ['\makebox[4in][c]{' str_EVM{n} ' $|$ ' ...
                str_SNR{n} '}'];
            k = k + 1;
        end
        if isGMI
            strTitle{k} = ['\makebox[4in][c]{' str_GMI{n} ' $|$ ' ...
                str_NGMI{n} '}'];
            k = k + 1;
        end
        if isBER || isEVM || isGMI
            hTitle(n) = title(hSubAxis(n),strTitle);
            set(hTitle(n),'Interpreter','latex','FontSize',10);
        end
    end
end
