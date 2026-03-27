function glb_puttrans(iv,latlondir,arrowbasepositions,section2put,Nsec,...
Iazi,Transec,gist,gmtname,scale,thinvsthickarrowsratio,figmt,...
p_arrowcolor,p_arrowwidth,p_mk_arrows,p_unc,Outdir,mapproj)
% KEY: put the arrows for the total/partial transport across sections
% USAGE :
% DESCRIPTION : 
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Apr99
% SEE ALSO : glb_putres
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: glb_transmap
% CALLEE:
    if ~p_mk_arrows
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %draw command for each section, creates transport ascii files
      for isa_h=1:Nsec
	latlon=load([latlondir section2put{isa_h} '.latlon']);
	lonsec=scan_longitude(latlon(:,2));
	latsec=latlon(:,1);
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%creates the tranports file
	%1):position of each arrow:
	ipairpos=floor(length(lonsec)/2);
	%flat=latsec(ipairpos);
	%flon=lonsec(ipairpos);
	flat=arrowbasepositions(isa_h,1);
	flon=arrowbasepositions(isa_h,2);
	
	%2):azimuth
	tazi=Iazi(isa_h);
	Ttransp=Transec(gist(isa_h)).Tanet(iv);
	dTtransp=Transec(gist(isa_h)).dTanet(iv);
	if isnan(Ttransp)
	  Ttransp=0;dTtransp=0;
	end
	%3):transport (scaled)
        Ttransp
        dTtransp
	if Ttransp<0
	  Ttransp=-Ttransp;
	  tazi=rem(tazi-180,360);
	end
	ftransp=['Trans/' gmtname '_' section2put{isa_h} '.transp'];
	fdtransp=['Trans/' gmtname '_' section2put{isa_h} '.dtransp'];
	if abs(Ttransp)>(scale*3) & iv~=2
	  Ttransp=Ttransp/scale/thinvsthickarrowsratio;
	  dTtransp=dTtransp/scale/thinvsthickarrowsratio;
	  fprintf(figmt,...
	    'psxy %s -R %s  -G%s -Sv%3g/%3g/%3g  -K -O -: >>$outfile\n',...
	    ftransp,mapproj,p_arrowcolor,p_arrowwidth,p_arrowwidth*0.12/0.04,...
	    p_arrowwidth*0.05/0.04);
	  if p_unc
	    fprintf(figmt,['psxy %s -R %s -Sv%3g/0.001/0.001 '...
		'-K -O -: >>$outfile\n'],fdtransp,mapproj,p_arrowwidth);
	  end
	  smallarrowwidth=p_arrowwidth;
	else
	  Ttransp=Ttransp/scale;
	  dTtransp=dTtransp/scale;
	  smallarrowwidth=p_arrowwidth*0.015/0.04;
	  fprintf(figmt,['psxy %s -R %s -G%s -Sv%3g/%3g/%3g '...
	      '-K -O -: >>$outfile\n'],ftransp,mapproj,p_arrowcolor,...
	    smallarrowwidth,...
	    p_arrowwidth*0.06/0.04,p_arrowwidth*0.02/0.04);
	  if p_unc
	    fprintf(figmt,['psxy %s -R %s -Sv%3g/0.001/0.001 ' ...
		'-K -O -: >>$outfile\n'],fdtransp,mapproj,smallarrowwidth);
	  end
	end
	fitransp=fopen([Outdir ftransp],'w');
	fprintf(fitransp,'%8.3f %8.3f %8.2f %8.4f\n',[flat flon tazi Ttransp]');
	fclose(fitransp);
	fitransp=fopen([Outdir fdtransp],'w');
	fprintf(fitransp,'%8.3f %8.3f %8.2f %8.4f\n',[flat flon ...
	    rem(tazi-180,360) dTtransp]');    
	fclose(fitransp);
	%disp(['TRANSPORTS FILE : ' ftransp])
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
	  
	  ftarr=[ gmtname '_' deblank(Names(isa_h,:)) '.tarr' ];
	  fdtarr=[ gmtname '_' deblank(Names(isa_h,:)) '.dtarr' ];
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
