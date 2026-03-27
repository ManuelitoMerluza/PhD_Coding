function [pctd,tctd,sctd,o2ctd]=ctd_readkolterman(fname,istat);
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
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jun 98
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:

  fictd=fopen(fname,'r');
  lnni=fgetl(fictd);
  iposcast=findstr(lnni,'cast');
  iposfrom=findstr(lnni,'from');
  istat1=floor(sscanf(lnni(iposcast+4:iposfrom-1),'%i')/1e3);
  if istat ~= istat1
    disp('Do not get the right station number in the ctd file: ')
    error(sprintf('should be %i got %i',istat,istat1))
  end
  
  while isempty(findstr(lnni(1:4),'DATA'))
    lnni=fgetl(fictd);
  end    
  alldata=fscanf(fictd,'%14e  %14e  %14e  %14e  %14e  %14e  %14e',[7,Inf]);
  fclose(fictd);
  if size(alldata,1)~= 7
    error(['Problem in ' fname])
  end
  ipr=1;
  itc=2;
  isc=3;
  iox=7;

  o2ctd=alldata(iox,:)';
  pctd=alldata(ipr,:)';
  tctd=alldata(itc,:)';
  sctd=alldata(isc,:)';

  %OXYGEN CONVERSION ml/l -> umol/kg
  ptmp = sw_ptmp(sctd,tctd,pctd,0);
  o2ctd=ox_units(o2ctd,sctd,ptmp);