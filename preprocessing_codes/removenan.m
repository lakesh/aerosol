dest_path = '/Users/lakesh/Aerosol/misr_nan_2004/';

for day=1:365
    try 
        load([num2str(day) '.mat']);
        aod = interpolatedData(:,:,7);
        aod(isnan(aod)) = 0;
        interpolatedData(:,:,7) = aod;
        save([dest_path num2str(day) '.mat'],'interpolatedData');
    catch e
    end
end
