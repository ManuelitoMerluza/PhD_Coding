%obs2_step1: part of obs2std code
%
%Following obs2std.f

disp('  obs2_step1.m ...')

w1=250;     %maximum depth window over which automatic 
            % interpolation is allowed
wl1=500;    %lower limit for this window's effect
w2=400;
wl2=1200;
disp('Max blank for automatic patching:')
disp(sprintf('%i db down to %idb, %idb down to %idb, 1000db below',...
  w1,wl1,w2,wl2))

disp(' Interpolation with a 2nd degree polynomial ')
disp(' (Aitken-Lagrange/obs2_alinterp.m)')
disp(' allowed only if the overshoot does not exceed')
disp(' 0 * deviation between the two data points if pressure < 400db')
disp(' 0 * deviation between the two data points if pressure > 400db')
disp(' linear interpolation is used otherwise')

bnprop=length(gip2treat);

disp('  treating station ...')
for is=1:onstat
  if is/10==floor(is/10)
    disp(is)
  end
  bmaxd(is)=max(find(stdd<=obotp(is)));
  for ipropstd=1:bnprop
    ipropobs=gip2treat(ipropstd);
    eval(['oprop=' opropnm{ipropobs} '(:,is);'])
    gid{is,ipropstd}=1:omaxd(is);
    %removes closely spaced data:
    gidn=find(diff(opres(gid{is,ipropstd},is))<20);
    for idn=gidn
      if ~isnan(oprop(idn))
	gid{is,ipropstd}(gidn+1)=[];
      else
	gid{is,ipropstd}(gidn)=[];
      end
    end
    nprop=obs2_alinterp(oprop(gid{is,ipropstd}),opres(gid{is,ipropstd},is),...
      stdd,w1,w2,wl1,wl2);
    giid=1:bmaxd(is);
    %plot(oprop(gid{is,ipropstd}),-opres(gid{is,ipropstd},is),'bo',...
    %  nprop(giid),-stdd(giid),'r-+')
    %ppause
    %THE NAME FOR STD VARIABLES DOES NOT INCLUDE THE o PREFIX
    nm=killblank(opropnm{ipropobs});
    bpropnm{ipropstd}=nm(2:length(nm));
    bpropunits{ipropstd}=killblank(opropunits{ipropobs});
    eval([bpropnm{ipropstd} '(:,is)=nprop(:);'])
  end %ipropobs
end %is
disp('Automatic patching done')