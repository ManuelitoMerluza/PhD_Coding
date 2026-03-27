function [datared,idatared]=reducedataforplot(datavec);
% reduces large amount of data for plotting
% returns indices of selected data (no interpolation)
% Adapted from P. Grimigni TSG software
% A. Ganachaud Aug 2006
lngdatavec=length(datavec);
if isempty(datavec)==0
    if (lngdatavec>2000)&(lngdatavec<4000)
        vecdim=1:2:lngdatavec;
    elseif (lngdatavec>=4000)&(lngdatavec<6000)
        vecdim=1:3:lngdatavec;
    elseif (lngdatavec>=6000)&(lngdatavec<8000)
        vecdim=1:4:lngdatavec;
    elseif (lngdatavec>=8000)&(lngdatavec<10000)
        vecdim=1:5:lngdatavec;
    elseif (lngdatavec>=10000)&(lngdatavec<15000)
        vecdim=1:7:lngdatavec;
    elseif (lngdatavec>=15000)
        vecdim=1:10:lngdatavec;
    else 
        vecdim=1:lngdatavec;
    end
    datared=datavec(vecdim);
else 
    datared=[];
end
idatared=vecdim;