function [A] = demodQAM_4thPower(A,M,p)

% Last Update: 02/05/2019


%% Check for Class A (QPSK-like) Symbols
if isfield(A,'A')
    A.A1 = abs(A.A).^p.*exp(1j*angle(A.A)*4);
end

%% 4th Power Demodulation for Other (non-QPSK) Symbols
if M == 64
    % Rotation angles definition:
    phiRotB = atan(3) - pi/4;
    phiRotC = atan(5) - pi/4;
    phiRotD = atan(5/3) - pi/4;
    phiRotE = atan(7) - pi/4;
    phiRotF = atan(7/3) - pi/4;
    phiRotG = atan(7/5) - pi/4;
    % 4th power demodulation:
    if isfield(A,'B')
        A.B1 = A.B.*exp(1j*phiRotB);
        A.B1 = abs(A.B1).^p.*exp(1j*angle(A.B1)*4);
        A.B2 = A.B.*exp(-1j*phiRotB);
        A.B2 = abs(A.B2).^p.*exp(1j*angle(A.B2)*4);
    end
    if isfield(A,'C')
        A.C1 = A.C.*exp(1j*phiRotC);
        A.C1 = abs(A.C1).^p.*exp(1j*angle(A.C1)*4);
        A.C2 = A.C.*exp(-1j*phiRotC);
        A.C2 = abs(A.C2).^p.*exp(1j*angle(A.C2)*4);
    end
    if isfield(A,'D')
        A.D1 = A.D.*exp(1j*phiRotD);
        A.D1 = abs(A.D1).^p.*exp(1j*angle(A.D1)*4);
        A.D2 = A.D.*exp(-1j*phiRotD);
        A.D2 = abs(A.D2).^p.*exp(1j*angle(A.D2)*4);
    end
    if isfield(A,'E')
        A.E1 = A.E.*exp(1j*phiRotE);
        A.E1 = abs(A.E1).^p.*exp(1j*angle(A.E1)*4);
        A.E2 = A.E.*exp(-1j*phiRotE);
        A.E2 = abs(A.E2).^p.*exp(1j*angle(A.E2)*4);
        A.E3 = abs(A.E).^p.*exp(1j*angle(A.E)*4);
    end
    if isfield(A,'F')
        A.F1 = A.F.*exp(1j*phiRotF);
        A.F1 = abs(A.F1).^p.*exp(1j*angle(A.F1)*4);
        A.F2 = A.F.*exp(-1j*phiRotF);
        A.F2 = abs(A.F2).^p.*exp(1j*angle(A.F2)*4);
    end
    if isfield(A,'G')
        A.G1 = A.G.*exp(1j*phiRotG);
        A.G1 = abs(A.G1).^p.*exp(1j*angle(A.G1)*4);
        A.G2 = A.G.*exp(-1j*phiRotG);
        A.G2 = abs(A.G2).^p.*exp(1j*angle(A.G2)*4);
    end
elseif M == 32
    % Rotation angles definition:
    phiRotB = atan(3)-pi/4;
    phiRotC = atan(5)-pi/4;
    phiRotD = atan(5/3)-pi/4;
    % 4th power demodulation:
    if isfield(A,'B')
        A.B1 = A.B.*exp(1j*phiRotB);
        A.B1 = abs(A.B1).^p.*exp(1j*angle(A.B1)*4);
        A.B2 = A.B.*exp(-1j*phiRotB);
        A.B2 = abs(A.B2).^p.*exp(1j*angle(A.B2)*4);
    end
    if isfield(A,'C')
        A.C1 = A.C.*exp(1j*phiRotC);
        A.C1 = abs(A.C1).^p.*exp(1j*angle(A.C1)*4);
        A.C2 = A.C.*exp(-1j*phiRotC);
        A.C2 = abs(A.C2).^p.*exp(1j*angle(A.C2)*4);
    end
    if isfield(A,'D')
        A.D1 = A.D.*exp(1j*phiRotD);
        A.D1 = abs(A.D1).^p.*exp(1j*angle(A.D1)*4);
        A.D2 = A.D.*exp(-1j*phiRotD);
        A.D2 = abs(A.D2).^p.*exp(1j*angle(A.D2)*4);
    end
elseif M == 16
    % Rotation angles definition:
    phiRotB = atan(3)-pi/4;
    % 4th Power Demod:
    if isfield(A,'B')
        A.B1 = A.B.*exp(1j*phiRotB);
        A.B2 = A.B.*exp(-1j*phiRotB);
        A.B1 = abs(A.B1).^p.*exp(1j*angle(A.B1)*4);
        A.B2 = abs(A.B2).^p.*exp(1j*angle(A.B2)*4);
    end
elseif M == 8
    if isfield(A,'B')
        % Rotation angles definition:
        phiRotB = pi/4;
        A.B1 = A.B.*exp(1j*phiRotB);
        A.B1 = abs(A.B1).^p.*exp(1j*angle(A.B1)*4);
    end
end

