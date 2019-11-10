function [H] = lambda2entropy(lambda,M)

% Last Update: 01/06/2017


%% Check if There is Probabilistic Shaping
if ~lambda
    H = log2(M);
    return;
end

%% SNR vs MI Table
fileName = [num2str(M) 'QAM'];
SNR_vs_MI = load(fileName);

H_LUT = SNR_vs_MI.MIs(end,:);
lambda_LUT = SNR_vs_MI.lambdas;

%% Linear interpolation to find the best-fit H for the query lambda values
H = interp1(lambda_LUT,H_LUT,lambda,'linear');
