%Computes the sum of the residuals in given layers. To be run 
%after hydrotrans for example.
%gilay2sum=2:10;iprop=4;
if ~exist('bhat')
  str=['load ' IPdir 'bhat_' Modelid '_' invid '.mat'];
  disp(str);eval(str)
end
if ~exist('Amat')
  str=[  'load ' IPdir Modelid '_equn.mat '];
  disp(str);eval(str)
end
if iprop==1
  disp('INITIAL FRESH WATER NOT INCLUDED !!!')
end
fw2subs=0;
%if p_res_units & iprop>3
%  disp(['Scaling ' propnm{iprop} ' residual by upper interface area'])
%end
disp(sprintf('%s sum ', propnm{iprop}))

if ~exist('lay2sum')
  lay2sum=readlay2sum('laytosum.dat',propnm);
end

for ibox2=1:length(lay2sum)
  if strcmp(lay2sum{ibox2}.boxname,boxi.name)
    gotit=1;
    break;
  else 
    gotit=0;
  end
end
if ~gotit
  error('Box not found in lay2sum !')
end
if any(strcmp(fieldnames(boxi.conseq),'rhs'))
  disp(['Substracting initial rhs to ' boxi.name])
  thisrhs=boxi.conseq.rhs(:,iprop);
else
  thisrhs=zeros(boxi.nlay,1);
end

for iglay=1:size(lay2sum{ibox2}.lay2sum,2) 
  %loop over group of layers to sum
  if ~isempty(lay2sum{ibox2}.lay2sum{iprop})&...
    ~isempty(lay2sum{ibox2}.lay2sum{iprop,iglay})
    gilay2sum=lay2sum{ibox2}.lay2sum{iprop,iglay};
    if (max(gilay2sum)==boxi.nlay)&( length(gilay2sum)>1)
      error('trying to sum a layer with top-to-bottom !')
    end
    girow=[(iprop-1)*boxi.nlay+gilay2sum];
    asum=ones(1,length(gilay2sum));
    resa=G(girow)+Ekman(girow)-fw2subs+Amat(girow,:)*bhat-thisrhs(gilay2sum);
    resa=asum*resa;
    dresa=sqrt(full(diag(...
      asum*Amat(girow,:)*P*Amat(girow,:)'*asum')));
    
    if p_res_units
     if gilay2sum(1)~=boxi.nlay
       scalefac0=1/boxi.harea(gilay2sum(1));
     else
       scalefac0=1/boxi.harea(1);
     end
     switch propnm{iprop}
      case {'oxyg','phos','sili','nita','po','Ns'} %,'heat'
        disp(['Scaling ' propnm{iprop} ' residual by average layer area'])
	%kmol/s -> mol/m2/yr
	scalefac=1e9/1e6*365*24*3600*scalefac0;
	resaunit='mol yr^{-1}m^{-2}';
	if strcmp(propnm{iprop},'oxyg')
	  resaname='OUR';
	elseif strcmp(propnm{iprop},'heat')
	  resaname='Heat flux';
	  resaunit='W m^{-2}';
	  scalefac=1e15*scalefac0;
	else
	  resname{iprop}=[propnm{iprop} ' utilization'];
	end
	resa=scalefac.*resa;
	dresa= scalefac.*dresa;
     otherwise
        resname{iprop}=[propnm{iprop} ' residuals'];
	resaunit=lunits{iprop};	  
     end %switch propnm{iprop}
    else 
      resaname=[propnm{iprop} ' residuals'];
      resaunit=lunits{iprop};
    end %p_res_units
  
    layintd=[0;cumsum(boxi.lavgwdth(1:length(boxi.glevels)-1))];
    if max(gilay2sum)==boxi.nlay %top2bottom budget
      if min(gilay2sum)~=boxi.nlay
	error('top2bottom added to an individual layer !')
      else
	glevmin=boxi.glevels(1);
	glevmax=boxi.glevels(boxi.nlay);
	dlevmin=layintd(1);
	dlevmax=layintd(boxi.nlay);
      end
    else
      glevmin=boxi.glevels(min(gilay2sum));
      glevmax=boxi.glevels(max(gilay2sum)+1);
      dlevmin=layintd(min(gilay2sum));
      dlevmax=layintd(max(gilay2sum)+1);
    end
    disp(sprintf('%5.5g and %5.5g: %4.3g +/- %4.3g %s',...
      glevmin,glevmax,...
      resa,dresa,resaunit))
    lay2sum{ibox2}.resa{iprop}(iglay)=resa;
    lay2sum{ibox2}.dresa{iprop}(iglay)=dresa;
    lay2sum{ibox2}.gilsup{iprop}(iglay)=glevmin;
    lay2sum{ibox2}.gilinf{iprop}(iglay)=glevmax;
    lay2sum{ibox2}.dilsup{iprop}(iglay)=dlevmin;
    lay2sum{ibox2}.dilinf{iprop}(iglay)=dlevmax;
    if exist('p_save_Amat')&p_save_Amat
      lay2sum{ibox2}.amat{iprop,iglay}=asum*Amat(girow,:);
    end
  end %if ~isempty(gilay2sum)
end % for iglay=1:size(lay2sum{ibox2}.lay2sum,2) 

%store section parameters
for isbb=1:length(gsecs.name)
  lay2sum{ibox2}.secname{isbb}=gsecs.name{isbb};
  lay2sum{ibox2}.gifcol(isbb)=pm.gifcol(isbb);
  lay2sum{ibox2}.gilcol(isbb)=pm.gilcol(isbb);
end
lay2sum{ibox2}.ifwcol=pm.ifwcol;
lay2sum{ibox2}.ilwcol=pm.ilwcol;
if any(strcmp(fieldnames(pm),'ifKzcol'))
  lay2sum{ibox2}.ifKzcol=pm.ifKzcol;
  lay2sum{ibox2}.ilKzcol=pm.ilKzcol;
else
  lay2sum{ibox2}.ifKzcol=[];
  lay2sum{ibox2}.ilKzcol=[];
end
lay2sum{ibox2}.ifw=pm.ifw;

%Store freshwater flux
lay2sum{ibox2}.freshwater=boxi.conseq.freshw+bhat(pm.ifw);
lay2sum{ibox2}.dfreshwater=sqrt(P(pm.ifw,pm.ifw));

