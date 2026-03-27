function E = gf3defs(code)
% Returns parameter name, units and format for a GF3 code.
%
% Description: Supplies the defaults for a given gf3 parameter code.
%
% Syntax:
% E = gf3defs(code);
% Input:
% code: The gf3 code for which the defaults are required.
% Output:
% E: the structured array of field defaults.
%Example:
%» E = gf3defs('TEMP')
%
%E =
%
%             code: 'TEMP'
%             desc: 'Sea Temperature'
%            units: 'degrees C'
%       fieldwidth: 10
%    decimalplaces: 3
%
%
% Documentation Date: Oct.16,2006 17:07:55
%
% Tags:
% {ODSTOOLS} {TAG}
%
%
%
%Other Notes: None.
%

%load gf3 mat file.
code = code(1:4);
load gf3def.mat;

%find corresponding code, set defaults.
for i= (1:length(gf3LIST))
   if strcmp(upper(code), upper(gf3LIST{i}.code))==1
      E.code = gf3LIST{i}.code;
      E.desc = gf3LIST{i}.desc;
      E.units = gf3LIST{i}.units;
      E.fieldwidth = gf3LIST{i}.fieldwidth;
      E.decimalplaces = gf3LIST{i}.decimalplaces;
   end
end

clear gf3LIST;


