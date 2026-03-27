%             [NAGWare Gateway Generator]
%
%Copyright (c) 1993-94 by the Numerical Algorithms Group Ltd 2.0 
%
%rd_std_hdr_m
%
%hdrname                               string
%ncasts_in_file                        integer
%icast (ncasts_in_file)                integer
%xlat (ncasts_in_file)                 real
%xlong (ncasts_in_file)                real
%botd (ncasts_in_file)                 real
%kt (ncasts_in_file)                   integer
%maxd (ncasts_in_file)                 integer
%
%[icast,xlat,xlong,botd,kt,maxd] = rd_std_hdr_m(hdrname,ncasts_in_file)
%
%
 function [icast,xlat,xlong,botd,kt,maxd] = rd_std_hdr_m(hdrname,ncasts_in_file)
%
%
%
%Call the MEX function
%
 [icast,xlat,xlong,botd,kt,maxd] = rd_std_hdr_mg(hdrname,...
 ncasts_in_file);
%
