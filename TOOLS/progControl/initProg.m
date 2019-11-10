function initProg()

% Last Update: 08/11/2019


%% Set Global PROG
global PROG;

%% Default PROG Parameters
if ~isfield(PROG,'showMessagesLevel')
    PROG.showMessagesLevel = 1;
end
PROG.progressBar = 0;
try
    PROG.GPU = gpuDevice;
    PROG.useGPU = true;
catch
    PROG.useGPU = false;
end

%% Define Start Date and Timer
PROG.myTic = tic;
PROG.dateStart  = datestr(clock);
myMessages(['Current Date: ',PROG.dateStart,'\n\n'],0);

%% Print Entrance Message
entranceMsg('PROGRAM INITIALIZATION');

