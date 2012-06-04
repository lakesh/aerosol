years=[2007];
path='/home/lakesh/Desktop/misr_2007/';

%This consists of the geographic information like latitude and longitude of the data points
coordinatePath='/home/lakesh/Desktop/preprocessing codes/MISR/coordinates/';

dateConverterPath = '/home/lakesh/Desktop/preprocessing codes/MISR/';


%USA geographical bounding box
leftBoundary=-124.848974;
rightBoundary=-66.885444;
bottomBoundary=24.396308;
topBoundary=49.384358;


%Random initialization for the size of the data points
misrData=zeros(1425060,15);
index=1;
cd(path);
days=dir('./');
curDir=pwd;
for counter=1:length(days)
    folderName = days(counter).name;
    
    if strcmp(folderName,'.') ~= 1 && strcmp(folderName,'..') ~= 1
        cd(folderName);
        MISRFileList = dir('*.mat');
        for counter1=1:length(MISRFileList)
            MISRFile = MISRFileList(counter1).name;
            load(MISRFile);
            P_Position = findstr('P', MISRFile);
            orbitNumber=MISRFile(P_Position:P_Position+3);
            disp(orbitNumber);
	    %%%%%%%%%%Every orbit has a corresponding geographic file consisting of the latitude and longitude information(Ancillary product)%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%% The satellite follows 233 distinct orbits and repeats itself after regular interval %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            load([coordinatePath 'MISR_AM1_AGP_' orbitNumber '.mat']);

	    %%%%%%%%%%%%% startBlock and endBlock define the valid blocks in the file. The file normally consists of 180 blocks out of which that defined
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%by startBlock and endBlock are valid %%%%%%%%%%%%%%%%%%%%%%%%

            startBlock = START_BLOCK(1,1);
            endBlock = END_BLOCK(1,1);
            for i=startBlock:endBlock
                timeBlock = PerBlockMetaDataTime{1};
                time = timeBlock(:,i);
                time = time';
                T_Position = findstr('T', time);
                hour = time(T_Position+1:T_Position+2);
                minute = time(T_Position+4:T_Position+5);
                if strcmp(hour,'00') ~= 1 || strcmp(minute,'00') ~= 1
                    for row=1:8
                        for column=1:32
                            dataPointLatitude = Latitude(i,row,column);
                            dataPointLongitude = Longitude(i,row,column); 

                            if dataPointLatitude >= bottomBoundary &&  dataPointLatitude <= topBoundary && dataPointLongitude <=rightBoundary && dataPointLongitude >= leftBoundary
                                %year 
                                misrData(index,1) = str2double(folderName(1:4));

                                %month
                                %misrData(index,2) = str2double(folderName(6:7));
                                %day
                                %misrData(index,3) = str2double(folderName(9:10));

                                curDir1 = pwd;
				%day of year
                                cd(dateConverterPath);
                                misrData(index,2) = floor(dayofyear(str2double(folderName(1:4)),str2double(folderName(6:7)),str2double(folderName(9:10)),str2double(hour),str2double(minute)));
                                cd(curDir1);


                                %hour
                                misrData(index,3) = str2double(hour);
                                %minute
                                misrData(index,4) = str2double(minute);


                                %latitude
                                misrData(index,5) = Latitude(i,row,column);
                                %longitude
                                misrData(index,6) = Longitude(i,row,column);
                                misrData(index,7) = RegBestEstimateSpectralOptDepth(i,row,column,1);
                                misrData(index,8) = RegBestEstimateSpectralOptDepth(i,row,column,2);
                                misrData(index,9) = RegBestEstimateSpectralOptDepth(i,row,column,3);
                                misrData(index,10) = RegBestEstimateSpectralOptDepth(i,row,column,4);
                                misrData(index,11) = GlitterAngle(i,row,column,5);
                                misrData(index,12) = ScatteringAngle(i,row,column,5);
                                misrData(index,13) = ViewZenithAngle(i,row,column,5);
                                misrData(index,14) = RealViewCameraAzimuthAngle(i,row,column,5);
                                misrData(index,15) = SolarZenithAngle(i,row,column);
                                index=index+1;
                            end
                        end
                    end
                end
            end
        end
        cd(curDir);
    end
end
