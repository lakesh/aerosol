dest_path = '/Users/lakesh/Aerosol/misr_nan_2004/';

for day=1:365
    try 
        load([num2str(day) '.mat']);
        aod = interpolatedData(:,:,7);
        quality_mask = interpolatedData(:,:,8);
        quality_mask_index = find(quality_mask == 4);
        aod(quality_mask_index) = 0;
        aod(isnan(aod)) = 0;
        interpolatedData(:,:,7) = aod;
        save([dest_path num2str(day) '.mat'],'interpolatedData');
    catch e
    end
end
