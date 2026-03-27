function setlargefig

po=get(gcf,'Paperorientation');
if strcmp(po,'portrait')
  set(gcf,'Paperposition', [0.3 0.5 8 10])
else
  set(gcf, 'Paperposition', [-0.5 0 10.5 8])
end