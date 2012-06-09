grid_path = '/Users/lakesh/Aerosol/preprocessing_codes/final_grid.mat';
load(grid_path);

source_path='';
dest_path='';

[row column dimension] = size(grid);


%Window size for interpolation
delta_X_interp = 5;
delta_Y_interp = 5;

year = 2007;
interpolatedData = zeros(row-1*column-1, 8);


tic;
%for day=1:365
    for i=1:row-1
        for j=1:column-1
            
            interpolation_point_lat = (grid(i,j,1) + grid(i+1,j,1)) / 2;
            interpolation_point_lon = (grid(i,j,2) + grid(i,j+1,2)) / 2;

            left_boundary =  interpolation_point_lon - delta_X_interp;
            right_boundary =  interpolation_point_lon + delta_X_interp;
            bottom_boundary =  interpolation_point_lat - delta_Y_interp;
            top_boundary =  interpolation_point_lat + delta_Y_interp;

            index = find(data(:,2) > left_boundary & data(:,2) < right_boundary & data(:,1) < top_boundary & data(:,1) > bottom_boundary);
            region_data = data(index,:);

            %Find the points having non null values and quality data
            index = find(region_data(:,7) ~= -9999 & region_data(:,8) < 4 );
            region_data = region_data(index,:);
            numberOfPoints = size(region_data,1);
            
            interp_value = sum(region_data(:,7)) / numberOfPoints;
            interpolatedData(i,j,1) = interpolation_point_lat;
            interpolatedData(i,j,2) = interpolation_point_lon;
            interpolatedData(i,j,3) = year;
            interpolatedData(i,j,4) = day;
            try 
                %hour
                interpolatedData(i,j,5) = griddata(region_data(:,1),region_data(:,2),region_data(:,5),interpolation_point_lat,interpolation_point_lon,'nearest');
                %minute
                interpolatedData(i,j,6) = griddata(region_data(:,1),region_data(:,2),region_data(:,6),interpolation_point_lat,interpolation_point_lon,'nearest');
                interpolatedData(i,j,7) = interp_value;
                %Quality mask
                interpolatedData(i,j,8) = griddata(region_data(:,1),region_data(:,2),region_data(:,8),interpolation_point_lat,interpolation_point_lon,'nearest');
            catch e 
                
            end
        end
    end
%end
toc;
