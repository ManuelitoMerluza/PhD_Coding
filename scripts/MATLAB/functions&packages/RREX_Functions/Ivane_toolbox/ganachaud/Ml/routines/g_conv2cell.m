%convert a few names to cell arrays
%(part of geovel.m)
    for ip=1:Nprop
      propnm{ip}=Propnm(ip,:);
      propunits{ip}=Propunits(ip,:);
      statfiles{ip}=Statfiles(ip,:);
      precision{ip}=Precision(ip,:);
    end
    Propnm=propnm;
    Propunits=propunits;
    Statfiles=statfiles;
    Precision=precision;
