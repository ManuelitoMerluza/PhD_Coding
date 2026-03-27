
fcsv = fopen('a25_hy1.csv','r');

fach = fopen('A25.ach','w');

flag_csv = ['2';'3';'5';'9'];
flag_ach = ['b';'b';'d';'m'];

flag_s1 = 'b';
flag_s2 = 'b';

n=1;
a= fgetl(fcsv);

  while(~feof(fcsv))


     wstat(1:3)     = a(26:28)
        while  (a(26:28) == wstat & ~feof(fcsv))
           nostat(n,1:3)    = a(26:28);
           nobout(n,1:2)    = a(47:48);

           ctdprs(n)    = str2num(a(94:99));
           ctdtmp(n)    = str2num(a(103:109));

           ctdsal(n)    = str2num(a(113:119));

% transformation des flags WOCE en flags LPO
% 2 = b, 3 = b, 5 = d, 9 = m
% -------------------------------------------


           i1 = find(a(121:121)==flag_csv);
           if (~isempty(i1))
              flag_s3(n,1:1) = flag_ach(i1);
                else
              fprintf('%s %s %s \n',nobout(n,:), ...
              'Flag chimie inconnu : ', a(121:121));
              flag_s3(nn,1:1) = 'm';
           end


           salc(n,:)      = str2num(a(125:131));
           i1 = find(a(133:133)==flag_csv);
           if (~isempty(i1))
              flag1(n,1:1) = flag_ach(i1);
                else
              fprintf('%s %s %s \n',nobout(n,:), ...
              'Flag chimie inconnu : ', a(133:133));
              flag1(nn,1:1) = 'm';
           end


           ctdoxk(n)    = str2num(a(139:143));
           i1 = find(a(145:145)==flag_csv);
           if (~isempty(i1))
              flag_s4(n,1:1) = flag_ach(i1);
                else
              fprintf('%s %s %s \n',nobout(n,:), ...
              'Flag chimie inconnu : ', a(145:145));
              flag_s4(nn,1:1) = 'm';
           end


           oxkc(n)      = str2num(a(151:155));
           i1 = find(a(157:157)==flag_csv);
           if (~isempty(i1))
              flag2(n,1:1) = flag_ach(i1);
                else
              fprintf('%s %s %s \n',nobout(n,:), ...
              'Flag chimie inconnu : ', a(157:157));
              flag2(nn,1:1) = 'm';
           end

           silc(n)      = str2num(a(163:167));
           i1 = find(a(169:169)==flag_csv);
           if (~isempty(i1))
              flag3(n,1:1) = flag_ach(i1);
                else
              fprintf('%s %s %s \n',nobout(n,:), ...
              'Flag chimie inconnu : ', a(169:169));
              flag3(nn,1:1) = 'm';
           end


           phoc(n)      = str2num(a(174:179));
           i1 = find(a(181:181)==flag_csv);
           if (~isempty(i1))
              flag4(n,1:1) = flag_ach(i1);
                else
              fprintf('%s %s %s \n',nobout(n,:), ...
              'Flag chimie inconnu : ', a(181:181));
              flag4(nn,1:1) = 'm';
           end


           cfc11(n)     = str2num(a(183:190));
           if  (a(193:193) ~= '9')
                 fprintf('cfc11')
           end
           i1 = find(a(193:193)==flag_csv);
           if (~isempty(i1))
              flag5(n,1:1) = flag_ach(i1);
                else
              fprintf('%s %s %s \n',nobout(n,:), ...
              'Flag chimie inconnu : ', a(193:193));
              flag5(nn,1:1) = 'm';
           end


           cfc12(n)     = str2num(a(196:203));
           i1 = find(a(205:205)==flag_csv);
           if  (a(205:205) ~= '9')
                 fprintf('cfc12')
           end

           if (~isempty(i1))
              flag6(n,1:1) = flag_ach(i1);
                else
              fprintf('%s %s %s \n',nobout(n,:), ...
              'Flag chimie inconnu : ', a(205:205));
              flag6(nn,1:1) = 'm';
           end


           cfc13(n)     = str2num(a(208:215));
           i1 = find(a(217:217)==flag_csv);
           if  (a(217:217) ~= '9')
                 fprintf('cfc13')
           end

           if (~isempty(i1))
              flag7(n,1:1) = flag_ach(i1);
                else
              fprintf('%s %s %s \n',nobout(n,:), ...
              'Flag chimie inconnu : ', a(217:217));
              flag7(nn,1:1) = 'm';
           end


           ccl4(n)      = str2num(a(220:227));
           i1 = find(a(229:229)==flag_csv);
           if  (a(229:229) ~= '9')
                 fprintf('ccl4')
           end

           if (~isempty(i1))
              flag8(n,1:1) = flag_ach(i1);
                else
              fprintf('%s %s %s \n',nobout(n,:), ...
              'Flag chimie inconnu : ', a(229:229));
              flag8(nn,1:1) = 'm';
           end


           n= n+1; 
           a= fgetl(fcsv);

       end;

         for nn = 1:n-1


          fprintf(fach,'%s %s %7.1f %s  %7.3f  %s %7.3f  %s %7.3f  %s %7.3f %s %7.3f %s %7.3f %s %7.3f %s %7.3f %s %7.3f %s  %7.3f %s %7.3f %s \n', nostat(nn,1:3), nobout(nn,1:2), ctdprs(nn), flag_s1, ctdtmp(nn), flag_s2,  ctdsal(nn) , flag_s3(nn), ctdoxk(nn) , flag_s4(nn), salc(nn), flag1(nn) , oxkc(nn), flag2(nn) , silc(nn), flag3(nn) , phoc(nn), flag4(nn) , cfc11(nn) , flag5(nn), cfc12(nn) , flag6(nn), cfc13(nn), flag7(nn) , ccl4(nn), flag8(nn));
               
        end
        n=1;
        clear nostat nobout ctdprs ctdtmp ctdsal salc;
        clear  ctdoxk oxkc ;
        clear silc  phoc ;
        clear cfc11 cfc12 ;
        clear cfc13  ccl4 ;
        clear flag1 flag2 flag3 flag4;
        clear flag5 flag6 flag7 flag8;
        clear flag_s3 flag_s4;
       
     
  end

fclose(fcsv);






     
