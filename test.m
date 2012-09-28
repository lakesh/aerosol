%For new CRF
alpha11=58.4058;
alpha21=51.8600;
alpha12=57.9054;
alpha22=14.5401;
beta1=4.8358;
beta2=21.8341;
alpha3=0.0001;

%For old CRF
%alpha1=
%alpha2=
%beta1=


cd ~/Aerosol/
load('colloc_data_summer_2007.mat');


%For new CRF
indicator_misr=colloc_data(:,1) ~= 0 & colloc_data(:,2) == 0;
indicator_modis=colloc_data(:,2) ~= 0 & colloc_data(:,1) == 0;
indicator_misr_modis=colloc_data(:,1) ~= 0 & colloc_data(:,2) ~= 0;
%indicator_dummy=colloc_data(:,1) == colloc_data(:,1);

len=size(colloc_data,1);
Q1=alpha11*spdiags(indicator_misr,0,len,len) + alpha21*spdiags(indicator_modis,0,len,len) + ...
    alpha12*spdiags(indicator_misr_modis,0,len,len) + alpha22*spdiags(indicator_misr_modis,0,len,len) + alpha3*spdiags(indicator_dummy,0,len,len);
%Q=2*(Q1+beta1*QSpatial+beta2*QTemporal);


%For Old CRF
indicator_misr=colloc_data(:,1) ~= 0;
indicator_modis=colloc_data(:,2) ~= 0;
len=size(colloc_data,1);
Q1=alpha1*spdiags(indicator_misr,0,len,len) + alpha2*spdiags(indicator_modis,0,len,len) + alpha3*spdiags(indicator_dummy,0,len,len);


%Q=2*(Q1+beta2*QTemporal);
Q=2*(Q1+beta1*QSpatial);

b=2*(alpha11*spdiags(indicator_misr,0,len,len)*colloc_data(:,1) + alpha21*spdiags(indicator_modis,0,len,len)*colloc_data(:,2) + ...
alpha12*spdiags(indicator_misr_modis,0,len,len)*colloc_data(:,1) + alpha22*spdiags(indicator_misr_modis,0,len,len)*colloc_data(:,2));
clear QSpatial QTemporal linearMatrix indicator_misr indicator_modis indicator_misr_modis Q1

%FRAC,MSE,RMSE


% For MISR
index=find(colloc_data(:,1) ~= 0 & colloc_data(:,3) ~= 0);
data=colloc_data(index,:);
p=u(index,:);
%p=data(:,1);

numberOfPoints = size(data,1);

mse=0;
for i=1:numberOfPoints
    mse = mse + (data(i,3)-p(i,1))^2;
end

mse = mse/numberOfPoints;
rmse = sqrt(mse);

yi_ti=zeros(numberOfPoints,1);
ti=zeros(numberOfPoints,1);
for i=1:numberOfPoints
    yi_ti(i,1) = abs(data(i,3)-p(i,1));
    ti(i,1) = 0.05 + 0.15*data(i,3);
end

count = 0;
for i=1:numberOfPoints
    if(yi_ti(i,1) <= ti(i,1))
        count = count+1;
    end
end
FRAC = (count/numberOfPoints);

% For MODIS
index=find(colloc_data(:,2) ~= 0 & colloc_data(:,3) ~= 0);
data=colloc_data(index,:);
p=u(index,:);
%p=data(:,2);

numberOfPoints = size(data,1);

mse=0;
for i=1:numberOfPoints
    mse = mse + (data(i,3)-p(i,1))^2;
end

mse = mse/numberOfPoints;
rmse = sqrt(mse);

yi_ti=zeros(numberOfPoints,1);

ti=zeros(numberOfPoints,1);
for i=1:numberOfPoints
    yi_ti(i,1) = abs(data(i,3)-p(i,1));
    ti(i,1) = 0.05 + 0.15*data(i,3);
end

count = 0;
for i=1:numberOfPoints
    if(yi_ti(i,1) <= ti(i,1))
        count = count+1;
    end
end
FRAC = (count/numberOfPoints);





index=find(colloc_data(:,1) ~= 0 & colloc_data(:,3) ~= 0);
block = 49;
block_left = 28;
block_right = 28;
block_central = 25;


start=3;
data=zeros(size(index,1),block);
weighted_average = zeros(size(index,1),1);

len = size(index,1);

row=155;
column = 95;
N=row*column;

%Taking the weighted average of the block

for i=1:len
    pointer = index(i,1);
    marker = 1;
    for j=start:-1:-start
        for k=-start:start
            if(pointer-(j*row)+k <=1354700)
                data(i,marker) = colloc_data(pointer-(j*row)+k,1);
            end
            marker = marker+1;
        end
 
    end
end



weight_matrix=zeros(block,1);
index=1;
for j=start:-1:-start
    for i=-start:start
        weight_matrix(index,1) = exp(-0.5*sqrt((i-0)^2+(j-0)^2));
        
        index=index+1;
    end
