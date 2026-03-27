% RANDUNIFC(a,b,n)
%   This function creates a continuous uniformly distributed random 
%   variable between 'a' and 'b'.  If a third argument is used, a 
%   vector of 'n' uniformly distributed random variables is created.
%
% See also RAND, RANDN, RANDEXPO, RANDGEO, RANDPOIS, RANDGAUSS

function out = randunifc(a,b,n)

if nargin == 2
    out = a + (b - a) * rand;
end

if nargin == 3
    randvec = rand(1,n);
    out = a + (b-a) * rand;
end
