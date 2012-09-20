input_data_file = '/home/lakesh/Aerosol/inputData_MISR_2006.mat';

aeronet_path = '/home/lakesh/Aerosol/aeronet_each_year/2006/';
aeronet_site_index_file = '/home/lakesh/Aerosol/preprocessing_codes/AERONET/site_index.mat';
load(input_data_file);
load(aeronet_site_index_file);

size_X = 155;
size_Y = 95;
N = size_X*size_Y;
days = 365;


number_aeronet_sites = 113;

collocated_misr = zeros(days*N,6);
collocated_modis = zeros(days*N,6);

collocated_misr(:,1) = inputData(:,5);
collocated_modis(:,1) = inputData(:,8);

count_misr = 0;

for site=1:number_aeronet_sites
    %Find the index where the site belongs to(the grid index)
    index = site_index(site,1);
    for day=1:365
        try
            load([aeronet_path num2str(day) '.mat']);
            aeronet_site_index = find(aeronetdata(:,18) == site);
            aeronetdata = aeronetdata(aeronet_site_index,:);
            number_points = size(aeronetdata,1);

            misr_point = inputData((day-1)*N + index,:);
            misr_hour = misr_point(1,6);
            misr_minute = misr_point(1,7);
            misr_total_time = misr_hour * 60 +  misr_minute;

            found = false;
            minimum_difference = 100;
           
            %Collocate MISR data point with AERONET
            for i=1:number_points
                aeronet_point = aeronetdata(i,:);
                aeronet_hour = aeronet_point(1,4);
                aeronet_minute = aeronet_point(1,5);
                aeronet_total_time = aeronet_hour * 60 + aeronet_minute;
                if abs(aeronet_total_time - misr_total_time) <= 30
                    if abs(aeronet_total_time - misr_total_time) < minimum_difference
                        minimum_difference = abs(aeronet_total_time - misr_total_time);
                        count_misr = count_misr + 1;
                        collocated_misr((day-1)*N + index,1) = misr_point(1,5);
                        collocated_misr((day-1)*N + index,2) = aeronet_point(1,17);
                        collocated_misr((day-1)*N + index,3) = aeronet_hour;
                        collocated_misr((day-1)*N + index,4) = aeronet_minute;
                        collocated_misr((day-1)*N + index,5) = misr_hour;
                        collocated_misr((day-1)*N + index,6) = misr_minute;
                        found = true;
                        %break;
                    end
                end
            end
            
            %MISR data point missing just add the label
            if number_points > 0 && misr_point(1,5) == 0
                collocated_misr((day-1)*N + index,2) = aeronetdata(1,17) ;
                collocated_misr((day-1)*N + index,3) = aeronetdata(1,4);
                collocated_misr((day-1)*N + index,4) = aeronetdata(1,5);
                
            %MISR data point is available but couldn't collocate with
            %AERONET(just add the MISR data point)
            elseif found == false && misr_point(1,5) ~= 0
                %collocated_misr((day-1)*N + index,1) = misr_point(1,5);
                %collocated_misr((day-1)*N + index,5) = misr_point(1,6);
                %collocated_misr((day-1)*N + index,6) = misr_point(1,7);
            end


        catch e
            %Data for that particular day is missing
        end
    end
end

count_modis = 0;
for site=1:number_aeronet_sites
    for day=1:365
        index = site_index(site,1);
        
        try
            load([aeronet_path num2str(day) '.mat']);
            aeronet_site_index = find(aeronetdata(:,18) == site);
            aeronetdata = aeronetdata(aeronet_site_index,:);
            number_points = size(aeronetdata,1);

            modis_point = inputData((day-1)*N + index,:);
            modis_hour = modis_point(1,9);
            modis_minute = modis_point(1,10);
            modis_total_time = modis_hour * 60 + modis_minute;
            
            
            found = false;
            minimum_difference = 100;
            %Collocate MODIS data point with AERONET
            for i=1:number_points
                aeronet_point = aeronetdata(i,:);
                aeronet_hour = aeronet_point(1,4);
                aeronet_minute = aeronet_point(1,5);
                
                aeronet_total_time = aeronet_hour * 60 + aeronet_minute;
                if abs(aeronet_total_time - modis_total_time) <= 30
                    if abs(aeronet_total_time - modis_total_time) < minimum_difference
                        minimum_difference = abs(aeronet_total_time - modis_total_time);                       
                        count_modis = count_modis + 1;
                        collocated_modis((day-1)*N + index,1) = modis_point(1,8);
                        collocated_modis((day-1)*N + index,2) = aeronet_point(1,17);
                        collocated_modis((day-1)*N + index,3) = aeronet_hour;
                        collocated_modis((day-1)*N + index,4) = aeronet_minute;
                        collocated_modis((day-1)*N + index,5) = modis_hour;
                        collocated_modis((day-1)*N + index,6) = modis_minute;
                        found = true;
                        %break;
                    end
    
                end
            end

            %MODIS data point missing just add the label
            if number_points > 0 && modis_point(1,8) == 0
                collocated_modis((day-1)*N + index,2) = aeronetdata(1,17);
                collocated_modis((day-1)*N + index,3) = aeronetdata(1,4);
                collocated_modis((day-1)*N + index,4) = aeronetdata(1,5);
            elseif found == false && modis_point(1,8) ~= 0
                %MODIS data point is available but couldn't collocate with
                %AERONET(just add the MODIS data point)
                collocated_modis((day-1)*N + index,1) = modis_point(1,8);
                collocated_modis((day-1)*N + index,5) = modis_point(1,9);
                collocated_modis((day-1)*N + index,6) = modis_point(1,10);
            end


        catch e
            %Data for that particular day is missing
        end
    end
end