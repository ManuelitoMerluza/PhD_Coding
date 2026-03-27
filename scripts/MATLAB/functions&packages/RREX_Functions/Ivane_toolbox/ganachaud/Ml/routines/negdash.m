function negdash(C,h)
% NEGDASH Make negatively-valued contours dashed.
%       NEGDASH(C,H) uses the output C and H of a contouring 
%       routine such as MATLAB's CONTOUR or Rich P.'s 
%       EXTCONTOUR to reset the LineStyle property of negative
%       contours to '--'. 
%
%       See also CONTOUR, CONTOURC, EXTCONTOUR*, CONTOURSURF*
%       (* by Rich Pawlowicz)

%       For applications where the value of the contour is 
%       repeatedly referenced, you might consider modifying
%       this routine to store the contour value as the UserData
%       property of each line. 

%       Dan Goldner 1/95
%       ----------------------------------------------------

        for linehandle=h',
           x=get(linehandle,'Xdata');startx=x(1);
           y=get(linehandle,'Ydata');starty=y(1);
           col=min(find((C(1,:)==startx)&(C(2,:)==starty)))-1;
           contourvalue=C(1,col);

           if(contourvalue<0), 
             set(linehandle,'LineStyle','--'); 
           end;
        end;

