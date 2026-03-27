%print color
%print -dcdjcolor -Pcolor15
%disp('Sent to color15 printer')
print -depsc tmpfigurecolor.epsc
unix('lpr -h -Pcolor15 tmpfigurecolor.epsc && \rm tmpfigurecolor.epsc');