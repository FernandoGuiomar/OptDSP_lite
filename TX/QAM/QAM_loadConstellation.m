function [const,symbolMap] = QAM_loadConstellation(MF_ID)

% Last Update: 13/02/2018


%% Load Constellation
C = load(MF_ID);
const = C.Constellation;
symbolMap = C.SymbolMapping;
