path='/home/lakesh/Desktop/modis_extracted_2007/';
dest_path='/home/lakesh/Desktop/modis_filtered_2007/';

AODFileList = dir([path '*.mat']);

for counter=1:length(AODFileList)
    AODFileName = AODFileList(counter).name;
    load([path AODFileName]);
    [row column] = size(dataPoints);
    data = zeros(row,12);
    %Latitude longitude year dayofyear hour minute
    data(:,1:6) = dataPoints(:,1:6);
    %AOD 550
    data(:,7) = dataPoints(:,13);
    %Cloud mask quality
    data(:,8) = dataPoints(:,23);
    save([dest_path AODFileName],'data');
    
    %QA_Conf_470
    data(:,9) = dataPoints(:,49);
    save([dest_path AODFileName],'data');
    
    %QA_Usefulness_470
    data(:,10) = dataPoints(:,86);
    save([dest_path AODFileName],'data');
    
    %QA_Conf_660
    data(:,11) = dataPoints(:,50);
    save([dest_path AODFileName],'data');

    %QA_Usefulness_660
    data(:,12) = dataPoints(:,87);
    save([dest_path AODFileName],'data');

end
