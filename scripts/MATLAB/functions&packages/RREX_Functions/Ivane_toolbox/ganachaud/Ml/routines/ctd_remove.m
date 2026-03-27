%ctd_remove : part of ctd_step3

disp('Select data to remove with mouse')
disp('Click twice at the same point to proceed without modif')
[x,y]=ginput(2);
y=-y;
if y(1)>y(2)
  yyy=y(1);
  y(1)=y(2);
  y(2)=yyy;
end
gimiss=find(cpres>y(1)&cpres<y(2));
if ~isempty(gimiss)
  prop(gimiss,is)=NaN;
end

