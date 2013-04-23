path='/home/lakesh/Desktop/misr_final_2005/';
dest_path='/home/lakesh/Desktop/misr_final_qa_2005/';

for day=1:365
    load([path num2str(day) '.mat']);
    %Remove the low quality data(Quality data have QA index 0 and 1
    index=find(data(:,8) == 253 | data(:,8) == 3 | data(:,8) == 2);
    data(index,7) = -9999;
    save([dest_path num2str(day) '.mat'],'data');
end

