% Script disp_pprop: Display (print and/or plot) pair properties)
%
% DESCRIPTION : 
%
% The following information must be specified:
% Idir     = directory location of input header and data files
% Ihdr     = name of input header file
% iprop    = property index desiginating property to be displayed
% ncols    = number of columns across printed page (defaults 17)
% do_print = param controlling whether print out (1->print)
% do_plot  = param controlling whether plot out (1->plot)
% 
% AUTHOR : D. Spiegel (diana@plume.mit.edu) , Dec 95
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: standalone or geovel 
% CALLEE: rhydro, print_pprop, plot_pprop

if ~exist('ncols') 	ncols   = 17; 		end
if ~exist('iprop') 	iprop   = 1; 		end
if ~exist('ipvec') 	ipvec   = [1:1]; 	end
if ~exist('do_print') 	do_print = 1; 		end
if ~exist('do_plot') 	do_plot  = 0; 		end
if ~exist('printit')    printit=0;              end
if ~exist('mkdry')      mkdry=0;                end

if ( mkdry == 1)
   diary disp_pprop.dry
end

% INPUT DIRECTORY:
  % 			Idir = '/data4/ganacho/HYDROSYS/EN129/';
  if ~exist('Idir') 	Idir = '/data17/diana/Alex/Hydrosys/EN129/Data/Cstslope/'; end
  
% INPUT DATA HEADER FILE:
if ~exist('Ihdr') 	Ihdr = 'EN129_PG_65W_mer_hdr'; 		end

  eval(['load ' Idir  Ihdr])
  
% for iprop = ipvec
 for iprop = 1:Nprop
% INPUT PROPERTY FILE:  
  prop = rhydro([Idir Pairfiles(iprop,:)], Precision(iprop,:), ...
      MPres(iprop), Npair, Maxdp(:,iprop));

  % disp('prop from rhydro:')
  % prop

if (do_print  == 1) 
  print_pprop(prop, Propnm(iprop,:), Propunits(iprop,:), Npair, ...
      Cruise, Kt, Plat, Plon, ncols, Pres )
end

distg = 1.e3 * sw_dist(Slat,Slon,'km');
distt = cumsum(distg);

dst = 1.e-3 * [0; distt];
dpt = 1.e-3 * [distt - 0.5 * distg];

if (do_plot == 1)
  plot_pprop(prop, Propnm(iprop,:), Propunits(iprop,:), Nstat, ...
      Cruise, dst, dpt, Pres, Maxd(:,iprop), Maxdp(:,iprop), Botd, Vcont);

  if ( printit == 1 )
    print
  end

end

end		% end for iprop

if ( mkdry == 1)
   diary off
end
