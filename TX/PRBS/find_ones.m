function [ pos ] = find_ones( x )

%% This function returns the position of the ones inide the input vector

% Input:

% - x = input vector

% Output:

% pos = vector containing the positions of the value 1 in x

i = 1;
while(x(i) ~= 1)
    i = i + 1;
end

x1 = x(i:end);
j = 1;
for i = length(x1):-1:1
    x2(j) = x1(i);
    j = j + 1;
end

pos = zeros(1,length(x2(x2 == 1)) - 1);
k = 1;
for i = 2:length(x2)
    if(x2(i) == 1)
        pos(k) = i - 1;
        k = k + 1;
    end
end