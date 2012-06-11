path='/Users/lakesh/Aerosol/preprocessing_codes/grid.mat';
load(path);

[row column dimension] = size(grid);

linear_grid = zeros((row-1)*(column-1),8);


index = 1;
for i=1:row-1
    for j=1:column-1
        
        %%Clockwise%%
        
        %topleft
        linear_grid(index,1) = grid(i+1,j,1);
        linear_grid(index,2) = grid(i+1,j,2);
        
        %topright
        linear_grid(index,3) = grid(i+1,j+1,1);
        linear_grid(index,4) = grid(i+1,j+1,2);
        
        %bottomright
        linear_grid(index,5) = grid(i,j+1,1);
        linear_grid(index,6) = grid(i,j+1,2);
        
        %bottomleft
        linear_grid(index,7) = grid(i,j,1);
        linear_grid(index,8) = grid(i,j,2);
        index=index+1;
    end
end

save('linear_grid.mat','linear_grid');