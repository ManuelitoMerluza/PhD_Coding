function g_pltpair(fig,ihp,Maxd,Pres,ishdp,gvel,s_dynh,d_dynh)
%key:
%synopsis :
% 
%description : 
%
%uses :
%
%side effects :
%
%author : A.Ganachaud (ganacho@gulf.mit.edu) , Oct 95
%
%see also :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(fig);

% Pres is taken till the deep station Pres:
  idep   = 1:Maxd(ishdp(2,ihp)); 
% extrapolated indices:
  idepsd =   Maxd(ishdp(1,ihp))+1 : Maxd(ishdp(2,ihp)); 
% last common Pres:
  lcd    = -Pres(Maxd(ishdp(1,ihp))); 

subplot(1,2,1);
 plot(gvel(idep,ihp), -Pres(idep), gvel(idep,ihp), -Pres(idep), '+'); 
 grid on;
 ax = axis; 
 hold on; 
 plot([ax(1) ax(2)], [ lcd lcd ])
 title('Velocity'); 
 xlabel(' cm / s ')
 ylabel('Pres (db)'); 
 tx1 = text(ax(1), lcd, 'LCD', 'VerticalAlignment', 'bottom');
 set(gca, 'fontsize', 8)
 
subplot(1, 2, 2)
 plot(d_dynh(idep,ihp), -Pres(idep), d_dynh(idep, ihp), -Pres(idep), 'o'); 
 hold on
 plot(s_dynh(idep,ihp), -Pres(idep), s_dynh(idep, ihp), -Pres(idep), 'x'); 
 grid on
 plot(s_dynh(idepsd,ihp), -Pres(idepsd), s_dynh(idepsd,ihp), -Pres(idepsd),'*');
 title('dyn. height uder LCD'); 
 set(gca, 'YTickLabels', []); 
 xlabel('m^2 / s^2')
 ylabel('o = data (deep st.), * = guess (shal st.)')
 axis([ floor(min([s_dynh(idepsd,ihp); d_dynh(idepsd,ihp)])) ...
         ceil(max([s_dynh(idepsd,ihp); d_dynh(idepsd,ihp)])) ax(3:4)])
 set(gca, 'fontsize', 8)

 suptitle(['LARGE DEPTH DIFFERENCE, PAIR ' int2str(ihp)])


