%script readwocebot
% KEY: read data in the WOCE format put them into arrays
% USAGE : readwocebot
%
% DESCRIPTION : 
%  1) READ THE SUM FILE
%  2) READ BOTTLE FILE. QUALITY FLAG=2 ONLY, NaN OTHERWISE
%  3) FIRST PASS: SUBMIT INTERACTIVELY STATIONS WITH MORE THAN ONE CAST
%     (if the rosette was dropped several times)
%     the user then selects the desired bottles
%  4) (Automated) Clean bottles than occur twice at the same depth
%     grabs missing data from the other bottles at the same depth if
%     necessary. Set p_debug=1 to watch this
%  5) (interactive) allow the user to eliminate some bottles until
%     depths are in increasing order.
%     Automatically eliminate the first point of the second rosette
%     if it is causing the trouble (it can be at the surface, the 
%     one after being right below the last point of the first rosette)
%
% INPUT:
%  sumfile: name of the .sum file
%  botfile: name of the bottle file
%  gisel (opt): stations that we want to read (referred to the .sum file)
%   if there is more stations in the .sum file than in the .bot file,
%   the program will stop unless gisel is set and does not exceed 
%   the number of stations in the bottle file. By default it will take all
%   the stations in the .sum file.
%
% OUTPUT: 
%   nlev: total number of depth in the properties
%   (is=Station, id = depth indice)
%   onstat: total number of stations
%   nvar: number of variables
%   ostnnbr(is):    Cruise station number 
%   ocastno(is):    cast number 
%   onobs(is):      number of observations at each station
%
%   opropnm{iprop}: string containing the property name (otemp, ...)
%   opropunits{iprop}
%   opres(id,is):  pressure
%   otemp, osali(id,is), ... bottle properties (otemp is from CTD)
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Oct 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: readobsfile
% CALLEE: rwb_step1, rwb_step2, rwb_step3
%         Paul Robbins' routines for WOCE format
disp('  w2o_readwocebot')

p_debug=0;

if ~exist('jadefile') %jade data already read with the header
  quality_level=2; %READ ONLY GOOD DATA
  disp('READ ONLY RELIABLE DATA (qual=2)')
  disp(['reading ' botfile '...'])
  if exist('p14s')&p14s
    [botdat,varname,varunits]=p14s_bot(botfile);
  elseif exist('civafile')
    disp('READ CIVA BOTTLES')
    [botdat,varname,varunits,qwrd1] = civa_bot(botfile,quality_level);
    disp('converting to umol/kg if necessary')
    [botdat,varname,varunits]=std_bot(botdat,varname,varunits);
  else
    [botdat,varname,varunits,qwrd1,qwrd2] = whp_bot(botfile,quality_level);
    disp('done')
    %CONVERTS TO STANDART UNITS OF MICROMOL/KG FOR NUTRIENTS
    disp('converting to umol/kg if necessary')
    [botdat,varname,varunits]=std_bot(botdat,varname,varunits);
  end
end

  %ipropwoce= PROPERTY INDICE IN THE ORIGINAL WOCE DATA
  %iprop=INDICE IN THE SELECTED DATA
  rwb_selectprop
  nvar=length(opropnm);
  
  % Dec 97 Step 1 may be skipped
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %FIRST STEP: CHECK DOUBLE ROSETTES
  %FOR A GIVEN STATION ONE MAY HAVE THE ROSETTE DROPPED TWICE
  %WHICH HAS TO BE SORTED OUT
  %Run without stop if Gidselectedcast already exists
  %disp('FOR A GIVEN STATION ONE MAY HAVE THE ROSETTE DROPPED TWICE')
  %disp('PLEASE SORT BOTTLES MONOTICALLY INCREASING OR DECREASING')
  %disp('DUMMY SURFACE BOTTLE BEGINNING THE MEASUREMENT OF A SECOND DEEP')
  %disp('CAST WILL BE REMOVED AFTERWARD')
  %ppause
  %if ~exist('Gidselectedcast')
  %  Gidselectedcast=[];
  %end
  %
  %rwb_step1
  %
  disp('saving in rwbstep1.mat')
  save rwbstep1.mat
  clear botdat qwrd1 qwrd2
  %load rwbstep1.mat;p_debug=0;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %SECOND STEP: CHECK FOR PRESSURE REPEATS
  %CASTS IN WHICH WE HAVE TWICE THE PRESSURE
  %PICK THE DATA IF THERE ARE SOME AT THE SAME PRESSURE AND REMOVES
  %ALL OTHER DATA AT THE SAME PRESSURE
  disp('SECOND STEP: CHECK FOR PRESSURE REPEATS');
  disp('CASTS IN WHICH WE HAVE TWICE THE PRESSURE');
  disp('PICK THE DATA IF THERE ARE SOME AT THE SAME PRESSURE AND REMOVES');
  disp('ALL OTHER DATA AT THE SAME PRESSURE ...');

  rwb_step2

  disp(['Saving in rwbstep2.mat'])
  save rwbstep2.mat
  %load rwbstep2.mat

   
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %LAST STEP: CHECK FOR INCREASING PRESSURE
  %ALLOW THE USER TO ELIMINATE BOTTLES UNTIL THE PRESSURE INCREASES
  %
  disp('LAST STEP: CHECK FOR INCREASING PRESSURE')
  disp('ELIMINATE BOTTLES UNTIL THE PRESSURE INCREASES')
  ppause

  rwb_step3
  p_debug=1;
  %need to recheck if some pressures are repetitive...
  rwb_step2
  disp('saving in rwbstep3.mat')
  save rwbstep3.mat
  disp('removing rwbstep1 and rwbstep2')
  unix('rm rwbstep1.mat rwbstep2.mat');
