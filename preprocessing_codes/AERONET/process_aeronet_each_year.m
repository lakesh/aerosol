function process_aeronet_each_year()

    year = 2003;
    
    %Number of attributes of aeronet data
    columns = 18;
    
    aeronet_path='/Users/lakesh/Aerosol/aeronet_processed_log_interpolation/';
    aeronet_list_file='/Users/lakesh/Aerosol/preprocessing_codes/AERONET/sorted.txt';
    dest_path = ['/Users/lakesh/Aerosol/aeronet_each_year/' num2str(year) '/'];
   
    sites = textread(aeronet_list_file,'%s');
    sites_number = size(sites,1);
    
    
    for day=1:365
        %Random number of rows initialized for the aeronet data daily.
        %It will surely be lot more than this :)
        aeronetdata_daily = zeros(1000,columns);
        mark = 1;
        for i=1:sites_number
            site = sites{i};
            load([aeronet_path site '.mat']);
            %Find the matching year and day of year
            index = find(aeronetdata(:,1)==year & aeronetdata(:,14)==day);
            matches = size(index);
            aeronetdata_daily(mark:(mark-1)+matches,:) = aeronetdata(index,:);
            mark = mark+matches;
        end
        aeronetdata = aeronetdata_daily;
        aeronetdata = aeronetdata(1:mark-1,:);
        save([dest_path num2str(day) '.mat'],'aeronetdata');
    end
   
    