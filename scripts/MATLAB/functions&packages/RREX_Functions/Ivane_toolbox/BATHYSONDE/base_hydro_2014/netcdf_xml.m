%------------------------------------------------------------------------------
%  Projet ATLANTIQUE NORD
%  ----------------------
%  Version: 1.0
%  ------------
%  Creation :Avril 2005 /  stagiaire: T.Loaec tuteur: C.Lagadec
%                                            
%------------------------------------------------------------------------------
% Creation du fichier de donnees xml a  partir d'un fichier Netcdf
%------------------------------------------------------------------------------
% Cette fonction est utilisable depuis l'environnement Matlab. 
% Tout d'abord, elle demande a  l'utilisateur a  partir de quel fichier netcdf
% il veut generer son fichier de donnees XML.
% Puis il genere le fichier xml coorespondant a  partir :
%              -start_date,stop_date,cruise_name,ship_name,pi_name
%     soit apra¨s transformation :
%              -date_deb,date_fin,camp_don,navire,chefmission
%
%
% Puis rajouter :
%   le nom de la carte, entre les balises <carte> et </carte>
%   le rapport, entre les balises <rappport></rapport>
%   l'adresse email du chef de mission, si elle existe, entre les balises <ADRCHEFMIS></ADRCHEFMIS>
%   l'adresse email du responsable des donnees chimiques, si elle existe, entre les balises <ADRRESP></ADRRESP>
%
% Enfin sous Windows, a  l'aide de Saxon8, on genere une nouvelle page HTML a  partir du fichier de donnees cree et a  l'aide de la feuille de style "campagne.xsl"
%     sous DOS(fenetre d'invite de commandes) grace a  la commande :
%                                                            " saxon8 fichier.xml campagne.xsl > resultat.html "

% Nom du fichier multistation 
fic_netcdf=input('Nom du fichier netcdf ? Pour generer le fichier xml correspondant\n','s')


% -------------------------------
% ouverture en lecture du fichier multistation Netcdf
  
      nc = netcdf(deblank(fic_netcdf),'read');


% debut et fin du fichier xml a  generer
debut='<?xml version="1.0"?><?xml-stylesheet type="text/xsl" href="campagne.xsl" ?><campagne>';
fin='</campagne>';
 
% dates de debut et de fin non rangees 
      start_date_don   = nc.Start_date(:);
      stop_date_don    = nc.Stop_date(:);
      
      list_param       = nc{'STATION_PARAMETERS'}(:,:);
      camp_don         = deblank(nc{'CRUISE_NAME'}(1,:));
      l = length(camp_don);
      camp_bl =[camp_don blanks(16-l)];


organisme=deblank(nc{'PI_ORGANISM'}(1,:));

% On trouve "ctd/bouteilles" a  partir des valeurs de BOTTLE_VOL et STATION_PARAM_CHIM     
bouteilles=strcmp(nc{'BOTTLE_VOL'}(1),'0');
if (nc{'BOTTLE_VOL'}(1)>=0)
      bouteilles='oui';
      ctd='oui';	
else 
      bouteilles='non';
      ctd='oui';
end
      
% navire
      navire=deblank(nc{'SHIP_NAME'}(1,:));

% chef de mission
      chefmission=deblank(nc{'PI_NAME'}(1,:));

% responsable des donnees chimiques      
      
      responsabledonneesChimie=deblank(nc{'CHPRS_RESP'}(:,1)');

% lien vers le fichier multistation netcdf      
      mlt=fic_netcdf;

% dates de debut et de fin rangees 
      date_deb=[start_date_don(7:8),'/',start_date_don(5:6),'/',start_date_don(1:4)];
      date_fin=[stop_date_don(7:8),'/',stop_date_don(5:6),'/',stop_date_don(1:4)]; 

% ecriture des parametres extraits entre les balises xml, tout ce qui est entre le debut et la fin du fichier de donnees xml

corps=['<CAMPAGNE>',camp_don,'</CAMPAGNE><DATEDEB>',date_deb,'</DATEDEB><DATEFIN>',date_fin,'</DATEFIN><CHEFMIS>',chefmission,'</CHEFMIS><ADRCHEFMIS></ADRCHEFMIS><ORGANISME>',organisme,'</ORGANISME><NAVIRE>',navire,'</NAVIRE><CTD>',ctd,'</CTD> <BOUTEILLES>',bouteilles,'</BOUTEILLES> <Rapport></Rapport> <RESP>',responsabledonneesChimie,'</RESP><ADRRESP></ADRRESP><carte></carte><MLT>',mlt,'</MLT><bouton>bliste.png</bouton>'];


% sauvegarde des trois variables:debut,corps,fin dans le fichier "fichier_xml"
      ipt = findstr(fic_netcdf,'_');
      fichier.xml = [deblank(fic_netcdf(1:ipt-1)) '.xml'];
      save fichier.xml debut corps fin;
     tout=[debut,corps,fin];
      dlmwrite(fichier.xml,tout,'');
      
% fermeture du fichier multistation Netcdf      
      close(nc)
