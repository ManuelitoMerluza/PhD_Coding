datadir='/data35/ganacho/A9/Stddata/';
secid='A9';
getsdat

p_lab=1;
for iprop=1:Nprop
  figure(iprop);clf
  eval(['prop=' Propnm{iprop} ';'])
  if iprop==Ioxyg
    rho=sw_dens(sali,temp,Pres);
    prop=0.022403*oxyg.*rho/1e3;
    punits='ml/l';
  else
    punits=Propunits{iprop};
  end
  plt_prop(prop,Propnm{iprop} , punits, ...
    Cruise, Pres, Maxd, Botp, Slat, Slon,6000, p_lab)
  land;setlargefig
end

