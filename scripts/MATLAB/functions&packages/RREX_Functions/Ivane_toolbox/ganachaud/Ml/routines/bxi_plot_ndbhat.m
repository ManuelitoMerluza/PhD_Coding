function bxi_plot_ndbhat(bhat,Binit,R,ttl,signstr,pm)
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
% CALLER:boxinvert
% CALLEE:

    figure;clf;land;setlargefig;%set(gcf,'paperorientation','factory')
    ndbhat=R.^-.5*(bhat-Binit);
    pl2=plot(ndbhat,'linewidth',.1);grid on
    absss=1:length(bhat);
    set(gca,'xlim',[1 length(ndbhat)])
    hold on;
    if any(strcmp(fieldnames(pm),'giEkcol'))
      pl3=plot(absss(pm.giEkcol),ndbhat(pm.giEkcol),'o');
    end
    wcols=[];
    if  any(strcmp(fieldnames(pm),'gifwcol'))
      gifwcol=pm.gifwcol;
      gilwcol=pm.gilwcol;
    else
      gifwcol=pm.ifwcol;
      gilwcol=pm.ilwcol;
    end
    for iba=1:length(gifwcol)
      wcols=[wcols gifwcol(iba):gilwcol(iba)];
    end
    pl4=plot(absss(wcols),ndbhat(wcols),'.');
    title(['Non dimensionnal bhat ' ttl])
    signature(signstr)
 drawnow