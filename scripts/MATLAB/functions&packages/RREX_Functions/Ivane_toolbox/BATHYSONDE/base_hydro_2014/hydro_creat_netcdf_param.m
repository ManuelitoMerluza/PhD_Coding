%-------------------------------------------------------------------------------
%
% hydro_ARGO_mlt_param    - Ecriture d'une variable du multistations au format NetCDF  
%
%-------------------------------------------------------------------------------
%  version:
%  --------
%  1.01   Creation                                      08/07/99  C.Lagadec
%       (largement inspire des sources des copines et copains ....
%
%  1.02  Quelques modifs + ajout ecriture variables     03/09/99  F.Gaillard
%  1.03  Objectif CORIOLIS                              09/02/00  F.Gaillard
%        Separation ecriture en-tete et variable        
%        Modele d'en-tete : OCTOPUS (programme de T. Terre)
  
%-------------------------------------------------------------------------------

function[msg_error] =  hydro_creat_netcdf_param (ficmlt_nc, tab_var, nom_var, err_var)

%-------------------------------------------------------------------------------

msg_error = 'ok';

fill_val  = -9999.;


if strcmp(deblank(nom_var),'DEPH')
   var_lnam = 'Vertical coordinate (positive) from local density';
   txt_unit = 'meter';
   val_rng = [0. 15000.];


elseif strcmp(deblank(nom_var), 'PRES')
   var_lnam = 'Sea Pressure';
   txt_unit = 'decibar';
   val_rng  = [0.0 15000.0];


elseif strcmp(deblank(nom_var), 'TEMP')
   var_lnam = 'In situ temperature ITS-90';
   txt_unit = 'degreee celsius';
   val_rng  = [-2.0 40.0];


elseif strcmp(deblank(nom_var), 'OXYL')
   var_lnam = 'Dissolved oxygen concentration';
   txt_unit = 'm/l';
   val_rng  = [0.0 40.0];

  
elseif strcmp(deblank(nom_var), 'OXYK')
   var_lnam = 'Dissolved oxygen concentration';
   txt_unit = 'micromol/kg';
   val_rng  = [0.0 600.0];


elseif strcmp(deblank(nom_var), 'PSAL')
   var_lnam = 'Practical salinity PSS78';
   txt_unit = 'psu';
   val_rng  = [0.0 60.0];


elseif strcmp(deblank(nom_var), 'TPOT')
   var_lnam = 'Potential Temperature';
   txt_unit = 'degree Celsius';
   val_rng  = [-15.0 40.0];


elseif strcmp(deblank(nom_var), 'SIGI')
   var_lnam = 'In-situ density anomaly';
   txt_unit = 'kg/m**3';
   val_rng  = [0.0 100.0];


elseif strcmp(deblank(nom_var), 'SIG0')
   var_lnam = 'Density anomaly referenced to P = 0';
   txt_unit = 'kg/m**3';
   val_rng  = [0.0 100.0];

elseif strcmp(deblank(nom_var), 'SIG1')
   var_lnam = 'Density anomaly referenced to P = 1000';
   txt_unit = 'kg/m**3';
   val_rng  = [0.0 100.0];

elseif strcmp(deblank(nom_var), 'SI15')
   var_lnam = 'Density anomaly referenced to P = 1500';
   txt_unit = 'kg/m**3';
   val_rng  = [0.0 100.0];

elseif strcmp(deblank(nom_var), 'SIG2')
   var_lnam = 'Density anomaly referenced to P = 2000';
   txt_unit = 'kg/m**3';
   val_rng  = [0.0 100.0];

 elseif strcmp(deblank(nom_var), 'SIG3')
   var_lnam = 'Density anomaly referenced to P = 3000';
   txt_unit = 'kg/m**3';
   val_rng  = [0.0 100.0];

elseif strcmp(deblank(nom_var), 'SIG4')
   var_lnam = 'Density anomaly referenced to P = 4000';
   txt_unit = 'kg/m**3';
   val_rng  = [0.0 100.0];

elseif strcmp(deblank(nom_var), 'SIG5')
   var_lnam = 'Density anomaly referenced to P = 5000';
   txt_unit = 'kg/m**3';
   val_rng  = [0.0 100.0];

elseif strcmp(deblank(nom_var), 'SIG6')
   var_lnam = 'Density anomaly referenced to P = 6000';
   txt_unit = 'kg/m**3';
   val_rng  = [0.0 100.0];

elseif strcmp(deblank(nom_var), 'DYNH')
   var_lnam = 'Dynamical height';
   txt_unit = 'dynamical meter';
   val_rng  = [-100 100];

elseif strcmp(deblank(nom_var), 'BRV2')
   var_lnam = 'Brunt-Vaisala frequency squared';
   txt_unit = '(rad/s)**2';
   val_rng  = [-1 1];

elseif strcmp(deblank(nom_var), 'SSDG')
   var_lnam = 'Sound speed Del Grosso formula';
   txt_unit = 'm/s';
   val_rng  = [1000 2000.0];

elseif strcmp(deblank(nom_var), 'VORP')
   var_lnam = 'Planetary vorticity (f/h)';
   txt_unit = '(m*s)**(-1)';
   val_rng  = [-1 1];

elseif strcmp(deblank(nom_var), 'GAMM')
   var_lnam = 'GAMMA';
   txt_unit = 'kg/m**3';
   val_rng  = [0 100];

end

if   ~strcmp(nom_var, 'XXXX')

   err_lnam   = [var_lnam ' precision'];
   var_prec   = [nom_var '_PREC' ];


   nc = netcdf.open(ficmlt_nc, 'NC_WRITE');
   netcdf.reDef(nc);
   
   dimnprof = netcdf.inqDimID(nc,'N_PROF') ;
   dimnlevels = netcdf.inqDimID(nc,'N_LEVELS');
   
% ----------------------------------
%    Creates and writes the variable
% ----------------------------------

   nc_ARGO_mlt_var(nc,nom_var,'NC_FLOAT',[dimnlevels,dimnprof], ...
                'long_name',var_lnam,  ...
                '_FillValue', single(fill_val), ...
                'units',txt_unit, ...
                'Valid_min',val_rng(1), ...
                'Valid_max',val_rng(2));
            
       nc_ARGO_mlt_var(nc,var_prec,'NC_FLOAT',dimnprof, ...
                'long_name',err_lnam,  ...
                '_FillValue', single(fill_val));
            
   netcdf.endDef(nc);

   isout = find(~isfinite(tab_var));
   if ~isempty(isout)
         tab_var(isout)  = fill_val*ones(size(isout));
   end

   ncwrite(ficmlt_nc,nom_var,tab_var');
   ncwrite(ficmlt_nc,var_prec,err_var');

% date de mise a jour

   dateupd = datestr(now,30);
   ncwriteatt(ficmlt_nc,'/','Last_update',  [dateupd(1:8) dateupd(10:15)]);

   netcdf.close(nc);

else

  msg_error = [' Variable inconnue, non ecrite :  '  nom_var];

end


