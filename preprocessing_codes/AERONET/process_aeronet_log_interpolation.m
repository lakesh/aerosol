%This function is for the logarithmic interpolation of the AOD values of
%the aeronet sites

function process_aeronet_log_interpolation()
    aeronet_path='/Users/lakesh/Aerosol/aeronet_processed_dayofyear/';
    aeronet_list_file='/Users/lakesh/Aerosol/preprocessing_codes/AERONET/sorted.txt';
    dest_path = '/Users/lakesh/Aerosol/aeronet_processed_log_interpolation/';
    
    
    sites = textread(aeronet_list_file,'%s');
    sites_number = size(sites,1);
    
    for i=1:sites_number
        site = sites{i};
        curDir = pwd;
        load([aeronet_path site '.mat']);
        [row column]  = size(aeronetdata);
        aeronetdata_new = zeros(row,column+4);
        aeronetdata_new(:,1:column)=aeronetdata;
        
        index=1;
        for j=1:row
            %AOD at 558
            %Angstrom exponent using AOD at 675 and 440nm
            if (isreal(aeronetdata(j,9)) == 1 && isreal(aeronetdata(j,11)) == 1 && aeronetdata(j,9) > 0 && aeronetdata(j,11) > 0)
                alpha = -log(aeronetdata(j,9)/aeronetdata(j,11)) / log(675/440);
                AOD_Value = aeronetdata(j,9) * (675/558)^alpha;
                
                if(isreal(AOD_Value) == 0)   
                    disp(aeronetdata(j,9));
                    disp(aeronetdata(j,11));
                    disp(AOD_Value);
                end
                
                
                %latitude
                aeronetdata_new(index,column+1) = latitude;
                %longitude
                aeronetdata_new(index,column+2) = longitude;
            
                aeronetdata_new(index,column+3) = AOD_Value;
                %site_number(just for reference)
                aeronetdata_new(index,column+4) = i;
                index=index+1;
            end
        end
        aeronetdata = aeronetdata_new;
        
        save([dest_path site '.mat'],'aeronetdata', 'latitude','longitude','location');
        cd(curDir);
        
    end
    
