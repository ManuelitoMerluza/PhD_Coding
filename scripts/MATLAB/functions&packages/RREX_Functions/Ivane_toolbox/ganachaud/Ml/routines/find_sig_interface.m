function [psigint]=find_sig_interface(sigint,sigipref,...
                   pref,temp,sali,Pres,maxdp,Pdep,gsecs)
% KEY: find pressure of the given sigma interfaces
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT:
%   sigint(nlayer)   sigma interface value
%   sigipref(nlayer) reference indices pressure for each interface
%   sigpref(npref)   reference pressures
%
%
% OUTPUT:
%   psigint(npair,nlayer)
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jan 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE: getsigpres


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%FOR EACH REFERENCE PRESSURE
  disp('looking for sigma interface depths ...')
  npair=size(temp,2);
  nlayint=length(sigint);
  psigint=NaN*ones(npair,nlayint);
  for ipref=1:max(sigipref)
    disp(sprintf('reference pressure = %i db',pref(ipref)))
    %get the sigma indices for this reference pressure
    gipref=find(sigipref==ipref);
    
    %get sigmas relative to that pressure reference over the whole section
    sig_curpref = -1000+sw_pden(sali,temp,Pres,pref(ipref));
    if nargin>=9
      if any(strcmp(fieldnames(gsecs),'sp'));
	disp('SPLINE FILTERING (CSAPS)...')
	id1=min(find(Pres>gsecs.sp.pint(1)));
	int1=min(id1,maxdp);
	sig_curpref1=sig_curpref;
	for is=1:size(sig_curpref,2)
	  sig_curpref1(1:int1(is),is)=csaps(Pres(1:int1(is)),...
	    sig_curpref(1:int1(is),is),gsecs.sp.scoef(1),Pres(1:int1(is)));
	end
	
	%SECOND SPLINE
	id2=min(find(Pres>gsecs.sp.pint(2)));
	int2=min(id2,maxdp);
	gis=find(int2>int1+1);
	for i=1:length(gis)
	  is=gis(i);
	  sig_curpref1(int1(is)+1:int2(is),is)=csaps(Pres(int1(is)+1:int2(is)),...
	    sig_curpref(int1(is)+1:int2(is),is),gsecs.sp.scoef(2),...
	    Pres(int1(is)+1:int2(is)));
	end
	
	%THIRD SPLINE
	int3=maxdp;
	gis=find(int3>int2+1);
	for i=1:length(gis)
	  is=gis(i);
	  sig_curpref1(int2(is)+1:int3(is),is)=csaps(Pres(int2(is)+1:int3(is)),...
	    sig_curpref(int2(is)+1:int3(is),is),gsecs.sp.scoef(3),...
	    Pres(int2(is)+1:int3(is)));
	end
	
	%REMOVE SPIKES AT JUNCTIONS
	for is=1:size(sig_curpref1,2)
	  imx=maxdp(is);
	  sig_curpref1(1:imx,is)=csaps(Pres(1:imx),sig_curpref1(1:imx,is),...
	    gsecs.sp.junccoef,Pres(1:imx));
	end
	if 0
	  is=5;plot(sig_curpref(:,is),-Pres,'+',sig_curpref1(:,is),-Pres,'-')
	  clf;vc=[26:.5:28.5,28.55:0.05:29.05,29.06:0.01:31]; Nd=900;Np=10;
	  [c,h]=contour(1:Np,-Pres(1:Nd),sig_curpref1(1:Nd,:),vc,'k');
	  clabel(c,h);hold on;plot(1:Np,-Pres(maxdp))
	end
      end
    end
    
    %interpolates the pressure to guess the sigma position
    psigint(:,gipref) = ...
      getsigpres(Pres,Pdep,maxdp,sig_curpref,sigint(gipref));
  end %ipref=1:max(sigipref)
  disp('interface depths found')
