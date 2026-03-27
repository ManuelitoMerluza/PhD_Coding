%randbits(in)
%   This function creates a random sequence of 'in' bits valued at 0 and 1.

function out = randbits(in)

out = round(rand(1,in));