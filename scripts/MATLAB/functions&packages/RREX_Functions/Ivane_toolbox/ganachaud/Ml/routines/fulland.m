function fulland
%print the current figure in lanscape, full page
% restores the previous parameters

pos=get(gcf,'Paperposition');
ori=get(gcf,'Paperorientation');

set(gcf, 'Paperposition',[-0.8 -0.1 11 8.5])
set(gcf, 'Paperorientation','landscape')
print

set(gcf, 'Paperposition',pos)
set(gcf, 'Paperorientation',ori)