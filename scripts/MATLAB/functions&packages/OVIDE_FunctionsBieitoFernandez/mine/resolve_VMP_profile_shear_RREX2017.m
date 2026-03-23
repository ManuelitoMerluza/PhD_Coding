function [BIN,SLOW] = resolve_VMP_profile_shear_RREX2017(DATA, info,dataf_name,PLOT)
    DATA
    despike_sh  = [ 8  0.5 0.04];
    despike_A = [8 0.5000 0.0400];
    if ~ isfield(info,'minvel_detect')
        info.minvel_detect = 0.05;
    end
    if ~ isfield(info,'pmin')
        info.pmin = 1;
    end
    if ~ isfield(info,'dp')
        info.pint = 1;
    end
    if ~ isfield(info,'dpD')
        info.dpD = 2;
    end
    if ~ isfield(info,'dpTr')
        info.dpTr = info.dp;
    end
    if ~ isfield(info,'dpGr')
        info.dpGr = info.dpD;
    end
    if ~ isfield(info,'prof_dir')
        info.prof_dir = 'down';
    end
    if ~ isfield(info,'k_HP_cut')
        info.k_HP_cut = 0.5;
    end
    if ~ isfield(info,'k_HP_cut_T')
        info.k_HP_cut_T = 0.0;
    end
    if ~isfield(info,'shear_decorrelation')
       info.shear_decorrelation = 1; 
    end
    if ~ isfield(info,'minKsh')
        info.minKsh = 1;
    end
    if ~ isfield(info,'minintKsh')
        info.minintKsh = 1;
    end
    if ~ isfield(info,'maxKsh')
        info.maxKsh = 50;
    end
    if ~ isfield(info,'minKT')
        info.minKT = 1;
    end
    if ~ isfield(info,'fAA')
        info.fAA = 110;
    end
    if ~ isfield(info,'fmaxT')
        info.fmaxT = 90;
    end
    if ~ isfield(info,'Tmethod')
        info.Tmethod = 'B';
    end
    if ~ isfield(info,'Tspec')
        info.Tspec = 'K';
    end    
    if ~ isfield(info,'noisep_T1')
        %info.noisep_T1 = [-10.24,-0.89,info.fAA];
        info.noisep_T1 = [-10.5,-0.6,info.fAA];
    else
        info.noisep_T1 = [info.noisep_T1, info.fAA];
    end
    if ~ isfield(info,'noisep_T2')
        info.noisep_T2 = [-10.5,-0.60,info.fAA];
        %info.noisep_T2 = [-10.08,-0.97,info.fAA];
    else
        info.noisep_T2 = [info.noisep_T2, info.fAA];
    end
    if ~isfield(info,'time_res')
        info.time_res = nan;%5.8/1000. %acording to sebastiano% Nan si for Rockland
    end
    if ~isfield(info,'time_res_speed')
        info.time_res_speed = 'Nash';%or Goto or Kocsis
    end
    if ~isfield(info,'pole')
        if isnan(info.time_res)
            info.pole = 'Double';%or Single or Double
        else
            info.pole = 'Single';
        end
    end
    if ~isfield(info,'hfactor')
        info.hfactor = 1/10;
    end
    if ~ isfield(info,'peak_rem_T1')
        info.peak_rem_T1 = [0,0];
    end
    if ~ isfield(info,'peak_rem_T2')
        info.peak_rem_T2 = [0,0];
    end
    if ~isfield(info,'chl_cal')
        info.chl_cal = [0.063,10];
    end
    if ~isfield(info,'turb_cal')
        info.turb_cal = [0.057,5];
    end
    if ~ isfield(info,'kmax_fac')
        info.kmax_factor = 1/1.66;
    end
    if ~ isfield(info,'thorpe_method')
        info.thorpe_method = 'simple'; %can be 'Galbraith'
    end
    

    %adds some more noise
    %info.noisep_T1 = info.noisep_T1 + [0.25,0,0];
    %info.noisep_T2 = info.noisep_T2 + [0.25,0,0];
    
    %constants
    D = 1.44e-7;
    
    %defines times
    time_fast0 = [0:1:length(DATA.P_fast)-1]/DATA.fs_fast;
    time_slow0= [0:1:length(DATA.P_slow)-1]/DATA.fs_slow;

    %sampling frequencies
    fss = DATA.fs_slow;
    fsf = DATA.fs_fast;  
    
    %date
    date = datenum(DATA.Year, DATA.Month, DATA.Day, DATA.Hour, DATA.Minute, DATA.Second );
    %date = date + iPs0(1,inp)/DATA.fs_slow/60/60/24;
    %datestr(date)
    
