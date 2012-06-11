path='/Users/lakesh/Aerosol/preprocessing_codes/normalized_linear_grid.mat';
aeronet_list_file='/Users/lakesh/Aerosol/preprocessing_codes/AERONET/sorted.txt';
aeronet_path='/Users/lakesh/Aerosol/aeronet_processed/';
load(path);

sites = textread(aeronet_list_file,'%s');    
sites_number = size(sites,1);

site_index = zeros(sites_number,3);

for i=1:sites_number
   %disp(i);
   site = sites{i};
   load([aeronet_path site '.mat']);
   %index = find(latitude > linear_grid(:,5) & latitude < linear_grid(:,1) & ...
   %    longitude < linear_grid(:,6) & longitude > linear_grid(:,2));
   
   index = find(latitude > normalized_linear_grid(:,5) & latitude < normalized_linear_grid(:,1) & ...
       longitude < normalized_linear_grid(:,4) & longitude > normalized_linear_grid(:,8));
   if size(index,1) ~= 0
       %disp(i);
       site_index(i,1) = index(1,1);
       site_index(i,2) = latitude;
       site_index(i,3) = longitude;
   else
       disp(i);
   end
end

save('site_index.mat','site_index');