% prototype file to read hydrographic information
% A.Ganachaud 09/95

cd EN129

load EN129_mergeOP.mat
whos

disp(Secname)
disp(Treatment)
disp(Remarks )
disp(Propnm)

% one example to load the temperature only:
disp(Propnm(1,:))
ufi=fopen(Propfiles(1,:),'r');
temp=fread(ufi,[Mdepth,Nstat],Precision(1,:));

%more general and reliable statment to read any property

for iprop=1:6

  ufi=fopen(Propfiles(iprop,:),'r');
  eval( ...
    [Propnm(iprop,:) '=fread(ufi,[Mdepth,Nstat],Precision(iprop,:));'])
  fclose(ufi);
  
  disp(['read ' Propnm(iprop,:) ' in ' Propfiles(iprop,:)])
  
  %now, to plots or make any treatment:
  eval(['prop=' Propnm(iprop,:) ';'])
  
  figure(iprop)
  extcontour(prop,'label');                      
  set(gca,'Ydir','reverse');
  title([Secname,' ' Propnm(iprop,:)])
  xlabel(['Unit= ' Propunits(iprop,:)])
  
end

% once the variables are read, one can use them with
% their name (temp, sali, dynh)
% or with their dynamic names Propnm(iprop,:) for loops.
