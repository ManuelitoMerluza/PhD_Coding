function zi=interp_pick(x,y,z,xi,yi,mask);
% KEY: 2-D interpolation by picking up the closest neighbor
% USAGE : zi=interp_pick(x,y,z,xi,yi,mask)
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT:
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jul 96
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
z=z';mask=mask';
if (min(size(x))>1 | min(size(y))>1 | ...
  min(size(xi))>1 | min(size(yi))>1)
  error('coordinates must be vectors'); 
end
if length(x)~=size(z,1)|length(y)~=size(z,2)
  error('x,y,z not the right size')
end
if length(xi)~=size(mask,1)|length(yi)~=size(mask,2)
  error('xi,yi and mask not the right size')
end
if max(xi)>max(x)|min(xi)<min(x)
  error('max(xi)>max(x)|min(xi)<min(x)')
end
if max(yi)>max(y)|min(yi)<min(y)
  error('max(yi)>max(y)|min(yi)<min(y)')
end
if (any(diff(x))<0)|(any(diff(y))<0)|...
    (any(diff(xi))<0)|(any(diff(yi))<0)
  error('x,y,xi,yi must grow')
end

if size(x,1)>1
  x=x';
end
if size(y,1)>1
  y=y';
end

%find the indices of one close neighbor
m=length(xi);
for i=1:m
  i2pick(i)=max(1,-1+min(find(xi(i)<x)));
end

n=length(yi);
for j=1:n  
  j2pick(j)=max(1,-1+min(find(yi(j)<y)));
end

M=length(x);N=length(y);
ingb=[i2pick;min(M*ones(1,m),1+i2pick);i2pick;min(M*ones(1,m),1+i2pick)];
jngb=[j2pick;min(N*ones(1,n),1+j2pick);min(N*ones(1,n),1+j2pick);j2pick];

zi=NaN*ones(m,n);
for j=1:n
  for i=1:m
    if mask(i,j)
      d=(ones(4,1)*xi(i)-x(ingb(:,i))').^2+...
	(ones(4,1)*yi(j)-y(jngb(:,j))').^2;
      
      %d(1)=distance to first neighbor ...
      %d(4)=distance to 4th neighbor
      %take the closest point
      [mind,imind]=min(d);
      if ~isnan(z(ingb(imind,i),jngb(imind,j)))
	zi(i,j)=z(ingb(imind,i),jngb(imind,j));
      else
	d(imind)=[];
	[mind,imind]=min(d);
	if ~isnan(z(ingb(imind,i),jngb(imind,j)))
	  zi(i,j)=z(ingb(imind,i),jngb(imind,j));
	else
	  d(imind)=[];
	  [mind,imind]=min(d);
	  if ~isnan(z(ingb(imind,i),jngb(imind,j)))
	    zi(i,j)=z(ingb(imind,i),jngb(imind,j));
	  else
	    d(imind)=[];
	    [mind,imind]=min(d);
	    if ~isnan(z(ingb(imind,i),jngb(imind,j)))
	      zi(i,j)=z(ingb(imind,i),jngb(imind,j));
	    end
	  end
	end
      end
    end
  end
end

zi=zi';

