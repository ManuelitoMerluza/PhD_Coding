%script from boxinvert:
% computes the SVD solution, rank K
disp(sprintf('SVD ESTIMATE, RANK=%i',K))
    Uk=U(:,1:K);
    Qu=U(:,K+1:m);
    Vk=V(:,1:K);
    Lk=sparse(L(1:K,1:K));
    bhat=Binit+(S.^0.5)'*( Vk*(Lk\(Uk'*Yp)) );
    P=(S'.^.5)* Vk*(Lk\Uk')*W'.^-.5*N*W.^-.5*Uk*(Lk\Vk') * (S.^.5);
    ntilde=W'.^0.5* Qu*Qu'*Yp;
 
    %Noise uncertainty, added 16-Jan-1998 (Not double checked)
    Pnn=Amat*P*Amat';
    dn=full(sqrt(diag(Pnn)));
    %RESOLUTION MATRIX
    Tv=Vk*Vk';
    %OBSERVATION MATRIX
    Tu=Uk*Uk';
    
    if p_plots
      ttl=sprintf('SVD Rank %i, %s %s ',K,Modelid,invid);
      bxi_plotres(Y-Amat*Binit,ntilde,dn,N,signstr,ttl,pm)
      bxi_plot_ndbhat(bhat,Binit,S,ttl,signstr,pm)
      bxi_plt_bhat(bhat,P,pm,gsecs,boxi,ttl,signstr)
      
      figure(8);clf;subplot(1,2,1)
      m1=size(U,1);
      for i=1:min(m1,max(K,5))
      %for i=1:m1
	if 1
	  plot(i*ones(m1,1)+U(:,i),1:m1,'-');hold on
	  plot([i i],[0 m1+1],':')
	else %plot residual components
	  plot(i*ones(m1,1)+.5*(U(:,i)'*Y)*U(:,i),1:m1,'-');hold on
	  plot([i i],[0 m1+1],':')
	end
      end
      set(gca,'ytick',1:m1,'yticklabel',pm.eqname(1:m1),'ydir','reverse',...
	'ylim',[0 m1+1],'xlim',[0 22])
      hold off;grid on;title(['U rows ' ttl])
      subplot(1,2,2);m1=size(V,1);
      for i=1:min(m1,max(K,5))
	plot(i*ones(m1,1)+V(:,i),1:m1,'-');hold on
	plot([i i],[0 m1+1],':')
      end
      hold off;grid on;land;setlargefig;title(['V rows ' ttl])
       
      %bxi_plot_resobsmatrix(Tv,Tu,m,n,pm,ttl,signstr)
    end
    %disp('printing !')
    %for i=[1,3:4,8],figure(i),print -P4,end

    figure(9);clf;ip=0;
    for ik=gKs
      ip=ip+1;
      lambda=diag(L);
      solk=(S.^0.5)'*V(:,ik)*U(:,ik)'*Yp/lambda(ik);
      subplot(1,length(gKs),ip)
      plot(1:pm.gilwcol(1)-pm.gifwcol(1)+1,solk(pm.gifwcol(1):pm.gilwcol(1)));
    end
