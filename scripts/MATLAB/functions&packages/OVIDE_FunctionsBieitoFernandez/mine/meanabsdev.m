function MAD = meanabsdev(Sobs, Steo, Sn)
    if nargin<3
        MAD = mean( abs( (Sobs./Steo) - mean(Sobs./Steo) )  );
    else
       MAD = mean( abs( (Sobs./(Steo+Sn)) - mean(Sobs./(Steo+Sn)) )  );
    end