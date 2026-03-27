function B = fill_gaps(A,n,per)
% B = fill_gaps(A,n,periodicity_index);
% fill the NaN values of A with the mean of the surrounding values. 
% It works iteratively (n iterations) from the borders.
% If periodicity_index is set to 1 (0 by default), A is smoothed as if 
%        it was periodic in both directions
if nargin<2,
  n = 1;
  disp('1 iteration only');
  per = 0;
elseif nargin==2,
  per = 0;
end

[mA,nA] = size(A);
B = A;

for i_iter=1:n,
  [inan,jnan] = find(isnan(B));
  nnan = length(inan);
  fill_val = nan(nnan,1);
  for i_pts = 1:length(inan),
    I = repmat([inan(i_pts)-1;inan(i_pts);inan(i_pts)+1],3,1);
    J = repmat([jnan(i_pts)-1,jnan(i_pts),jnan(i_pts)+1],3,1);
    J = J(:);
    if per == 1,
      I(I==0) = mA;
      I(I==mA+1) = 1;
      J(J==0) = nA;
      J(J==nA+1) = 1;
    else
      i_out = unique(find(I==0 | I == mA+1 | J == 0 | J == nA+1));
      I(i_out) = [];
      J(i_out) = [];
    end
    block = B(I,J);
    if any(isfinite(block(:)))
      fill_val(i_pts) = meanoutnan(block(:));
    end
  end
  B(sub2ind(size(A),inan,jnan)) = fill_val;
end
