function A = gf3namechk(A)
% Checks validity and if necessary, prompts the user to change the gf3 codes in a given ODF array
%
% Description: Checks for valid GF3 codes, and if necessary, changes parameter
% names to conform to the ODF parameter naming convention. It also changes the
% names of each of the parameters to a standardized form, and updates the
% history. If a code is invalid, the user is asked to insert a valid code name.
%
% Syntax:
% Usage: A= gf3namechk(A)
% Input:
% A : the ODF structured array containing the parameters to be checked.
% Output:
% A : the verified ODF structured array.
% Example:
% A = gf3namechk(A)
%
% Documentation Date: Oct.16,2006 17:08:53
%
% Tags:
% {ODSTOOLS} {TAG}
%
%



e = length(A.Parameter_Header);
F = cell(e,1);
for i = (1:e)
   rr = char(A.Parameter_Header{i}.Name);
   r = char(A.Parameter_Header{i}.Code);
   if isfield(A.Parameter_Header{i},'WMO_Code')
      s = zclip3(char(A.Parameter_Header{i}.WMO_Code));
      s_old = zclip3(char(A.Parameter_Header{i}.WMO_Code));
   else
      s = r(1:4);
      s_old = r(1:4);
   end

   zz=0;

   while (isgf3(s)==0)
      disp(['gf3 Code ',char(39),s,char(39),' invalid.'])
      inpstr =['Please enter a valid 4-Character gf3 Code for parameter named ',char(39),rr,char(39),': '];
      s = input(inpstr,'s');
      zz = 1;
   end

   if zz==1;
      s=upper(s);
      histr = (['Changing gf3_Code ',char(96),s_old,char(180),' to ',char(96),s,char(180),'.']);
      A = add_history(A,histr) ;
      disp(histr);
      A.Parameter_Header{i}.WMO_Code = cellstr(zqset(s));
      hh = gf3defs(s);

      A.Parameter_Header{i}.Units = hh.units;
      A.Parameter_Header{i}.Print_Field_Width = hh.fieldwidth;
      A.Parameter_Header{i}.Print_Decimal_Places = hh.decimalplaces;

      zz=0;
   end

   if length(r)==7
        g = strncmp(r,s,4);
        h = strcmp(r(5),'_');
      j = (~isempty(str2num(r(6:7))));
   else
      j = 0;
      h = 0;
      g = 0;
   end

   histmark = 0;
   xx=0;
   dd = 0;

   if ((g*h*j)==0)
      for y=(1:(length(A.Polynomial_Cal_Header)))
         if isfield(A.Polynomial_Cal_Header{y}, 'Parameter_Name')
            if (strcmp(rr,char(A.Polynomial_Cal_Header{y}.Parameter_Name))==1)
               xx=y;
            end
         elseif isfield(A.Polynomial_Cal_Header{y}, 'Parameter_Code')
            if strcmp(r,char(A.Polynomial_Cal_Header{y}.Parameter_Code))==1
               xx=y;
            end
         end
      end

      for cc=(1:(length(A.Compass_Cal_Header)))
         if isfield(A.Compass_Cal_Header{cc}, 'Parameter_Name')
            if strcmp(rr,char(A.Compass_Cal_Header{cc}.Parameter_Name))==1
               dd=cc;
            end
         elseif isfield(A.Compass_Cal_Header{cc}, 'Parameter_Code')
            if strcmp(r,char(A.Compass_Cal_Header{cc}.Parameter_Code))==1
               dd=cc;
            end
         end
      end

      r = [s,'_01'];
      histmark = 1;
   end

   m=1;
   v=0;

   while(m==1)

        for l = (1:i)
        if (strcmp(char(F{l}),r)==1)
            histmark = 1;
            v=1;
        end
        end

      if (v==1);
        nu = str2num(r(6:7));
        nu=nu+1;
        nm =sprintf('%02d',nu);
         r(6:7) = nm;
         v=0;
      else
         m=0;
      end

   end

      F{i}=r;



   if histmark==1;
      histr =(['The code of Parameter ',char(96), char(A.Parameter_Header{i}.Name), char(180), ' will be changed to: ',char(96),r,char(180),'.']);
      A = add_history(A,histr);
      disp(histr);
      A.Parameter_Header{i}.Code = cellstr(r);
      if xx>0
         A.Polynomial_Cal_Header{xx}.Parameter_Code = cellstr(r);
      end

      if dd>0
         A.Compass_Cal_Header{dd}.Parameter_Code = cellstr(r);
      end

                %create history
   end
end

