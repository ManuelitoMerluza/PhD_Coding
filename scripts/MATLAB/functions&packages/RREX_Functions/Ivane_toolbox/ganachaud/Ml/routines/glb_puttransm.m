function [Hp,Ht,Hpu,Htu,htx]=glb_puttransm(iv,latlon,arrowbasepositions,section2put,Nsec,...
Iazi,Transec,gist,figname,scale,thinvsthickarrowsratio,...
p_arrowcolor,p_arrowwidth,p_mk_arrows,p_unc,Outdir,...
p_writeflux,p_put_transports,p_bw)
% 					KEY: put the arrows for the total/partial transport across sections
% USAGE :
% DESCRIPTION : 
% INPUT: 
% OUTPUT: handles to transport arrows
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Apr99
%          June 01: added possibility of net/bt/bi/gyre transports 
% SIDE EFFECTS :
% SEE ALSO : glb_putresm
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: glb_transmap
% CALLEE:
global Llll p_resfontsize
htx=[];
Hpu=[];
Htu=[];
set(gca,'PlotBoxAspectRatioMode','auto')
set(gca,'DataAspectRatioMode','auto')
set(gca,'cameraviewanglemode','auto')

    arrcolor=p_arrowcolor;
    p_unc1=p_unc;
    if ~p_mk_arrows
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %draw command for each section, creates transport ascii files
      for isa_h=1:Nsec
	%latlon=load([latlondir section2put{isa_h} '.latlon']);
	lonsec=scan_longitude(latlon{isa_h}(:,2));
	latsec=latlon{isa_h}(:,1);
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%creates the tranports file
	%1):position of each arrow:
	ipairpos=floor(length(lonsec)/2);
	%flat=latsec(ipairpos);
	%flon=lonsec(ipairpos);
	flat=arrowbasepositions(isa_h,1);
	flon=arrowbasepositions(isa_h,2);
	p_arrowcolor=arrcolor;
	p_unc=p_unc1;
	% LOOP ON ARROWS TO SUCCESSIVELY PLOT TOTAL, BT, BI, HORIZ.
	largearrow=0;
	if flat<-55
	  flat=-55;
	end
	iloop=1;
	while iloop<=4
	  %2):azimuth
	  tazi=Iazi(isa_h);
	  switch iloop
	    case 1
	      Ttransp=Transec(gist(isa_h)).Tanet(iv);
	      dTtransp=Transec(gist(isa_h)).dTanet(iv);
	      if p_bw
		p_arrowcolor='k';
	      end
	    case 2  % BT transport
	      Nlay=size(Transec(gist(isa_h)).Tbi,1);
	      Ttransp=Transec(gist(isa_h)).Tbi(Nlay,iv);
	      flon=flon+4*tazi/90;
	      flat=flat+2*(tazi-90)/90;
	      if p_bw
		p_arrowcolor=0.4*[1 1 1];
	      else
		p_arrowcolor='g';
	      end
	      p_unc=0;
	    case 3  % BI transport
	      gil2sum=find(~isnan(Transec(gist(isa_h)).Tbi(1:Nlay-1,iv)));
	      transbi=sum(Transec(gist(isa_h)).Tbi(gil2sum,iv));
	      Ttransp=transbi;
	      flon=flon+4*tazi/90;
	      flat=flat+2*(tazi-90)/90;
	      if p_bw
		p_arrowcolor=0.7*[1 1 1];
	      else
		p_arrowcolor='b';
	      end
	    case 4  % Gyre transport
	      Ttransp=Transec(gist(isa_h)).Tanet(iv)-transbi-...
		Transec(gist(isa_h)).Tbi(Nlay,iv);
	      flon=flon+4*tazi/90;
	      flat=flat+2*(tazi-90)/90;
	      if p_bw
		p_arrowcolor=[1 1 1];
	      else
		p_arrowcolor='b';
	      end
	  end
	  if isnan(Ttransp)
	    Ttransp=0;dTtransp=0;
	  end
	  %3):transport (scaled)
	  if Ttransp<0
	    Ttransp=-Ttransp;
	    tazi=rem(tazi-180,360);
	  end
%	  if iloop==1 %set the large/small arrow scale 
	    if abs(Ttransp)>(scale*3)
	      largearrow=1;
	      divddd=scale*thinvsthickarrowsratio;
	    else
	      divddd=scale;
	    end
