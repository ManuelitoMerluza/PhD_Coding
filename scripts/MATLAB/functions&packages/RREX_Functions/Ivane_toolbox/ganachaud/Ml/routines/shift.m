function y=shift(x,k)

[a,b]=size(x);
if a==1
  x=x';
  p_rev=1;
  a=b;b=1;
else
  p_rev=0;
end

if k>0
  y=[zeros(k,b);x(1:a-k,:)];
elseif k<0
  y=[x(1-k:a,:);zeros(-k,b)];
else
  y=x;
end

if p_rev
  y=y';
end