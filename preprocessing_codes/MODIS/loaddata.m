path='/home/lakesh/Desktop/modis_nan_2004';

rows = 191;
columns = 311;
days = 365;

data = zeros(rows*columns*days,1);
index=1;

for i=1:days
   try
       load([path num2str(data) '.mat']);
       interpolatedData = interpolatedData';
       interpolatedData =reshape(interpolatedData,rows*columns,1);  
       numberOfPoints = size(interpolatedData,1);

       data(index:(index+numberOfPoints-1),:) = interpolatedData;
   catch e
       disp(['File not found for day' num2str(i)]);
   end
   index = index+numberOfPoints;
end