%% gplots.m  
%% Purpose: To compare 6 year average Topex/Poseidon and MIT Forward Model
%%      altimetric result to Alex Ganachaud's hydrography section sea-surface heights. 
%% Chris Holloway 7/23/99
%%
%% Should be in 'Elevations' directory.
%% Note: Topex/Poseidon gridded data variables have 'g' as their first
%%      letter, while the MIT Forward Model variables have 'f' as their
%%      first letter. 

ca

%%
%% Parameters:
%%
%%    Filename for gridded 6-yr. Topex/Poseidon average altimetric results data:
gfname='tpg_ref.av5-226';

%%    Plots Topex/Poseidon gridded data: 
p_gcontour=0;

%%    Plots forward model data:
p_fcontour=0;

%%    Section name:
secname='I4';

%%    Filename for hydrography section
hfname=sprintf('elev_%s.mat',secname);

%%    Plots hydrography elevation vs. Longitude
p_h_plot=0;

%%    Plots curves of Elevations from Top./Pos., Forward Model, and
%%        hydrography vs. either Longitude or Latitude
p_plotcurves=0;

%%    Graph Elevations vs. Longitude (else will be vs. Latitude)
% Sets automatically now depending on range of Slat and Slon
%p_vs_long=1;

%%    Use Fourier Transform Analysis on Interpolated points
p_ft=1;

%%    Plot curves of Elevations vs. dist
p_curves_vs_dist=0;


%%%%%    Read Gridded Data   %%%%%
[glon,glat,gdata]=read_gridded(gfname,0);


%%%%%    Read Forward Model Data   %%%%%
readfmodel

flat=[-79.5:79.5]';
flon=[0.5:359.5]';

%%%%%    Units conversion   %%%%% 
%%   The internal forward model calculations use ps in terms of height
%%   (in meters).
%%   Prior to output, the averaged output has been multiplied by: 
%%   g * ReferenceDensityForWater = 9.81 * 999.8 kg/m**3 = 9808.04 kg/m**3
%%   giving ps in pressure units (pascals).  (from Diana Spiegel)
field=field./98.0804;

field(find(field==0))=NaN;

