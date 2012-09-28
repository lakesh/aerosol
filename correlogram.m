site_index_data = '/home/lakesh/Aerosol/site_index.mat';
load(site_index_data);
site_name = '/home/lakesh/Aerosol/sorted.mat';
load(site_name);

rows = 95;
columns = 155;
N=rows*columns;
days = 365;

blocks = 49;
mid = 25;
start = 3;

number_sites = size(site_index,1);
site_data = cell(1,number_sites);

data = zeros(1,blocks);

index = 1;

for j=1:number_sites
    location = site_index(j,1);
    
    for i=2004:2007 
        load(['collocated_misr_modis_aeronet_' num2str(i) '.mat']);   
        for day=1:days
           marker = 1;
           if collocated_misr_modis_aeronet((day-1)*N + location,1) ~= 0
               for k=start:-1:-start
                   for l=-start:start
                       if (day-1)*N + (location+(k*columns)+l) <= N*days
                           data(index,marker) = collocated_misr_modis_aeronet((day-1)*N + (location+(k*columns)+l),1);
                           marker=marker+1;
                       end
                   end
               end
               index=index+1;
           end
           
        end
    end
    
    site.name = sorted{site_index(j,4)};
    site.data = data;
    site.latitude = site_index(j,2);
    site.longitude = site_index(j,3);
    
    site_data{j} = site;
    
    data = zeros(1,blocks);
    index=1;
end

%save('correlogram_data.mat','site_data');

correlation_data = cell(1,number_sites);

for i=1:number_sites
    data = site_data{i}.data;
    correlation = zeros(blocks,1);
    data_points = zeros(blocks,1);
    
    for j=1:blocks
       %disp(j);
       index=find(data(:,j) ~= 0 & data(:,mid) ~=0);
       if(size(index,1) ~= 0)
           comparing_data = data(index,:);
           correlation(j,1) = corr(comparing_data(:,j),comparing_data(:,mid));
           data_points(j,1) = size(index,1);
       end
    end
    
    correlation_data{1,i}=correlation;
    correlation = reshape(correlation',7,7);
    correlation(1,1) = 0;
    data_points = reshape(data_points',7,7);
    data_points = data_points';
    correlation = correlation';
    
    imagesc(correlation);
    colorbar;
    data_points
    %disp(i);
    hold on
    title(site_data{i}.name);
    pause();
end