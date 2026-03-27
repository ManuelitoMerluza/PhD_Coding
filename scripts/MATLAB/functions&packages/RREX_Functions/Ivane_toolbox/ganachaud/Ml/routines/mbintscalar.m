function mbintscalar(a)
%MBINTSCALAR Must be integer scalar.
%	The statement
%
%	    mbintscalar(x)
%
%	is equivalent to
%
%	    mbint(x) & mbscalar(x)
%
%	See also MBINT, MBREAL, MBSCALAR, MBVECTOR.

if any(any(a ~= fix(a))),
	error( 'argument to mbintscalar must be integer' );
end
if any( size(a) ~= [1 1] ),
	error( 'argument of mbintscalar must be scalar' );
end
