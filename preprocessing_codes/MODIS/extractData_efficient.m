%%%%%%%%%%%%%%%%%%% This file is for extracting the MODIS data for USA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%from Kosta's data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

path='/home/lakesh/Desktop/';
years=[2006];
dest_path='/home/lakesh/Desktop/modis_extracted_2006/';

%USA geographic boundary
leftBoundary=-129;
rightBoundary=-62;
bottomBoundary=24;
topBoundary=50;

%Random initialization for the number of data points

curdir=pwd;

width=203;
height=135;

for y=1:length(years)
    AODFileList = dir([path 'modis_' num2str(years(y)) '/*.mat']);

    for counter=1:length(AODFileList)
        AODFileName = AODFileList(counter).name;
        data = load([path 'modis_' num2str(years(y)) '/' AODFileName]);
        latitudeData=data.Latitude;
        longitudeData=data.Longitude;
        disp(AODFileName);
        name=regexp(AODFileName,'\.','split');

        index = find(latitudeData > bottomBoundary & latitudeData < topBoundary & longitudeData < rightBoundary & longitudeData > leftBoundary);
        numberOfPoints = size(index,1);
        if ~isempty(index)
            try 
                dataPoints=zeros(numberOfPoints,87);
                dataPoints(:,1) = data.Latitude(index);
                dataPoints(:,2) = data.Longitude(index);
                %year
                dataPoints(:,3) = years(y);
                %day of year
                dataPoints(:,4) = str2double(name{2}(5:7));
                %hour
                dataPoints(:,5) = str2double(name{3}(1:2));
                %minute
                dataPoints(:,6) = str2double(name{3}(3:4));

                dataPoints(:,7) = data.AODSmall_213(index); %7 
                dataPoints(:,8) = data.AODSmall_470(index); %8
                dataPoints(:,9) = data.AODSmall_550(index); %9 
                dataPoints(:,10) = data.AODSmall_660(index); %10
                dataPoints(:,11)= data.AOD_213(index); %11
                dataPoints(:,12)= data.AOD_470(index); %12
                dataPoints(:,13)= data.AOD_550(index); %13
                dataPoints(:,14)= data.AOD_660(index); %14
                dataPoints(:,15)= data.AOD_DB_412(index); %15
                dataPoints(:,16)= data.AOD_DB_470(index); %16
                dataPoints(:,17)= data.AOD_DB_550(index); %17
                dataPoints(:,18)= data.AOD_DB_660(index); %18
                dataPoints(:,19)= data.AerosolType(index); %19
                dataPoints(:,20)= data.Angstrom_C005(index); %20
                dataPoints(:,21)= data.Angstrom_DB(index); %21
                dataPoints(:,22)= data.CloudFraction(index); %22
                dataPoints(:,23)= data.CloudMask_Quality(index); %23
                dataPoints(:,24)= data.CloudMask_Summary(index); %24
                dataPoints(:,25)= data.CriticalReflectance_470(index); %25
                dataPoints(:,26)= data.CriticalReflectance_660(index); %26
                dataPoints(:,27)= data.DB_Aerosol_Type(index); %27
                dataPoints(:,28)= data.DB_QA_Conf(index); %28
                dataPoints(:,29)= data.DB_QA_Usefulness(index); %29
                dataPoints(:,30)= data.DB_Retrieving_Condition(index); %30
                dataPoints(:,31)= data.Elevation(index); %31
                dataPoints(:,32)= data.Error_CriticalReflectance_470(index); %32
                dataPoints(:,33)= data.Error_CriticalReflectance_660(index); %33
                dataPoints(:,34)= data.Error_PathRadiance_470(index); %34
                dataPoints(:,35)= data.Error_PathRadiance_660(index); %35
                dataPoints(:,36)= data.FittingError(index); %36
                dataPoints(:,37)= data.Land_Type(index); %37
                dataPoints(:,38)= data.MassConc(index); %38
                dataPoints(:,39)= data.NumberPixelsUsedDB_412(index); %39
                dataPoints(:,40)= data.NumberPixelsUsedDB_470(index); %40
                dataPoints(:,41)= data.NumberPixelsUsedDB_660(index); %41
                dataPoints(:,42)= data.OpticalDepthRatio(index); %42
                dataPoints(:,43)= data.PathRadiance_470(index); %43
                dataPoints(:,44)= data.PathRadiance_660(index); %44
                dataPoints(:,45)= data.PixelsUsed_470(index); %45
                dataPoints(:,46)= data.PixelsUsed_660(index); %46
                dataPoints(:,47)= data.ProcPathPart_1(index); %47
                dataPoints(:,48)= data.ProcPathPart_2(index); %48
                dataPoints(:,49)= data.QA_Conf_470(index); %49
                dataPoints(:,50)= data.QA_Conf_660(index); %50
                dataPoints(:,51)= data.QualityWeight_CriticalReflectance_470(index); %51
                dataPoints(:,52)= data.QualityWeight_CriticalReflectance_660(index); %52
                dataPoints(:,53)= data.QualityWeight_PathRadiance_470(index); %53
                dataPoints(:,54)= data.QualityWeight_PathRadiance_660(index); %54
                dataPoints(:,55)= data.ReflectanceDB_412(index); %55
                dataPoints(:,56)= data.ReflectanceDB_470(index); %56
                dataPoints(:,57)= data.ReflectanceDB_660(index); %57
                dataPoints(:,58)= data.Reflectance_After_Cloud_Screening_2100(index); %58
                dataPoints(:,59)= data.Reflectance_After_Cloud_Screening_470(index); %59
                dataPoints(:,60)= data.Reflectance_After_Cloud_Screening_660(index); %60
                dataPoints(:,61)= data.SSA_DB_412(index); %61
                dataPoints(:,62)= data.SSA_DB_470(index); %62
                dataPoints(:,63)= data.SSA_DB_660(index); %63
                dataPoints(:,64)= data.STD_AOD_DB_412(index); %64
                dataPoints(:,65)= data.STD_AOD_DB_470(index); %65
                dataPoints(:,66)= data.STD_AOD_DB_550(index); %66
                dataPoints(:,67)= data.STD_AOD_DB_660(index); %67
                dataPoints(:,68)= data.STD_Reflectance_After_Cloud_Screening_2100(index); %68
                dataPoints(:,69)= data.STD_Reflectance_After_Cloud_Screening_470(index); %69
                dataPoints(:,70)= data.STD_Reflectance_After_Cloud_Screening_660(index); %70
                dataPoints(:,71)= data.ScatteringAngle(index); %71
                dataPoints(:,72)= data.SensorAzimuth(index); %72
                dataPoints(:,73)= data.SensorZenith(index); %73
                dataPoints(:,74)= data.SnowCover(index); %74
                dataPoints(:,75)= data.SnowIce(index); %75
                dataPoints(:,76)= data.SolarAzimuth(index); %76
                dataPoints(:,77)= data.SolarZenith(index); %77
                dataPoints(:,78)= data.SurfaceReflectanceDB_412(index); %78
                dataPoints(:,79)= data.SurfaceReflectanceDB_470(index); %79
                dataPoints(:,80)= data.SurfaceReflectanceDB_660(index); %80
                dataPoints(:,81)= data.SurfaceReflectance_2130(index); %81
                dataPoints(:,82)= data.SurfaceReflectance_470(index); %82
                dataPoints(:,83)= data.SurfaceReflectance_660(index); %83
                dataPoints(:,84)= data.TotalOzone(index); %84
                dataPoints(:,85)= data.TotalPrecWater(index); %85
                dataPoints(:,86)= data.QA_Usefulness_470(index); %86
                dataPoints(:,87)= data.QA_Usefulness_660(index); %87
                save([dest_path AODFileName], 'dataPoints');
            catch err
                disp(AODFileName);
                disp(err);
            end
        end    
        clear data
    end
    

end