%	  end
	  Ttransp=Ttransp/divddd;
	  dTtransp=dTtransp/divddd;
	  arrowwidth=p_arrowwidth*0.5*(1+largearrow);
	  fmttrans={'''%1g ''';'''%1.2g ''';'''%1g ''';'''%4.0f ''';
	  '''%2.0f ''';'''%3.0f ''';'''%3.0f ''';'''%3g ''';'''%3g ''';
	  '''%3g '''};
	  roundoff=[ 1 10 1 .1 1 .1 .1 .1 10 10 10 10];
	  if p_writeflux==1
	    eval(['slabel=deblank(sprintf(' fmttrans{iv} ...
		',round(roundoff(iv)*Transec(gist(isa_h)).Tanet(iv))/'...
		'roundoff(iv)));'])
	  elseif p_writeflux==2
	    eval(['slabel=deblank(sprintf(' fmttrans{iv} ...
		',round(roundoff(iv)*Transec(gist(isa_h)).Tanet(iv))/'...
		'roundoff(iv)'...
		',round(roundoff(iv)*Transec(gist(isa_h)).dTanet(iv))/'...
		'roundoff(iv)));'])
	  end
	  [hp,ht]=m_vec(1,flon,flat,Ttransp*cos(tazi*pi/180),...
	    Ttransp*sin(tazi*pi/180),p_arrowcolor,...
	    'shaftwidth',arrowwidth,'headwidth',arrowwidth*1.4);
	  Hp{isa_h}=hp;
	  Ht{isa_h}=ht;
	  %htx{isa_h}=m_text(flon,flat,slabel,'horiz','right','vert','bot',...
	  %'clipping','off','color',p_arrowcolor,'fontsize',12);
	  if p_unc
	    [hpu,htu]=m_vec(1,flon,flat,-dTtransp*cos(tazi*pi/180),...
	      -dTtransp*sin(tazi*pi/180),'w',...
	      'shaftwidth',arrowwidth,'headlength',0,'EdgeColor','k');
	    Hpu{isa_h}=hpu;
	    Htu{isa_h}=htu;
	  end
	  if p_writeflux
	    load Latlon/txtheattranspos.dat
	    [hp,ht]=m_vec(0.77,txtheattranspos(isa_h,2),...
	      txtheattranspos(isa_h,1),0.3,0,[1 1 1],...
	      'shaftwidth',0.55*p_resfontsize,'headlength',0,'EdgeColor',p_arrowcolor);
	    htx=m_text(txtheattranspos(isa_h,2)+.5,...
	      txtheattranspos(isa_h,1)+.15,slabel,...
	      'fontsize',p_resfontsize*8/12,'color',p_arrowcolor);
	  end

	  if iloop==3
	    largearrow=0;
	  end
	  if p_put_transports==2
	    set(hp,'EdgeColor','k')
	    iloop=iloop+1;
	  else
	    iloop=10;
	  end
	end %while iloop
      end %on isa_h
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %^L DRAW PARTIAL TRANSPORTS 
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else %if p_mk_arrows
      error('arrows not coded')
      if p_arrows==iv
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%draw command for each section, also creates the arrow and
	%lat/long ascii files
	for isa_h=section2put
	  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	  %creates the tranports file
	  %1):position of each arrow
	  %find the non-NaN arrows
	  isgood=find(~isnan(tlat(:,isa_h)));
	  arlat=tlat(isgood,isa_h);
	  arlon=tlon(isgood,isa_h);
	  
	  %2):azimuth
	  tazi=Iazi(isa_h)*ones(size(isgood));
	  tarr=tarrows_iv(isgood,isa_h);
	  dtarr=dtarrows_iv(isgood,isa_h);
	  %3):arrows (scaled)
	  sumtarr=sum(tarr);
	  ineg=find(tarr<0);
	  tarr(ineg)=-tarr(ineg);
	  tazi(ineg)=rem(-180+tazi(ineg),360);
	  
	  ftarr=[ figname '_' deblank(Names(isa_h,:)) '.tarr' ];
	  fdtarr=[ figname '_' deblank(Names(isa_h,:)) '.dtarr' ];
	  if (abs(sumtarr)>(scale/2))
	    tarr=tarr/scale/10;
	    dtarr=dtarr/scale/10;
	    fprintf(figmt,['psxy %s -R %s -G0/0/0 -Sv0.04/0.12/0.05 '...
		'-K -O -: >>$outfile\n'],ftarr,mapproj);
	    if p_unc
	      fprintf(figmt,['psxy %s -R %s -Sv0.04/0.001/0.001 '...
		  '-K -O -: >>$outfile\n'],fdtarr,mapproj);
	    end
	  else
	    tarr=tarr/scale;
	    dtarr=dtarr/scale;
	    fprintf(figmt,['psxy %s -R %s -Sv0.015/0.06/0.02 -G0/0/0 ' ...
		'-K -O -: >>$outfile\n'],ftarr,mapproj);
	    if p_unc
	      fprintf(figmt,['psxy %s -R %s -Sv0.015/0.001/0.001 '...
		  '-K -O -: >>$outfile\n'],fdtarr,mapproj);
	    end
	  end
	  fitarr=fopen([Outdir ftarr],'w');
	  fprintf(fitarr,'%8.3f %8.3f %8.2f %8.4f\n',[arlat arlon tazi tarr]');
	  fclose(fitarr);
	  fitarr=fopen([Outdir fdtarr],'w');
	  fprintf(fitarr,'%8.3f %8.3f %8.2f %8.4f\n',[arlat arlon ...
	      rem(tazi-180,360) dtarr]');    
	  fclose(fitarr);
	  
	end %on isa_h
      end %if p_arrows == iv
      
    end%if ~p_mk_arrows