%     %gets profiles
%     %gets profiles
%     iPf0 = get_profile(DATA.P_fast,DATA.W_fast,0,info.minvel_detect,info.prof_dir,info.mindur_detect,DATA.fs_fast);
%     iPs0 = get_profile(DATA.P_slow,DATA.W_slow,0,info.minvel_detect,info.prof_dir,info.mindur_detect,DATA.fs_slow);
%     NP = size(iPf0);
%     NP = NP(2);
%     if inp<0 > inp>NP
%         fprintf('Wrong number of profiles')
%         return
%     end
%     
%     %gets index for the desired profile
%     if NP>0
%         iipf = iPf0(1,inp):iPf0(2,inp);
%         iips = iPs0(1,inp):iPs0(2,inp);
%     else
%         iipf = [1:1:length(DATA.P_fast)];
%         iips = [1:1:length(DATA.P_slow)-1];
%     end

    istart_f = find(DATA.W_fast>info.minvel_detect,1,'first');
    iend_f0 = find(DATA.P_fast == max(DATA.P_fast),1,'first');
    Wf0 = DATA.W_fast(1:iend_f0);
    Pf0 = DATA.P_fast(1:iend_f0);
    %iend_f0
    iend_f1 = find( (Wf0 <info.minvel_detect) & (Pf0 > max(Pf0)-info.dpD),1,'first');
    iend_f = nanmin([iend_f0,iend_f1]);
    %pause()

    iipf = istart_f:iend_f;
    P00 = DATA.P_fast(istart_f);
    istart_s = find(DATA.P_slow>=P00,1,'first');
    iend_s = find(DATA.P_slow == max(DATA.P_slow),1,'first');
    iips = istart_s:iend_s;
    iips_u = iend_s:length(DATA.P_slow);

    %gets fast response sensors
    timef = time_fast0(iipf);
    Pf = DATA.P_fast(iipf);
    T1f = DATA.T1_fast(iipf);
    T2f = DATA.T2_fast(iipf);
    sh1 = DATA.sh1(iipf);
    sh2 = DATA.sh2(iipf);
    Ax = DATA.Ax(iipf);
    Ay = DATA.Ay(iipf);
    AA = [Ax,Ay];
    Wf = DATA.W_fast(iipf);

    %gets slow response sensors
    times = time_slow0(iips);
    Ps = DATA.P_slow(iips);
    T_SB = DATA.sbt(iips);
    C_SB = DATA.sbc(iips);
    T1s = DATA.T1_slow(iips);
    T2s = DATA.T2_slow(iips);

    T_SB_up = DATA.sbt(iips_u);
    C_SB_up = DATA.sbc(iips_u);
    Ps_up = DATA.P_slow(iips_u);    
    
    %pressure correction
    if isfield(info,'pres_cor')
       Ps = Ps*info.pres_cor(1) + info.pres_cor(2); 
       Pf = Pf*info.pres_cor(1) + info.pres_cor(2);
    end

    %matches the FP07 to the high accuracy sensors
    [polT1, deltaP1] = calibration_FP07(Ps,T1s, T_SB, fss);
    [polT2, deltaP2] = calibration_FP07(Ps,T2s, T_SB, fss);
    T1f = polyval(polT1,T1f);
    T2f = polyval(polT2,T2f);
    deltaP = 0.5*(deltaP1+deltaP2);
    Ps = Ps+deltaP;
    Ps_up = Ps_up+deltaP;
    
    %accurate T in fast sensors grid to input the odas_diss
    %calculation when thermistors are not working
    T_SB_fast = interp1(Ps,T_SB,Pf);
    i1 = find(isfinite(T_SB_fast),1,'first');
    if i1>1
        T_SB_fast(1:i1-1) = T_SB_fast(i1);
    end
    i2 = find(isfinite(T_SB_fast),1,'last');
    if i2<length(T_SB_fast)
        T_SB_fast(i2+1:end) = T_SB_fast(i2);
    end


    %sets maximum depth
    if ~ isfield(info,'pmax')
        info.pmax = round(max(Ps)-info.dpD/2)+1;
    end

    %calculates salinity and density
    S_SB = salinity(Ps,T_SB,C_SB);
    Theta_SB = sw_ptmp(S_SB, T_SB, Ps,0);
    sgt = sw_pden(S_SB, T_SB,Ps,0);
    mrho = cumsum(sgt)./[1:length(sgt)]';
    if isfield(info,'Latitude')
        depth=sw_dpth(Ps, info.Latitude);
    else
        depth=10000*Ps./(mrho*9.81);
    end

    S_SB_up = salinity(Ps_up,T_SB_up,C_SB_up);
    Theta_SB_up = sw_ptmp(S_SB_up, T_SB_up, Ps_up,0);

    
    %slow data for output
    SLOW.date = date;
    SLOW.filename = dataf_name;
    SLOW.depth = depth;
    SLOW.pres = Ps;
    SLOW.T = T_SB;
    SLOW.C = C_SB;
    SLOW.S = S_SB;
    SLOW.sigmat = sgt;

    SLOW.pres_up = Ps_up;
    SLOW.T_up = T_SB_up;
    SLOW.C_up = C_SB_up;
    SLOW.S_up = S_SB_up;

    
   

    %binned temperature, salinity and density
    %defines the presure vector where to calculate
    pres = [info.pmin:info.dp:info.pmax];
    BIN.pres = pres;
    BIN.date = date;
    BIN.filename = dataf_name;
    BIN.depth = pres_av(Ps,depth,pres,info.dpTr,2.7);
    BIN.T=pres_av(Ps,T_SB,pres,info.dpTr,2.7);
    BIN.theta=pres_av(Ps,Theta_SB,pres,info.dpTr,2.7);
    BIN.C = pres_av(Ps,C_SB,pres,info.dpTr,2.7);
    BIN.S = pres_av(Ps,S_SB,pres,info.dpTr,2.7);
    BIN.sigmat = pres_av(Ps,sgt,pres,info.dpTr,2.7);
    BIN.grT = mean_grad(Ps,Theta_SB,pres,info.dpGr);
    BIN.grS = mean_grad(Ps,S_SB,pres,info.dpGr);
    BIN.N2 = -9.81*( -sw_alpha(BIN.S,BIN.theta,pres).*BIN.grT + sw_beta(BIN.S,BIN.theta,pres).*BIN.grS );
    sort_rho = sort(sgt);
    BIN.N2_s = -9.81*mean_grad(Ps,sort_rho,pres,info.dpGr)/1000; %N2 from sorted density
        
    BIN.theta_up=pres_av(Ps_up,Theta_SB_up,pres,info.dpTr,2.7);
    BIN.S_up = pres_av(Ps_up,S_SB_up,pres,info.dpTr,2.7);
    
    %calculates displacements for thorpe length
    if strcmp(info.thorpe_method,'simple')
        if ismember(info.prof_dir,'down')
            [sort_rho, isd] = sort(sgt);
            displ = Ps - Ps(isd);

        else
            [sort_rho, isd] = sort(sgt,'descend');
            displ = Ps - Ps(isd);


        end
        BIN.LT = sqrt(pres_av(Ps,displ.^2,pres,info.dpD,0));
        
    else
        %Uses the Galbraith method
        LT_0 = calculates_thorpe_scale(Ps,sgt,'density',info.prof_dir,PLOT);
        BIN.LT = sqrt(pres_av(Ps,LT_0,pres,info.dpD,0));
        
    end
        
    
    %plots raw
    figure(1)
    clf
    subplot(4,1,1)
    plot(DATA.P_fast)
    ylabel('p (db)')
    hold on
    plot(iipf,Pf)
    set(gca,'xticklabel',[])
    set(gca,'xticklabel',[])
    subplot(4,1,2)
    plot( T1f)
    hold on
    plot( T2f)
    ylabel('T fast (°C)')
    set(gca,'xticklabel',[])
    subplot(4,1,3)
    plot( sh1)
    hold on
    plot( sh2)
    ylabel('shear (1/s)')
    set(gca,'xticklabel',[])
    subplot(4,1,4)
    plot(Wf)
    ylabel('w (m/s)')
    ['profile_',dataf_name,'_p','.png']

    % This part makes a directory used to save the figures
     outDir = fullfile(pwd, 'profiles_REXX2017');   % or whatever parent you want
        if ~isfolder(outDir)               % this evaluates if the directory does not exists
            mkdir(outDir)
        end
    outfile1=fullfile(outDir,['profile_',dataf_name,'_p','.png']);
    saveas(gcf,outfile1)
  
    

    %filters shear and highpasses microstructure
    %makes strange things at the borders (avoid?)
    [sh1, ~, ~, ~ ] =  despike(sh1, despike_sh(1), despike_sh(2), fsf, round(despike_sh(3)*fsf));
    [sh2, ~, ~, ~ ] =  despike(sh2, despike_sh(1), despike_sh(2), fsf, round(despike_sh(3)*fsf));
    mW = (max(Pf)-min(Pf))/(max(timef)-min(timef));
    if info.k_HP_cut>0
        f_HP_cut = info.k_HP_cut*mW;
        [bh,ah] = butter(1, f_HP_cut/(fsf/2), 'high');
        
        sh1_hp = filter(bh, ah, sh1);
        sh1_hp = flipud(sh1_hp);
        sh1_hp = filter(bh, ah, sh1_hp);
        sh1_hp = flipud(sh1_hp);
        
        sh2_hp = filter(bh, ah, sh2);
        sh2_hp = flipud(sh2_hp);
        sh2_hp = filter(bh, ah, sh2_hp);
        sh2_hp = flipud(sh2_hp);
        
    else
        sh1_hp = sh1;
        sh2_hp = sh2;
    end

    %for temperature    
    if info.k_HP_cut_T>0
        f_HP_cut_T = info.k_HP_cut_T*mW;
        [bh,ah] = butter(1, f_HP_cut_T/(fsf/2), 'high');

         T1f_hp = filter(bh, ah, T1f);
         T1f_hp = flipud(T1f_hp);
         T1f_hp = filter(bh, ah, T1f_hp);
         T1f_hp = flipud(T1f_hp);
 
         T2f_hp = filter(bh, ah, T2f);
         T2f_hp = flipud(T2f_hp);
         T2f_hp = filter(bh, ah, T2f_hp);
         T2f_hp = flipud(T2f_hp);
    else

        T1f_hp = T1f;
        T2f_hp = T2f;
    end
    
    %-- despike the piezo-accelerometer signals
    piezo_accel_num = size(AA,2);
    if  ~isempty(AA) && despike_A(1) ~= inf
        for probe = 1:piezo_accel_num
            [AA(:,probe), ~, ~, ~]  = ...
                despike(AA(:,probe),  despike_A(1), ...
                despike_A(2), fsf, round(despike_A(3)*fsf));
        end
    end

    %choose the right accelerometer for correction
    %shear 1
    PSDsh1 = csd_odas(detrend(sh1_hp),detrend(sh1_hp),1024,fsf,[],512,'linear');
    PSDA1 = csd_odas(detrend(AA(:,1)),detrend(AA(:,1)),1024,fsf,[],512,'linear');
    PSDA2 = csd_odas(detrend(AA(:,2)),detrend(AA(:,2)),1024,fsf,[],512,'linear');
    CSDsh1A1 = csd_odas(detrend(sh1_hp),detrend(AA(:,1)),1024,fsf,[],512,'linear');
    [CSDsh1A2,fA] = csd_odas(detrend(sh1_hp),detrend(AA(:,2)),1024,fsf,[],512,'linear');
    COHsh1A1 = abs(CSDsh1A1.^2./(PSDA1.*PSDsh1));
    COHsh1A2 = abs(CSDsh1A2.^2./(PSDA2.*PSDsh1));
    if nanmean(COHsh1A1)>nanmean(COHsh1A2)
        A1 = AA(:,1);
    else
        A1 = AA(:,2);
    end
    
    %shear 2
    PSDsh2 = csd_odas(detrend(sh2_hp),detrend(sh2_hp),1024,fsf,[],512,'linear');
    PSDA1 = csd_odas(detrend(AA(:,1)),detrend(AA(:,1)),1024,fsf,[],512,'linear');
    PSDA2 = csd_odas(detrend(AA(:,2)),detrend(AA(:,2)),1024,fsf,[],512,'linear');
    CSDsh2A1 = csd_odas(detrend(sh2_hp),detrend(AA(:,1)),1024,fsf,[],512,'linear');
    [CSDsh2A2,fA] = csd_odas(detrend(sh2_hp),detrend(AA(:,2)),1024,fsf,[],512,'linear');
    COHsh2A1 = abs(CSDsh2A1.^2./(PSDA1.*PSDsh2));
    COHsh2A2 = abs(CSDsh2A2.^2./(PSDA2.*PSDsh2));
    if nanmean(COHsh2A1)>nanmean(COHsh2A2)
        A2 = AA(:,1);
    else
        A2 = AA(:,2);
    end
    %removes the correlation
    if info.shear_decorrelation == 0
        A1(:) = 0;
        A2(:) = 0;
    end
        
    
    %defines output variables
    
    BIN.W = nan(1,length(pres));
    BIN.epsSH1 = nan(1,length(pres));
    BIN.KBSH1 = nan(1,length(pres));
    BIN.MADsh1 = nan(1,length(pres));
    BIN.MADcsh1 = nan(1,length(pres));
    BIN.fit_flag_sh1 = nan(1,length(pres));


    BIN.epsSH2 = nan(1,length(pres));
    BIN.KBSH2 = nan(1,length(pres));
    BIN.MADsh2 = nan(1,length(pres));
    BIN.MADcsh2 = nan(1,length(pres));
    BIN.fit_flag_sh2 = nan(1,length(pres));
    
    BIN.Xic1 = nan(1,length(pres));
    BIN.Xif1 = nan(1,length(pres));
    BIN.KB1 = nan(1,length(pres));
    BIN.sXif1 = nan(1,length(pres));
    BIN.sKB1 = nan(1,length(pres));
    BIN.Xiv1 = nan(1,length(pres));
    BIN.maxK1 = nan(1,length(pres));
    BIN.epsT1 = nan(1,length(pres));
    BIN.epsT1max = nan(1,length(pres));
    BIN.MAD1 = nan(1,length(pres));
    BIN.MADf1 = nan(1,length(pres));
    BIN.LKH1 = nan(1,length(pres));
    BIN.LKHratio1 = nan(1,length(pres));
    BIN.MADc1 = nan(1,length(pres));
    BIN.fit_flag_T1 = nan(1,length(pres));

    BIN.Xic2 = nan(1,length(pres));
    BIN.Xif2 = nan(1,length(pres));
    BIN.KB2 = nan(1,length(pres));
    BIN.sXif2 = nan(1,length(pres));
    BIN.sKB2 = nan(1,length(pres));
    BIN.Xiv2 = nan(1,length(pres));
    BIN.maxK2 = nan(1,length(pres));
    BIN.epsT2 = nan(1,length(pres));
    BIN.epsT2max = nan(1,length(pres));
    BIN.MAD2 = nan(1,length(pres));
    BIN.MADf2 = nan(1,length(pres));
    BIN.LKH2 = nan(1,length(pres));
    BIN.LKHratio2 = nan(1,length(pres));
    BIN.MADc2 = nan(1,length(pres));
    BIN.fit_flag_T2 = nan(1,length(pres));

    
    for i = 1:length(pres)
        jp = find(Pf>=pres(i)-info.dpD/2 & Pf<=pres(i)+info.dpD/2);
        visco = viscosity(BIN.T(i));
        if isfield(info,'Nfft')
           Nfft = info.Nfft;
        else
            Nfft = round(length(jp)/2)-1;
        end
        
        if isfield(info,'overlap')
           overlap = info.overlap;
        else
           overlap = round(Nfft/2);
        end

        if length(jp)<2*Nfft | length(jp)<256
            continue
        end
        BIN.W(i) = mean(abs(Wf(jp)));
        
        try
            %ODAS epsilon calculation
            %[BIN.epsSH1(i), ~, BIN.fit_flag_sh1(i), BIN.MADsh1(i), BIN.MADcsh1(i)] = dis_spec_ODAS(sh1_hp(jp), A1(jp), fsf, fss, Wf(jp), T_SB_fast(jp),timef(jp), Pf(jp), visco,Nfft, PLOT);
            %BIN.KBSH1(i)=1/(2*pi())*(BIN.epsSH1(i)/(visco*D^2))^(1/4); 

            %with my function
            [BIN.epsSH1(i), ~, ~,~, BIN.MADsh1(i), ~,BIN.MADcsh1(i),BIN.fit_flag_sh1(i)]= dis_spec(Pf(jp),sh1_hp(jp),A1(jp),info.minKsh,info.minintKsh,info.maxKsh,visco, Nfft, overlap, PLOT);
            BIN.KBSH1(i)=1/(2*pi())*(BIN.epsSH1(i)/(visco*D^2))^(1/4); 
        end
        
        
        try
            %ODAS
            %[BIN.epsSH2(i), ~, BIN.fit_flag_sh2(i), BIN.MADsh2(i), BIN.MADcsh2(i)] = dis_spec_ODAS(sh2_hp(jp), A2(jp), fsf, fss, Wf(jp), T_SB_fast(jp),timef(jp), Pf(jp), visco,Nfft,  PLOT);
            %BIN.KBSH2(i)=1/(2*pi())*(BIN.epsSH2(i)/(visco*D^2))^(1/4);
            %with my function
            [BIN.epsSH2(i), ~, ~,~, BIN.MADsh2(i), ~,BIN.MADcsh2(i),BIN.fit_flag_sh2(i)]= dis_spec(Pf(jp),sh2_hp(jp),A2(jp),info.minKsh,info.minintKsh,info.maxKsh,visco, Nfft, overlap, PLOT);
            BIN.KBSH2(i)=1/(2*pi())*(BIN.epsSH2(i)/(visco*D^2))^(1/4); 
        end
        
        KBsh = 0.5*BIN.KBSH1(i) + 0.5*BIN.KBSH2(i); 
        %FP07 calculations
        try
            [BIN.Xiv1(i),BIN.Xic1(i),BIN.Xif1(i),BIN.KB1(i),BIN.fit_flag_T1(i),BIN.sXif1(i), BIN.sKB1(i), BIN.MAD1(i), BIN.MADf1(i),BIN.MADc1(i),BIN.LKH1(i), BIN.LKHratio1(i), BIN.maxK1(i)] =Xi_spec(Pf(jp),T1f_hp(jp),info.minKT,info.fmaxT,KBsh,mean(abs(Wf(jp))),info.noisep_T1,  Nfft, overlap,info.Tspec,info.Tmethod,info.time_res, info.time_res_speed, info.pole,info.hfactor,info.peak_rem_T1,PLOT);
            BIN.epsT1(i) = visco*D^2*(2*pi()*BIN.KB1(i))^4;
            BIN.epsT1max(i) = visco*D^2*(2*pi()*BIN.maxK1(i)*info.kmax_factor)^4;
        end
        
        try
            [BIN.Xiv2(i),BIN.Xic2(i),BIN.Xif2(i),BIN.KB2(i),BIN.fit_flag_T2(i), BIN.sXif2(i), BIN.sKB2(i), BIN.MAD2(i), BIN.MADf2(i),BIN.MADc2(i),BIN.LKH1(i), BIN.LKHratio2(i), BIN.maxK2(i)] =Xi_spec(Pf(jp),T2f_hp(jp),info.minKT,info.fmaxT,KBsh,mean(abs(Wf(jp))),info.noisep_T2,  Nfft, overlap,info.Tspec,info.Tmethod,info.time_res, info.time_res_speed, info.pole, info.hfactor, info.peak_rem_T2,PLOT);
            BIN.epsT2(i) = visco*D^2*(2*pi()*BIN.KB2(i))^4;
            BIN.epsT2max(i) = visco*D^2*(2*pi()*BIN.maxK2(i)*info.kmax_factor)^4;
        end
        
    end


    BIN.KOsb1 = 0.2*BIN.epsSH1.*(BIN.N2_s).^-1;
    BIN.KOsb2 = 0.2*BIN.epsSH2.*(BIN.N2_s).^-1;
    BIN.KOsbT1 = 0.2*BIN.epsT1.*(BIN.N2_s).^-1;
    BIN.KOsbT2 = 0.2*BIN.epsT2.*(BIN.N2_s).^-1;
    BIN.KTf1 = 0.5*BIN.Xif1.*(BIN.grT).^-2;
    BIN.KTf2 = 0.5*BIN.Xif2.*(BIN.grT).^-2;
    [BIN.Reb1,~,BIN.KBB1] = Bouffard_model(BIN.epsT1,BIN.N2,BIN.T,7);
    [BIN.Reb2,~,BIN.KBB2] = Bouffard_model(BIN.epsT2,BIN.N2,BIN.T,7);
    BIN.LO1 = (BIN.epsT1./BIN.N2_s.^(3/2)).^(0.5);
    BIN.LO2 = (BIN.epsT2./BIN.N2_s.^(3/2)).^(0.5);

    pmin = info.pmin - info.dpD/2;
    pmax = pres( find(isfinite(BIN.T),1,'last')) + info.dpD/2;
    
    %plots profile
    figure(2)
    clf
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [29 20]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 29 20]);

    ax1=subplot(2,4,1);
    %plot(T_SB, Ps,'linewidth',1)
    %hold on
    %plot(Theta_SB, Ps,'linewidth',1,'color','green')
    plot(BIN.theta, pres,'linewidth',1,'color','green')
    hold on
    plot(BIN.theta_up, pres,'linewidth',1,'color','green','linestyle','--')
    xlabel('T/\theta (°C)')
    ylabel('p (db)')
    set(gca,'YDir','reverse')
    ylim([pmin,pmax])
    ax2=axes('Position',get(ax1,'Position'));
    set(ax2,'box','off')
    %plot(S_SB, Ps,'r', 'parent' , ax2,'linewidth',1)
    plot(BIN.S, pres,'r', 'parent' , ax2,'linewidth',1)
    hold on
    plot(BIN.S_up, pres,'r', 'parent' , ax2,'linewidth',1,'linestyle','--')
    set(ax2,'XAxisLocation','top',...
            'YAxisLocation','right',...
            'Color','none',...
            'XColor','r','YColor','k');
    yticklabels([])
    ylim([pmin,pmax])
    xlabel('Salinity')
    set(gca,'yticklabel',[])
    set(gca,'YDir','reverse')
        
    ax3=subplot(2,4,2)
    plot(BIN.W,BIN.pres,'-','linewidth',1,'markersize',4)
    hold on
    plot(Wf, Pf, 'color','r')
    xlabel('W (db/s)')
    ylim([pmin,pmax])
    set(gca,'yticklabel',[])
    set(gca,'YDir','reverse')
    grid('on')
    
    
    subplot(2,4,3)
    plot(BIN.epsT1,BIN.pres,'-','linewidth',1,'markersize',4)
    hold on
    plot(BIN.epsT2,BIN.pres,'-','linewidth',1,'markersize',4)
    plot(BIN.epsSH1,BIN.pres,'linewidth',1)
    plot(BIN.epsSH2,BIN.pres,'linewidth',1)
    plot(0.5*(BIN.epsT1max+BIN.epsT2max),BIN.pres,'-','linewidth',1,'markersize',4,'color',[0.5,0.5,0.5])
    legend('T01','T02','sh1','sh2','maxT','fontsize',7,'location','southeast')
    xlabel('\epsilon (m^2 s^{-3})')
    set(gca,'yticklabel',[])
    set(gca,'YDir','reverse')
    set(gca, 'xscale','log')
    xlim([1e-12,1e-4])
    ylim([pmin,pmax])
    set(gca,'xtick',10.^[-12:2:-4])
    grid('on')
    
    subplot(2,4,4)
    l1=plot(BIN.Xif1,BIN.pres,'-','linewidth',1,'markersize',4);
    hold on
    l2=plot(BIN.Xif2,BIN.pres,'-','linewidth',1,'markersize',4);
    plot(BIN.Xiv1,BIN.pres,'--','linewidth',1,'color',l1.Color())
    plot(BIN.Xiv2,BIN.pres,'--','linewidth',1,'color',l2.Color())
    legend('T01_f','T02_f','fontsize',7,'location','southeast')
    xlabel('\chi (K^2 s^{-1})')
    set(gca,'yticklabel',[])
    set(gca,'YDir','reverse')
    set(gca,'xscale','log')
    xlim([1e-12,1e-3])
    ylim([pmin,pmax])
    set(gca,'xtick',10.^[-11:2:-3])
    grid('on')
    
    subplot(2,4,5)
    plot(BIN.KTf1,BIN.pres,'-','linewidth',1,'markersize',4)
    hold on
    plot(BIN.KTf2,BIN.pres,'-','linewidth',1,'markersize',4)
    plot(BIN.KOsb1,BIN.pres,'-','linewidth',1,'markersize',4)
    plot(BIN.KOsb2,BIN.pres,'-','linewidth',1,'markersize',4)
    legend('T01 (O&C)','T02 (O&C)','SH01 (O)', 'SH01 (O)','fontsize',7,'location','southeast')
    xlabel('K (m^2 s^{-1})')
    ylabel('p (db)')
    set(gca,'YDir','reverse')
    set(gca,'xscale','log')
    xlim([1e-9,1e0])
    ylim([pmin,pmax])
     set(gca,'xtick',10.^[-7:2:0])
    grid('on')
    
    subplot(2,4,6)
