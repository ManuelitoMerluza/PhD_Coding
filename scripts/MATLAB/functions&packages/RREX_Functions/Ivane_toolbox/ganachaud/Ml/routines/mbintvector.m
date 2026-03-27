function mbintvector(a)
%MBINTVECTOR Must be integer vector.
%	The statement
%
%	    mbintvector(x)
%
%	is equivalent to
%
%	    mbint(x) & mbvector(x)
%
%	See also MBINT, MBREAL, MBSCALAR, MBVECTOR.

if( min(size(a)) > 1 )
	error( 'argument to mbintvector must be a vector' );
end
if any(any(a ~= fix(a))),
	error( 'argument to mbintvector must be integer' );
end
