function [pctd,tctd,sctd,o2ctd]=ctd_readi9s(fname);
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
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Dec 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:

  fictd=fopen(fname,'r');
  for iline=1:15
    lnni=fgetl(fictd);
    if iline==2
      lnn2=lnni;
    end
  end
  disp(lnn2);
  if ~findstr(lnni,'NOBS') | ~findstr(lnni,'OXGY*')
    disp(lnni)
    error(['Problem in the input file' fname])
  end
  alldata=fscanf(fictd,'%f,%f,%f,%f,%f',[Inf]);
  fclose(fictd);
  if length(alldata)/5 ~= fix(length(alldata)/5)
    error(['Problem in ' fname])
  end
  alldata=reshape(alldata,5,length(alldata)/5)';
  ipr=1;
  itc=2;
  isc=3;
  iox=4;

  o2ctd=alldata(:,iox);
  pctd=alldata(:,ipr);
  tctd=alldata(:,itc);
  sctd=alldata(:,isc);

  %OXYGEN CONVERSION ml/l -> umol/kg
  ptmp = sw_ptmp(sctd,tctd,pctd,0);
  o2ctd=ox_units(o2ctd,sctd,ptmp);