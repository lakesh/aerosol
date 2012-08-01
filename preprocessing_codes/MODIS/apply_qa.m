path='/home/lakesh/Desktop/modis_final_2004/';
dest_path='/home/lakesh/Desktop/modis_final_qa_2004/';

for day=1:365
    load([path num2str(day) '.mat']);
    %Remove the low quality data(Quality data have QA index 2 and 3, 2 for
    %good and 3 for excellent, the other flags represent low quality data)
    index=find(data(:,9) == 0 | data(:,9) == 1);
    data(index,7) = -9999;
    save([dest_path num2str(day) '.mat'],'data');
end

