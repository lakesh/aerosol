path = '/Users/lakesh/Aerosol/';
load([path 'collocated_misr_aeronet_2007.mat']);
load([path 'collocated_modis_aeronet_2007.mat']);


rows = size(collocated_misr,1);
collocated_misr_modis_aeronet = zeros(rows,3);


%AERONET missing in both(just add the misr and modis values; [label is
%missing]
index = find(collocated_misr(:,2) == 0 & collocated_modis(:,2) == 0);
collocated_misr_modis_aeronet(index,1) = collocated_misr(index,1);
collocated_misr_modis_aeronet(index,2) = collocated_modis(index,1);










%MISR and its label missing; just add the MODIS and its label for such
%situation
index = find(collocated_misr(:,1) == 0 & collocated_misr(:,2) == 0);
collocated_misr_modis_aeronet(index,2) = collocated_modis(index,1);
collocated_misr_modis_aeronet(index,3) = collocated_modis(index,2);









%MODIS and its label missing; just add the MISR and its label for such
%situation
index = find(collocated_modis(:,1) == 0 & collocated_modis(:,2) == 0);
collocated_misr_modis_aeronet(index,1) = collocated_misr(index,1);
collocated_misr_modis_aeronet(index,3) = collocated_misr(index,2);







%For the case where both the labels for MISR and MODIS are available
index = find(collocated_misr(:,2) ~= 0 & collocated_modis(:,2) ~= 0);

misr_aeronet_hour = collocated_misr(index,3);
misr_aeronet_minute = collocated_misr(index,4);
misr_aeronet_total_minute = misr_aeronet_hour * 60 + misr_aeronet_minute;
modis_aeronet_hour = collocated_modis(index,3);
modis_aeronet_minute = collocated_modis(index,4);
modis_aeronet_total_minute = modis_aeronet_hour * 60 + modis_aeronet_minute;

num_entries = size(index,1);

for i=1:num_entries
    %MISR,MODIS and AERONET are collocated
    if( abs(modis_aeronet_total_minute(i,1) - misr_aeronet_total_minute(i,1)) <= 30 )
        collocated_misr_modis_aeronet(index(i,1),1) = collocated_misr(index(i,1),1);
        collocated_misr_modis_aeronet(index(i,1),2) = collocated_modis(index(i,1),1);
        collocated_misr_modis_aeronet(index(i,1),3) = (collocated_misr(index(i,1),2) + collocated_modis(index(i,1),2)) / 2;
    else
        %MISR,MODIS and AERONET are not collocated
        
        %MISR is missing(just use the MODIS data)
        if(collocated_misr(index(i,1),1) == 0) 
            collocated_misr_modis_aeronet(index(i,1),2) = collocated_modis(index(i,1),1);
            collocated_misr_modis_aeronet(index(i,1),3) = collocated_modis(index(i,1),2);
        %MODIS is missing(just use the MISR data)
        elseif(collocated_modis(index(i,1),1) == 0) 
            collocated_misr_modis_aeronet(index(i,1),1) = collocated_misr(index(i,1),1);
            collocated_misr_modis_aeronet(index(i,1),3) = collocated_misr(index(i,1),2);    
        else
            %Ignore the labels just add the MISR and MODIS values
            collocated_misr_modis_aeronet(index(i,1),1) = collocated_misr(index(i,1),1);
            collocated_misr_modis_aeronet(index(i,1),2) = collocated_modis(index(i,1),1);    
        end
    end
end

clear misr_aeronet_hour misr_aeronet_minute modis_aeronet_hour modis_aeronet_minute misr_aeronet_total_minute modis_aeronet_total_minute





%MISR missing but label available
index = find(collocated_misr(:,1) == 0 & collocated_misr(:,2) ~= 0);
misr_aeronet = collocated_misr(index,:);
modis_aeronet = collocated_modis(index,:);

%Find data with missing aeronet and MODIS
index_modis = find(modis_aeronet(:,2) == 0 & modis_aeronet(:,1) == 0);
%Just add the label of collocated misr and aeronet
collocated_misr_modis_aeronet(index(index_modis,1),3) = collocated_misr(index(index_modis,1),2);

%Find data with missing aeronet but MODIS available
index_modis = find(modis_aeronet(:,2) == 0 & modis_aeronet(:,1) ~= 0);

misr_aeronet_hour = misr_aeronet(index_modis,3);
misr_aeronet_minute = misr_aeronet(index_modis,4);
misr_aeronet_total_minute = misr_aeronet_hour * 60 + misr_aeronet_minute;

modis_hour = modis_aeronet(index_modis,3);
modis_minute = modis_aeronet(index_modis,4);
modis_total_minute = modis_hour * 60 + modis_minute;

entries = size(index_modis,1);
for i=1:entries
    
    if(abs(modis_total_minute(i,1) - misr_aeronet_total_minute(i,1)) <=30)
        %if collocated at the label of MISR and modis AOD
       collocated_misr_modis_aeronet(index(index_modis(i,1),1),2) = modis_aeronet(index_modis(i,1),1);
       collocated_misr_modis_aeronet(index(index_modis(i,1),1),3) = misr_aeronet(index_modis(i,1),2);
    else
        %if not collocated just add the modis AOD
        collocated_misr_modis_aeronet(index(index_modis(i,1),1),2) = modis_aeronet(index_modis(i,1),1);
    end
end










%MODIS missing but label available
index = find(collocated_modis(:,1) == 0 & collocated_modis(:,2) ~= 0);
misr_aeronet = collocated_misr(index,:);
modis_aeronet = collocated_modis(index,:);

%Find data with missing aeronet and MISR
index_misr = find(misr_aeronet(:,2) == 0 & misr_aeronet(:,1) == 0);
%Just add the label of collocated modis and aeronet
collocated_misr_modis_aeronet(index(index_misr,1),3) = modis_aeronet(index_misr,2);

%Find data with missing aeronet but MISR available
index_misr = find(misr_aeronet(:,2) == 0 & misr_aeronet(:,1) ~= 0);

misr_hour = misr_aeronet(index_misr,3);
misr_minute = misr_aeronet(index_misr,4);
misr_total_minute = misr_hour * 60 + misr_minute;

modis_aeronet_hour = modis_aeronet(index_misr,3);
modis_aeronet_minute = modis_aeronet(index_misr,4);
modis_aeronet_total_minute = modis_aeronet_hour * 60 + modis_aeronet_minute;

entries = size(index_misr,1);
for i=1:entries
    
    if(abs(modis_aeronet_total_minute(i,1) - misr_total_minute(i,1)) <=30)
        %if collocated at the label of MODIS and MISR AOD
       collocated_misr_modis_aeronet(index(index_misr(i,1),1),1) = misr_aeronet(index_misr(i,1),1);
       collocated_misr_modis_aeronet(index(index_misr(i,1),1),3) = modis_aeronet(index_misr(i,1),2);
    else
        %if not collocated just add the MISR AOD
        collocated_misr_modis_aeronet(index(index_misr(i,1),1),1) = misr_aeronet(index_misr(i,1),1);
    end
end









%MISR available but label not available
index = find(collocated_misr(:,1) ~= 0 & collocated_misr(:,2) == 0);

misr_aeronet = collocated_misr(index,:);
modis_aeronet = collocated_modis(index,:);

%Find modis data with label available but MODIS missing
index_modis = find(modis_aeronet(:,1) == 0 & modis_aeronet(:,2) ~= 0);

misr_hour = misr_aeronet(index_modis,3);
misr_minute = misr_aeronet(index_modis,4);
misr_total_minute = misr_hour * 60 + misr_minute;

modis_aeronet_hour = modis_aeronet(index_modis,3);
modis_aeronet_minute = modis_aeronet(index_modis,4);
modis_aeronet_total_minute = modis_aeronet_hour * 60 + modis_aeronet_minute;

entries = size(index_modis,1);
for i=1:entries
    
    if(abs(modis_aeronet_total_minute(i,1) - misr_total_minute(i,1)) <=30)
        %if collocated at the label of MODIS and misr AOD
       collocated_misr_modis_aeronet(index(index_modis(i,1),1),1) = misr_aeronet(index_modis(i,1),1);
       collocated_misr_modis_aeronet(index(index_modis(i,1),1),3) = modis_aeronet(index_modis(i,1),2);
    else
        %if not collocated just add the MISR AOD
        collocated_misr_modis_aeronet(index(index_modis(i,1),1),1) = misr_aeronet(index_modis(i,1),1);
    end
end


%Find modis data with label available and MODIS as well
index_modis = find(modis_aeronet(:,1) ~= 0 & modis_aeronet(:,2) ~= 0);

misr_hour = misr_aeronet(index_modis,3);
misr_minute = misr_aeronet(index_modis,4);
misr_total_minute = misr_hour * 60 + misr_minute;

modis_aeronet_hour = modis_aeronet(index_modis,3);
modis_aeronet_minute = modis_aeronet(index_modis,4);
modis_aeronet_total_minute = modis_aeronet_hour * 60 + modis_aeronet_minute;

entries = size(index_modis,1);
for i=1:entries
    
    if(abs(modis_aeronet_total_minute(i,1) - misr_total_minute(i,1)) <=30)
        %if collocated at the label of MODIS and misr AOD, add all
       collocated_misr_modis_aeronet(index(index_modis(i,1),1),1) = misr_aeronet(index_modis(i,1),1);
       collocated_misr_modis_aeronet(index(index_modis(i,1),1),2) = modis_aeronet(index_modis(i,1),1);
       collocated_misr_modis_aeronet(index(index_modis(i,1),1),3) = modis_aeronet(index_modis(i,1),2);
    else
        %if not collocated just add the MODIS AOD and its label(ignore
        %MISR)
        collocated_misr_modis_aeronet(index(index_modis(i,1),1),2) = modis_aeronet(index_modis(i,1),1);
        collocated_misr_modis_aeronet(index(index_modis(i,1),1),3) = modis_aeronet(index_modis(i,1),2);
    end
end









%MODIS available but label not available
index = find(collocated_modis(:,1) ~= 0 & collocated_modis(:,2) == 0);

misr_aeronet = collocated_misr(index,:);
modis_aeronet = collocated_modis(index,:);

%Find misr data with label available but misr missing
index_misr = find(misr_aeronet(:,1) == 0 & misr_aeronet(:,2) ~= 0);

misr_aeronet_hour = misr_aeronet(index_misr,3);
misr_aeronet_minute = misr_aeronet(index_misr,4);
misr_aeronet_total_minute = misr_aeronet_hour * 60 + misr_aeronet_minute;

modis_hour = modis_aeronet(index_misr,3);
modis_minute = modis_aeronet(index_misr,4);
modis_total_minute = modis_hour * 60 + modis_minute;

entries = size(index_misr,1);

for i=1:entries    
    if(abs(modis_total_minute(i,1) - misr_aeronet_total_minute(i,1)) <=30)
        %if collocated at the label of MISR and modis AOD
       collocated_misr_modis_aeronet(index(index_misr(i,1),1),1) = modis_aeronet(index_misr(i,1),1);
       collocated_misr_modis_aeronet(index(index_misr(i,1),1),3) = misr_aeronet(index_misr(i,1),2);
    else
        %if not collocated just add the MODIS AOD
        collocated_misr_modis_aeronet(index(index_misr(i,1),1),2) = modis_aeronet(index_misr(i,1),1);
    end
end


%Find misr data with label available and MISR as well
index_misr = find(misr_aeronet(:,1) ~= 0 & misr_aeronet(:,2) ~= 0);

misr_aeronet_hour = misr_aeronet(index_misr,3);
misr_aeronet_minute = misr_aeronet(index_misr,4);
misr_aeronet_total_minute = misr_aeronet_hour * 60 + misr_aeronet_minute;

modis_hour = modis_aeronet(index_misr,3);
modis_minute = modis_aeronet(index_misr,4);
modis_total_minute = modis_hour * 60 + modis_minute;

entries = size(index_misr,1);
for i=1:entries
    
    if(abs(modis_total_minute(i,1) - misr_aeronet_total_minute(i,1)) <=30)
        %if collocated at the label of MISR and modis AOD, add all
       collocated_misr_modis_aeronet(index(index_misr(i,1),1),1) = misr_aeronet(index_misr(i,1),1);
       collocated_misr_modis_aeronet(index(index_misr(i,1),1),2) = modis_aeronet(index_misr(i,1),1);
       collocated_misr_modis_aeronet(index(index_misr(i,1),1),3) = misr_aeronet(index_misr(i,1),2);
    else
        %if not collocated just add the MISR AOD and its label(ignore
        %MODIS)
        collocated_misr_modis_aeronet(index(index_misr(i,1),1),1) = misr_aeronet(index_misr(i,1),1);
        collocated_misr_modis_aeronet(index(index_misr(i,1),1),3) = misr_aeronet(index_misr(i,1),2);
    end
end









