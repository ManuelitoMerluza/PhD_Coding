%conv_at109
% KEY: input file for data conversion, AT109
% USAGE : conv_at109
% 
%  see the hydrosys html page for precisions
%  /data4/ganacho/web/hydrosys.html
%
% DESCRIPTION : 
%  This script MUST BE MODIFIED for each Output file treated
%  It call the actual routine p_convdata
%
% INPUT:
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Nov 96
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE: pconv_at109

p_conv_stat=1        %station data conversion
p_conv_pair=0        %pair data conversion

%STANDART DEPTHS FILE:
stddf='/data39/alison/mast/data/stdd.37';

%IPdir='/data39/alison/phd/data/';
IPdir='/data39/alison/phd/progs/mergech/';

OPdir='/data1/ganacho/HDATA/';
datafile=[IPdir 'at109'];

Itemp=1; Isali=2; Ioxyg=3; Iphos=4; Isili=5; Inita=6;

nstat=213;%total number of stations in the record
nvar=6;   %temp, sali, oxyg, phos, sili, nita

%SECTION SEPARATION
namesec=['a36n';'a24n';'flst'];

%STATIONS TO GET
s2get1=1:101; s2get2=102:191; s2get3=192:202;

%PAIRS TO GET
p2get1=1:100; p2get2=101:189; p2get3=190:199;

cruises=['at109, leg 1, Roemmich';...
         'at109, leg 2, Wunsch  ';...
         'at109, leg 2, Wunsch  ';];
secdate=['Summer 1981';...
         'Summer 1981';...
	 'Summer 1981'];

if p_conv_stat
  ndep=37;
  reclen=4*ndep*(nvar+1); %+1 for dyn. height
  Idynh=7
  p_dynh=1;
  Propnm =   ['temp';'sali';'oxyg';'phos';'sili';'nita';'dynh'];
  Propunits =['cels';'g/Kg';'ml/l';'um/K';'um/K';'um/K';'dy m'];
  
  conv_sdata
  %(stddf,IPdir,OPdir,datafile,reclen,ndep,nstat,..
  %  Itemp,Isali,Ioxyg,Iphos,Isili,Propnm,Propunits,..
  %  namesec,cruises,secdate,s2get1 .. ,p2get1 );
  clear Idynh
end %if p_conv_stat

if p_conv_pair
  npair=209;  ndep=37+1;
  reclen=4*ndep*(nvar+1);

  Propnm =   ['temp';'sali';'oxyg';'phos';'sili';];
  Propunits =['cels';'g/Kg';'ml/l';'um/K';'um/K';];
  conv_pdata
  %(stddf,IPdir,OPdir,datafile,npair,reclen,ndep,nstat,...
  %  Itemp,Isali,Ioxyg,Iphos,Isili,Propnm,Propunits,...
  %  namesec,firstpair,lastpair,firststat,laststat,cruises,secdate);       
end %if p_conv_pair

