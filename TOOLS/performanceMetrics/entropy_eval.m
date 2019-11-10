function [entropy] = entropy_eval(symProb)


symProb = symProb / sum(symProb);
tmp = log2(symProb);
tmp(isinf(tmp)) = 0;
entropy = -sum(symProb.*tmp);