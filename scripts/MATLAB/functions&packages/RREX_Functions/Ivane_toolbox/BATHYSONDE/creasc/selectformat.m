function selectformat()

global CHOIX;
global h_FormatsAModifier;
global h_ListUnites;
global h_ListFormats;

valc = get(gcbo, 'Value');

set(h_ListUnites,'Value',valc);
set(h_ListFormats,'Value',valc);

set (h_FormatsAModifier,'String',CHOIX.format(valc,:)); 
