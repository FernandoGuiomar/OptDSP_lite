function myMessages(string,msgLevel,msgType)

% Last Update: 05/01/2018


global PROG;

%% Input Parser
if ~exist('msgType','var')
    msgType = 'regular';
end
if isfield(PROG,'showMessagesLevel')
    showMessagesLevel = PROG.showMessagesLevel;
else
    showMessagesLevel = 0;
end

%% Print Message
if msgLevel <= showMessagesLevel
    switch msgType
        case 'regular'
            fprintf(string);
        case 'warning'
            warning(string);
    end
end

