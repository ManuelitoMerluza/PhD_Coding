function disp_layavg(boxi,propnm,Propunits)
% KEY: displays average properties of a boxi
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT: boxi.<layer properties>
%        conservative properties names
%        Propunits (property units from pair files)
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jul 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: mkequats
% CALLEE:
Nprop=size(boxi.lavgprop,2);
Nlay=size(boxi.lavgprop,1);
if ~iscell(Propunits) %conversion for compatibility with previous versions
  for iprop=1:Nprop
    Propunits1{iprop}=Propunits(iprop,:);
  end
  Propunits=Propunits1;
end

disp('AVERAGE LAYER PROPERTIES OVER THE BOX')
disp(['BOX ' boxi.name])
for iprop=1:Nprop
  disp('***********************************************')
  nodisp=0;
  ttl=upper(propnm{iprop});
  scalef=ones(Nlay,1); %boxi.lavgprop(:,1);
  if iprop>1&iprop<8
    units=[Propunits{iprop-1}];
  end
  switch propnm{iprop}
    case{'mass'}
      scalef=1000*ones(Nlay,1);
      units='kg/l';
      ndigits=4;
    case{'heat'}
      %scalef=sw_cp(35,0,0)*boxi.lavgprop(:,1);
      %units='rho*DEG '; (APPROX, CP(35,0,0))
      units='DEG ';
      ndigits=3;
      ttl='POT TEMP ';
    case{'sali'}
      ndigits=4;
    case{'oxyg','phos','sili','nita'}
      ndigits=3;
    case {'po38','NO'}
      units='UMOL/KG';
    otherwise
      nodisp=1;
      disp([upper(propnm{iprop}),' NOT PROGRAMED FOR DISPLAY'])
  end
  if ~nodisp
    disp('LAYERS ...')
    disp(sprintf('\n%s (%s)',ttl,units))
    disp(sprintf('layer\tmean\trms  \tstd.dev  LAST IS TOP TO BOTTOM'))
    for il=1:Nlay
      disp(sprintf('%3i\t  %-4.*g\t  %-4.*g\t  %-4.*g',il,...
	ndigits,boxi.lavgprop(il,iprop),...
	ndigits,boxi.lrmsprop(il,iprop),...
	ndigits,boxi.lstdprop(il,iprop)))
    end
    disp(' ')
    disp('INTERFACES ...')
     disp(sprintf('intfce\tmean\trms  \tstd.dev  LAST IS TOP TO BOTTOM'))
    for il=1:Nlay
      disp(sprintf('%3i\t  %-4.*g\t  %-4.*g\t  %-4.*g',il,...
	ndigits,boxi.liavgprop(il,iprop),...
	ndigits,boxi.lirmsprop(il,iprop),...
	ndigits,boxi.listdprop(il,iprop)))
    end
   
  end
end