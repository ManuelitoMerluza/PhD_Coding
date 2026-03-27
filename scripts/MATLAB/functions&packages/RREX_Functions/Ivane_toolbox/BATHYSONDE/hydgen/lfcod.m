%------------------------------------------------------------
%
%	lfcod
%
% fonction lecture fichier des codes 
%
% C.Fontaine - Atlantide
%
% le 23/2/98
% 
% janvier 99 : modif. C.Lagadec
% ----------
%  
%      ajout de l'initilisation des tableaux n'existant pas
%       - pour les parametres physiques (ORGCHIM et RESPCHIM)
%       - pour les parametres chimiques (LISSPHYS et METHPHYS)
%
%-------------------------------------------------------------

function [messerr] = lfcod ();

global COD;

% initialisations
% ---------------
COD.nomfic = 'service/ficodf';
messerr = '';
COD.npar = 0;

% Ouverture du fichier des codes
% ------------------------------

fcod = fopen(COD.nomfic,'r');
if (fcod == -1)
	messerr = sprintf('%s %s', 'Erreur d''ouverture du fichier des codes ', COD.nomfic)

else

	nolig = 0;
	while (~feof(fcod) & isempty(messerr))

		ligne=fgetl(fcod);
        nolig = nolig + 1;
        lignesb = strjust(ligne, 'left');
		lignesb = deblank(lignesb);
		if ((~isempty(lignesb)) & (length(ligne) == 76))
		
   			COD.npar = COD.npar + 1;
   			COD.codpar (COD.npar,1:4)  = ligne(1:4);
   			COD.nompar (COD.npar,:)    = ligne(6:43);
   			COD.unipar (COD.npar,:)    = ligne(44:55);
            COD.valmin (COD.npar)      = str2num(ligne(57:62));
            COD.valmax (COD.npar)      = str2num(ligne(72:76));

        else
		    messerr = sprintf('%s%d%s%s%s', 'La ligne ', nolig, ' du fichier des codes ', COD.nomfic, ' est incorrecte.')
			
        end
 
	end

   clear ligne nolig lignesb ;

   fclose(fcod);
end


