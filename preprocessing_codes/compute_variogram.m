grid_path = '/Users/lakesh/Aerosol/preprocessing_codes/grid.mat';
load(grid_path);

[row column dimension] = size(grid);

%Window size for calculating the variogram
delta_X = 5;
delta_Y = 5;

%Window size for interpolation
delta_X_interp = 1;
delta_Y_interp = 1;

global distance_interp distance_neighbors

for i=1:row-1
    for j=1:column-1
        interpolation_point_lat = (grid(i,j,1) + grid(i+1,j,1)) / 2;
        interpolation_point_lon = (grid(i,j,1) + grid(i,j+1,1)) / 2;
        
        
        %Define the region to create the variogram from
        left_boundary =  interpolation_point_lon - delta_X;
        right_boundary =  interpolation_point_lon + delta_X;
        bottom_boundary =  interpolation_point_lat - delta_Y;
        top_boundary =  interpolation_point_lat + delta_Y;
        
        index = find(data(:,1) > left_boundary & data(:,1) < right_boundary & data(:,2) < top_boundary & data(:,2) > bottom_boundary);
        region_data = data(index,:);
        
        numberOfPoints = size(region_data,1);
        variogram = zeros(numberOfPoints * numberOfPoints,2);
        
        
        %calculate the distance and variance
        index=1;
        for i=1:numberOfPoints
            for j=1:numberOfPoints
                variogram(index,1) = calculateDistance(region_data(i,1),region_data(i,2),region_data(j,1),region_data(j,2));
                variogram(index,2) = 0.5* (region_data(i,3) - region_data(j,3))^2;
                index = index+1;
            end
        end
        
        %Round off the distance to 4 decimal places
        variogram(:,1) = round2(variogram(:,1), 1e-4);
        
        
        %Find the maximum distance
        max_distance = floor(max(variogram(:,1)));
        
        
        %Find the experimental/semi variogram from which model variogram
        %could be calculated
        
        semi_variogram = zeros(max_distance,2);
        window = 0.5;
        for i=1:max_distance
            index = find(variogram(:,1) > i-window & variogram(:,1) <= i+window);
            numberOfPoints = size(index,1);
            variances = sum(variogram(index,1));
            semi_variogram(i,1) = i;
            semi_variogram(i,2) = variances/numberOfPoints;
        end
        
        %Now calculate the exponential model variogram
        [estimate,model] = fitcurvedemo(semi_variogram(:,1),semi_variogram(:,2));
        
        
        %Start the interpolation
        %Define the neighboring region
        
        left_boundary =  interpolation_point_lon - delta_X_interp;
        right_boundary =  interpolation_point_lon + delta_X_interp;
        bottom_boundary =  interpolation_point_lat - delta_Y_interp;
        top_boundary =  interpolation_point_lat + delta_Y_interp;
        
        index = find(data(:,1) > left_boundary & data(:,1) < right_boundary & data(:,2) < top_boundary & data(:,2) > bottom_boundary);
        region_data = data(index,:);
        
        numberOfPoints = size(region_data,1);
        
        distance_interp = zeros(numberOfPoints,1);
        distance_neighbors = zeros(numberOfPoints, numberOfPoints);
        
        for i=1:numberOfPoints
            distance_interp(i,1) = calculateDistance(interpolation_point_lat,interpolation_point_lon,region_data(i,1),region_data(i,2));
            for j=1:numberOfPoints
                distance_neighbors(i,j) = calculateDistance(region_data(i,1),region_data(i,2),region_data(j,1),region_data(j,2));
            end
        end
        options=optimset('Display','iter');
        x0 = rand(1,numberOfPoints+1);
        [w,fval] = fsolve(@calculate_weight,x0,options);
        
        interp_value = 0;
        for i=1:numberOfPoints
            if region_data(i,3) ~= -9999
                interp_value = interp_value + w(i)*region_data(i,3);
            end
        end
    end
end

