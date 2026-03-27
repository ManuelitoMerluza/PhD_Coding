function  [clat,clon,cmaxd,Cpres,Ctemp,Csali,Coxyg, ctime,...
  ccast, cdownup,cstat,cbotd]=...
    read_fieux_ctd(fname);
% KEY: Read Michele Fieux CTD format
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
%  cmaxd: number of observation at each station
%
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
%
disp(['Reading ' fname ' CTD data'])
fid=fopen(fname);
if strcmp(fname,'Data/JADE2-10dbar')
  disp('!! Position may be wrong: no conversion seconds/minutes/100')
  ppause
end

istat=0;
while 1 %read each station
  hdrline=fgetl(fid);
  if hdrline==-1 %end of file
    break
  end
  if strcmp(fname,'Data/JADE2-10dbar')
    dshift=-1; %no iquality in JADE-2 data
    params(1)=sscanf(hdrline(1:6),'%i4');
    params(3)=sscanf(hdrline(7:8),'%i');
    params(2)=sscanf(hdrline(9:10),'%i');
    params(4)=1900+sscanf(hdrline(11:12),'%i');
    params(5)=sscanf(hdrline(13:17),'%f');
    params(6)=sscanf(hdrline(18:26),'%f');
    params(7)=sscanf(hdrline(27:35),'%f');
    params(8)=sscanf(hdrline(36:39),'%f');
    statnbr=sscanf(hdrline(1:2),'%i');
    icast=sscanf(hdrline(3),'%i');
  else
    dshift=0;
    params=sscanf(hdrline,'%g');
    statnbr=floor(params(1)/100);
    icast=floor(rem(params(1),100)/10);
  end
  disp(sprintf('reading station %i',statnbr));
  
  %read each depth
  id=0;
  clear pctd tctd sctd o2ctd
  while 1 %read each depth
    if strcmp(fname,'Data/JADE2-10dbar')
      curline=fgetl(fid);
      datas(1)=sscanf(curline(1:3),'%3i');
      datas(2:7)=sscanf(curline(4:48),'%g');
    else
      datas=sscanf(fgetl(fid),'%g');
    end
    ginan=find(datas==-9|datas==-99|datas==-999|datas==-9999);
    datas(ginan)=NaN;
    if datas(1) %some observations
      id=id+1;
      pctd(id)=datas(3+dshift);
      tctd(id)=datas(4+dshift);
      sctd(id)=datas(6+dshift);
      o2ctd(id)=datas(8+dshift);
    elseif all(datas==0)
      break %end of station record/go to next station
    end
  end %while 1 %read each depth
  
  %istat is still previous station at this point
  if istat~=0 & cstat(istat)==statnbr 
    if mmax(pctd(:))>mmax(Cpres{istat})
      skipit=0; %keep same istat
      disp(sprintf('Station has two casts: take the deepest (cast %i)',icast))
    else
      skipit=1; %skip this cast
      disp(sprintf('Station has two casts: take the deepest (cast %i)',...
	ccast(istat)))
    end
  else %this is a new station
    istat=istat+1;
    skipit=0;
  end
  if ~skipit
    cmaxd(istat)=id;
    cstat(istat)=statnbr;
    ccast(istat)=icast;
    cdownup(istat)=rem(params(1),10);
    cday=params(2);
    cmon=params(3);
    cyr=params(4);
    chour=floor(params(5));
    cmin=100*rem(params(5),1);
    ctime(istat)=cyr+cal2dec(cmon,cday,chour,cmin)/365.25;
    clat(istat)=fix(params(6))+100*rem(params(6),1)/60;
    clon(istat)=fix(params(7))+100*rem(params(7),1)/60;
    cbotd(istat)=params(8);
    Cpres{istat}=pctd(:);
    Ctemp{istat}=tctd(:);
    Csali{istat}=sctd(:);
    %convert oxygen to umol/kg
    pottmp=sw_ptmp(sctd,tctd,pctd,0);
    Coxyg{istat}=ox_units(o2ctd(:),sctd(:),pottmp(:));
  end %if ~skipit
    
end %while 1 %read each station

fclose(fid);

cmaxd=cmaxd(:);
cstat=cstat(:);
ccast=ccast(:);
cdownup=cdownup(:);
ctime=ctime(:);
clat=clat(:);
clon=clon(:);
cbotd=cbotd(:);

