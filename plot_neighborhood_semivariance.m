function plot_neighborhood_semivariance(site)
    site_index_file = '/home/lakesh/Aerosol/site_index.mat';
    aod_file = '/home/lakesh/Aerosol/colloc_data_summer_2006.mat';

    load(aod_file);
    load(site_index_file);


    rows = 95;
    columns = 155;
    N = rows*columns;

    days = 92;
    %Size of the kernel mask
    block_sizes = [1; 2; 3; 4; 5; 6; 7; 8];
    number_block_size = size(block_sizes,1);
    %Distance from the center 
    x=30:30:number_block_size*30;

    site_location = site_index(site,1);
    %disp(site_location);
    %site_latitude = site_index(site,2);
    %site_longitude = site_index(site,3);
    
    %semivariance based upon the block size
    semivariance_list = zeros(number_block_size,1);
    observation_count = zeros(number_block_size,1);

    for day=1:days
        misr_point = colloc_data((day-1)*N+site_location, 1);
        location = (day-1)*N+site_location;

        if(misr_point ~= 0) 
            for block_index = 1:number_block_size
                block = block_sizes(block_index,1);
                
                misr_data = zeros(1, 1);

                marker = 1;

                for j=block:-2*block:-block
                    for k=-block:block
                        if(site_location-(j*columns)+k <=1354700 && location-(j*columns)+k >= 1)
                           misr_data(marker,1) = colloc_data(location-(j*columns)+k,1);
                           marker = marker+1;
                        end

                    end
                end

                for j=block:-1:-block
                    for k=-block:2*block:block
                        if(site_location-(j*columns)+k <=1354700 && location-(j*columns)+k >= 1)
                           misr_data(marker,1) = colloc_data(location-(j*columns)+k,1);
                           marker = marker+1;
                        end

                    end
                end

                indicator_absent = misr_data == 0;
                indicator_present = misr_data ~= 0;

                misr_data = misr_data - misr_point;
                misr_data = misr_data .^ 2;

                misr_data(indicator_absent) = 0;
                semivariance_list(block_index,1) =  sum(misr_data);
                observation_count(block_index,1) = sum(indicator_present);
              

            end
            semivariance_list = semivariance_list ./ observation_count;
            semivariance_list = semivariance_list/2;

            plot(x,semivariance_list);
            pause;
            clf;
        end

    end
end

