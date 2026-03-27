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

global_coulsIHM;

figverif  =  figure('Units','normalized', ...
	                    'Color',CBG_fig, ...
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



