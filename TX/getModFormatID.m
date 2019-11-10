function [MF_ID,modFormat,mode_QAM] = getModFormatID(M,encoding)

% Last Update: 16/05/2018


%% Input Parser
if nargin == 1
    encoding = 'normal';
end

%% Set Modulation Format ID
if mod(sqrt(M),1) == 0 && M >=4
    mode_QAM = 'square-QAM';
    if M > 4
        modFormat = [num2str(M),'QAM'];
        MF_ID = [modFormat, '_square'];
    elseif M == 4
        modFormat = 'QPSK';
        MF_ID = modFormat;
    end
elseif mod(log2(M),1) == 0
    if M > 2
        mode_QAM = 'cross-QAM';
        modFormat = [num2str(M),'QAM'];
        MF_ID = [modFormat, '_cross'];
    elseif M == 2
        mode_QAM = 'square-QAM';
        modFormat = 'BPSK';
        MF_ID = modFormat;
    end
else
    error('The QAM_config function is only compatible with QAM constellation of size 2^n or n^2, for any integer n. The parsed constellation size, %d, does not fulfill this condition. Please consider changing the constellation size.',M);
end
if strcmp(encoding,'diff-quad') && M >= 4
    MF_ID = [MF_ID '_DiffQuad'];
end
