source_path='/home/lakesh/Desktop/modis_final_2007/';
dest_path='/home/lakesh/Desktop/modis_final_projection_2007/';
m_map_path='/home/lakesh/Aerosol/preprocessing_codes/m_map/';
    
cd(m_map_path);

for day=1:365
    load([source_path num2str(day) '.mat']);
    [row column] = size(data);
    projected_data = zeros(row,column+2);
    projected_data(:,1:column) = data;
    m_proj('albers equal-area');
    [x y] = m_ll2xy(data(:,2),data(:,1));
    projected_data(:,column+1) = x;
    projected_data(:,column+2) = y;
    data=projected_data;
    save([dest_path num2str(day) '.mat'],'data');
end


