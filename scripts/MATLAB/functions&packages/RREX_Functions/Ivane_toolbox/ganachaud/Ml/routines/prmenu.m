function prmenu(nfig)
%key: offer the choice to print or not the figure 'nfig' 
%synopsis : prmenu(nfig)
% 
% can also create post-script files, choose the size ...
%
%
%description : 
%
%
%
%
%uses :
%
%side effects : the position is random !
%
%author : A.Ganachaud (ganacho@gulf.mit.edu) , Oct 95
%
%see also :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(nfig);
global MENU_VARIABLE;
MENU_VARIABLE = 0;

im=menu(sprintf('PRINT FIGURE %i ?',nfig),'YES','NO');

if im==1
  MENU_VARIABLE = 0;
  im=menu('ORIENTATION','Portrait','Landscape');
  if im==1
     set(gcf, 'Paperorientation', 'Portrait') 
     MENU_VARIABLE = 0;
     im1=menu('SIZE','normal','whole paper','manual');
     if im1==1
        set(gcf, 'Paperposition', [0.25 2.5 8 6])
     elseif im1==2
        set(gcf, 'Paperposition', [0.3 0.5 8 10])
     else
       sz=get(gcf, 'Paperposition');
       disp(sprintf('Current size is %3.1f %3.1f %3.1f %3.1f',sz))
       ppsz=input('FIGURE SIZE [ leftboty leftbotx ysize xsize ]');
       set(gcf, 'Paperposition',ppsz)
     end
  else
     set(gcf, 'Paperorientation', 'landscape') 
     MENU_VARIABLE = 0;
     im1=menu('SIZE','normal','whole paper','manual');
     if im1==1
        set(gcf, 'Paperposition', [0.25 2.5 8 6])
     elseif im1==2
        set(gcf, 'Paperposition', [-0.8 -0.1 11 8.5])
     else
       sz=get(gcf, 'Paperposition');
       disp(sprintf('Current size is [%3.1f %3.1f %3.1f %3.1f]',sz))
       ppsz=input('FIGURE SIZE [ leftboty leftbotx ysize xsize ] ');
       set(gcf, 'Paperposition',ppsz)
     end
  end   
  MENU_VARIABLE = 0;
  im=menu('OUTPUT','printer','post-script','both');
  if im==1
    print
  else
    nf=input('name of .eps file ','s');
    eval(['print -deps ' nf ]);
    if im==3
      unix(['lpr ' nf '.eps']);
    end
  end
  im=menu('ONE MORE PRINT ?','yes','no');
  if im==1
    prmenu(gcf);
  end
end


     