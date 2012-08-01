fileName = '/Users/lakesh/Aerosol/preprocessing_codes/final_grid_30x30.mat';
m_map_path = '/Users/lakesh/Aerosol/preprocessing_codes/m_map';
load(fileName);

rows = size(new_grid,1);

new_grid_projection = zeros(rows,4);

new_grid_projection(:,1:2) = new_grid(:,:);

cd(m_map_path);
m_proj('albers equal-area');

[x y] = m_ll2xy(new_grid(:,2),new_grid(:,1));
new_grid_projection(:,3) = x;
new_grid_projection(:,4) = y;

grid=new_grid_projection;
save('projected_grid.mat','grid');    
