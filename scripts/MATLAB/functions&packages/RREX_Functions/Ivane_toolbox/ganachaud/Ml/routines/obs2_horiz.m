%obs2_horiz.m : part of obs2std
d1=sw_dist(oslat([nb,is]),oslon([nb,is]),'km');
d2=sw_dist(oslat([nf,is]),oslon([nf,is]),'km');
if nb>is
  d1=-d1;
  disp('Extrapolation !')
end
if nf<is
  d2=-d2;
  disp('Extrapolation !')
end
if (nf~=nb)
  bprop(gimiss,is)=bprop(gimiss,nb)+...
    d1*(bprop(gimiss,nf)-bprop(gimiss,nb))/(d1+d2);
else
  disp('Same stations !!')
end