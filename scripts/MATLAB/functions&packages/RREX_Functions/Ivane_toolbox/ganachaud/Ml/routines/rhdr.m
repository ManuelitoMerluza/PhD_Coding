function [M,Ship,Cast,Lati,Long,Botd,Xdep,Kt,Nobs,Maxd]=rhdr(hdrname)
%key: read informations in the ASCII header file <hdrname>
%synopsis :
% 
%
%
%
%description : 
%
%
%
%
%uses :
%
%side effects :
%
%author : A.Ganachaud (ganacho@gulf.mit.edu) , Oct 95
%
%see also :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%LOADING THE ASCII HEADER FILE
disp(['loading header file ' hdrname])
disp('Read variables : ')
hdl=fopen(hdrname,'r');

varname=[];
for icol=1:11
  str=fscanf(hdl,'%s',1);
  varname=str2mat(varname,str);
  disp( str )
end

% expected variable name 
Vname=['M   '; ... 
       'SHIP'; ...
       'CAST'; ...
       'LAT '; ...
       'LONG'; ...
       'BOT '; ...
       'D   '; ...
       'XDEP'; ...
       'KT  '; ...
       'NOBS'; ...
       'MAXD'];
if strcmp(varname(2:12,:),Vname)==0
  error('the variables are not the one expected')
end

disp(' ')

ct=1;ln=1;tt=[];
while ct
  [vv,ct]=fscanf(hdl,'%f',10);
  if ct>0
    tt=[tt,zeros(10,1)];
    if ct==10
      tt(:,ln)=vv;
    end
  end
  ln=ln+1;
end  

fclose(hdl);

   M=tt(1,:)';
Ship=tt(2,:)';
Cast=tt(3,:)';
Lati=tt(4,:)';
Long=tt(5,:)';
Botd=tt(6,:)';
Xdep=tt(7,:)';
Kt  =tt(8,:)';
Nobs=tt(9,:)';
Maxd=tt(10,:)';
