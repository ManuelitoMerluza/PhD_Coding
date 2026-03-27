% converts the output of mergch into our format:
load endev129_mrg

Secname='ENDEVOR129';
Secdate=485;
Nstat=92;
Mdepth=37;
Lati='this will be an array 92x1';
Long='this will be an array 92x1';
Botdepth='this will be an array 92x1';
Depth='this array will contain the depth value';

Propnm=['temp';'sali';'oxyg';'phos';'sili';'dynh'];
Propunits=['cels';'g/Kg';'ml/l';'um/K';'um/K';'cm  '];
Precision=['float32';'float32';'float32';'float32';...
  'float32';'float32'];
Propsize=zeros(6);

Remarks=['properties are Mdepth x Nstat   '...
    'this is just an example data file, all variables'...
    ' and units are not reliable yet'];
Treatment='O/P from mergech, 0 values replaced with NaN';

Propfiles=['EN129temp.bin';'EN129sali.bin';'EN129oxyg.bin';...
  'EN129phos.bin';'EN129sili.bin';'EN129dynh.bin'];

for iprop=1:6
  for istat=1:92
    eval(['prop(:,istat)=STA' int2str(istat) '(:,iprop);'])
  end
  prop=sparse(prop);
  eval([Propnm(iprop,:) '=prop;'])
  disp(Propnm(iprop,:))
  if 0
    iground=find(prop==0);
    prop(iground)=NaN*ones(size(iground));
    figure(iprop)
    extcontour(prop,'label');                      
    set(gca,'Ydir','reverse');
    title([Secname,' ' Propnm(iprop,:)])
    printyn
    prop(iground)=0*ones(size(iground));
  end
end

cd EN129
for iprop=1:6
  ufi=fopen(Propfiles(iprop,:),'w');
  eval(['prop=' Propnm(iprop,:) ';']);
  [ii,jj,pp]=find(prop);
  Propsize(iprop)=length(pp);
  fwrite(ufi,ii,'ushort');
  fwrite(ufi,jj,'ushort');
  fwrite(ufi,pp,Precision(iprop,:));
  fclose(ufi);
end

save EN129_mergeOP.mat Secname Secdate Mdepth Nstat Lati Long ...
  Botdepth Depth Propnm Propunits Propsize Precision Propfiles ...
  Treatment Remarks 

