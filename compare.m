data_file = '/home/lakesh/Aerosol/smoothed_data_misr_2004.mat';
data_misr_aeronet_location = '/home/lakesh/Aerosol/misr_aeronet_data_location.mat';
collocated_data = '/home/lakesh/Aerosol/colloc_data_summer_2006.mat';
site_index_data = '/home/lakesh/Aerosol/site_index.mat';
sorted_site_name = '/home/lakesh/Aerosol/sorted.mat';

%Consists of the collocated misr and aeronet points with the sitename and
%location
load(data_file);
%Consists of the misr, smoothed misr with different block size and aeronet labels
load(data_misr_aeronet_location);
%Load the collocated data
load(collocated_data);
load(site_index_data);

len = size(data,1);

comparison = zeros(len,1);

block_size_values = [1;3;5;7];

for i=1:len
    error = 100;
    block_size = 0;
    %Compare the block size(which one has the least error)Use only the 1x1
    %and 7x7 only
    for j=1:3:4
        block_error = abs(data(i,j) - data(i,5));
        if(block_error < error)
            error = block_error;
            block_size = block_size_values(j);
        end
    end
    comparison(i,1) = block_size;
end


data(:,6) = comparison;



index=find(colloc_data(:,1) ~= 0 & colloc_data(:,3) ~= 0);
locations = zeros(size(index,1),1);

 
row=155;
column = 95;
N=row*column;

 
for i=1:size(index,1)
   location = index(i,1);
   rem = floor(location/N);
   
   if rem == 0
       locations(i,1) = location;
   else
       locations(i,1) = location - floor(location/N)*N;
   end
end

positions=zeros(size(index,1),1);
for i=1:size(index,1)
    location = locations(i,1);
    index=find(site_index(:,1) == location);
    location=site_index(index,4);
    positions(i,1)=location;
end

data(:,7) = positions;


%%%%%%%%%%%%%%%% Aggregate the data for the four years before using the code  below %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


unique_sites = unique(data(:,7));
unique_sites_count = size(unique_sites,1);
sitemap = cell(unique_sites_count,7);

load(sorted_site_name); 

for i=1:unique_sites_count
   unique_site = unique_sites(i,1);
   index = find(data(:,7) == unique_site);
   count_1 = 0;
   count_3 = 0;
   count_5 = 0;
   count_7 = 0;
   for j=1:size(index,1)
       data_point = data(index(j,1),:);
       if (data_point(1,6) == 1)
           count_1 = count_1 + 1;
       elseif (data_point(1,6) == 3)
           count_3 = count_3 + 1;
       elseif (data_point(1,6) == 5)
           count_5 = count_5 + 1;
       elseif (data_point(1,6) == 7)
           count_7 = count_7 + 1;
       end
   end
   
   help_smoothing = 'no';
   if(count_1 <= (count_3 + count_5 + count_7))
      help_smoothing = 'yes'; 
   end
   
   index = find(site_index(:,4) == unique_site);
   site = site_index(index,:);
   latitude = site(1,2);
   longitude = site(1,3);
   site_name = sorted(unique_site);
   
   sitemap{i,1} = site_name;
   sitemap{i,2} = latitude;
   sitemap{i,3} = longitude;
   sitemap{i,4} = count_1;
   sitemap{i,5} = count_3;
   sitemap{i,6} = count_5;
   sitemap{i,7} = count_7;
   sitemap{i,8} = help_smoothing;
   
end

save('smoothing_comparision.mat','sitemap');
