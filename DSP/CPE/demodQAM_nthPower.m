function S = demodQAM_nthPower(S,M)


%% Demodulate
if M == 16
    % 4th Power Demod:
    S = abs(S).*exp(1j*angle(S)*4);
    % pi Rotation:
    S = S*exp(1j*pi);
    % nth Power Demod:
    c = 2*pi/(pi-4*atan(1/3));
    S = abs(S).*exp(1j*angle(S)*c);
end


%         case 'recenter'
%             S = A.A;
%             % 4th Power Demod:
%             S = abs(S).*exp(1j*angle(S)*4);
%             % pi Rotation:
%             S = S*exp(1j*pi);
%             % 1/4th Power:
%             S = abs(S).*exp(1j*angle(S)/4);
%             % Recenter:
% %                 a=(-pi+4*atan(3))/4;
% %                 d=sqrt(mean(abs(S).^2)/10);
% %                 c=sqrt(10)*d*cos(a);
%             c = 2/3;
%             S = S-c;
%             % pi/4 Rotation:
%             S = S*exp(1j*pi/4);
%             %
%             Sp = ringPartitionQAM(S,CPE,0.555555555555555);
%             % 4th Power Demod:
%             A.A1 = abs(S).*exp(1j*angle(S)*4);
