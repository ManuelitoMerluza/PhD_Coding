%          ???   conversion +++
% subroutine conversion(xlono,xlato,xlon1,xlat1,ax,ay)
%.
%.
%.this routine transforms lat and lon of a position xlat1,xlon1
%.into cartesian coordinates ax,ay with respect to a given origin xlato,xlono
%.input variables are in decimal degrees,output in kms
%.x axis is eastward,yaxis is northward
%.w lon must be negative,e lon positive
%.s lat must be negative,n lat positive
%.this routine may be applied for local problems only as the simple
%.formula used does not allow for large excursions(greater than 5 deg,say)


% -------------------------------------------------------------
%  C.Lagadec   24 mars 2000
% transformation de la routine fortran "conversion.f"
% prise dans la bibliothèque hydgeo  de la chaine Bathysonde
% -------------------------------------------------------------

[ax,ay] = conversion(xlon0,xlat0,xlon1,xlat1)

pi=4.*atan(1.);
ty=(xlat0+xlat1)/2.;
ax=(xlon1-xlon0)*cos(pi*ty/180.)*60.*1.852;
ay=(xlat1-xlat0)*60.*1.852;
