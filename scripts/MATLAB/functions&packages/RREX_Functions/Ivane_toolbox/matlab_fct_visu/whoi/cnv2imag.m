function cnv2imag(Gcf)
% CNV2IMAG   Converts all axes with surfaces or pcolors to images 
%            (for faster printing and colour banding). Preserves axes 
%            tickmarks, labels, directions. Does not change axes with
%            lines only. Does not work if Aspect ratios have been set.
%
%            This is really useful to a) speed up the printing of
%            complicated plots, and b) to preserve the colour banding
%            you see when plotting on the screen in a discrete number
%            of colours.

% R. Pawlowicz (rpawlowicz@whoi.edu) 20/11/93 


if (nargin==0), Gcf=gcf; end;

Fchild=get(Gcf,'children');   % All children of figure

Axei=[];

% NB - even if some axes have flat shading, we have to change them
% too because the colormap gets screwed.

for ii=length(Fchild):-1:1,                   % Go through all children
  Ctyp=get(Fchild(ii),'type');              
  if (Ctyp(1:3)=='axe'),                   % Axes - keep testing ...
    Achild=get(Fchild(ii),'children');
    for jj=1:length(Achild);               % ...Go through all children
      Ctyp=get(Achild(jj),'type');    
      if (Ctyp(1:3)=='sur' | Ctyp(1:3)=='pat'),  % Surface or patch, but..
 %%%       Coltyp=get(Achild(jj),'Facecolor');     
 %%%         if (Coltyp(1:3)=='int'),           % Interpolated! so..
            Axei=[Axei;ii];                  % Save the axes handle
        end;
      end;
    end;
  end;
end;

Fchild=Fchild(Axei);  % Store only axes that need to be changed

if any(Fchild),
  [X,clmp]=capture(Gcf);      % Get the full pixelmap.

  for ii=1:length(Fchild),    % Loop through all the axes that need to be 
                              % Converted.

    % This is tedious - save all the axis properties (if you want something
    % special saved, add it yourself...

    Asp=get(Fchild(ii),'aspect');
    Axexl=get(Fchild(ii),'xlim'); 
    Axxtk=get(Fchild(ii),'xtick');
    Axxtklb=get(Fchild(ii),'xticklabels');
    Xdr=get(Fchild(ii),'xdir');
    Axeyl=get(Fchild(ii),'ylim');
    Axytk=get(Fchild(ii),'ytick');
    Axytklb=get(Fchild(ii),'yticklabels');
    Ydr=get(Fchild(ii),'ydir');
    Tdr=get(Fchild(ii),'tickdir');
    Lyr=get(Fchild(ii),'layer');
    Xlab=get(get(Fchild(ii),'xlabel'),'string');
    Ylab=get(get(Fchild(ii),'ylabel'),'string');
    Titl=get(get(Fchild(ii),'title'),'string');

    % Get the axis position in the pixmap

    Unit=get(Fchild(ii),'Units');
    set(Fchild(ii),'units','pixels');  % Axis rectangle
    Axrct=get(Fchild(ii),'position');
    set(Fchild(ii),'units',Unit);

    Xmid=Axrct(1)+Axrct(3)/2;
    dx=Axrct(3)/2;
    Ymid=size(X,1)-Axrct(2)-Axrct(4)/2;
    dy=Axrct(4)/2;
    if ( ~isnan(Asp(1)) ),
       set(Fchild(ii),'units','points');  % Axis rectangle - I need it in
       Axrctp=get(Fchild(ii),'position'); % absolute units to get scaling 
       set(Fchild(ii),'units',Unit);      % correct
       Asppoint=Axrctp(3)/Axrctp(4);
       Cnvr=Asppoint*Axrct(4)/Axrct(3);  % Fix for pixel ratios != 1:1
       if ( Asp(1) > Asppoint ),
          dy=Axrct(3)/Asp(1)/2*Cnvr;
          Ymid=size(X,1)-Axrct(2)-Axrct(4)/2;
        else
          dx=Axrct(4)*Asp(1)/2/Cnvr;
          Xmid=Axrct(1)+Axrct(3)/2;
        end;
    end;
    Xindex=[ceil(Xmid-dx):fix(Xmid+dx)];
    Yindex=[ceil(Ymid-dy):fix(Ymid+dy)];

    if ( ~isnan(Asp(2)) ),
       if ( Asp(2) > diff(Axeyl)/diff(Axexl) )
          Axeyl=mean(Axeyl)+diff(Axexl)*[-1 1]/2*Asp(2);
       else
          Axexl=mean(Axexl)+diff(Axeyl)*[-1 1]/2/Asp(2);
       end;
       Asp(2)=NaN;
    end;

    % Delete all the children of the axis...we don't need them anymore, right?

    Achild=get(Fchild(ii),'children');
    for jj=1:length(Achild), delete(Achild(jj)); end;
 
    % Draw the "image" replacing the current plot.

    set(Gcf,'CurrentAxes',Fchild(ii));
    image(Axexl,Axeyl,flipud(X(Yindex,Xindex)));

    % Now fix everything.

    set(gca,'xlim',Axexl,'xtick',Axxtk,'xticklabels',Axxtklb,'xdir',Xdr,...
        'ylim',Axeyl,'ytick',Axytk,'yticklabels',Axytklb,'ydir',Ydr,...
        'tickdir',Tdr,'layer',Lyr,'aspect',Asp);
    xlabel(Xlab);
    ylabel(Ylab);
    title(Titl);

  end;

  % This looks weird, but believe me you need it. Too bad it screws up
  % future colourmap changes.

  set(Gcf,'mincolor',max(max(X)),'colormap',clmp);

end;

   
