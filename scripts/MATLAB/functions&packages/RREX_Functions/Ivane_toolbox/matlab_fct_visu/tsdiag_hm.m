function [CS,H,HL]=tsdiag_hm(S,T,P,sigma,ho)
% [CS,H,HL]=tsdiag2(S,T,P,sigma,hold);
% TSDIAG  This function plots a temp vs. salinity diagram,
%         with selected density contours.
%
%         TSDIAG(S,T,P,SIGMA) draws contours lines of density anomaly
%         SIGMA (kg/m^3) at pressure P (dbars), given a range of
%         salinity (ppt) and temperature (deg C) in the 2-element vectors
%         S,T.  The freezing point (if visible) will be indicated.
%
%         TSDIAG(S,T,P) draws several randomly chosen contours.
%         TSDIAG(S,T,P,SIGMA,1) draws contours on current fig and axes (hold on, SIGMA can be []).


%Notes: RP (WHOI) 9/Dec/91
%                 7/Nov/92 Changed for Matlab 4.0
%                 14/Mar/94 Made P optional.
%       PL (LODYC)10/Mar/98 Changed for personnal use
% pas de clf (par rapport a tsdiag) +option hold

if (nargin<2),
   error('tsdiagram: Not enough calling parameters');
elseif (nargin==2),
   P=0;
   sigma=5;
   ho=0;
elseif (nargin==3),
   sigma=5;
   ho=0;
elseif (nargin==4),
   ho=0;
elseif (nargin==5)&& isempty(sigma),
   sigma=5;
end;

if length(P)>1,
  disp('Takes the first pressure to reference the isopycnal lines');
end

% Convert to columns to be on the safe side
sigma=sigma(:);

% grid points of contouring
Sg=S(1)+[0:30]/30*(S(2)-S(1));
Tg=T(1)+[0:30]'/30*(T(2)-T(1));

[~,SG]=swstat90(ones(size(Tg))*Sg,Tg*ones(size(Sg)),P(1));
SGmin=min(min(SG)); SGmax=max(max(SG));

% Calculate sigma if not indicated
if length(sigma)==1,
  sigma=divrond([SGmin SGmax],sigma);
end;


%whitebg('w');
%set(gcf,'PaperType','a4letter'); orient tall;
if ho, a1=gca; hold on;
else   a1=axes('Box','on','Position',[0.1 0.15 0.75 0.7],'Color','none'); 
       hold on; axis([S(1) S(2) T(1) T(2)]);
end;
%hold on;
%axis([S(1) S(2) T(1) T(2)]);
%xlabel('Salinity (psu)');
%ylabel('Temperature (deg C)');
if ~(all(sigma<SGmin | sigma>SGmax)),
  [CS,H]=contour(Sg,Tg,SG,sigma,'k-');set(H,'LineWidth',.2,'Color',[.3 .3 .3]);
  HL=clabel(CS,H,'FontSize',12,'LabelSpacing',500);
end;

%plot freezing temp.
freezeT=swfreezetemp(S,P(1));
if ~ho, lfr=line(S,freezeT,'LineStyle','--'); end;


% Label with pressure, then return to other axes

if P(1) == 0,
  tep=text(S(1),T(2),[' Ref. pressure = 0 dbar']);
else
  tep=text(S(1),T(2),[' Ref. pressure = ' int2str(P(1)) ' dbars']);
end
set(tep,'horiz','left','Vert','bottom','FontSize',10);

set(gcf,'Color','w');
