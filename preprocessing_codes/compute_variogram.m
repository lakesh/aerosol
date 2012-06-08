grid_path = '/Users/lakesh/Aerosol/preprocessing_codes/grid.mat';
load(grid_path);

[row column dimension] = size(grid);

%Window size for calculating the variogram
delta_X = 5;
delta_Y = 5;

%Window size for interpolation
delta_X_interp = 1;
delta_Y_interp = 1;

threshold_variogram = 20;

distance_increment = 10;

%global distance_interp distance_neighbors

interpolatedData = zeros(row-1,column-1);

%for i=1:row-1
%    for j=1:column-1
tic;
for i=1:row-1
    for j=1:column-1
        
        %Find the points in the grid where we want to calculate the
        %interpolated AOD
        interpolation_point_lat = (grid(i,j,1) + grid(i+1,j,1)) / 2;
        interpolation_point_lon = (grid(i,j,2) + grid(i,j+1,2)) / 2;
        
        interp_value = 0;
        
        %Define the region to create the variogram from
        left_boundary =  interpolation_point_lon - delta_X;
        right_boundary =  interpolation_point_lon + delta_X;
        bottom_boundary =  interpolation_point_lat - delta_Y;
        top_boundary =  interpolation_point_lat + delta_Y;
        
        index = find(data(:,2) > left_boundary & data(:,2) < right_boundary & data(:,1) < top_boundary & data(:,1) > bottom_boundary);
        
        region_data = data(index,:);
        index = find(region_data(:,7) ~= -9999 & region_data(:,8) < 4 & region_data(:,7) > 0);
        region_data = region_data(index,:);
        
        numberOfPoints = size(region_data,1);
        
        if(numberOfPoints > threshold_variogram)
            variogram = zeros(numberOfPoints * numberOfPoints,2);

            %calculate the distance and variance
            index=1;
            for k=1:numberOfPoints
                for l=1:numberOfPoints
                    variogram(index,1) = calculateDistance(region_data(k,1),region_data(k,2),region_data(l,1),region_data(l,2));
                    variogram(index,2) = 0.5* (region_data(k,7) - region_data(l,7))^2;
                    index = index+1;
                end
            end

            %Round off the distance to 4 decimal places
            variogram(:,1) = Roundoff(variogram(:,1), 2);


            %Find the maximum distance
            max_distance = floor(max(variogram(:,1)));


            %Find the experimental/semi variogram from which model variogram
            %could be calculated

            semi_variogram = zeros(floor(max_distance/distance_increment),2);
            window = distance_increment/2;
            pointer = 1;
            for k=10:10:max_distance
                index = find(variogram(:,1) > k-window & variogram(:,1) <= k+window);
                numberOfPoints = size(index,1);
                variances = sum(variogram(index,2));
                semi_variogram(pointer,1) = k;
                semi_variogram(pointer,2) = variances/numberOfPoints;
                pointer = pointer+1;
            end
            
            [row column] = size(semi_variogram);
            semi_variogram = semi_variogram(1:floor(80/100*row),:);

            %Now calculate the exponential model variogram
            %Plot the variogram to check
            [estimates,model] = fitcurvedemo(semi_variogram(:,1),semi_variogram(:,2));
            
            %Define the exponential curve
            range = estimates(1);
            sill = estimates(2);
            
            %Start the interpolation
            %Define the neighboring region

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
            
            if numberOfPoints > 1
                %distance_interp = zeros(numberOfPoints,1);
                %distance_neighbors = zeros(numberOfPoints, numberOfPoints);

                %for k=1:numberOfPoints
                %    distance_interp(k,1) = calculateDistance(interpolation_point_lat,interpolation_point_lon,region_data(k,1),region_data(k,2));
                %    for l=1:numberOfPoints
                %        distance_neighbors(k,l) = calculateDistance(region_data(k,1),region_data(k,2),region_data(l,1),region_data(l,2));
                %    end
                %end
                
                %options=optimset('Display','iter');
                %x0 = rand(1,numberOfPoints+1);
                %[w,fval] = fsolve(@calculate_weight,x0,options);
                
                %See ordinary kriging wikipedia page for this formula
                variance_matrix = zeros(numberOfPoints+1, numberOfPoints+1);
                interp_matrix = zeros(numberOfPoints+1,1);
                
                for k=1:numberOfPoints
                    distance = calculateDistance(interpolation_point_lat,interpolation_point_lon,region_data(k,1),region_data(k,2));
                    interp_matrix(k,1) = estimates(2)*(1- exp(-3 * distance/estimates(1)));
                    for l=1:numberOfPoints
                        distance  = calculateDistance(region_data(k,1),region_data(k,2),region_data(l,1),region_data(l,2));
                        variance_matrix(k,l) = estimates(2)*(1- exp(-3 * distance/estimates(1)));
                    end
                end
                
                variance_matrix(numberOfPoints+1, 1:numberOfPoints) = 1;
                variance_matrix(1:numberOfPoints, numberOfPoints+1) = 1;
                interp_matrix(numberOfPoints+1,1) = 1;
                
                %Calculate the weight matrix
                w = variance_matrix \ interp_matrix;
                
                for k=1:numberOfPoints
                    interp_value = interp_value + w(k)*region_data(k,7);
                end
                interp_value = interp_value / numberOfPoints;
            elseif numberOfPoints == 1
                %Make the single AOD value as its value
                interp_value = region_data(1,8);
            end
        else
            left_boundary =  interpolation_point_lon - delta_X_interp;
            right_boundary =  interpolation_point_lon + delta_X_interp;
            bottom_boundary =  interpolation_point_lat - delta_Y_interp;
            top_boundary =  interpolation_point_lat + delta_Y_interp;

            index = find(data(:,1) > left_boundary & data(:,1) < right_boundary & data(:,2) < top_boundary & data(:,2) > bottom_boundary);
            region_data = data(index,:);

            %Find the points having non null values and quality data

            index = find(region_data(:,8) ~= -9999 & region_data(:,7) < 4 );
            region_data = region_data(index,:);
            numberOfPoints = size(region_data,1);
            
            for k=1:numberOfPoints
                interp_value = interp_value + region_data(k,8);
            end
            interp_value = interp_value / numberOfPoints;
            
        end
        
        interpolatedData(i,j) = interp_value;
    end
end
toc;
