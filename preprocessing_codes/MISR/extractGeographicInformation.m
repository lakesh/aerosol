path='/home/lakesh/Desktop/Geographic/1999.11.08';
currentPath=pwd;

cd(path);
ancillaryFileList=dir('./*.hdf');

for counter=1:length(ancillaryFileList)
%for counter=1:1

    fileName = ancillaryFileList(counter).name;
    rawLatitude = hdfread(fileName, '/Standard/Data Fields/GeoLatitude');
    rawLongitude = hdfread(fileName, '/Standard/Data Fields/GeoLongitude');
    processedLatitudeLocation = zeros(180,8,32);
    processedLongitudeLocation = zeros(180,8,32);
    for i=1:180
        for j=0:16:112
            for k=0:16:496
                latitude = 0;
                longitude = 0;
                for l=1:16
                    for m=1:16
                        latitude = latitude + rawLatitude(i,j+l,k+m);
                        longitude = longitude + rawLongitude(i,j+l,k+m);
                    end
                end
                latitude = latitude/16;
                longitude = longitude/16;
                processedLatitudeLocation(i,int64((j+l)/16),int64((k+m)/16)) = latitude;
                processedLongitudeLocation(i,int64((j+l)/16),int64((k+m)/16)) = longitude;
            end
        end
    end
    Latitude=processedLatitudeLocation;
    Longitude=processedLongitudeLocation;
    P_Position = findstr('P', fileName);
    P_Position = P_Position + 2;
    orbitNumber = fileName(P_Position:P_Position+3);
    outputFileName = ['MISR_AM1_AGP_' orbitNumber '.mat'];
    save(outputFileName,'Latitude','Longitude');

end