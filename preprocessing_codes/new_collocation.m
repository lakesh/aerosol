input_data = load_data_v2();
aeronet_path = '/work/aeronet/2007/';

size_X = 13;
size_Y = 9;
N = size_X*size_Y;
days = 365;


%billerica, harvardforest, mvco, thompson farm
number_aeronet_sites = 4;
row = zeros(4,1);
column = zeros(4,1);

%billerica
row(1) = 6;
column(1) = 10;
%harvard forest
row(2) = 1;
column(2) = 10;
%mvco
row(3) = 9;
column(3) = 1;
%thompson farm
row(4) = 7;
column(4) = 13;



collocated_misr = zeros(days*N,4);
collocated_modis = zeros(days*N,4);

count_misr = 0;
for site=1:number_aeronet_sites
    index = (row(site)-1)*size_X + column(site);
    for day=1:365
        try
            load([aeronet_path num2str(day) '.mat']);
            aeronet_site = find(aeronetdata(:,15) == site);
            aeronetdata = aeronetdata(aeronet_site,:);
            number_points = size(aeronetdata,1);

            misr_point = input_data((day-1)*N + index,:);
            misr_hour = misr_point(1,7);
            misr_minute = misr_point(1,8);
            misr_total_time = misr_hour * 60 +  misr_minute;

            found = false;
            for i=1:number_points
                aeronet_point = aeronetdata(i,:);
                aeronet_hour = aeronet_point(1,4);
                aeronet_minute = aeronet_point(1,5);
                aeronet_total_time = aeronet_hour * 60 + aeronet_minute;
                if abs(aeronet_total_time - misr_total_time) <= 30
                    count_misr = count_misr + 1;
                    collocated_misr((day-1)*N + index,1) = misr_point(1,5);
                    collocated_misr((day-1)*N + index,2) = aeronet_point(1,10);
                    collocated_misr((day-1)*N + index,3) = aeronet_hour;
                    collocated_misr((day-1)*N + index,4) = aeronet_minute;
                    found = true;
                    break;
                end
            end

            if found == false  && number_points > 0 && misr_point(1,5) == 0
                aod_average = sum(aeronetdata(:,10)) / number_points;
                collocated_misr((day-1)*N + index,2) = aod_average;
                collocated_misr((day-1)*N + index,3) = aeronet_hour;
                collocated_misr((day-1)*N + index,4) = aeronet_minute;
                
            elseif found == false && misr_point(1,5) ~= 0
                collocated_misr((day-1)*N + index,1) = misr_point(1,5);
            end


        catch e

        end
    end
end

h=[];
count_modis = 0;
for site=1:number_aeronet_sites
    for day=1:365
    
        index = (row(site)-1)*size_X + column(site);
        try
            load([aeronet_path num2str(day) '.mat']);
            aeronet_site = find(aeronetdata(:,15) == site);
            aeronetdata = aeronetdata(aeronet_site,:);
            number_points = size(aeronetdata,1);

            modis_point = input_data((day-1)*N + index,:);
            modis_hour = modis_point(1,11);
            modis_minute = modis_point(1,12);
            modis_total_time = modis_hour * 60 +  modis_minute;
            
            
            found = false;
            
            for i=1:number_points
                
                aeronet_point = aeronetdata(i,:);
                aeronet_hour = aeronet_point(1,4);
                aeronet_minute = aeronet_point(1,5);
                
                aeronet_total_time = aeronet_hour * 60 + aeronet_minute;
                if abs(aeronet_total_time - modis_total_time) <= 30
                    count_modis = count_modis + 1;
                    collocated_modis((day-1)*N + index,1) = modis_point(1,9);
                    collocated_modis((day-1)*N + index,2) = aeronet_point(1,10);
                    collocated_modis((day-1)*N + index,3) = aeronet_hour;
                    collocated_modis((day-1)*N + index,4) = aeronet_minute;
                    found = true;
                    break;
                end
            end

            if found == false && number_points > 0 && modis_point(1,9) == 0
    
                aod_average = sum(aeronetdata(:,10)) / number_points;
                collocated_modis((day-1)*N + index,2) = aod_average;
                collocated_modis((day-1)*N + index,3) = aeronet_hour;
                collocated_modis((day-1)*N + index,4) = aeronet_minute;
            elseif found == false && modis_point(1,9) ~= 0
                collocated_modis((day-1)*N + index,1) = modis_point(1,9);
            end


        catch e

        end
    end
end