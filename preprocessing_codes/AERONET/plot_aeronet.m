%This function is for the plotting the aeronet sites in the USA map

function plot_aeronet()
    aeronet_path='/Users/lakesh/Aerosol/aeronet_processed_dayofyear/';
    aeronet_list_file='/Users/lakesh/Aerosol/preprocessing_codes/AERONET/sorted.txt';
    dest_path = '/Users/lakesh/Aerosol/aeronet_processed_log_interpolation/';
    
    figure; ax = usamap('conus');
    states = shaperead('usastatelo', 'UseGeoCoords', true,...
      'Selector',...
      {@(name) ~any(strcmp(name,{'Alaska','Hawaii'})), 'Name'});
    faceColors = makesymbolspec('Polygon',...
        {'INDEX', [1 numel(states)], 'FaceColor', ... 
        polcmap(numel(states))}); %NOTE - colors are random
    geoshow(ax, states, 'DisplayType', 'polygon', ...
       'SymbolSpec', faceColors)
    framem off; gridm off; mlabel off; plabel off
    
    sites = textread(aeronet_list_file,'%s');
    sites_number = size(sites,1);
    
    
    fid=fopen('/Users/lakesh/Desktop/aeronet_sites.csv','w');
    fprintf(fid,'%s,%s,%s\n','latitude','longitude','name');
    for i=1:sites_number
        site = sites{i};
        load([aeronet_path site '.mat']);
        plotm(latitude,longitude,'o');
        fprintf(fid,'%s,%s,%s\n',latitude,longitude,site);

        [site]
        disp(latitude);
        disp(longitude);
        %pause 
    end
    fclose(fid);
