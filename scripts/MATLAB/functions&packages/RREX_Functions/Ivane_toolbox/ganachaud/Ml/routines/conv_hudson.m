%conv_hudson
% KEY: input file for data conversion, HUDSON cruise (A48N)
% USAGE : 
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
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jan 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE: 

p_conv_stat=1        %station data conversion
p_conv_pair=0        %pair data conversion

%STANDART DEPTHS FILE:
stddf='/data39/alison/mast/data/stdd.37';

%IPdir='/data39/alison/phd/data/';
IPdir='/data39/alison/phd/progs/mergech/';
OPdir='/data1/ganacho/HDATA/';
datafile=[IPdir 'hudson'];

Itemp=1; Isali=2; Ioxyg=3; Iphos=4; Isili=5; Inita=6;

%TOTAL NUMBER OF STATIONS IN THE RECORD
nstat=78;

%VARIABLES NOT INCLUDING DYN.HEIGHT OR VELOCITY
nvar=6;   %temp, sali, oxyg, phos, sili, nita

%SECTION SEPARATION
namesec=['a48n'];

%STATIONS TO GET
s2get1=[78:-1:50,48:-1:1];

%PAIRS TO GET
p2get1=76:-1:1;

cruises=['Hudson, Hendry';];
secdate=['Spring 1982'];

if p_conv_stat
  ndep=37;
  reclen=4*ndep*(nvar+1); %+1 for dyn. height
  Idynh=7
  p_dynh=1;
  Propnm =   ['temp';'sali';'oxyg';'phos';'sili';'nita';'dynh'];
  Propunits =['cels';'g/Kg';'ml/l';'um/K';'um/K';'um/K';'dynh'];
  
  conv_sdata
  %(stddf,IPdir,OPdir,datafile,reclen,ndep,nstat,..
  %  Itemp,Isali,Ioxyg,Iphos,Isili,Propnm,Propunits,..
  %  namesec,cruises,secdate,s2get1 .. ,p2get1 );
  clear Idynh
end %if p_conv_stat

if p_conv_pair
  npair=76;  ndep=37+1;
  reclen=4*ndep*(nvar+1);
  Propnm =   ['temp';'sali';'oxyg';'phos';'sili'];
  Propunits =['cels';'g/Kg';'ml/l';'um/K';'um/K'];
  
  conv_pdata
  %(stddf,IPdir,OPdir,datafile,npair,reclen,ndep,nstat,...
  %  Itemp,Isali,Ioxyg,Iphos,Isili,Propnm,Propunits,...
  %  namesec,firstpair,lastpair,firststat,laststat,cruises,secdate);       
end %if p_conv_pair

