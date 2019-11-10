function [A] = classPartitionQAM(Ap,M,QAM_classes)

% Last Update: 31/03/2019


%% Check for Outer/Inner QPSK
if contains(QAM_classes,'outer')
    if M == 32
        A.A = Ap(3,:);
    elseif M == 128
        A.A = Ap(9,:);
    else
        A.A = Ap(end,:);
    end
    return;
end
if contains(QAM_classes,'inner')
    A.A = Ap(1,:);
    return;
end

%% QAM Class Partitioning
switch M
    case 4
        A = Ap;
    case 8
        if contains(QAM_classes,'A') || contains(QAM_classes,'all')
            A.A = Ap(1,:);
        end
        if contains(QAM_classes,'B') || contains(QAM_classes,'all')
            A.B = Ap(2,:);
        end
    case 16
        if contains(QAM_classes,'A') || contains(QAM_classes,'all')
            A.A = Ap(1,:) + Ap(3,:);
        end
        if contains(QAM_classes,'B') || contains(QAM_classes,'all')
            A.B = Ap(2,:);
        end
    case 32
        if contains(QAM_classes,'A') || contains(QAM_classes,'all')
            A.A = Ap(1,:) + Ap(3,:);
        end
        if contains(QAM_classes,'B') || contains(QAM_classes,'all')
            A.B = Ap(2,:);
        end
        if contains(QAM_classes,'C') || contains(QAM_classes,'all')
            A.C = Ap(4,:);
        end
        if contains(QAM_classes,'D') || contains(QAM_classes,'all')
            A.D = Ap(5,:);
        end
    case {64,128,256,512,1024}
        if contains(QAM_classes,'A') || contains(QAM_classes,'all')
            A.A = Ap(1,:) + Ap(3,:) + Ap(9,:);
        end
        if contains(QAM_classes,'B') || contains(QAM_classes,'all')
            A.B = Ap(2,:);
        end
        if contains(QAM_classes,'C') || contains(QAM_classes,'all')
            A.C = Ap(4,:);
        end
        if contains(QAM_classes,'D') || contains(QAM_classes,'all')
            A.D = Ap(5,:);
        end
        if contains(QAM_classes,'E') || contains(QAM_classes,'all')
            A.E = Ap(6,:);
        end
        if contains(QAM_classes,'F') || contains(QAM_classes,'all')
            A.F = Ap(7,:);
        end
        if contains(QAM_classes,'G') || contains(QAM_classes,'all')
            A.G = Ap(8,:);
        end
end


