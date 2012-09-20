function [inputData]= loaddata_v2()

    %For year 2004%
    interpolatedMISRPath = '/home/lakesh/Desktop/misr_nan_2007/';
    interpolatedMODISPath = '/home/lakesh/Desktop/modis_nan_2005/';

    row = 95;
    column = 155;
    N = row*column;
    
    inputData = zeros(N,10);
    year = 2005;
    index =1;
    
    %Load the MISR data
    for day=1:365
        try 
            load([interpolatedMISRPath num2str(day) '.mat']);
            %year
            inputData(index:index+N-1,1) = interpolatedData(:,3);
            %dayofyear
            inputData(index:index+N-1,2) = interpolatedData(:,4);
            %latitude
            inputData(index:index+N-1,3) = interpolatedData(:,1);
            %longitude
            inputData(index:index+N-1,4) = interpolatedData(:,2);
            %AOD value
            inputData(index:index+N-1,5) = interpolatedData(:,7);
            %hour
            inputData(index:index+N-1,6) = interpolatedData(:,5);
            %minute
            inputData(index:index+N-1,7) = interpolatedData(:,6);
            index = index + N;
            
        catch err
            %In case we don't have MISR data for a particular day use 0
            index = index + N;
        end

    end

    index = 1;

    %Load the MODIS data
    for day=1:365
        try 
            load([interpolatedMODISPath num2str(day) '.mat']);
            aods = interpolatedData(:,7);
            %Read the quality flag
            %qas = interpolatedData(:,8);
            %marker = find(qas == 4);
            %Set the low quality aod data to 0
            %aods(marker,:) = 0;
            %AOD Value
            inputData(index:index+N-1,8) = aods;
            %hour
            inputData(index:index+N-1,9) = interpolatedData(:,5);
            %minute
            inputData(index:index+N-1,10) = interpolatedData(:,6);
            index = index + N;
        catch err
            %In case we don't have MODIS data for a particular day use 0
            index = index + N;
        end

    end
   
    
    clear N column data day err filePrefix i index interpolatedMISRPath interpolatedMODISPath j row;