function [RGB] = fancyColors(varargin)

% Last Update: 24/11/2016


%% Define RGB Colors
RGB.itred       = [0.73 0.07 0.169];
RGB.itblue      = [0.0 0.24 0.431];
RGB.red         = [0.7 0 0];
RGB.green       = [0 0.5 0];
RGB.blue        = [0 0 0.7];
RGB.black       = [0 0 0];
RGB.gray        = [0.7 0.7 0.7];
RGB.violet      = [0.4 0.1 0.6];
RGB.orange      = [0.9 0.4 0.2];
RGB.cyan        = [0 0.7 0.7];
RGB.yellow      = [1 1 153/255];
RGB.pink        = [1 0 127/255];
RGB.lightBlue   = [153 204 255]/255;
RGB.lightRed    = [255 102 102]/255;
RGB.lightGreen  = [204 255 102]/255;
RGB.lightGray   = [0.9 0.9 0.9];
RGB.darkGray    = [0.3 0.3 0.3];

%% Shades of Blue
RGB.blueShades = {RGB.itblue,...
    RGB.itblue+[0 0.05 0.1],...
    RGB.itblue+[0 0.1 0.2],...
    RGB.itblue+[0 0.15 0.3],...
    RGB.itblue+[0 0.2 0.4],...
    RGB.itblue+[0 0.25 0.5],...
    RGB.itblue+[0 0.3 0.6]};

%% Set Pre-Defined RGB Color List
RGB.list = {RGB.red; RGB.black; RGB.blue; RGB.green; RGB.orange; ...
    RGB.gray; RGB.cyan; RGB.pink; RGB.yellow};

%% Set Output
if nargin == 1
    RGB = RGB.list{varargin{1}};
end
