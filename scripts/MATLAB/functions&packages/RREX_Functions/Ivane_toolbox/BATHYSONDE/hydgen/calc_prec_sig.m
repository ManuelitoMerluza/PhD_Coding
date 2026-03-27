function prec = calc_sig_prec(prec_t,prec_s,Smax,Tmax,Pmax,SIGmax)

% calcul de la precision de SIG0 à SIG6 et de SIGI
% en fonction de la precision de T (ou TPOT) et S

% prec_t : precision de TEMP ou TPOT (idem)
% prec_s : precision de PSAL
% Smax : valeur du dernier niveau de PSAL
% Tmax : valeur du dernier niveau de TEMP (pour SIGI) ou de TPOT (pour SIG0,1,2 ...6)
% Pmax : valeur du dernier niveau de PRES
% SIGmax : valeur du dernier niveau de SIG

a=sw_alpha(Smax,Tmax,Pmax,'ptmp');
b=sw_beta(Smax,Tmax,Pmax,'ptmp');

prec=(1000+SIGmax)*sqrt((a*prec_t)^2 +(b*prec_s)^2);
