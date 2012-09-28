site_index_file='/home/lakesh/Aerosol/preprocessing_codes/AERONET/site_index.mat';
load(site_index_file);

site_index=site_index(:,1);
aod_file='/home/lakesh/Aerosol/colloc_data_summer_2007.mat';

load(aod_file);

indexes=size(site_index,1);

diff=0;
count=0;

rows=95;
columns=155;
N=rows*columns;

days=92;

for day=1:days-1
   for index=1:indexes
      y1=colloc_data((day-1)*N+site_index(index,1),3);
      y2=colloc_data(N+((day-1)*N+site_index(index,1)),3);
      if (y1 ~=0 && y2 ~= 0)
         diff = diff + (y1-y2)^2;
         count=count+1;
      end
   end
end