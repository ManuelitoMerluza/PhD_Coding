function print_sprop(prop, pname, punits, Nstat, ...
    cruise, Kt, Slat, Slon, ncols,pres )
% KEY:   print stat property values
% USAGE:
% print_sprop(prop, Propnm(iprop,:), Propunits(iprop,:), Nstat, ...
%      Cruise, Kt, Slat, Slon, ncols )
%
% DESCRIPTION : 
%
% INPUT:
%
% ncols = number of colums (i.e. fields) across a line of printed output
% Nstat = total number of colums 
%
% OUTPUT:
%
% AUTHOR : D. Spiegel (diana@plume.mit.edu) , Dec 95
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: geovel or disp_sprop
% CALLEE: parr

mi = min(mmin(prop));
mx = max(mmax(prop));

disp(sprintf('\nCruise: %s   Stat Property: %s   Units: %s\n',cruise,pname,punits))  

for colstart = 1:ncols:Nstat
  colstart;
  colend = colstart+ncols-1;
  if colend > Nstat
    colend = Nstat;
  end
  colend;
  fprintf('\n'); 
  pparrn(Kt(colstart:colend),     11, 0, 'f', colend-colstart+1,'Sta  ');
% pparrn(Kt(colstart+1:colend+1), 11, 0, 'f', colend-colstart+1); %for pair data
  pparrn(Slat(colstart:colend),   11, 1, 'f', colend-colstart+1,'Lat  ');
  pparrn(Slon(colstart:colend),   11, 1, 'f', colend-colstart+1,'Lon  ');
  fprintf('Pres\n');      
  pparr(prop(:,colstart:colend)',11, 6, 'f', colend-colstart+1,pres);
end                      

