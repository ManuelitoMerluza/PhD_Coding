function [xo,yo] = flstairs(x,y)
%FLSTAIRS Stairstep graph (bar graph without internal lines).
%	 Stairstep plots are useful for drawing time history plots of
%	 digital sampled-data systems.
%	 STAIRS(Y) draws a stairstep graph of the elements of vector Y.
%	 STAIRS(X,Y) draws a stairstep graph of the elements in vector Y at
%	 the locations specified in X.

%        !! This is the matlab routine stairs, modified to draw the lines
%        at the exact x values not between them, x values do not have to be
%        evenly spaced.

%	 [XX,YY] = FLSTAIRS(X,Y) does not draw a graph, but returns vectors
%	 X and Y such that PLOT(XX,YY) is the stairstep graph.
%	 See also STAIRS BAR and HIST.

%	A. Macdonald, 10-3-90.

               
n = length(x-1);
if nargin == 1
	y = x;
	x = 1:n;
end

% nn is the number of vectors
nn = 2*n;

% xx and yy contain the vectors, zero them out
yy = zeros(nn,1);
xx = yy;

% t is a temporary version of x
t=x(1:n)';

% set up xx and yy
xx(1:2:nn) = t;
xx(2:2:nn) = t;

yy(1)=y(1);
yy(2:2:nn) = y(2:n+1);
yy(3:2:nn) = y(2:n);

yy(nn+1)=yy(nn);
xx(nn+1)=0;
yy(nn+2)=0;
xx(nn+2)=0;
yy(nn+3)=0;
xx(nn+3)=xx(1);

if nargout == 0
	plot(xx,yy)
else
	xo = xx;
	yo = yy;
end
