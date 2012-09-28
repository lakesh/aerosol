rows = 95;
columns = 155;
days = 92;

N = rows*columns;

connected_days = 1;
possible_days = days-connected_days;

%%Intialize the diagonal elements
diagonal_elements_value_whole_year = zeros(N*days,1);
diagonal_elements_x_whole_year = zeros(N*days,1);
diagonal_elements_y_whole_year = zeros(N*days,1);

diagonal_elements_x_whole_year(1:N*days,1) = 1:N*days;
diagonal_elements_y_whole_year(1:N*days,1) = 1:N*days;
diagonal_elements_value_whole_year(1:N*days,1) = 1;
    
%Only the points in the middle will have previous and future connected
%points
start_both_ends = connected_days*N + 1;
stop_both_ends = (days-connected_days)*N;
diagonal_elements_value_whole_year(start_both_ends:stop_both_ends,1) = diagonal_elements_value_whole_year(start_both_ends:stop_both_ends,1) + 1;



%Initialize the upper triangular elements
elements_x_upper_whole_year = zeros(N*possible_days,1);
elements_y_upper_whole_year = zeros(N*possible_days,1);
elements_value_upper_whole_year = zeros(N*possible_days,1);

elements_x_upper_whole_year(1:N*possible_days,1) = 1:possible_days*N;
elements_y_upper_whole_year(1:N*possible_days,1) = N*connected_days+1:days*N;
elements_value_upper_whole_year(1:N*possible_days,1) = -1;

%Initialize the lower triangular elements
elements_x_lower_whole_year = zeros(N*possible_days,1);
elements_y_lower_whole_year = zeros(N*possible_days,1);
elements_value_lower_whole_year = zeros(N*possible_days,1);

elements_x_lower_whole_year(1:N*possible_days,1) = N*connected_days+1:days*N;
elements_y_lower_whole_year(1:N*possible_days,1) = 1:possible_days*N;
elements_value_lower_whole_year(1:N*possible_days,1) = -1;


%Add all of them, diagonal, upper triangular and lower triangular
elements_x_whole_year = zeros(size(diagonal_elements_x_whole_year,1) + size(elements_x_upper_whole_year,1) + size(elements_x_lower_whole_year,1),1);
elements_y_whole_year = zeros(size(diagonal_elements_x_whole_year,1) + size(elements_x_upper_whole_year,1) + size(elements_x_lower_whole_year,1),1);
elements_value_whole_year = zeros(size(diagonal_elements_x_whole_year,1) + size(elements_x_upper_whole_year,1) + size(elements_x_lower_whole_year,1),1);

elements_x_whole_year(1:size(diagonal_elements_x_whole_year,1),1) = diagonal_elements_x_whole_year;
elements_y_whole_year(1:size(diagonal_elements_y_whole_year,1),1) = diagonal_elements_y_whole_year;
elements_value_whole_year(1:size(diagonal_elements_value_whole_year,1),1) = diagonal_elements_value_whole_year;

index = size(diagonal_elements_x_whole_year,1);

elements_x_whole_year(index+1:(index+size(elements_x_lower_whole_year,1)),1) = elements_x_lower_whole_year;
elements_y_whole_year(index+1:(index+size(elements_y_lower_whole_year,1)),1) = elements_y_lower_whole_year;
elements_value_whole_year(index+1:(index+size(elements_value_lower_whole_year,1)),1) = elements_value_lower_whole_year;

index = size(diagonal_elements_x_whole_year,1) + size(elements_x_lower_whole_year,1);

elements_x_whole_year(index+1:(index+size(elements_x_upper_whole_year,1)),1) = elements_x_upper_whole_year;
elements_y_whole_year(index+1:(index+size(elements_y_upper_whole_year,1)),1) = elements_y_upper_whole_year;
elements_value_whole_year(index+1:(index+size(elements_value_upper_whole_year,1)),1) = elements_value_upper_whole_year;

%Create the Temporal matrix
QTemporal = sparse(elements_x_whole_year', elements_y_whole_year', elements_value_whole_year', N*days, N*days);
