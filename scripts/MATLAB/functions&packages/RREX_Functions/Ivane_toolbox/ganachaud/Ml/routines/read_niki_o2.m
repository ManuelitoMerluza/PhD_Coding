function [latt,oxyg2]=read_niki_o2(fname)
% read oxygen from Nicolas Gruber (AOS Program, Princeton University)
%File     : o2trans_pobm1.dat
%Author   : Nicolas Gruber, Princeton Univ., gruber@splash.princeton.edu
%Date     : 10.04.99
%Content  : Zonally integrated surface fluxes (total flux, i.e. gas ex +
%           virtual flux) from POBM1 (as described by Murnane et al. (1999)
%           BGC, 13(2)) Units are mol m-1 yr-1.
%
%Comments : The surface fluxes have been uniformly adjusted to remove
%           the globally integrated net flux of oxygen caused by the
%           neglect of denitrification in POBM1. 
%
%	   The original fluxes are in mol m-2 yr-1. Zonal integration 
%results then in
%units of mol m-1 yr-1. In order to get the net meridional flux across a
%certain latitude band, you need to integrate the fluxes starting from a
%point where there is zero transport (this gives mol yr-1). In the case of
%the North Atlantic, you probably want to start at the North Pole, because
%this model doesn't have any Pacific/Atlantic connection. This is important
%if you compare with your observation (which might or might not include the
%Bering Strait troughflow). In the global case, you can start either in the
%south or in the north. 
%
%Yes, you are nearly there. The only thing to consider is that the values
%are given at the middle of the boxes. You therefore have to do the
%integration from the 90deg to the mid lat between the two boxes. I use
%ferret to do that for me. Here are the results. I hope I did it right ;-)
%Note, however, that the latitudes should be shifted by half a grid box, to
%be entirely correct.
%
%PS: here the output for the Atlantic, Fluxes are in units of mol yr-1.
%
% 87.3N / 40:  0.000E+00
% 82.3N / 39: -8.592E+10
% 77.8N / 38: -3.169E+11
% 73.4N / 37: -2.094E+12


fid=fopen(fname);
ii=0;
while 1
  line = fgetl(fid);
  if ~isstr(line), break, end
  ii=ii+1;
  is=findstr(line(1:7),'S');
  in=findstr(line(1:7),'N');
  if ~isempty(is)
    jj=is;
    sgn=-1;
  else
    jj=in;
    sgn=1;
  end
  latt(ii)=sgn*sscanf(line(1:jj-1),'%f');
  icol=findstr(line,':');
  oxyg1(ii)=sscanf(line(icol+1:length(line)),'%f'); %in mol/m/yr
end
fclose(fid);

latt2=(latt(1:ii-1)+latt(2:ii))/2;
dx=1000*sw_dist([90,latt2],zeros(size([90,latt2])),'km');
oxyg2=[0,cumsum([dx,0].*oxyg1)];
oxyg2=-oxyg2(1:length(oxyg2)-1)/1000/365/24/3600; %in kmol/s


