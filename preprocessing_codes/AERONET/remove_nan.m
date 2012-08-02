aeronet_path = '/Users/lakesh/Aerosol/aeronet_each_year/2007/';
dest_path = '/Users/lakesh/Aerosol/aeronet_each_year/2007/';

for day=1:365
    load([aeronet_path num2str(day) '.mat']);
    aods = aeronetdata(:,17);
    index = isnan(aods);
    index = find(index == 1);
    aods(index,:) = 0;
    aeronetdata(:,17) = aods;
    save([dest_path num2str(day) '.mat'],'aeronetdata');
end