function mbint(a)
%MBINT	Must be integer.
%	The statement
%
%	    mbint(x)
%
%	asserts that, at that point in the computation, the variable x 
%	has components which can be declared type "int" in the resulting
%	C program.  If this assertion is false, an error occurs; if this
%	assertion is true, the computation proceeds.
%
%	See also MBREAL, MBSCALAR, MBVECTOR, MBINTSCALAR, MBINTVECTOR.

if any(any(a ~= fix(a))),
	error( 'argument to mbint must be integer' );
end
