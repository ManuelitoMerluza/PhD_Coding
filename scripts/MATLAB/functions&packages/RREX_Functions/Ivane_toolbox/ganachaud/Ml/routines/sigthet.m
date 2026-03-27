% script sigthet.m
% PURPOSE:  calc and display pot temp (theta) and pot dens (sigma)
% 	to be used standalone or from geovel.
% AUTHOR:   D. Spiegel, Jan 96
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Beginning of the standalone section:
%
%alex_path
%path(path,'/data4/ganacho/ML/ROUTINES');
%path(path,'/data4/ganacho/HYDROSYS');
%cd /data4/ganacho/HYDROSYS/EN129
%load EN129_PG_65W_mer_hdr
% the following is for testing purposes only using EN129 data
% ultimately these statements s/b moved to a separate startup file

format compact
if ~exist('ncols')      ncols   = 17;           end
if ~exist('iprop')      iprop   = 1;            end
if ~exist('ipvec')      ipvec   = [1:1];        end
if ~exist('do_print')   do_print = 1;           end
if ~exist('do_plot')    do_plot  = 0;           end
if ~exist('printit')    printit=0;              end
if ~exist('mkdry')      mkdry=0;                end

% INPUT DIRECTORY:
  if ~exist('Idir') Idir = '/data17/diana/Alex/Hydrosys/EN129/Data/Cstslope/'; end

% INPUT DATA HEADER FILE:
if ~exist('Ihdr')   Ihdr = 'EN129_PG_65W_mer_hdr';              end

if ( mkdry == 1)
   ovw = diarystart([Idir Ihdr  '_sigthet']);
end

eval(['load ' Idir  Ihdr])

if ~exist('Prefs')
   Prefs=[0 1000 2000 3000 4000]';
end

temp=rhydro([Idir Pairfiles(1,:)],Precision(1,:),MPres(1),Npair,Maxdp(:,1));
sali=rhydro([Idir Pairfiles(2,:)],Precision(2,:),MPres(2),Npair,Maxdp(:,2));
oxyg=rhydro([Idir Pairfiles(3,:)],Precision(3,:),MPres(3),Npair,Maxdp(:,3));
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
for iref=1:size(Prefs)
   ptemp = sw_ptmp(sali, temp,  Pres, Prefs(iref));     
   pden  = sw_pden(sali, ptemp, Pres, Prefs(iref)) -1000.;
   if (do_print == 1) 
     label = [' at ref level ' num2str(Prefs(iref))];
     print_pprop(ptemp, ['ptemp' label], Propunits(Itemp,:), Npair, ...
         Cruise, Kt, Plat, Plon, ncols, Pres )
     print_pprop(pden , ['pden ' label], 'pot den - 1000', Npair, ...
         Cruise, Kt, Plat, Plon, ncols, Pres )
   end
end   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
diary off



