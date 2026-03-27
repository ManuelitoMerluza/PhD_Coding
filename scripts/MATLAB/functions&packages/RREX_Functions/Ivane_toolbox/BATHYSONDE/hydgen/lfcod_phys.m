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
% juin 2013 : CL : lecture uniquement codes physiques
%-------------------------------------------------------------

function [messerr] = lfcod_phys ();

global COD;

% initialisations
% ---------------
     messerr = '';
     COD.npar = 0;

dirbathys=getenv('DIRBATHYS');
if ~isempty(dirbathys)
     COD.nomfic = [dirbathys 'modele/ficodf_phys'];

% Ouverture du fichier des codes
% ------------------------------

    fcod = fopen(COD.nomfic,'r');
    if (fcod == -1)
	messerr = sprintf('%s %s', 'Erreur d''ouverture du fichier des codes physiques ', COD.nomfic)

   else

	nolig = 0;
	while (~feof(fcod) & isempty(messerr))

		ligne=fgetl(fcod);
        nolig = nolig + 1;
        lignesb = strjust(ligne, 'left');
		lignesb = deblank(lignesb);
		if ((~isempty(lignesb)) & (length(ligne) == 102))
		
   			COD.npar = COD.npar + 1;
   			COD.codpar (COD.npar,1:4)  = ligne(1:4);
   			COD.nompar (COD.npar,:)    = ligne(6:60);
%            COD.nompar (COD.npar,39:49)   = ' ';
   			COD.unipar (COD.npar,:)    = ligne(61:76);
            COD.valmin (COD.npar)      = str2num(ligne(77:82));
            COD.valmax (COD.npar)      = str2num(ligne(92:96));
            COD.forpar (COD.npar,1:5)      = ligne(98:102);

        else
		    messerr = sprintf('%s%d%s%s%s', 'La ligne ', nolig, ' du fichier des codes ', COD.nomfic, ' est incorrecte.')
			
        end
 
	end

   clear ligne nolig lignesb ;

   fclose(fcod);
end

else
 messerr=sprintf('%s ','La variable d''environnement DIRBATHYS n''existe pas ')
end



