%run right after the readobsfile session or load the observation mask
%load /data39/alison/phd/atldata/at109.observedm_sun_obsmask.mat

close all

for iprop=1:nvar
  figure(iprop);clf
  for isec=1:nsec
    gisec=fstat(isec):lstat(isec);
    dsec=[0;cumsum(sw_dist(Slat(gisec),Slon(gisec),'km'))];
    subplot(nsec,1,isec)
    plot(dsec,-Botd(gisec))
    hold on;grid on
    h=plot(dsec,-opres(:,gisec).*bitget(isobs(:,gisec),iprop),'r.');
    set(h, 'Clipping', 'off')
    axis([min(dsec),max(dsec),-max(Botd(gisec)),0]);
    if isec==1
      title(propnm(iprop,:))
    end
    zoom
    ylabel('db')
  end
  xlabel('distance (km)')
  setlargefig
end  
