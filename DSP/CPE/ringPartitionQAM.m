function [A,bounds] = ringPartitionQAM(Srx,Stx,C)

% Last Update: 02/05/2019


%% Normalize Received Signal
Srx = Srx * sqrt(mean(abs(Stx).^2)/mean(abs(Srx).^2));

%% Get QAM Rings
radii = uniquetol(abs(C),1e-6);
Stx = uniquetol(abs(Stx),1e-6);
fun = @(h) (h*radii.'-Stx)*(h*radii.'-Stx)';
scaleFactor = fminsearch(fun,1);
radii = radii * scaleFactor;

%% Determine Inter-Ring Boundaries
bounds = radii(1:end-1) + diff(radii)/2;
nRadius = length(radii);

%% Filter Samples Corresponding to Each QAM Ring
P = abs(Srx);
A = repmat(Srx,nRadius,1);
A(1,P>=bounds(1)) = 0;
for n = 2:nRadius-1
    A(n,P<bounds(n-1) | P>=bounds(n)) = 0;
end
A(end,P<bounds(end)) = 0;
