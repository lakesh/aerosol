%Convert the resolution of the grid from 15x15km to 30x30km

fileName='/Users/lakesh/Aerosol/preprocessing_codes/final_grid_v2.mat';
load(fileName);

size_x = 96;
size_y = 156;
coordinates = 2;

grid_new_resolution = zeros(size_x,size_y, coordinates);

k=1;
l=1;
for i=1:2:191
    for j=1:2:311
        grid_new_resolution(k,l,1) = grid(i,j,1);
        grid_new_resolution(k,l,2) = grid(i,j,2);
        l=l+1;
    end
    k=k+1;
    l=1;
end

grid=grid_new_resolution;

save('grid_30x30.mat','grid');