
function aide_carte(i);

%-----------------------------------------------------------------------------------
%  Projet ARCHIVAGE HYDRO
%  ----------------------
%  Version: 1.0
%  ------------
%  Creation : Fevrier 2003
%  Modification : Avril 2007 T.Loaëc                                    
%------------------------------------------------------------------------
%  BASE DE DONNEES ARCHIVAGE HYDROLOGIE : AIDE MEMENTO pour l'utilisateur
%------------------------------------------------------------------------


mess_carte{1} = str2mat('L''extraction se fait sur les fichiers Multistation Netcdf classes dans le repertoire mltnc_h2v2.Il est possible de visualiser la totalité des données extraites (stations H2V2 sous forme de croix bleus,stations du LPO en forme de plus rouges et stations en double sont entourées en vert) ou de visualiser uniquement les stations en double (des données extraites).Il est également possible de lister les données extraites, ainsi le fichier créé est liste_profils.lst (sous le répertoire wk_resu).');

messaffich = mess_carte{1};
helpdlg(messaffich(i,:),'Guide');

