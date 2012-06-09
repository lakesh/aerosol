years=[2006];
path='/home/lakesh/Desktop/backup_may31_2012/misr_2006/';

%This consists of the geographic information like latitude and longitude of the data points
coordinatePath='/home/lakesh/Desktop/preprocessing codes/MISR/coordinates/';

dateConverterPath = '/home/lakesh/Desktop/preprocessing codes/MISR/';
dest_path = '/home/lakesh/Desktop/misr_extracted_2006/';

%USA geographical bounding box
leftBoundary=-126;
rightBoundary=-62;
bottomBoundary=25;
topBoundary=50;


%Random initialization for the size of the data points
misrData=zeros(1425060,15);
index=1;
cd(path);
days=dir('./');
curDir=pwd;

row=8;
column=32;
for counter=1:length(days)
    folderName = days(counter).name;
     
    if strcmp(folderName,'.') ~= 1 && strcmp(folderName,'..') ~= 1
        cd(folderName);
        
        curDir1 = pwd; 
        %day of year
        cd(dateConverterPath);  
        mark_dayofyear = floor(dayofyear(str2double(folderName(1:4)),str2double(folderName(6:7)),str2double(folderName(9:10))));
        cd(curDir1);
        
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
	        timeBlock = PerBlockMetaDataTime{1};
            marker=startBlock:endBlock;
            time = timeBlock(:,marker);
            time = time';
            T_Position = findstr('T', time(1,:));
            hour = time(:,T_Position+1:T_Position+2);
            minute = time(:,T_Position+4:T_Position+5);
            
            if(strcmp(hour(1,:),'0') == 0 && strcmp(minute(1,:),'0') == 0)
               hour(1,:) = [];
               minute(1,:) = [];
               marker(1) = [];
            end

            Latitude = Latitude(marker,:,:);
            Longitude = Longitude(marker,:,:);
            RegBestEstimateSpectralOptDepth = RegBestEstimateSpectralOptDepth(marker,:,:,:);
            GlitterAngle = GlitterAngle(marker,:,:,:);
            ScatteringAngle = ScatteringAngle(marker,:,:,:);
            ViewZenithAngle = ViewZenithAngle(marker,:,:,:);
            RealViewCameraAzimuthAngle = RealViewCameraAzimuthAngle(marker,:,:,:);
            SolarZenithAngle = SolarZenithAngle(marker,:,:);

            current_pointer = 1;

            for i=1:size(marker,2);
                index = find(Latitude(i,:,:) >= bottomBoundary &  Latitude(i,:,:) <= topBoundary & Longitude(i,:,:) <=rightBoundary & Longitude(i,:,:) >= leftBoundary);
            
                if ~isempty(index)
                    Latitude_i = Latitude(i,:,:);
                    Longitude_i = Longitude(i,:,:);
                    dataPointLatitude = Latitude_i(index);
                    dataPointLongitude = Longitude_i(index);

                    pointer = size(index,1);

                    misrData(current_pointer:(current_pointer+pointer-1),1) = str2double(folderName(1:4));

                    curDir1 = pwd; 
                    cd(dateConverterPath);
                    %day of year
                    misrData(current_pointer:(current_pointer+pointer-1),2) = mark_dayofyear;
                    %hour
                    misrData(current_pointer:(current_pointer+pointer-1),3) = str2double(hour(i,:));
                    %minute
                    misrData(current_pointer:(current_pointer+pointer-1),4) = str2double(minute(i,:));

                    cd(curDir1);

                    %latitude
                    misrData(current_pointer:(current_pointer+pointer-1),5) = dataPointLatitude;
                    %longitude
                    misrData(current_pointer:(current_pointer+pointer-1),6) = dataPointLongitude;
                    RegBestEstimateSpectralOptDepth_446 = RegBestEstimateSpectralOptDepth(i,:,:,1);
                    misrData(current_pointer:(current_pointer+pointer-1),7) = RegBestEstimateSpectralOptDepth_446(index);
                    RegBestEstimateSpectralOptDepth_558 = RegBestEstimateSpectralOptDepth(i,:,:,2);
                    misrData(current_pointer:(current_pointer+pointer-1),8) = RegBestEstimateSpectralOptDepth_558(index);
                    RegBestEstimateSpectralOptDepth_672 = RegBestEstimateSpectralOptDepth(i,:,:,3);
                    misrData(current_pointer:(current_pointer+pointer-1),9) = RegBestEstimateSpectralOptDepth(index);
                    RegBestEstimateSpectralOptDepth_886 = RegBestEstimateSpectralOptDepth(i,:,:,4);
                    misrData(current_pointer:(current_pointer+pointer-1),10) =  RegBestEstimateSpectralOptDepth_886(index);
                    GlitterAngle_5 = GlitterAngle(i,:,:,5);
                    misrData(current_pointer:(current_pointer+pointer-1),11) = GlitterAngle_5(index);
                    ScatteringAngle_5 = ScatteringAngle(i,:,:,5);
                    misrData(current_pointer:(current_pointer+pointer-1),12) =  ScatteringAngle_5(index);
                    ViewZenithAngle_5 = ViewZenithAngle(i,:,:,5);
                    misrData(current_pointer:(current_pointer+pointer-1),13) =  ViewZenithAngle_5(index);
                    RealViewCameraAzimuthAngle_5 = RealViewCameraAzimuthAngle(i,:,:,5);
                    misrData(current_pointer:(current_pointer+pointer-1),14) = RealViewCameraAzimuthAngle_5(index);
                    SolarZenithAngle_5 = SolarZenithAngle(i,:);
                    misrData(current_pointer:(current_pointer+pointer-1),15) = SolarZenithAngle_5(index);     
                    current_pointer = current_pointer + pointer;
                end
            end
            misrData = misrData(1:current_pointer-1,:);
            save([dest_path num2str(mark_dayofyear) '/' MISRFile],'misrData');            
        end
        cd(curDir);
    end
end
