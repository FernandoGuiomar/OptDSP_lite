function [phi_CS,nCS]=VV_cycleSlipDetect(phi,CPE)

% Last Update: 29/01/2014


%% Input Parser
if ~exist('CPE','var')
    CPE.segChangeDetect=true;
end

%% Input Parameters
[nSignals,nSamples]=size(phi);
nCS=zeros(nSignals,1);
phi_CS=zeros(nSignals,nSamples);

%% Detect and Remove Cycle-Slips
mem=5;
if CPE.segChangeDetect
    for k=1:nSignals
        for m=40:length(phi)
            if phi(k,m)-phi(k,m-1)<-0.8*pi/4
                nCS(k)=nCS(k)+1;
            end
            if phi(k,m)-phi(k,m-1)>0.8*pi/4
                nCS(k)=nCS(k)-1;
            end
            % check for "hidden" cycle slips:
            if m>60 && phi(k,m)+nCS(k)*pi/2-max(phi_CS(k,m-mem:m-1))<-0.8*pi/4
                nCS(k)=nCS(k)+1;
            end
            if m>60 && phi(k,m)+nCS(k)*pi/2-min(phi_CS(k,m-mem:m-1))>0.8*pi/4
                nCS(k)=nCS(k)-1;
            end
        %     if m>60 && phi(m)+nCS*pi/2-max(phi_CS(m-20:m-1))<-0.8*pi/4
        %         nCS=nCS+1;
        %     end
        %     if m>60 && phi(m)+nCS*pi/2-min(phi_CS(m-20:m-1))>0.8*pi/4
        %         nCS=nCS-1;
        %     end
            phi_CS(k,m)=phi(k,m)+nCS(k)*pi/2;
        end
    end
else
    phi_CS=phi;
end
