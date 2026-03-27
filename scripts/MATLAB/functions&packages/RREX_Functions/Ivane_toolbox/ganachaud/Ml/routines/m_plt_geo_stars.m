function m_plt_geo_stars(tlondec,tlatdec,datared,minax,maxax)
[X2,Y2]=m_ll2xy(tlondec,tlatdec,'clip','on');
npts=length(datared);
% échelle des couleurs :
cm=colormap;
caxis([minax maxax])
css=(1:npts);
ccs=ones(npts,3);
ecs=64/(maxax-minax);
css=min(64,round((datared-minax)*ecs));
gis0=find(~css);
css(gis0)=1;
%for jj=1:npts
%    if css(jj)==0
%        css(jj)=1;
%    end
%end
ccs=cm(css,:);
%[ll]=m_line(tlondec(min(gis):max(gis)),tlatdec(min(gis):max(gis)));
%set(ll,'color','k','linewidth',1)
for i=1:npts
    plot(X2(i),Y2(i),'*','MarkerEdgeColor',ccs(i,:),'markersize',8)
end
colorbar
