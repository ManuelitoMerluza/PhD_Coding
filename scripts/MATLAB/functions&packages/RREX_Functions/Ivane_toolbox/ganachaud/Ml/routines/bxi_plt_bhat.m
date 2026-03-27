function bxi_plt_bhat(bhat,P,pm,gsecs,boxi,ttl,signstr)
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
  figure;clf;%set(gcf,'position',[35 50 700 900])
  Nsec=length(pm.gifcol);

  p_kz=any(strcmp(fieldnames(pm),'ifKzcol'));
  for isec=1:Nsec
    subplot(Nsec+1+p_kz,1,isec)
    gisec=pm.gifcol(isec):pm.gilcol(isec)-any(strcmp(fieldnames(gsecs),'dEkstd'));
    dbhat=sqrt(diag(P(gisec,gisec)));
    %pl=errorbar(bhat(gisec),dbhat,'-o');
    if 0
      pl=plot(bhat(gisec),'r-','linewidth',1.5);hold on
      pl1=plot(bhat(gisec)+dbhat,'-','linewidth',.1);
      pl2=plot(bhat(gisec)-dbhat,'-','linewidth',.1);
    else
      np=length(gisec);
      pl1=fill([1:np,np:-1:1],[dbhat;-reverse(dbhat)],...
	.85*[1 1 1]);
      set(pl1,'EdgeColor',.85*[1 1 1]);hold on
      pl=plot(bhat(gisec),'k-','linewidth',1);hold on
    end
    %set(pl,'clipping','off')
    grid on;title(gsecs.name{isec});
    ylabel('cm/s');zoom on
    set(gca,'xlim',[1 length(gisec)])
    %  ,'ylim',[min(bhat(gisec))-.5,max(bhat(gisec))+.5])
  end %for isec
  if 1 %SEVERAL BOXES
    if any(strcmp(fieldnames(pm),'gifwcol'))
      gifwcol=pm.gifwcol;
      gilwcol=pm.gilwcol;
    else
      gifwcol=pm.ifwcol;
      gilwcol=pm.ilwcol;
    end
    for ibox=1:length(gifwcol)
      subplot(Nsec+1+p_kz,length(gifwcol),(Nsec)*length(gifwcol)+ibox)
      giw=gifwcol(ibox):gilwcol(ibox);
      dbw=sqrt(diag(P(giw,giw)));
      %pl=errorbar(bhat(giw),dbw,'-o');
      if 0
	pl=plot(bhat(giw),'r-','linewidth',1.5);hold on
	pl1=plot(bhat(giw)+dbw,'b-','linewidth',.1);
	pl2=plot(bhat(giw)-dbw,'b-','linewidth',.1);
      else
	nw=length(giw);
	pl1=fill([1:nw,nw:-1:1],[dbw;-reverse(dbw)],...
	  .85*[1 1 1]);
	set(pl1,'EdgeColor',.85*[1 1 1]);hold on
	pl=plot(bhat(giw),'k-','linewidth',1);hold on
      end
      grid on;title('w star');
      ylabel('cm/s')
      %set(pl,'clipping','off')
    end
    if p_kz
      subplot(Nsec+1+p_kz,length(gifwcol),(Nsec)*length(gifwcol)+...
	ibox*length(gifwcol)+ibox)
      gikz=pm.ifKzcol(ibox):pm.ilKzcol(ibox);
      dbkz=sqrt(diag(P(gikz,gikz)));
      %pl=errorbar(bhat(gikz),dbw,'-o');
      pl=plot(bhat(gikz),'k-','linewidth',1.5);hold on
      pl1=plot(bhat(gikz)+dbkz,'b-','linewidth',.1);
      pl2=plot(bhat(gikz)-dbkz,'b-','linewidth',.1);
      grid on;title('Vertical Mixing');
      ylabel('cm^2/s')
    end %p_kz
  else
    subplot(Nsec+1,1,Nsec+1)
    giw=pm.ifwcol:pm.ilwcol;
    dbw=sqrt(diag(P(giw,giw)));
    errorbar(bhat(giw),dbw,'-o')
    grid on;title('w star');zoom on
  end
  setlargefig;;drawnow
  signature(signstr)
  suptitle(ttl)
  drawnow