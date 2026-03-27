function y = mstd(x,flag,dim)
%STD    Standard deviation, NaN excluded.
%   For vectors, STD(X) returns the standard deviation. For matrices,
%   STD(X) is a row vector containing the standard deviation of each
%   column.  For N-D arrays, STD(X) is the standard deviation of the
%   elements along the first non-singleton dimension of X.
%
%   STD(X) normalizes by (N-1) where N is the sequence length.  This
%   makes STD(X).^2 the best unbiased estimate of the variance if X
%   is a sample from a normal distribution.
%
%   STD(X,1) normalizes by N and produces the second moment of the
%   sample about its mean.  STD(X,0) is the same as STD(X).
%
%   STD(X,FLAG,DIM) takes the standard deviation along the dimension
%   DIM of X.  When FLAG=0 STD normalizes by (N-1), otherwise STD
%   normalizes by N.
%
%   Example: If X = [4 -2 1
%                    9  5 7]
%     then std(X,0,1) is [ 3.5355 4.9497 4.2426] and std(X,0,2) is [3.0
%                                                                   2.0]
%   See also COV, MEAN, VAR, MEDIAN, CORRCOEF.

%   J.N. Little 4-21-85
%   Revised 5-9-88 JNL, 3-11-94 BAJ, 5-26-95 dlc, 5-29-96 CMT.
%   Copyright 1984-2001 The MathWorks, Inc. 
%   $Revision: 5.23 $  $Date: 2001/04/15 12:01:25 $

if nargin<2, flag = 0; end
if nargin<3,
  if isempty(x), y = 0/0; return; end % Empty case without dim argument
  dim = min(find(size(x)~=1));
  if isempty(dim), dim = 1; end
end

% Avoid divide by zero for scalar case
if size(x,dim)==1, y = zeros(size(x)); y(isnan(x))=NaN; return, end

tile = ones(1,max(ndims(x),dim));
tile(dim) = size(x,dim);

if any(any(isnan(x))) %A. Ganachaud
  if dim==2
    x=x';
  end
  m=size(x);
  
  for j=1:m(2)
    xc=x(:,j);
    ig=find(~isnan(xc));
    if ~isempty(ig)
      xc=xc-mean(xc(ig));
      if flag
	y(j)=sqrt(sum(conj(xc(ig)).*xc(ig))/length(ig));
      else
	y(j)=sqrt(sum(conj(xc(ig)).*xc(ig))/(length(ig)-1));
      end
    else
      y(j)=NaN;
    end
  end %for j=1:m(2)
  if dim==2
    y=y(:);
  end
else  %if any(isnan(x)) 
  xc = x - repmat(sum(x,dim)/size(x,dim),tile);  % Remove mean
  if flag,
    y = sqrt(sum(conj(xc).*xc,dim)/size(x,dim));
  else
    y = sqrt(sum(conj(xc).*xc,dim)/(size(x,dim)-1));
  end
end

