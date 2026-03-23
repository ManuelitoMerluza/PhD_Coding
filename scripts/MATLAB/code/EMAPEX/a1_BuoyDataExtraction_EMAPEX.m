% This is the script I'll use to recover the microstructure data from the
% EMAPEX buoys

% We load paths and colorbars
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/Year 1 - 2026'))
%addpath(genpath('D:/Respaldo PC/iop/materia/Magister/Semestre 2/PRODIGY/m_map/'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)

%% The structure of the .txt files are

% First row: float number and number of cast (in this case a pair because is an upcast)
% Second row: year, month, day, hour, minute, second 
% Third row: latitude, longitude, junk, junk
% Forth row: number of data rows Ndata
% Example:
% 4966 2 
% 2019 5 29 13 53 35 
% 58.301487 -23.921009 0.000000 0.000000 
% 1036 

% Fifth row and beyond:
% Depth z, temperature gradient Tz, Buoyancy Frequency N2, chi1, chi2,
% eps1, eps2, KT1, KT2
% -646.82  0.0040 6.4e-06  4e-08 8.6e-06  4e-08 8.5e-06  0.0012 0.26 

%% First, we define the folder path

folder='C:/Users/mitg1n25/Desktop/PhD/Year 1 - 2026/Microstructure Data/EMAPEX/processedmicro';
filenames = dir(fullfile(folder,'*.txt')); % Selects the files of the folder that have a .txt extension (data)

% We need to select the buoys using their serial number
% The buoy number that remained in the water for longer periods where:
% 4969 4971 7802 7806 7807 7808
b={'4969' '4971' '7802' '7806' '7807' '7808'};

for i=1:length(filenames)
filename(i,:) = filenames(i).name;
end
number = filename(:,5:8);

%% Start the process of separating the files

for j=1:length(b)

% We select the filenames that coincide and then extract the position
equal=all(number==b{j},2); a=find(equal); A=length(a);

% Scroll through the files to see which one is the bigger
% That way it can define the maximum size for out matrix

n=NaN(A,1);
k=1;
for i=a(1):a(end)
    fid = fopen(filename(i,:), 'r');
    first_line = fgetl(fid);
    datetime_line = fgetl(fid);
    latlon_line = fgetl(fid);
    Ndata_line = fgetl(fid);

    n(k) = sscanf(Ndata_line, '%d');
    fclose(fid);
    k=k+1;
end
N=max(n);

% Prepare variables for the script
dropnumber=NaN(1,A);
time=NaT(1,A); lat=NaN(1,A); lon=NaN(1,A);
z=NaN(N,A); Tz=NaN(N,A); N2=NaN(N,A);
chi1=NaN(N,A); chi2=NaN(N,A);
eps1=NaN(N,A); eps2=NaN(N,A);
KT1=NaN(N,A); KT2=NaN(N,A);

% Make a cycle for opening the files that contain the b{j} number

k=1;
for i=a(1):a(end)

% Open the file
fid = fopen(filename(i,:), 'r');

% Read the first 4 lines
first_line = fgetl(fid); %clear first line
datetime_line = fgetl(fid); 
latlon_line = fgetl(fid);
Ndata_line = fgetl(fid);

first_line_parts = sscanf(first_line, '%f %f');
dropnumber(k)=first_line_parts(2);
datetime_parts = sscanf(datetime_line, '%d %d %d %d %d %d');
time(k) = datetime(datetime_parts(1), datetime_parts(2), datetime_parts(3), ...
                         datetime_parts(4), datetime_parts(5), datetime_parts(6));

latlon_parts = sscanf(latlon_line, '%f %f %f %f');
lat(k) = latlon_parts(1);
lon(k) = latlon_parts(2);

% Read the data rows
% Use textscan with NaN for -2e+30 values
Ndata = sscanf(Ndata_line, '%d');
data_cell = textscan(fid, '%f %f %f %f %f %f %f %f %f', Ndata);
data_matrix = cell2mat(data_cell);

% Replace -2e+30 with NaN (if they weren't automatically converted)
data_matrix(data_matrix < -1e30) = NaN;

fclose(fid); % Close the file

% Save each column as a different variable
z(1:Ndata,k)=data_matrix(:,1);
Tz(1:Ndata,k)=data_matrix(:,2);
N2(1:Ndata,k)=data_matrix(:,3);
chi1(1:Ndata,k)=data_matrix(:,4);
chi2(1:Ndata,k)=data_matrix(:,5);
eps1(1:Ndata,k)=data_matrix(:,6);
eps2(1:Ndata,k)=data_matrix(:,7);
KT1(1:Ndata,k)=data_matrix(:,8);
KT2(1:Ndata,k)=data_matrix(:,9);

k=k+1;
end

% Create the struct that will be saved as a MAT file
OUTPUT.dropnumber = dropnumber;
OUTPUT.z = z;
OUTPUT.lat = lat;
OUTPUT.lon = lon;
OUTPUT.time = time;
OUTPUT.Tz = Tz;
OUTPUT.N2 = N2;
OUTPUT.chi1 = chi1;
OUTPUT.chi2 = chi2;
OUTPUT.eps1 = eps1;
OUTPUT.eps2 = eps2;
OUTPUT.KT1 = KT1;
OUTPUT.KT2 = KT2;

save(['EMAPEX_float',b{j},'.mat'], '-struct' , 'OUTPUT')

end