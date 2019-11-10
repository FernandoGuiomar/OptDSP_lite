function [] = exitProg()

% Last Update: 27/04/2016

global PROG;

%% Define Ending Date and Elapsed Time
PROG.elapsedTime = toc(PROG.myTic);
PROG.dateEnd     = datestr(clock);

%% Print Exit Message
fprintf('\n\nTotal Elapsed Time: %1.4f [s]\n',PROG.elapsedTime);
entranceMsg('END');

%% Ready Sound
% WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
% Audio = audioplayer(WarnWave, 22050);
% play(Audio);