if p_gcontour
  figure; clf;
  [cs,h]=contour(glon,glat,gdata',[-200:10:200]); hold on;
  clabel(cs,h); xlabel('Longitude'); ylabel('Latitude'); 
  title('Top./Pos Gridded Contours, every 10 cm'); hold off;
end
if p_fcontour
  figure; clf;
  [cs,h]=contour(flon,flat,field',[-200:10:200]); hold on;
  clabel(cs,h); xlabel('Longitude'); ylabel('Latitude'); 
  title('Forward Model Gridded Contours, every 10 cm'); hold off;
end

eval(['load ' hfname]);
[Slon,Sdiscont]=scan_longitude(Slon);
if p_h_plot
  figure; clf;
  plot(Slon,eta2,'b-+'); hold on;
  xlabel('Longitude'); ylabel('Elevation in cm');
  title(sprintf('Elevation vs. Long. for Section %s',secname)); hold off;
end
%%% Set p_vs_long
if abs(max(Slon)-min(Slon))>=abs(max(Slat)-min(Slat))
  p_vs_long=1;
else
  p_vs_long=0;
end

%%%%%    Allign Longitudes glon and flon for both correct sign and continous
%    and monotonic over range of Slon   %%%%%

%%glon(find(glon>180))=glon(find(glon>180))-360;
if max(glon)>=max(Slon)
  endglon=min(find(glon>=max(Slon)));
else
  endglon=min(find(glon>max(Slon)-360));
end
if endglon==length(glon)
  endglon=1;
end
glon=[glon(endglon+1:length(glon));glon(1:endglon)];
gdata=[gdata(endglon+1:length(glon),:);gdata(1:endglon,:)];
[glon,gdiscont]=scan_longitude(glon);

%%flon(find(flon>180))=flon(find(flon>180))-360;
if max(flon)>=max(Slon)
  %endflon=find(flon==min(flon(find(flon>=max(Slon)))));
  endflon=min(find(flon>=max(Slon)));
else
  endflon=min(find(flon>max(Slon)-360));
end
if endflon==length(flon)
  endflon=1;
end
flon=[flon(endflon+1:length(flon));flon(1:endflon)];
field=[field(endflon+1:length(flon),:);field(1:endflon,:)];
[flon,fdiscont]=scan_longitude(flon);

ginterp=interp2(glat',glon,gdata,Slat',Slon);
finterp=interp2(flat',flon,field,Slat',Slon);
for idiag=1:length(Slon)
  gintdiag(idiag)=ginterp(idiag,idiag);
  fintdiag(idiag)=finterp(idiag,idiag);
end
gintdiag2=gintdiag-mean(gintdiag(find(~isnan(gintdiag))));
fintdiag2=fintdiag-mean(fintdiag(find(~isnan(fintdiag))));
eta3=eta2-mean(eta2(find(~isnan(eta2))));
etar2=etar-mean(etar(find(~isnan(etar))));
surfvel=[NaN;surfvel];
gigood=find(~isnan(gintdiag2));
gintdiag=gintdiag2(gigood);
geta2=eta3(gigood);
gccelev=corrcoef(gintdiag',geta2);
gpelev=gccelev(2,1);
figood=find(~isnan(fintdiag2));
fintdiag=fintdiag2(figood);
feta2=eta3(figood);
fccelev=corrcoef(fintdiag',feta2);
fpelev=fccelev(2,1);

if p_plotcurves
  figure; clf;
  if p_vs_long
    plot(Slon,eta3,'b-'); hold on;
    h5=fill([Slon;reverse(Slon)],[deta2;-reverse(deta2)],[.9,.9,.9]);
    set(h5,'edgecolor',[.9,.9,.9]);
    h1=plot(Slon,eta3,'b-');
    h2=plot(Slon,gintdiag2,'r-','linewidth',2);
    h3=plot(Slon,fintdiag2,'gx-','markersize',3);
    h4=plot(Slon,etar2,'--');
    xlabel('Longitude'); ylabel('Elevation in cm');
    xlim([min(Slon),max(Slon)]);
    title(sprintf(...
      'Section %s with Top./Pos. and F. Model (minus means)  T/P CC = %g; F. Mod. CC = %g', ... 
      secname,gpelev,fpelev));
    legend([h1,h2,h3,h4,h5],sprintf(' = Section %s Elev.',secname), ...
      ' = Top./Pos.',' = F. Model',' = Relative Elev.',' = Elev. error',0);
    plot(Slon,zeros(1,length(Slon)));
  else
    plot(Slat,eta3,'b-'); hold on;
    h5=fill([Slat;reverse(Slat)],[deta2;-reverse(deta2)],[.9,.9,.9]);
    set(h5,'edgecolor',[.9,.9,.9]);
    h1=plot(Slat,eta3,'b-');
    h2=plot(Slat,gintdiag2,'r-','linewidth',2);
    h3=plot(Slat,fintdiag2,'gx-','markersize',3);
    h4=plot(Slat,etar2,'--');
    xlabel('Latitude'); ylabel('Elevation in cm');
    xlim([min(Slat),max(Slat)]);
    title(sprintf(...
      'Section %s with Top./Pos. and F. Model (minus means)  T/P CC = %g; F. Mod. CC = %g', ... 
      secname,gpelev,fpelev));
    legend([h1,h2,h3,h4,h5],sprintf(' = Section %s Elev.',secname), ...
      ' = Top./Pos.',' = F. Model',' = Relative Elev.',' = Elev. error');
    if Slat(find(abs(Slat)==max(abs(Slat))))<=0
      set(gca,'xdir','reverse');
    end 
    plot(Slat,zeros(1,length(Slat)));
  end
  hold off;
end

if p_ft
  [dist]=sw_dist(Slat,Slon,'km');
  gigood=find(~isnan(gintdiag2));
  [gdist]=sw_dist(Slat(gigood),Slon(gigood),'km');
  figood=find(~isnan(fintdiag2));
  [fdist]=sw_dist(Slat(figood),Slon(figood),'km');
  imindist=max(min(gigood),min(figood));
  imaxdist=min(max(gigood),max(figood));
  dist=[0;cumsum(dist)];
  
  gdist=[dist(gigood)];
  fdist=[dist(figood)];
  mdist=50;  %standardized sample spacing
  maxdist=dist(imaxdist);
  mindist=dist(imindist);
  dist1=[(mdist*ceil(mindist/mdist)):mdist:(mdist*floor(maxdist/mdist))];
  gintdiag2=gintdiag2(gigood);
  fintdiag2=fintdiag2(figood);
 
  eta3int=interp1(dist,eta3,dist1);
  etar2int=interp1(dist,etar2,dist1);
  gint3=interp1(gdist,gintdiag2,dist1);
  fint3=interp1(fdist,fintdiag2,dist1);
  
  eta3int=eta3int-mean(eta3int);
  etar2int=etar2int-mean(etar2int);
  gint3=gint3-mean(gint3);
  fint3=fint3-mean(fint3);
  
  gintccelev=corrcoef(gint3',eta3int);
  gintpelev=gintccelev(2,1);
  fintccelev=corrcoef(fint3',eta3int);
  fintpelev=fintccelev(2,1);
end   %%%%%% CONTINUES LATER
  
if p_curves_vs_dist
  figure; clf;
  h4=plot(dist1,etar2int,'b--'); hold on;
  h1=plot(dist1,eta3int,'b-');
  h2=plot(dist1,gint3,'r-','linewidth',2);
  h3=plot(dist1,fint3,'gx-','markersize',3);
  title(sprintf...
    ('Section %s vs. dist. (minus means) Interp. every %i km,  Top./Pos. CC = %3.2g, F. Mod. CC = %3.2g',...
    secname,mdist,gintpelev,fintpelev));
  legend([h1,h2,h3,h4],... 
    sprintf(' = Section %s Elev.',secname), ...
    ' = Top./Pos.',' = F. Model',' = Relative Elev.',0)
  xlabel('distance in km');
  ylabel('Elevation in cm');
  xlim([min(dist),max(dist)]);
  plot(dist,zeros(1,length(dist)))
  hold off;
end
  
if p_ft  %%%%%% CONTINUED FROM ABOVE
%  [gspec,gfreq,glow,gup]=spectru3(gint3,1,mdist);
%  [fspec,ffreq,flow,fup]=spectru3(fint3,1,mdist);
%  [etaspec,etafreq,etalow,etaup]=spectru3(eta3int,1,mdist);
%  [etarspec,etarfreq,etarlow,etarup]=spectru3(etar2int,1,mdist);
%  figure;clf;
%  h4=plot(etarfreq,etarspec,'b--'); hold on;
%  h1=plot(etafreq,etaspec,'b-');
%  h2=plot(gfreq,gspec,'r-','linewidth',2);
%  h3=plot(ffreq,fspec,'gx-','markersize',3);
%  title(sprintf('%s',secname));
%  legend([h1,h2,h3,h4],... 
%    sprintf(' = Section %s Elev.',secname), ...
%    ' = Top./Pos.',' = F. Model',' = Relative Elev.')
%  xlabel('km^-^1');
%  ylabel('yy');
%  hold off;

  
  figure;clf;
  M=5;
  [gcspec,etacspec,gcoamp,gcopha,freq,low,up,cbnd]=...
    coher4(gint3,eta3int,mdist,M);
  [fcspec,etacspec,fcoamp,fcopha,freq,low,up,cbnd]=...
    coher4(fint3,eta3int,mdist,M);
  [etarcspec,etacspec,etarcoamp,etarcopha,freq,low,up,cbnd]=...
    coher4(etar2int,eta3int,mdist,M);
  cbnd=cbnd*ones(2,1);
 
  
  
  subplot;
  if M~=1
    subplot(221),loglog(freq,gcspec,'o'),hold on,loglog(freq,fcspec,'r.'),
    errorbar(2*10^-4,1,low,up,'.'),
    text(2.3*10^-4,1,'Const. Error Bar'),
    grid
    xlabel('FREQUENCY in km^-^1'),ylabel('POWER DEN in cm^2*km^2'),
    title(sprintf('Section %s, %s',secname,'Top./Pos. (=o) and F. Model (=.)')),
    axis([10^-4 10^-2 10^-1 10^7]);
    
    subplot(222),loglog(freq,etacspec,'o'),hold on,loglog(freq,etarcspec,'r.'),
    errorbar(2*10^-4,1,low,up,'.'),
    text(2.3*10^-4,1,'Const. Error Bar'),
    grid
    xlabel('FREQUENCY in km^-^1'),ylabel('POWER DEN in cm^2*km^2'),
    title(sprintf...
      ('Section %s, %s',secname,'Hydro. Elev. (=o) and Rel. Elev. (=.)')),
    axis([10^-4 10^-2 10^-1 10^7]);
    
    subplot(223),semilogx([10^-4,10^-2],cbnd,'-'),hold on,
    semilogx(freq,gcoamp,'o'),
    semilogx(freq,fcoamp,'r.'),
    ax=axis;axis([ax(1),ax(2),0,1]),
    text(1.1*10^-4,cbnd(1)+.05,'95 %'),
    text(1.1*10^-4,cbnd(1)-.05,'Conf.'),
    grid
    xlabel('FREQUENCY in km^-^1'),ylabel('COH AMPL.');
    title(sprintf('Coh. Amp. (vs. Hydro.), Top./Pos. (=o), F. Model (=.)'));
    
    subplot(224),semilogx(freq,gcopha,'o'),hold on,semilogx(freq,fcopha,'r.'),
    axis([ax(1),ax(2),-180,180]);
    grid
    xlabel('FREQUENCY in km^-^1'),ylabel('COH PHASE');
    title(sprintf('Coh. Pha. (vs. Hydro.), Top./Pos. (=o), F. Model (=.)'));
  else
    error('CANNOT USE M == 1')
  end
  hold off;
  
  %figure;clf;
  %[fcspec,etacspec,fcoheramp,fcoherpha,fcfreq]=...
  %  coher(fint3,eta3int,mdist,5,'F. Model','Hydro. Section',secname); 
  %legend([h1,h2,h3,h4],a, ...
   %   ' = Top./Pos.',' = F. Model',' = Relative Elev.',' = Elev. error',0);
  %
  %feta3=abs(fft(geta3int));
  %fgint3=abs(fft(gint3));
  %fvect=(0:length(gdist)-1)'*(1/(mdist*length(gdist)));
  %figure
  %plot(fvect,feta3,'b-');hold on;
  %plot(fvect,fgint3,'r-');
 %%%%%%%% xlabel('km^-1')
end
  



