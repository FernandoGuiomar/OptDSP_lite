function [SNR_out_dB] = osnr2snr(varargin)

% Last Update: 05/12/2017


%% Input Parser
if isstruct(varargin{1})
    OSNR_isStruct = true;
    OSNR_in_dB = varargin{1}.OSNR_dB;
    rBW_in_Hz = varargin{1}.RBW_GHz*1e9;
else
    if isnumeric(varargin{1})
        OSNR_isStruct = false;
        OSNR_in_dB = varargin{1};
        if isnumeric(varargin{2})
            rBW_in_Hz = varargin{2};
        else
            error('When the OSNR is parsed as a struct, the function osnr2snr must take at least a 2nd numeric input argument: rBW_out_Hz (numeric)');
        end
    end
end
if OSNR_isStruct
    idx = 2;
else
    idx = 3;
end
if isstruct(varargin{idx})
    SIG = varargin{idx};
    Rs = [SIG.symRate];
    nSC = numel(SIG);
else
    if isnumeric(varargin{idx})
        Rs = varargin{idx};
        if nargin == idx + 1
            nSC = varargin{idx+1};
        else
            error('When the SIG is parsed as a struct, the function osnr2snr must take at least a 2nd numeric input argument: nSC (numeric)');
        end
    end
end

%% Convert OSNR
SNR_out_dB = OSNR_in_dB + 10*log10(rBW_in_Hz./Rs) - 10*log10(nSC);

