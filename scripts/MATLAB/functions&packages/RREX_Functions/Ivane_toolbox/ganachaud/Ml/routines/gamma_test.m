% TEST OF THE NEUTRAL SURFACE OF MACDOUGALL


path(path,'/data4/ganacho/HYDROSYS')
secid='a36n'; secrelindice='4'; ylim=[-7000,0];isig=12;
datadir='/data1/ganacho/HDATA/';
getpdat

p=Pres*ones(1,Npair);
[g,dgl,dgh]=gamma_n(sali,temp,p,Plon,Plat);

extcontour(
glevels=[26.8 27.9 28.0 28.1 28.197];

[sns,tns,pns,dsns,dtns,dpns]=neutral_surfaces(sali,temp,Pres,g,glevels);

