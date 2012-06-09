function filter_misr()


source_path='/home/lakesh/Desktop/misr_extracted_2007/';
dest_path='/home/lakesh/Desktop/misr_final_2007/';

days=365;

for i=1:days
    %Random initialization of size of misrData
    data = zeros(10000,6);
    index = 1;
    cd([source_path num2str(i)]);
    files = dir('*.mat');
    
    for counter=1:length(files)
        misr_file = files(counter).name
        load(misr_file);
        [row column] = size(misrData);
        %latitude
        data(index:(index+row-1),1) = misrData(:,5);
        %longitude
        data(index:(index+row-1),2) = misrData(:,6);
        %year
        data(index:(index+row-1),3) = misrData(:,1);
        %dayofyear
        data(index:(index+row-1),4) = misrData(:,2);
        %hour
        data(index:(index+row-1),5) = misrData(:,3);
        %minute
        data(index:(index+row-1),6) = misrData(:,4);
        %AOD_558
        data(index:(index+row-1),7) = misrData(:,8);
        index = index+row;
    end
    
    save([dest_path num2str(i) '.mat'], 'data');
   
end

end