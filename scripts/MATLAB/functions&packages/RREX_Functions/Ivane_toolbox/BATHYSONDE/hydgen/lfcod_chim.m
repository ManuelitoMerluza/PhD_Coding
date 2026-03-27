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
% juin 2013 : CL : lecture uniquement codes chimiques
%
%-------------------------------------------------------------

function [messerr] = lfcod_chim ();

global COD;

% initialisations
% ---------------
dirbathys=getenv('DIRBATHYS');

if ~isempty(dirbathys)
     COD.nomfic = [dirbathys 'modele/ficodf_chim'];
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
		if ((~isempty(lignesb)) & (length(ligne) == 103))
		
   			COD.npar = COD.npar + 1;
   			COD.codpar (COD.npar,1:7)  = ligne(1:7);
   			COD.nompar (COD.npar,:)    = ligne(9:57);
   			COD.unipar (COD.npar,:)    = ligne(58:79);
            COD.valmin (COD.npar)      = str2num(ligne(80:82));
            COD.valmax (COD.npar)      = str2num(ligne(92:96));
            COD.forpar (COD.npar,:)    = ligne(100:103);

        else
		    messerr = sprintf('%s%d%s%s%s', 'La ligne ', nolig, ' du fichier des codes chimiques ', COD.nomfic, ' est incorrecte.')
			
        end
 
	end

   clear ligne nolig lignesb ;

   fclose(fcod);
end
else
     messerr=sprintf('%s ','La variable d''environnement DIRBATHYS n''existe pas ')
end


