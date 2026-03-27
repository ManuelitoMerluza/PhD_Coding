function check_val(prop,pname)
%key: check the consistency of the property
%synopsis :
% 
%  lat, lon in degree
%  pressure in Db
%  temp: celsius
%  sali: g  / Kg
%  oxyg: ml / l
%  sili, phos, nita: micro-mol / Kg
%
%
%description : 
%  verifies that the properties are within reasonnable
%  intervals.
%
%uses :
%
%side effects : it does not prove that the properties are good !
% ex: if sili is actually the phosphate or something like that
%     it won't detect it.
%
%author : A.Ganachaud (ganacho@gulf.mit.edu) , Oct 95
%
%see also :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pname=deblank(pname);
err=0;

if strcmp(pname,'lon')
  if any(abs(prop)>360)|any(prop<-180)
    err=1;
  end
 
elseif strcmp(pname,'lat')
  if any(abs(prop)>90)
    err=1;
  end

elseif strcmp(pname,'pres')
  if any((prop>20000)|(prop<0))
    err=1;
  end

elseif strcmp(pname,'dynh')
  if any((prop>10)|(prop<0))
    err=1;
  end

elseif strcmp(pname,'temp')
  if any((prop>35)|(prop<-5))
    err=1;
  end

elseif strcmp(pname,'sali')
  if any((prop<30)|(prop>40))
    err=1;
  end

elseif strcmp(pname,'oxyg')
  if any((prop<0)|(prop>15))
    err=1;
  end

elseif strcmp(pname,'sili')
  if any((prop<0)|(prop>300))
    err=1;
  end

elseif strcmp(pname,'nita')
  if any((prop<0)|(prop>100))
    err=1;
  end

elseif strcmp(pname,'phos')
  if any((prop<0)|(prop>10))
    err=1;
  end

elseif strcmp(pname,'tcarbn')|strcmp(pname,'alkali')
  if any((prop<1500)|(prop>2500))
    err=1;
  end

elseif strcmp(pname,'uvel')|strcmp(pname,'vvel')
  if any((prop>1000))
    err=1;
  end

elseif strcmp(pname,'NODATA')
  if any(~isnan(prop))
    err=1;
  end
  
else
  error([pname ' unknown'])
end

if err
  error([pname ' inconsistent'])
end