function [Aout] = CPE_sampleSelection_mQAM(Ain,nTaps,convMethod)

% Last Update: 19/02/2018


%% Input Parameters
nSamples = length(Ain.A1);
classes = fieldnames(Ain);
k = 1;
for n = 1:length(classes)
    c = classes{n};
    if length(c) == 1
        classesQAM(k,1) = c;
        k = k+1;
    end
end
classesQAM = classesQAM(classesQAM~='A');
nClass = size(classesQAM,1);

%% Select Samples Closest to QPSK-like Phase Estimation
A_mQAM = zeros(nClass,nSamples);
if nClass
    % Phase Estimation for Class A Symbols
    [~,~,A_QPSK] = VV_phaseEstimation(Ain.A1,nTaps,convMethod,'[class A]');
    % Select "Best Samples" in Other mQAM subClasses
    for k = 1:nClass
        c = classesQAM(k);
        A1 = eval(['Ain.' c '1;']);
        A2 = eval(['Ain.' c '2;']);
        d1 = abs(A_QPSK-A1);
        d2 = abs(A_QPSK-A2);
        if strcmpi(c,'E')
            A3 = eval(['Ain.' c '3;']);
            d3 = abs(A_QPSK-A3);
            A_mQAM(k,d1<=d2 & d1<=d3) = A1(d1<=d2 & d1<=d3);
            A_mQAM(k,d2<d1 & d2<d3) = A2(d2<d1 & d2<d3);
            A_mQAM(k,d3<d1 & d3<d2) = A3(d3<d1 & d3<d2);
        else
            A_mQAM(k,d1<=d2) = A1(d1<=d2);
            A_mQAM(k,d2<d1) = A2(d2<d1);
        end
    end
    Aout = Ain.A1 + sum(A_mQAM,1);
else
    Aout = Ain.A1;
end

