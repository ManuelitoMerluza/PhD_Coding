%function 
% plot the referenced velocity after inversion
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
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Apr 98
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
if ~exist('xax')
  xax='lon';
end
if ~exist('bhat')
  error('need bhat !')
end
str=[  'load ' IPdir Modelid '_equn.mat '];
disp(str)
eval(str)

if ~exist('gisb')
  gisb=1:length(gsecs.name);
end

for isb=gisb
  figure(isb);clf
  secid=[gsecs.name{isb} gsecs.namesuf{isb}];
  datadir=gsecs.datadir{isb};
  hdrname = [secid '_pair.hdr.mat'];
  str=['load ' datadir hdrname ];
  disp(str);eval(str)
  
  if strcmp(xax,'lon')
    xabs=Slon;pxabs=Plon;
    xlab=[gsecs.name{isb} ' Longitude'];
  elseif strcmp(xax,'lat')
    xabs=Slat;pxabs=Plat;
    xlab=[gsecs.name{isb} ' Latitude'];
  elseif strcmp(xax,'dist')
    xabs=cumsum([0;sw_dist(Slat,Slon,'km')]);
    pxabs=(xabs(1:gsecs.npair(isb))+xabs(2:gsecs.npair(isb)+1))/2;
    xlab=[gsecs.name{isb} ' distance (km)'];
  end
  
  gicols=pm.gifcol(isb):pm.gilcol(isb)-...
    any(strcmp(fieldnames(pm),'giEkcol'));
  
  if ~exist('p_plt_cumtrans') | ~p_plt_cumtrans %plot velocities
    gvelabs=100*grelvel{isb}+...
      ones(size(grelvel{isb},1),1)*bhat(gicols)';
    axes('position',[0.13 0.85 0.775 0.1])
    dbhat=sqrt(diag(P(gicols,gicols)));
    np=length(gicols);
    pl1=fill([pxabs(1:np);pxabs(np:-1:1)],[dbhat;-reverse(dbhat)],...
      .85*[1 1 1]);
    set(pl1,'EdgeColor',.85*[1 1 1]);hold on
    pl0=plot(pxabs,bhat(gicols),'linewidth',.7);grid on;
    set(gca,'xticklabel',[],'xlim',[min(xabs) max(xabs)]);
    ylabel('cm s^{-1}');
    if strcmp(xax,'lat')
      set(gca,'xdir','reverse')
    end
    set(gca,'position',[0.13 0.85 0.775 0.1])
    
    axes('position',[0.13 0.10 0.775 0.70])
    gi2p=1:Npair;
    
    %gi2p=1:fix(Npair/2);
    %gi2p=fix(Npair/2):Npair;
    
    %gi2p=1:fix(Npair/3);
    %gi2p=fix(Npair/3):fix(2*Npair/3);
    %gi2p=fix(2*Npair/3):Npair;
    gi2ps=[gi2p,max(gi2p+1)];
    plt_prop(gvelabs(:,gi2p), 'vel', 'cm/s', gsecs.name{isb}, Presctd, ...
      Maxd(gi2ps,1), Botp(gi2ps), Slat(gi2ps), Slon(gi2ps),...
      500*ceil(max(Botp)/500),1,gi2p,xax)
    xlabel(xlab)
    pl=plot(pxabs,-rlpres{isb},'-.','linewidth',0.2);
    title('')
    if exist('printit')&printit
      land
      setlargefig
      disp('PRINTING ...')
      ph
    end
    
  else %plot cumulative transport
    if p_pltstream
      error('transports where caculated cumulative from bottom');
    end
      
    if ~exist('lay2plot')
      lay2plot=1:boxi.nlay-1;
    end
    if exist('p_plot_cTr')&p_plot_cTr
      cTrans=cTr{isb,iprop};strr=' Relative ';
    else
      cTrans=cTa{isb,iprop};strr=' Absolute ';
    end
    ipair=fix(Npair/2);
    lonlim=xabs(ipair);
    clf;plot(pxabs,cTrans(lay2plot,:)')
    set(gca, 'xlim',[min(xabs) max(xabs)])
    hold on;plot([lonlim lonlim],get(gca,'ylim'),'linewidth',0.1)
    corder=get(gca,'colororder');
    ncolor=size(corder,1);
    for iil=1:length(lay2plot)
      ilay=lay2plot(iil);
      htx(ilay)=text(lonlim-6*(isint(iil/2)),full(cTrans(ilay,ipair)),...
	sprintf('%2i',(ilay)'),'fontsize',10,'VerticalAlignment','bottom',...
	'color',corder(1+mod(iil-1,ncolor),:));
    end
    grid on; 
    title([gsecs.name{isb} strr ...
	' layer cumulative transport from West/North'])
    signature
    xlabel(xlab);ylabel(lunits{iprop});
    switch xax
     case 'lat'
      set(gca,'xdir','reverse') %to go from N to S
      labelaxlat(gca)
     case 'lon' 
      labelaxlong(gca)
     otherwise
    end
    land
    setlargefig
    str=sprintf('print -depsc fig%i.epsc',isb');
    disp(str)
    eval(str)
  end %if ~p_cumtrans
end %isb

