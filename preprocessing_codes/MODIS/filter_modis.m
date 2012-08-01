path='/home/lakesh/Desktop/modis_extracted_2004_remaining/';
dest_path='/home/lakesh/Desktop/modis_filtered_remaining_2004/';

AODFileList = dir([path '*.mat']);

for counter=1:length(AODFileList)
    AODFileName = AODFileList(counter).name;
    load([path AODFileName]);
    [row column] = size(dataPoints);
    data = zeros(row,8);
    %Latitude longitude year dayofyear hour minute
    data(:,1:6) = dataPoints(:,1:6);
    %AOD 550
    data(:,7) = dataPoints(:,13);
    %Cloud mask quality
    data(:,8) = dataPoints(:,23);
    save([dest_path AODFileName],'data');
end
