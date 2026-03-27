function prop=rhydro(pname,psize,precision,Mdepth,Nstat,iprop)
%key:
%synopsis :
% 
%
%
%
%description : 
%
%
%
%
%uses :
%
%side effects :
%
%author : A.Ganachaud (ganacho@gulf.mit.edu) , Sept 95
%
%see also :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nstat=92;

  ufi=fopen(pname(iprop,:),'r');
  ii=fread(ufi,psize(iprop),'ushort');
  jj=fread(ufi,psize(iprop),'ushort');
  pp=fread(ufi,psize(iprop),precision(iprop,:));
  prop=full(spconvert([ii,jj,pp]));
  fclose(ufi);

  %it can happen than the last(s) depth are no longer in the
  % data. to avoid dimension problems, we set the size of
  % prop to [Mdepth,Nstat]

  sz=size(prop);
  if sz(1)<Mdepth
    prop=[prop;zeros(Mdepth-sz(1),sz(2))];
  end
  if sz(2)<Nstat
    prop=[prop,zeros(Mdepth,Nstat-sz(2))];
  end
  
  iground=find(prop==0);
  prop(iground)=NaN*ones(size(iground));