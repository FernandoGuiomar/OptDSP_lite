function [] = entranceMsg(MSG,msgLevel)

% Last Update: 05/01/2018

global PROG;


%% Input Parser
if ~exist('msgLevel','var')
    msgLevel = 1;
end
if isfield(PROG,'showMessagesLevel')
    showMessagesLevel = PROG.showMessagesLevel;
else
    showMessagesLevel = 0;
end

%% Input Parameters
nCharsLine = 70;
nCharsMsg = length(MSG);
nSpacesInit = floor((nCharsLine-6-nCharsMsg)/2);
nSpacesEnd = ceil((nCharsLine-6-nCharsMsg)/2);

%% Print Message
if showMessagesLevel >= msgLevel
%     fprintf('\n\n');
    fprintf('\n%s\n',repmat('%',1,nCharsLine));
    fprintf('%%%% %s%s%s %%%%',repmat(' ',1,nSpacesInit),MSG,repmat(' ',1,nSpacesEnd));
    fprintf('\n%s\n',repmat('%',1,nCharsLine));
end