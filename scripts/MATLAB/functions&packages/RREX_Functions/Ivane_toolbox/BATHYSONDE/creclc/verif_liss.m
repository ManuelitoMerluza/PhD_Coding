function verif_liss(tvalint,tvaliss,il,pmin,pmax);

% ----------------------------------------------
% fonction verif_liss - C.Lagadec(janv. 99)
%  - appelee par creat_clc
%
% tvalint : valeur brute
% tvaliss : valeur lissee
% il      : no d'ordre du parametre a lisser
% ----------------------------------------------


globalVarDef;

globalVarEtiquni;

figverif  =  figure('Units','normalized', ...
	                    'Color',[0.8 0.8 0.8], ...
	                    'Name','Verification des lissages ', ...
                            'NumberTitle','off', ...
                            'MenuBar','none');

pmax = min(pmax,length(tvalint));
plot(tvalint(il,pmin:pmax),-P_INT(pmin:pmax),'r',tvaliss(il,pmin:pmax),-P_INT(pmin:pmax),'g');

grid;

butt = questdlg('C''est vu ','Lissage','Oui', ' ');
if strcmp(butt, 'Oui')
        close;
end



