    disp(sprintf('treating pair %i ', ipair))

    iss   = ishdp(1,ipair);	%shallow station index 
    isd   = ishdp(2,ipair);	%deep    station index
    %isdeep=[]; %index for the next station on the deep side
    
    % calculate pair dynamic height
    sgpan = gpans(:,iss);
    dgpan = gpans(:,isd);
    pgpan = 0.5 * (sgpan + dgpan); 
    extrapolated_temp=[];
    
    if ~dynh_option 
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Original code of:
      %extrapolate shal and pair dynh in bottom triangle using g_botwedge
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      [sgpan,pgpan,dgpan] = g_botwedge(bwedgemethod, p_plt_botwedge, ipair, ...
	'gpan','m^2/s^2' , pres, ...
	sgpan, Maxd(iss,Itemp), dgpan, Maxd(isd,Itemp), pgpan, ...
	distg(ipair), slopmx);
      sflag(ipair)=0;
      
    else %(dyn_opt) %Optional code extrapolate on T and S then recompute
      %dynamic height (as in GEOVEL.F)
      
      extrapolated_temp=temps;
      % temperature 
      if p_hz_ex
	[stemp,sflagt,isdeep]=g_horiz_extrap(temps,ishdp,ipair,Slat, Slon);
	imaxdt=max(find(~isnan(stemp)));
      else
	stemp = temps(:,iss);
	imaxdt=Maxd(iss,Itemp);
	sflagt=0;
      end
      dtemp = temps(:,isd);
      ptemp = 0.5 * (stemp + dtemp);
      
      % extrapolate shal and pair temp in bottom triangle using g_botwedge
      % if horizontal interpolation was already done, it will extrapolate
      % on possibly remaining points
      [stemp,ptemp,dtemp] = g_botwedge(bwedgemethod, p_plt_botwedge, ipair, ...        
	Propnm{Itemp}, Propunits{Itemp}, pres, ...
	stemp, imaxdt, dtemp, Maxd(isd,Itemp), ptemp, ...
	distg(ipair), slopmx);
      extrapolated_temp(:,iss)=stemp;
      
      % salinity
      if p_hz_ex
	[ssali,sflags]=g_horiz_extrap(salis,ishdp,ipair,Slat, Slon);
	imaxds=max(find(~isnan(ssali)));
      else
	ssali = salis(:,iss);
	imaxds=Maxd(iss,Isali);
	sflags=0;
      end
      sflag(ipair)=sflagt|sflags;
      dsali = salis(:,isd);
      psali = 0.5 * (ssali + dsali);
      
      
      % extrapolate shal and pair sali in bottom triangle using g_botwedge
      [ssali,psali,dsali] = g_botwedge(bwedgemethod, p_plt_botwedge, ipair, ...
	Propnm{Isali}, Propunits{Isali}, pres, ...
	ssali, imaxds, dsali, Maxd(isd,Isali), psali, ...
	distg(ipair), slopmx);
      
      % calc shal gpan at all levels based on shallow S and T (for debug only)
      %sgpan = sw_gpan(ssali,stemp,pres); 
      
      % calc shal gpan in bot triangle as an addon to the integrated values up to LCD
      idtrig = Maxd(iss,Itemp) : Maxd(isd,Itemp);
      swgp = sw_gpan(ssali(idtrig), stemp(idtrig), pres(idtrig));
      dwgp = sw_gpan(dsali(idtrig), dtemp(idtrig), pres(idtrig));
      sgpan(idtrig) = sgpan(Maxd(iss,Itemp)) - swgp(1) + swgp;
      dgpan(idtrig) = dgpan(Maxd(iss,Itemp)) - dwgp(1) + dwgp;
      
      % calc pair gpan at all levels based on pair S and T
      pgpan = sw_gpan(psali,ptemp,pres);
      
    end	%end Optional code to calculate gpan in bottom triangle
    %prop(:,iss)=stemp;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % geostrophic velocity (cm/s):
    gvel(:,ipair) = 100*signp(ipair)* ...
      sw_gvel([sgpan,dgpan], Slat([iss isd]), Slon([iss isd]));

