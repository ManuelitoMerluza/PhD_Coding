% RANDGEO(p,n)
%   This function creates a geometrically distributed random variable
%   with parameter 'p'.  If a second argument is used, a vector of
%   'n' geometric variables is created.
%
% See also RAND, RANDN, RANDUNIFC, RANDEXPO, RANDPOIS, RANDGAUSS

function out = randgeo(p,n)

if nargin == 1
    out = floor(log(rand)/log(1-p));
end

if nargin == 2
    randvec = rand(1,n);
    out= floor(log(randvec)./log(1-p));
end