end




for i=1:len
    indicator = data(i,:) ~= 0;
    weighted_average(i,1) = (weight_matrix'* data(i,:)') / sum(weight_matrix'*indicator');
end

index=find(colloc_data(:,1) ~= 0 & colloc_data(:,3) ~= 0);
data=colloc_data(index,:);
diff = data(:,3)-weighted_average(:,1);
diff = diff'*diff;

mse = diff/len;


%Plot the points
x=1:block;
x_array = x;
for i=1:len
    x_array = x;
    point = data(i,:);
    index = point == 0;
    point(index) = [];
    x_array(index) = [];
    line(x_array,point,'Color','r');
    pause;
    clf;
    
end

%Taking the weighted average leaving out the middle one
weight_matrix(block_central,1) = 0;

for i=1:len
    indicator = data(i,:) ~= 0;
    weighted_average(i,1) = (weight_matrix'* data(i,:)') / sum(weight_matrix'*indicator');
end

index=find(colloc_data(:,1) ~= 0 & colloc_data(:,3) ~= 0);
data=colloc_data(index,:);
diff = data(:,3)-weighted_average(:,1);
diff = diff'*diff;

mse = diff/len;


%Taking the weighted average of only the left 

data=zeros(size(index,1),block_left);

for i=1:len
    pointer = index(i,1);
    marker = 1;
    for j=start:-1:-start
        for k=-start:0
            if(pointer-(j*row)+k <=1354700)
                data(i,marker) = colloc_data(pointer-(j*row)+k,1);
            end
            marker = marker+1;
        end
 
    end
end

weight_matrix=zeros(block_left,1);
index=1;
for j=start:-1:-start
    for i=-start:0
        weight_matrix(index,1) = exp(-0.5*sqrt((i-0)^2+(j-0)^2));
        index=index+1;
    end
end




for i=1:len
    indicator = data(i,:) ~= 0;
    weighted_average(i,1) = (weight_matrix'* data(i,:)') / sum(weight_matrix'*indicator');
end

index=find(colloc_data(:,1) ~= 0 & colloc_data(:,3) ~= 0);
data=colloc_data(index,:);
diff = data(:,3)-weighted_average(:,1);
diff = diff'*diff;

mse = diff/len;


%Taking the weighted average of only the right 

data=zeros(size(index,1),block_left);

for i=1:len
    pointer = index(i,1);
    marker = 1;
    for j=start:-1:-start
        for k=-start:0
            if(pointer-(j*row)+k <=1354700)
                data(i,marker) = colloc_data(pointer-(j*row)+k,1);
            end
            marker = marker+1;
        end
 
    end
end

weight_matrix=zeros(block_left,1);
index=1;
for j=start:-1:-start
    for i=0:start
        weight_matrix(index,1) = exp(-0.5*sqrt((i-0)^2+(j-0)^2));
        index=index+1;
    end
end



for i=1:len
    indicator = data(i,:) ~= 0;
    weighted_average(i,1) = (weight_matrix'* data(i,:)') / sum(weight_matrix'*indicator');
end

index=find(colloc_data(:,1) ~= 0 & colloc_data(:,3) ~= 0);
data=colloc_data(index,:);
diff = data(:,3)-weighted_average(:,1);
diff = diff'*diff;

mse = diff/len;










































locations = zeros(size(index,1),1);

for i=1:size(index,1)
   location = index(i,1);
   rem = floor(location/N);
   if rem == 0
       locations(i,1) = location;
   else
       locations(i,1) = location - floor(location/N)*N;
   end
end


misr_data=zeros(len,4);
index=find(colloc_data(:,1) ~= 0 & colloc_data(:,3) ~= 0);
data=colloc_data(index,:);

misr_data(:,1)=data(:,1);
misr_data(:,3)=data(:,3);
misr_data(:,2)= weighted_average;
misr_data(:,4)=locations;

aeronet = unique(misr_data(:,4));
count = size(aeronet,1);

marker = zeros(count,3);
for i=1:count
    location = aeronet(i,1);
    index=find(misr_data(:,4) == location);
    data=misr_data(index,:);
    len=size(data,1);
    if (i==4)
        pause
    end
    for j=1:len
        misr_original_error = abs(data(j,3)-data(j,1));
        smoothed_error =  abs(data(j,3)-data(j,2));
        if(misr_original_error > smoothed_error)
            marker(i,2)=marker(i,2)+1;
        else
            marker(i,3)=marker(i,3)+1;
        end
        
    end
    marker(i,1)=aeronet(i,1);
end

for i=1:132
    mse_misr=mse_misr+(data(i,3)-data(i,1))^2;
    mse_smoothed=mse_smoothed+(data(i,3)-data(i,2))^2;
    
    [mse_misr mse_smoothed]
    pause;
end


