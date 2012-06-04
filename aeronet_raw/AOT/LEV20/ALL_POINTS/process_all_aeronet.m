function process_all_aeronet()

% each station will be saved in separate .m file
% each .m file has the following info
%       1. longitude, latitude, elevation, Nmeas, PI, e-mail
%       2. large table, where the columns are the following:
%           year, month, day, hour, minute, second, then AODs: 1020nm, 870, 675, 500, 440, 380, 340 

files = dir('./');
tic;
for i = 1 : size(files, 1)
    % first take the filename and the sitename
    curr_file = files(i).name;
    
    if strcmp(curr_file,'.') ~= 1 && strcmp(curr_file,'..') ~= 1
        space = find(curr_file == ' ', 1);
        if (~isempty(space))
            curr_file = curr_file(1 : space - 1);
        else
            curr_file = curr_file(1 : end);
        end;    
        curr_site = curr_file(15 : end - 6);

        % get file info, so we know how much space to get
        fileInfo = dir(curr_file);
        fileSize = fileInfo.bytes / 1024;
        max_rows = round(fileSize / 0.3051); % one row approx takes 0.3051 kbytes
        max_rows = max_rows + 200; % allow 200 more (error margin)

        % now open the file and take all we need, then save in .m file
        fid = fopen(curr_file, 'rt');

        % discard first two rows
        tline = fgetl(fid);
        tline = fgetl(fid);

        % take site info
        tline = fgetl(fid);
        commas = strfind(tline, ',');
        location = curr_site;
        longitude = str2double(tline(commas(1) + 6 : commas(2) - 1));
        latitude = str2double(tline(commas(2) + 5 : commas(3) - 1));
        elevation = str2double(tline(commas(3) + 6 : commas(4) - 1));
        Nmeas = str2double(tline(commas(4) + 7 : commas(5) - 1));
        PI = tline(commas(5) + 4 : commas(6) - 1);
        E_mail = tline(commas(6) + 7 : end);

        % discard two more rows
        tline = fgetl(fid);
        tline = fgetl(fid);

        aeronet_data = zeros(max_rows, 13);
        counter = 0;
        while (1)
            % get a line and check if EOF
            tline = fgetl(fid);
            if (~ischar(tline))
                break;     
            else
                counter = counter + 1;
            end;

            commas = find(tline == ',', 19);

            % get time of measurement
            aeronet_data(counter, 1) = str2double(tline(7 : 10));
            aeronet_data(counter, 2) = str2double(tline(4 : 5));
            aeronet_data(counter, 3) = str2double(tline(1 : 2));    
            aeronet_data(counter, 4) = str2double(tline(12 : 13));
            aeronet_data(counter, 5) = str2double(tline(15 : 16));
            aeronet_data(counter, 6) = str2double(tline(18 : 19));

            % get aerosol data
            aeronet_data(counter, 7)  = str2double(tline(commas(4) + 1 : commas(5) - 1));
            aeronet_data(counter, 8)  = str2double(tline(commas(5) + 1 : commas(6) - 1));
            aeronet_data(counter, 9)  = str2double(tline(commas(6) + 1 : commas(7) - 1));
            aeronet_data(counter, 10) = str2double(tline(commas(12) + 1 : commas(13) - 1));
            aeronet_data(counter, 11) = str2double(tline(commas(15) + 1 : commas(16) - 1));
            aeronet_data(counter, 12) = str2double(tline(commas(17) + 1 : commas(18) - 1));
            aeronet_data(counter, 13) = str2double(tline(commas(18) + 1 : commas(19) - 1));
        end;

        % take only valid data
        aeronet_data = aeronet_data(1 : counter, :);

        % save in .m file and move on
        fclose(fid);
        save(strcat('AERONET_data/', location, '.mat'), 'aeronet_data', 'location', 'longitude', 'latitude', 'elevation', 'Nmeas', 'PI', 'E_mail')

        curr_site
        toc
        i
        tic
    end
end;
toc;