%     l1=plot(BIN.KB1,BIN.pres,'-','linewidth',1,'markersize',4);
%     hold on
%     l2=plot(BIN.KB2,BIN.pres,'-','linewidth',1,'markersize',4);
%     plot(BIN.maxK1,BIN.pres,'--','linewidth',1,'color',l1.Color())
%     plot(BIN.maxK2,BIN.pres,'--','linewidth',1,'color',l2.Color())
%     xlabel('K_B (m)')
%     set(gca,'YDir','reverse')
%     %set(gca,'xscale','log')
%     grid('on')
%     ylim([pmin,pmax])
    
     plot(BIN.LT,BIN.pres,'-','linewidth',1,'markersize',4)
     hold on
     plot(BIN.LO1,BIN.pres,'-','linewidth',1,'markersize',4)
     plot(BIN.LO2,BIN.pres,'-','linewidth',1,'markersize',4)
     legend('L_T','L_O_1','L_O_2','fontsize',7,'location','southeast')
     xlabel('L_T, L_O (m)')
     set(gca,'YDir','reverse')
     set(gca,'xscale','log')
     grid('on')
     ylim([pmin,pmax])
    
    subplot(2,4,7)
    plot(BIN.MADf1, BIN.pres,'-','linewidth',1,'markersize',4)
    hold on
    plot(BIN.MADf2, BIN.pres,'-','linewidth',1,'markersize',4)
    plot(BIN.MADsh1, BIN.pres,'-','linewidth',1,'markersize',4)
    plot(BIN.MADsh2, BIN.pres,'-','linewidth',1,'markersize',4)
    plot(BIN.MADc1, BIN.pres,'k-')
    plot(BIN.MADc1*2, BIN.pres,'k-')
    xlabel('MAD')
    xlim([0,2])
    set(gca,'yticklabel',[])
    set(gca,'YDir','reverse')
    grid('on')
    ylim([pmin,pmax])
    
    subplot(2,4,8)
    plot(BIN.LKHratio1, BIN.pres,'-','linewidth',1,'markersize',4)
    hold on
    plot(BIN.LKHratio2, BIN.pres,'-','linewidth',1,'markersize',4)
    line([2,2],ylim, 'color','k')
    xlabel('Likelihood ratio')
    set(gca,'yticklabel',[])
    set(gca,'YDir','reverse')
    grid('on')
    ylim([pmin,pmax])
    
    outfile2=fullfile(outDir,[dataf_name,'_P','.png']);
    saveas(gcf,outfile2)
    

    %hold on
    %semilogx(epsilon2,-pres)
    %semilogx(epsilonN,-pres)
