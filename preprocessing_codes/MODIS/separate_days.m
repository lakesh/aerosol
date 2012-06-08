function separate_days()
    path='/home/lakesh/Desktop/modis_filtered_2007/';
    dest_path='/home/lakesh/Desktop/modis_final_2007/';
    year = 2007;
    
    AODFileList = dir([path '*.mat']);
    
    for day=1:365
        modis_data = zeros(10000,87);
        index = 1;
        for counter=1:length(AODFileList)
            AODFileName = AODFileList(counter).name;
            load([path AODFileName]);
            pointer = find(data(:,1) == year & data(:,2) == day);
            row = size(pointer,1);
            modis_data(index:index+row-1,:) = data(pointer,:);
            index = index+row;
        end
        data = modis_data;
        save([dest_path num2str(day) '.mat'],'data');
    end
    
end