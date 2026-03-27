function print_pprop(prop, pname, punits, Npair, ...
    cruise, Kt, Plat, Plon, ncols, pres )
% KEY:   print pair property values
% USAGE:
% print_pprop(prop, Propnm(iprop,:), Propunits(iprop,:), Npair, ...
%      Cruise, Kt, Plat, Plon, ncols )
%
% DESCRIPTION : 
%
% INPUT:
%
% ncols = number of colums (i.e. fields) across a line of printed output
% Npair = total number of colums 
%
% OUTPUT:
%
% AUTHOR : D. Spiegel (diana@plume.mit.edu) , Dec 95
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: geovel or disp_pprop
% CALLEE: parr

mi = min(mmin(prop));
mx = max(mmax(prop));

disp(sprintf('\nCruise: %s   Pair Property: %s   Units: %s\n',cruise,pname,punits))  

for colstart = 1:ncols:Npair
  colstart;
  colend = colstart+ncols-1;
  if colend > Npair
    colend = Npair;
  end
  colend;
  fprintf('\n'); 
  pparrn(Kt(colstart:colend),     7, 0, 'f', colend-colstart+1,'Sta1');
  pparrn(Kt(colstart+1:colend+1), 7, 0, 'f', colend-colstart+1,'Sta2 ');
  pparrn(Plat(colstart:colend),   7, 1, 'f', colend-colstart+1,'Lat  ');
  pparrn(Plon(colstart:colend),   7, 1, 'f', colend-colstart+1,'Lon  ');
  fprintf('Pres\n');  
  pparr(prop(:,colstart:colend)',7, 2, 'f', colend-colstart+1, pres);
end                      
