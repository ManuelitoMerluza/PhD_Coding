%function [yy]=mmean(xy)
%  returns mean value of data cols. with nans excluded
function [yy]=mmean(xy)
y=[];
z=[];
yy=[];

m=size(xy);

for j=1:m(2)

  z=xy(:,j);  ig=find(~isnan(z)>0);  y=mean(z(ig)); yy=[yy y]; end 

