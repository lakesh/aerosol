function form_grid()
    grid_path = '/Users/lakesh/Aerosol/preprocessing_codes/grid.mat';
    load(grid_path);
    
    [row column dimension] = size(grid);
    grid_centralized = zeros(row-1,column-1,dimension);
    index=1;
    for i=1:row-1
        for j=1:column-1
            grid_centralized(i,j,1) = (grid(i,j,1) + grid(i+1,j,1)) / 2;
            grid_centralized(i,j,2) = (grid(i,j,2) + grid(i,j+1,2)) / 2;
            index = index+1;
        end
    end
    
    grid = grid_centralized;