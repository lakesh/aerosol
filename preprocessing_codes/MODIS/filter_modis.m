path='/home/lakesh/Desktop/modis_extracted_2004/';
dest_path='/home/lakesh/Desktop/modis_filtered_2004/';

AODFileList = dir([path '/*.mat']);

for counter=1:length(AODFileList)
    AODFileName = AODFileList(counter).name;
    load([path AODFileName]);
    [row column] = size(dataPoints);
    data = zeros(row,8);
    %Latitude longitude year dayofyear hour minute
    data(:,1:6) = dataPoints(:,1:6);
    %Cloud mask quality
    data(:,7) = dataPoints(:,13);
    %AOD 550
    data(:,8) = dataPoints(:,23);
    save([dest_path AODFileName],'data');
end
