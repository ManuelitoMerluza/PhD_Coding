function mbvector(a)
%MBVECTOR Must be vector.
%	The statement
%
%	    mbvector(x)
%
%	asserts that, at that point in the computation, the varible x has
%	size m-by-1 or 1-by-n.  If this assertion is false, an error occurs;
%	if this assertion is true, the computation proceeds.
%
%	See also MBINT, MBREAL, MBSCALAR, MBINTVECTOR, MBREALVECTOR.

if( min(size(a)) > 1 )
	error( 'argument to mbvector must be a vector' );
end
