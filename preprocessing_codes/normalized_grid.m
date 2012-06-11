
grid_path = '/Users/lakesh/Aerosol/preprocessing_codes/linear_grid.mat';
load(grid_path);

row = size(linear_grid,1);
normalized_linear_grid=zeros(row,1);

for i=1:row
    %topvertical
    normalized_linear_grid(i,1) = (linear_grid(i,1) + linear_grid(i,3))/2;
    normalized_linear_grid(i,2) = (linear_grid(i,2) + linear_grid(i,4))/2;
    %righthorizontal
    normalized_linear_grid(i,3) = (linear_grid(i,3) + linear_grid(i,5))/2;
    normalized_linear_grid(i,4) = (linear_grid(i,4) + linear_grid(i,6))/2;
    %bottomvertical
    normalized_linear_grid(i,5) = (linear_grid(i,5) + linear_grid(i,7))/2;
    normalized_linear_grid(i,6) = (linear_grid(i,6) + linear_grid(i,8))/2;
    %lefthorizontal
    normalized_linear_grid(i,7) = (linear_grid(i,7) + linear_grid(i,1))/2;
    normalized_linear_grid(i,8) = (linear_grid(i,8) + linear_grid(i,2))/2;
    
end


