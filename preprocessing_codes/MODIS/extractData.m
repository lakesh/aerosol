%%%%%%%%%%%%%%%%%%% This file is for extracting the MODIS data for USA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%from Kosta's data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


path='/home/lakesh/Desktop/';
years=[2007];

%USA geographic  boundary
leftBoundary=-129;
rightBoundary=-66.885444;
bottomBoundary=24.396308;
topBoundary=49.384358;


dataPoints=zeros(1425060,87);
curdir=pwd;

width=203;
height=135;
index = 1;

for y=1:length(years)
    AODFileList = dir([path 'modis_' num2str(years(y)) '/*.mat']);

    for counter=1:length(AODFileList)
        AODFileName = AODFileList(counter).name;
        data = load([path 'modis_' num2str(years(y)) '/' AODFileName]);
        latitudeData=data.Latitude;
        longitudeData=data.Longitude;
        disp(AODFileName);
        name=regexp(AODFileName,'\.','split');
        for i=1:width
            for j=1:height
                try 
                    %If the point is inside our region include it
                    if latitudeData(i,j) > bottomBoundary && latitudeData(i,j) < topBoundary && longitudeData(i,j) < rightBoundary && longitudeData(i,j) > leftBoundary
                        dataPoints(index,1) = data.Latitude(i,j);
                        dataPoints(index,2) = data.Longitude(i,j);
			%year
                        dataPoints(index,3) = years(y);
			%day of year
                        dataPoints(index,4) = str2double(name{2}(5:7));
			%hour
			dataPoints(index,5) = str2double(name{3}(1:2));
			%minute
			dataPoints(index,6) = str2double(name{3}(3:4));

                        dataPoints(index,7) = data.AODSmall_213(i,j); %7 
                        dataPoints(index,8) = data.AODSmall_470(i,j); %8
                        dataPoints(index,9) = data.AODSmall_550(i,j); %9 
                        dataPoints(index,10) = data.AODSmall_660(i,j); %10
                        dataPoints(index,11)= data.AOD_213(i,j); %11
                        dataPoints(index,12)= data.AOD_470(i,j); %12
                        dataPoints(index,13)= data.AOD_550(i,j); %13
                        dataPoints(index,14)= data.AOD_660(i,j); %14
                        dataPoints(index,15)= data.AOD_DB_412(i,j); %15
                        dataPoints(index,16)= data.AOD_DB_470(i,j); %16
                        dataPoints(index,17)= data.AOD_DB_550(i,j); %17
                        dataPoints(index,18)= data.AOD_DB_660(i,j); %18
                        dataPoints(index,19)= data.AerosolType(i,j); %19
                        dataPoints(index,20)= data.Angstrom_C005(i,j); %20
                        dataPoints(index,21)= data.Angstrom_DB(i,j); %21
                        dataPoints(index,22)= data.CloudFraction(i,j); %22
                        dataPoints(index,23)= data.CloudMask_Quality(i,j); %23
                        dataPoints(index,24)= data.CloudMask_Summary(i,j); %24
                        dataPoints(index,25)= data.CriticalReflectance_470(i,j); %25
                        dataPoints(index,26)= data.CriticalReflectance_660(i , j); %26
                        dataPoints(index,27)= data.DB_Aerosol_Type(i,j); %27
                        dataPoints(index,28)= data.DB_QA_Conf(i,j); %28
                        dataPoints(index,29)= data.DB_QA_Usefulness(i,j); %29
                        dataPoints(index,30)= data.DB_Retrieving_Condition(i,j); %30
                        dataPoints(index,31)= data.Elevation(i,j); %31
                        dataPoints(index,32)= data.Error_CriticalReflectance_470(i,j); %32
                        dataPoints(index,33)= data.Error_CriticalReflectance_660(i,j); %33
                        dataPoints(index,34)= data.Error_PathRadiance_470(i,j); %34
                        dataPoints(index,35)= data.Error_PathRadiance_660(i,j); %35
                        dataPoints(index,36)= data.FittingError(i,j); %36
                        dataPoints(index,37)= data.Land_Type(i,j); %37
                        dataPoints(index,38)= data.MassConc(i,j); %38
                        dataPoints(index,39)= data.NumberPixelsUsedDB_412(i,j); %39
                        dataPoints(index,40)= data.NumberPixelsUsedDB_470(i,j); %40
                        dataPoints(index,41)= data.NumberPixelsUsedDB_660(i,j); %41
                        dataPoints(index,42)= data.OpticalDepthRatio(i,j); %42
                        dataPoints(index,43)= data.PathRadiance_470(i,j); %43
                        dataPoints(index,44)= data.PathRadiance_660(i,j); %44
                        dataPoints(index,45)= data.PixelsUsed_470(i,j); %45
                        dataPoints(index,46)= data.PixelsUsed_660(i,j); %46
                        dataPoints(index,47)= data.ProcPathPart_1(i,j); %47
                        dataPoints(index,48)= data.ProcPathPart_2(i,j); %48
                        dataPoints(index,49)= data.QA_Conf_470(i,j); %49
                        dataPoints(index,50)= data.QA_Conf_660(i,j); %50
                        dataPoints(index,51)= data.QualityWeight_CriticalReflectance_470(i,j); %51
                        dataPoints(index,52)= data.QualityWeight_CriticalReflectance_660(i,j); %52
                        dataPoints(index,53)= data.QualityWeight_PathRadiance_470(i,j); %53
                        dataPoints(index,54)= data.QualityWeight_PathRadiance_660(i,j); %54
                        dataPoints(index,55)= data.ReflectanceDB_412(i,j); %55
                        dataPoints(index,56)= data.ReflectanceDB_470(i,j); %56
                        dataPoints(index,57)= data.ReflectanceDB_660(i,j); %57
                        dataPoints(index,58)= data.Reflectance_After_Cloud_Screening_2100(i,j); %58
                        dataPoints(index,59)= data.Reflectance_After_Cloud_Screening_470(i,j); %59
                        dataPoints(index,60)= data.Reflectance_After_Cloud_Screening_660(i,j); %60
                        dataPoints(index,61)= data.SSA_DB_412(i,j); %61
                        dataPoints(index,62)= data.SSA_DB_470(i,j); %62
                        dataPoints(index,63)= data.SSA_DB_660(i,j); %63
                        dataPoints(index,64)= data.STD_AOD_DB_412(i,j); %64
                        dataPoints(index,65)= data.STD_AOD_DB_470(i,j); %65
                        dataPoints(index,66)= data.STD_AOD_DB_550(i,j); %66
                        dataPoints(index,67)= data.STD_AOD_DB_660(i,j); %67
                        dataPoints(index,68)= data.STD_Reflectance_After_Cloud_Screening_2100(i,j); %68
                        dataPoints(index,69)= data.STD_Reflectance_After_Cloud_Screening_470(i,j); %69
                        dataPoints(index,70)= data.STD_Reflectance_After_Cloud_Screening_660(i,j); %70
                        dataPoints(index,71)= data.ScatteringAngle(i,j); %71
                        dataPoints(index,72)= data.SensorAzimuth(i,j); %72
                        dataPoints(index,73)= data.SensorZenith(i,j); %73
                        dataPoints(index,74)= data.SnowCover(i,j); %74
                        dataPoints(index,75)= data.SnowIce(i,j); %75
                        dataPoints(index,76)= data.SolarAzimuth(i,j); %76
                        dataPoints(index,77)= data.SolarZenith(i,j); %77
                        dataPoints(index,78)= data.SurfaceReflectanceDB_412(i,j); %78
                        dataPoints(index,79)= data.SurfaceReflectanceDB_470(i,j); %79
                        dataPoints(index,80)= data.SurfaceReflectanceDB_660(i,j); %80
                        dataPoints(index,81)= data.SurfaceReflectance_2130(i,j); %81
                        dataPoints(index,82)= data.SurfaceReflectance_470(i,j); %82
                        dataPoints(index,83)= data.SurfaceReflectance_660(i,j); %83
                        dataPoints(index,84)= data.TotalOzone(i,j); %84
                        dataPoints(index,85)= data.TotalPrecWater(i,j); %85
                        dataPoints(index,86)= data.QA_Usefulness_470(i,j); %86
                        dataPoints(index,87)= data.QA_Usefulness_660(i,j); %87
 
                        index=index+1;
                    end
                catch err

                end
            end
        end
            
        clear data
    end
    

end

