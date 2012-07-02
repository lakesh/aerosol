%Find the proportion of missing data
path='/work/';
file_prefix = 'collocated_MISR_MODIS_AERONET_NEW_';
dest_path = '/Users/lakesh/Aerosol/synthetic1/'

years=[2004;2005;2006;2007];
numberOfPoints = 42705;

proportions = zeros(length(years),3);

for i=1:length(years)
    year = years(i);
    load([path file_prefix num2str(year) '.mat']);
    
    colloc_data = collocated_misr_modis_aeronet;
    
    misr = find(colloc_data(:,1) == 0);
    modis = find(colloc_data(:,2) == 0);
    aeronet = find(colloc_data(:,3) == 0);
    row = size(misr,1);
    missing_misr = row/numberOfPoints;
    row = size(modis,1);
    missing_modis = row/numberOfPoints;
    row = size(aeronet,1);
    missing_aeronet = row/numberOfPoints;
    
    proportions(i,1) = missing_misr;
    proportions(i,2) = missing_modis;
    proportions(i,3) = missing_aeronet;
end
save('proportions.mat','proportions');

%Generate the synthetic data
load('proportions.mat');
rows = 95;
columns = 155;
days = 365;
N = rows*columns*days;

for i=1:length(years)
    year = years(i);
    aeronet = randn(N,1);
    misr = aeronet(:,1) + 0.1*randn(N,1);
    modis = aeronet(:,1) + 0.3*randn(N,1);
    
    missing_misr = proportions(i,1) * N;
    missing_modis = proportions(i,2) * N;
    missing_aeronet = proportions(i,3) * N;
    
    misr_index = randperm(N, floor(missing_misr));
    misr(misr_index,1) = 0;
    clear misr_index;
    modis_index = randperm(N, floor(missing_modis));
    modis(modis_index,1) = 0;
    clear modis_index;
    aeronet_index = randperm(N, floor(missing_aeronet));
    aeronet(aeronet_index,1) = 0;
    clear aeronet_index;
    
    clear missing_misr missing_modis missing_aeronet
    
    data = zeros(N,3);
    data(:,1) = misr;
    clear misr;
    data(:,2) = modis;
    clear modis;
    data(:,3) = aeronet;
    clear aeronet;
    
    save([dest_path file_prefix num2str(year) '.mat'],'data');
end

