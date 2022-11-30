function seq = getRandBinarySeq(seq_length, num_ones)
% Function to return a random binary sequence of a given length, with a set
% number of ones.
%
% author: Bradley Treeby
% date: 11th November 2019
% last update: 11th November 2019

% check the inputs
if num_ones >= seq_length
    error('Number of ones must be less than sequence lenght.');
end

% generate empty array
seq = false(1, seq_length);

% generate random numbers
for counter = 1:num_ones

    % infinite while loop
    while true
    
        % generate random index
        rand_index = randi([1, seq_length], 1);
        
        % set value if not already one, and exit while loop
        if seq(rand_index) ~= 1
            seq(rand_index) = 1;
            break;
        end
        
    end
    
end
