function Rwght=rem_eq(Rwght,pm,eqstr)
%Set to zero equation weight in the string is found in the
%equation name
gi2remove=[];
for ieq=1:length(pm.eqname)
  if findstr(pm.eqname{ieq},eqstr)
    gi2remove=[gi2remove,ieq];
    disp(['remove equation ' pm.eqname{ieq}])
  end
end
Rwght(gi2remove)=0;