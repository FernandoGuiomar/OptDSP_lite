function [Aout] = demodQAM_4thPower_DA(S,txSignal,M)

% Last Update: 02/02/2019


%% Input Parser
txSignal = round(txSignal*1e5)/1e5;

%% Class Partition
if M == 16
    I = real(txSignal);
    Q = imag(txSignal);
    I_set = unique(real(txSignal));
    Q_set = unique(imag(txSignal));
    classA_ind = find(abs(I) == abs(Q));
    classA = S(classA_ind);
    classB1_ind = find(abs(I) == max(I_set) & abs(Q) == Q_set(3) & ...
        sign(I) == sign(Q) | abs(I) == I_set(3) & abs(Q) == max(Q_set) ...
        & sign(I) ~= sign(Q));
    classB1 = S(classB1_ind);
    classB2_ind = find(abs(Q) == max(Q_set) & abs(I) == I_set(3) & ...
        sign(I) == sign(Q) | abs(Q) == Q_set(3) & abs(I) == max(I_set) ...
        & sign(I) ~= sign(Q));
    classB2 = S(classB2_ind);
end

%% Demodulation
if M == 16
    phiRotB = atan(3)-pi/4;
    classA = abs(classA).*exp(1j*angle(classA)*4);
    classB1 = classB1*exp(1j*phiRotB);
    classB1 = abs(classB1).*exp(1j*angle(classB1)*4);
    classB2 = classB2*exp(-1j*phiRotB);
    classB2 = abs(classB2).*exp(1j*angle(classB2)*4);
end

%% Output Signal
if M == 16
    Aout = zeros(size(S));
    Aout(classA_ind) = classA;
    Aout(classB1_ind) = classB1;
    Aout(classB2_ind) = classB2;
end

