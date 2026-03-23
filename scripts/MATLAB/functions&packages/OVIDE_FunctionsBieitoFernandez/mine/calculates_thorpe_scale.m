function [LT, ov_num, ov_size, ov_len, minRL] = calculates_thorpe_scale(Z,X,variable,orientation,PLOT, maxnn)
    fprintf('\n Thorpe Scale Calculation Galbraith')
    if nargin<3
        variable = 'density';
    end
    if nargin<4
        orientation = 'down';
    end
    if nargin<5
        PLOT = 0;
    end
    if nargin<6
        maxnn = 20;
    end
    if strcmp(orientation, 'up')
        Z = Z(end:-1:1);
        X = X(end:-1:1);
    end
    if strcmp(variable,'density')
        order = 'ascend';
    elseif strcmp(variable,'temperature')
        order = 'descend';
    end
    
    [sortX, ist1] = sort(X,order);
    displ = Z - Z(ist1);
    
    %calculates minimum run length
    RL = [];
    rl = 1;
    sign0 = displ(1)/abs(displ(1));
    for i = 2:length(displ)
        sign = displ(i)/abs(displ(i));
        if sign == sign0
            rl = rl+1;
        else
            RL = [RL,rl];
            rl = 1;
        end
    end
    
    %calculates minimum run length
    [nRL,xRL] = hist(RL,linspace(1,maxnn,20));
    nRL = nRL/sum(nRL);
    

    minRL = xRL(find(nRL>2*2.^-xRL,1,'first'));
       
    
    cumd = abs(cumsum(displ));
    ov_num = ones(size(cumd));
    LT = zeros(size(cumd));
    ov_size = zeros(size(cumd));
    ov_len = zeros(size(cumd));
    ovN0 = 1;
    ilast = 1;
    imaxcd0 = 1;
    imincd0 = 1;
    for i = 2:length(ov_num)
       if sum(cumd(ilast:i))<1e-5
           ilast = i;
       end
       [maxcd, imaxcd] = max( cumd(ilast:i) );
       imaxcd= imaxcd+ilast-1;
       [mincd, imincd] = min( cumd(imaxcd:i) );
       imincd = imincd+imaxcd-1;
       
%        figure(22)
%        clf
%        plot(Z(ilast:i),cumd(ilast:i))
%        hold on
%        plot(Z(imincd),cumd(imincd),'v')
%        plot(Z(i),cumd(i),'s')
%        plot(Z(imaxcd),cumd(imaxcd),'^')
%        title(ovN0)
%        pause()
%        
       if imaxcd==imaxcd0 && imincd == imincd0 && mincd<1e-5*maxcd
           imaxcd0 = i;
           imincd0 = i;
           ovlen0 = i+1-ilast;
           %ovlen = [ovlen,ovlen0];
           if ovlen0>minRL
               ovN0 =ovN0 + 1;
                ov_num(ilast:i) = ovN0;
                LT(ilast:i) = var(displ(ilast:i)).^0.5;
                ov_size(ilast:i) = Z(i)-Z(ilast);
                ov_len(ilast:i) = ovlen0;
           else
               ov_num(ilast:i) = 0;
               LT(ilast:i) = 0.;
               ov_size(ilast:i) = 0.;
               ov_len(ilast:i) = ovlen0;
           end
           ilast = i;
       else
           imaxcd0 = imaxcd;
           imincd0 = imincd;
       end

    end
        
    if PLOT == 1
        figure()
        plot(xRL,nRL,'o-')
        hold on
        plot(xRL, 2.^-xRL,'r')
        plot(xRL, 2*2.^-xRL,'r--')
        ylabel('Probability')
        xlabel('Segment length')
        set(gca,'yscale','log')
        pause()
    
        figure()
        subplot(1,3,1)
        plot(displ,Z)
        axis ij
        ylabel('Pressure [db]')
        xlabel('Displ [m]')
        hold on
        plot(LT,Z,'linewidth',2)
        legend('Displ','L_T')
        set(gca,'yticklabels',[])
        subplot(1,3,2)
        plot(cumd,Z)
        axis ij
        xlabel('Cum. disp [m]')
        set(gca,'yticklabels',[])
        subplot(1,3,3)
        plot(abs(displ),Z)
        axis ij
        hold on
        plot(LT,Z,'linewidth',2)
        plot(ov_size,Z,'linewidth',2)
        legend('Displ','L_T','L_{ov}')
        xlabel('|Displ|, L_T, L_{ov} [m]')
        pause()
    end


