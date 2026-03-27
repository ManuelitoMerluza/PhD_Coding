function [cslat,cslon,cndep,Cpres,Ctemp,Csali,Coxyg]=...
read_talley_ctd(fname);
% KEY: 
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT: 
%
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jan 98
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
%fname='a36n.ctd.talleyfmt';
%
disp(['Reading ' fname ' CTD data'])
fid=fopen(fname);
line1=fgetl(fid);
instat=findstr(line1,'STATIONS');
line2=fgetl(fid);
Onstat=str2num(line2(instat:instat+7));

iox=findstr(line1,'OXYGEN');
isox=num2str(line2(iox:iox+6));

for istat=1:Onstat
  line3=fgetl(fid);
  params=sscanf(line3,'%g');
  cslat(istat)=params(3);
  cslon(istat)=params(4);
  cndep(istat)=params(7);
  if isox
    [ctdrec,nitems]=fscanf(fid,'%g',[5,cndep(istat)]);
  else
    error('no oxygen !')
  end
  if nitems~=(5*cndep(istat))
    error('problem reading file')
  end
  gnan=find((ctdrec==-9)|(ctdrec==-99)|(ctdrec==-999)|(ctdrec==-9999));
  ctdrec(gnan)=NaN;
  Cpres{istat}=ctdrec(1,:)';
  Ctemp{istat}=ctdrec(2,:)';
  Csali{istat}=ctdrec(4,:)';
  Coxyg{istat}=ctdrec(5,:)';
  if any(Coxyg{istat}<100)
    pottmp=sw_ptmp(Csali{istat},Ctemp{istat},Cpres{istat},0);
    Coxyg{istat}=ox_units(Coxyg{istat},Csali{istat},pottmp);
  end
  linedummy=fgets(fid);
end %for istat
fclose(fid);

cslat=cslat';
cslon=cslon';
cndep=cndep';
