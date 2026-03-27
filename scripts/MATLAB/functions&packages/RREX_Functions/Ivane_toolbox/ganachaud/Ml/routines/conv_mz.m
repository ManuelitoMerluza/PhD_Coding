%conv_mz
% KEY: input file for data conversion, mozambic channel
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
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Nov 96
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE: conv_pdata, conv_sdata

p_conv_stat=1        %station data conversion
p_conv_pair=0        %pair data conversion

%STANDART DEPTHS FILE:
stddf='/data39/alison/mast/data/stdd.37';

IPdir='/data39/alison/phd/data/';
OPdir='/data1/ganacho/HDATA/';
datafile=[IPdir 'auss37'];

Itemp=1; Isali=2; Ioxyg=3; Iphos=4; Isili=5; 
p_dynh=0;  %no dynamic height data

nstat=348;%total number of stations in the record
nvar=5;   %temp, sali, oxyg, phos, sili 

%SECTION SEPARATION
namesec=['mz_n';...
         'mz_s'];

%STATIONS TO GET
s2get1=[35 36 37 39 43 44];
s2get2=[292 291 294 293 295];

%PAIRS TO GET
%p2get1=

cruises=['Australian Oceanographic Data Center, You and Tomczac (1993)';...
         'Australian Oceanographic Data Center, You and Tomczac (1993)'];
secdate=['Spring 1965';...
         'Spring 1965'];

if p_conv_stat
  ndep=37;
  if p_dynh
    reclen=4*ndep*(nvar+1); %+1 for dyn. height
    Idynh=6;
    Propnm =   ['temp';'sali';'oxyg';'phos';'sili';'dynh'];
    Propunits =['cels';'g/Kg';'ml/l';'um/K';'um/K';'dy m'];
  else
    reclen=4*ndep*nvar; 
    Idynh=NaN;
    Propnm =   ['temp';'sali';'oxyg';'phos';'sili'];
    Propunits =['cels';'g/Kg';'ml/l';'um/K';'um/K'];
  end  
  
  conv_sdata
  %(stddf,IPdir,OPdir,datafile,reclen,ndep,nstat,..
  %  Itemp,Isali,Ioxyg,Iphos,Isili,Propnm,Propunits,..
  %  namesec,cruises,secdate,s2get1 .. ,p2get1 );
  clear Idynh
end %if p_conv_stat

if p_conv_pair
  error('this part not set up')
  npair=209;  ndep=37+1;
  reclen=4*ndep*(nvar+1);

  Propnm =   ['temp';'sali';'oxyg';'phos';'sili';];
  Propunits =['cels';'g/Kg';'ml/l';'um/K';'um/K';];
  conv_pdata
  %(stddf,IPdir,OPdir,datafile,npair,reclen,ndep,nstat,...
  %  Itemp,Isali,Ioxyg,Iphos,Isili,Propnm,Propunits,...
  %  namesec,firstpair,lastpair,firststat,laststat,cruises,secdate);       
end %if p_conv_pair

