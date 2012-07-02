path='/Users/lakesh/Aerosol/misr_nan_2007/';

rows = 191;
columns = 311;

days = 365;

data = zeros(rows*columns*days,1);

for day=1:days
    load([path num2str(day) '.mat']);
    data = interpolatedData(:,:,7);
end