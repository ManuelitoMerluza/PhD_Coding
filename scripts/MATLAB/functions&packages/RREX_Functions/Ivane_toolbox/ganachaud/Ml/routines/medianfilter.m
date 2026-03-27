function yf=medianfilter(xx,p_filter)
%median filter through vector or vectors of array xx
if size(xx,1)==1
    xx=xx(:);
end
n1=floor(p_filter/2);
ndepf=size(xx,1);
%keep ends unchanged
yf(1:n1,:)=xx(n1,:);
yf(ndepf-n1+1:ndepf,:)=xx(ndepf-n1+1:ndepf,:);
for iintf=n1+1:ndepf-n1
    yf(iintf,:)=median(xx(iintf-n1:iintf+n1,:));
end
