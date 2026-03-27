function [hhmmmm]= h2hmmmm(latorlong)
%convert decimal position lat long to hhmm.mm
hhmmmm=fix(latorlong);
hhmmmm=hhmmmm+0.6*(latorlong-hhmmmm);