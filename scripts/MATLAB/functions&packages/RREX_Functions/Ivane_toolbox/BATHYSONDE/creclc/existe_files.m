function existe_files()

%
%%%%%%%%%%%
%
% Verifie l'existence des fichiers contenus dans NOM_FILES, affiche la liste
% des fichiers non trouves(NOM_FILES_INCON) et les effaces de NOM_FILES
%
% C.B. creation , mise a jour le 16/06/97
%
% variables globales utilisees et modifiees : 
%      NOM_FILES, NOM_FILES_INCON, NBFILES
%
% variable globale utilisee et non modifiee : 
%      REPLECT
%
%%%%%%%%%%%
%

globalVarEtiquni;

globalRepDef;


% Parcours de la liste des fichiers a traiter
% ------------------------------------------- 

index=1;
while  index<=length(NOM_FILES(:,1))
	% Test d'existence du fichier
	if ~exist([REPLECT deblank(NOM_FILES(index,:))],'file')
                NBFILES = NBFILES - 1;
		% Non trouve
		if (isempty(NOM_FILES_INCON)),
			% Premier fichier non trouve
			NOM_FILES_INCON(1,:)=NOM_FILES(index,:);
		else,
			% Autres fichiers non trouves
			NOM_FILES_INCON(length(NOM_FILES_INCON(:,1))+1,:) = NOM_FILES(index,:);
		end;
		% Suppression du fichier dans la liste
		NOM_FILES(index,:)=[];	
	else,
		% On incremente l'indice seulement si le fichier existe
		% car les indices de NOM_FILES changent lorsque l'on un des noms
		index=index+1;	
	end;
end;  

% Afficher la liste dans une fenetre
% ----------------------------------

if (~isempty(NOM_FILES_INCON)),

	% Transforme en chaine de caracteres
	NOM_FILES_INCON=char(NOM_FILES_INCON);

	% Affiche la liste des fichiers non trouves
         lf = size(NOM_FILES_INCON);
         if  lf(1) > 20
            h = warndlg([NOM_FILES_INCON(1,:), ' a ', NOM_FILES_INCON(lf(1),:)],'Fichiers inconnus');
          else
	    h = warndlg(NOM_FILES_INCON,'Fichiers inconnus');
         end;
         waitfor(h);
end;

% Aucun fichier n'existe
% ----------------------

if (isempty(NOM_FILES)),
	% Message d'avertissement
	h=warndlg('Aucun des fichiers n''a ete trouve','Attention');
	waitfor(h);
   else,
        lnom = length(NOM_FILES(1,:));
        STAT1 = str2num(NOM_FILES(1,lnom-9:lnom-7));
        STATN = str2num(NOM_FILES(NBFILES,lnom-9:lnom-7));
end;
